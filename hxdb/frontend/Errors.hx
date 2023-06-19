package hxdb.frontend;

import haxe.Exception;

import hxdb.frontend.Logging.GeneralLogger;

class HXDBException extends Exception {
    public function new(message: String) {
        var msg = 'CRITICAL: $message';

        GeneralLogger.error(msg);
        super(msg);
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

final class UnsafeUpdatingException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class UsingTerminatedConnectionException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class CharTypeException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}

final class UnknownLexingException extends HXDBException {
    public function new(message: String) {
        super(message);
    }
}
