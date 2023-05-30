package hxdb;

import haxe.Exception;

import hxdb.Logging.GeneralLogger;

private class HXDBException extends Exception {
    public function new(message: String) {
        GeneralLogger.error('Uncaught exception: $message');
        super(message);
    }
}

final class ConnectionModeException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class AlreadyConnectedException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class MissingConnectionException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class UnexistingFileException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class ReadingFileException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class WritingFileException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class UnsafeConnectionUpdateException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}
