package hxdb.driver;

import haxe.ds.GenericStack;

import hxdb.Errors.AlreadyConnectedException;
import hxdb.Errors.MissingConnectionException;
import hxdb.Errors.UnsafeConnectionUpdateException;
import hxdb.Logging.ConsoleLogger;
import hxdb.Logging.GeneralLogger;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.ConnectionMode;
import hxdb.Types.SafetyLevel;

final class Connection {
    public final fileName: String;
    public final mode: ConnectionMode;
    
    public function new(fileName: String, ?mode: ConnectionMode) {
        mode ??= ConnectionMode.Readable;

        this.fileName = fileName;
        this.mode = mode;

        Connections.add(this);
    }

    public function query(): Void {

    }

    public function terminate(): Void {

    }

    public function toString(): String {
        return '("$fileName": $mode)';
    }

    @:op(A == B)
    public function eq(other: Connection): Bool {
        return fileName == other.fileName && mode == other.mode;
    }
}

final class Connections {
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

            switch (WrapperSettings.safetyLevel) {
                case SafetyLevel.Strict:
                    if (bufferedConnection.mode == ConnectionMode.Writable) {
                        throw new UnsafeConnectionUpdateException(
                            "It's unsafe to override connection with \"Writable\" mode."
                        );
                    }
                case SafetyLevel.Soft:
                case SafetyLevel.Zero:
                    if (bufferedConnection.mode == ConnectionMode.Writable) {
                        ConsoleLogger.warn("It's unsafe to override connection with \"Writable\" mode.");
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

    @:deprecated
    public static function toString(): String {
        return '$store | $bufferedConnection';
    }
}
