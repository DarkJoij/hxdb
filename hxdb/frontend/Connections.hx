package hxdb.frontend;

import haxe.ds.GenericStack;

import hxdb.backend.QueryEntry.Executor;
import hxdb.frontend.Errors.AlreadyConnectedException;
import hxdb.frontend.Errors.HXDBException;
import hxdb.frontend.Errors.MissingConnectionException;
import hxdb.frontend.Errors.UnsafeUpdatingException;
import hxdb.frontend.Errors.UsingTerminatedConnectionException;
import hxdb.frontend.Logging.ConsoleLogger;
import hxdb.frontend.Logging.GeneralLogger;
import hxdb.frontend.Settings.WrapperSettings;
import hxdb.frontend.Types.ConnectionMode;
import hxdb.frontend.Types.SafetyLevel;
import hxdb.frontend.Types.ExecutionResult;

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
        super(fileName, mode ?? ConnectionMode.Readable);

        if (ConnectionsStore.exists(fileName)) {
            return ConnectionsStore.update(this);
        }

        ConnectionsStore.add(this);
    }

    public function query(query: String): Void {
        if (isTerminated) {
            switch (WrapperSettings.safetyLevel) {
                case SafetyLevel.Strict:
                    throw new UsingTerminatedConnectionException('Using terminated connection $this.');
                case SafetyLevel.Soft | SafetyLevel.Zero:
                    GeneralLogger.warn('Using terminated connection $this was rejected.');
            }
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
                'Connection with file "${connection.fileName}" already exists.'
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
                    case SafetyLevel.Soft | SafetyLevel.Zero:
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
