package hxdb;

import haxe.ds.GenericStack;

import hxdb.driver.QueryEntry.Executor;
import hxdb.Errors.AlreadyConnectedException;
import hxdb.Errors.HXDBException;
import hxdb.Errors.MissingConnectionException;
import hxdb.Errors.UsingTerminatedConnection;
import hxdb.Errors.UnsafeUpdatingException;
import hxdb.Logging.ConsoleLogger;
import hxdb.Logging.GeneralLogger;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.ConnectionMode;
import hxdb.Types.SafetyLevel;
import hxdb.Types.ExecutionResult;

private class Mask {
    public final fileName: String;
    public final mode: ConnectionMode;

    public function new(fileName: String, mode: ConnectionMode) {
        this.fileName = fileName;
        this.mode = mode;
    }

    public function toString(): String {
        return 'C($fileName: $mode)';
    }

    @:op(A == B)
    public function eq(other: Mask): Bool {
        return fileName == other.fileName && mode == other.mode;
    }
}

final class Connection extends Mask {
    private var isTerminated: Bool = false;
    
    public function new(fileName: String, ?mode: ConnectionMode) {
        mode ??= ConnectionMode.Readable;

        super(fileName, mode);

        ConnectionsStore.exists(fileName) 
            ? ConnectionsStore.update(this)
            : ConnectionsStore.add(this);
    }

    public function query(query: String): Void {
        if (isTerminated) {
            throw new UsingTerminatedConnection('Using terminated connection ($this).');
        }
        
        switch (Executor.execute(query)) {
            case ExecutionResult.Success:
                GeneralLogger.info('Successfully executed query: "$query".');
            case ExecutionResult.Undefined(some):
                GeneralLogger.warn('Result of execution is Undefined. Recieved object: $some.');
            case ExecutionResult.Error(message):
                throw new HXDBException(message);
        }
    }

    public function terminate(): Void {
        ConnectionsStore.del(this);
        isTerminated = true;

        GeneralLogger.info('Connection $this terminated.');
    }
}

final class ConnectionsStore {
    private static var bufferedConnection: Mask;
    private static final store: GenericStack<Mask> = new GenericStack();

    public static function add(connection: Connection): Void {
        if (exists(connection.fileName)) {
            throw new AlreadyConnectedException(
                'Connection with file "${connection.fileName}" already exists. Use "update" method instead.'
            );
        }

        store.add(connection);
        GeneralLogger.info('Successfully created connection: $connection.');
    }

    public static function del(connection: Connection): Void {
        store.remove(connection);
        GeneralLogger.info('Successfully deleted connection: $connection.');
    }

    public static function get(fileName: String): Mask {
        if (exists(fileName, true)) {
            return bufferedConnection;
        }

        throw new MissingConnectionException('Connection with file "$fileName" not found.');
    }

    public static function update(connection: Mask): Void {
        if (exists(connection.fileName, true)) {
            if (bufferedConnection == connection) {
                return ConsoleLogger.warn('Connection similar to $connection already exists. Passing.');
            }
            
            if (bufferedConnection.mode == ConnectionMode.Writable) {
                var message = "It's unsafe to override connection with \"Writable\" mode.";

                switch (WrapperSettings.safetyLevel) {
                    case SafetyLevel.Strict:
                        throw new UnsafeUpdatingException(message);
                    case SafetyLevel.Soft:
                    case SafetyLevel.Zero:
                        ConsoleLogger.warn(message);
                }
            }

            store.remove(bufferedConnection);
            store.add(connection);

            return GeneralLogger.info('Successfully updated connection: $connection.');
        }

        throw new MissingConnectionException('Connection with file "${connection.fileName}" not found.');
    }

    public static function exists(fileName: String, writeToBuffer: Bool = false): Bool {
        for (connection in store) {
            if (connection.fileName == fileName) {
                if (writeToBuffer) {
                    bufferedConnection = connection;
                }

                return true;
            }
        }

        return false;
    }
}
