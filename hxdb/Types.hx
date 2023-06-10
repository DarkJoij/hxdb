package hxdb;

import haxe.iterators.ArrayIterator;
import haxe.Rest;
import sys.io.File;

import hxdb.Logging.LogFmt;

private final defaultLogFileName = "hxdb.log";

enum ConnectionMode {
    Readable;
    Writable;
}

enum LogLevel {
    All;
    NotInfo;
    OnlyErrors;
    Nothing;
}

enum SafetyLevel {
    Strict;
    Soft;
    Zero;
}

enum ExecutionResult {
    Success;
    Undefined(object: Any);
    Error(message: String);
}

abstract LogFiles(Array<String>) {
    public static function def(): Array<String> {
        return [defaultLogFileName];
    }

    public static function defaultAndCustom(fileNames: Rest<String>): Array<String> {
        return fileNames.append(defaultLogFileName);
    }

    @:from
    public static function fromArray(array: Array<String>): LogFiles {
        return new LogFiles(array);
    }

    public inline function new(fileNames: Array<String>) {
        this = fileNames.length == 0 ? [defaultLogFileName] : fileNames;

        for (fileName in this) {
            LogFmt.safeCreateIfNotExists(fileName);
            File.saveContent(fileName, ""); // TODO: Must be checked.
        }
    }

    public function toString(): String {
        var sequence = this.join(", ");

        if (this.contains(defaultLogFileName)) {
            if (this.length == 1) {
                return 'Default: $defaultLogFileName.';
            }

            return 'DefaultAndCustom: $sequence.';
        }

        return 'Custom: $sequence.';
    }

    public inline function iterator(): ArrayIterator<String> {
        return this.iterator();
    }
}
