package hxdb;

import haxe.ds.GenericStack;

import hxdb.driver.QueryEntry.Executor;
import hxdb.Errors.AlreadyConnectedException;
import hxdb.Errors.HXDBException;
import hxdb.Errors.MissingConnectionException;
import hxdb.Errors.UsingTerminatedConnection;
import hxdb.Errors.UnsafeConnectionUpdateException;
import hxdb.Logging.ConsoleLogger;
import hxdb.Logging.GeneralLogger;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.ConnectionMode;
import hxdb.Types.SafetyLevel;
import hxdb.Types.ExecutionResult;

final class Connection {
    private var isTerminated: Bool = false;

    public final fileName: String;
    public final mode: ConnectionMode;
    
    public function new(fileName: String, ?mode: ConnectionMode) {
        mode ??= ConnectionMode.Readable;

        this.fileName = fileName;
        this.mode = mode;

        ConnectionsStore.add(this);
    }

    public function query(query: String): Void {
        if (isTerminated) {
            throw new UsingTerminatedConnection('Using terminated connection ($this).');
        }

        var result = Executor.execute(query);
        
        switch (result) {
            case ExecutionResult.Undefined(some):
                GeneralLogger.warn('Result of execution is $result. Recieved object: $some.');
            case ExecutionResult.Error(message):
                throw new HXDBException(message);
            case ExecutionResult.Success:
                GeneralLogger.info('Successfully executed query: "$query".');
        }
    }

    public function terminate(): Void {
        ConnectionsStore.del(this);
        this.isTerminated = true;

        GeneralLogger.info('Connection $this terminated.');
    }

    public function toString(): String {
        return '("$fileName": $mode)';
    }

    @:op(A == B)
    public function eq(other: Connection): Bool {
        return fileName == other.fileName && mode == other.mode;
    }
}

final class ConnectionsStore {
    private static var bufferedConnection: Connection;
    private static final store: GenericStack<Connection> = new GenericStack();

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

    public static function get(fileName: String): Connection {
        if (exists(fileName, true)) {
            return bufferedConnection;
        }

        throw new MissingConnectionException('Connection with file "$fileName" not found.');
    }

    public static function update(connection: Connection): Void {
        if (exists(connection.fileName, true)) {
            if (bufferedConnection == connection) {
                return ConsoleLogger.info('Connection similar to $connection already exists. Passing.');
            }

            if (bufferedConnection.mode == ConnectionMode.Writable) {
                var message = "It's unsafe to override connection with \"Writable\" mode.";

                switch (WrapperSettings.safetyLevel) {
                    case SafetyLevel.Strict:
                        throw new UnsafeConnectionUpdateException(message);
                    case SafetyLevel.Soft:
                    case SafetyLevel.Zero:
                        ConsoleLogger.warn(message);
                }
            }

            store.add(connection);
            GeneralLogger.info('Successfully updated connection: $connection.');
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
