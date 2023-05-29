package hxdb.driver;

import haxe.ds.GenericStack;

import hxdb.Errors.AlreadyConnectedException;
import hxdb.Errors.MissingConnectionException;
import hxdb.Types.ConnectionMode;

final class Connection {
    public final fileName: String;
    public final mode: ConnectionMode;
    
    public function new(fileName: String, ?mode: ConnectionMode) {
        mode ??= ConnectionMode.Readable;

        this.fileName = fileName;
        this.mode = mode;
    }

    public function toString(): String {
        return 'File "$fileName", mode: "$mode".';
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
    }

    public static function del(connection: Connection): Void {
        store.remove(connection);
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
            
            }
        }
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
