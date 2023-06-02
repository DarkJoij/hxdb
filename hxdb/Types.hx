package hxdb;

import haxe.iterators.ArrayIterator;
import haxe.Rest;
import sys.io.File;

import hxdb.Logging.LogFmt;

final defaultLogFileName = "hxdb.log";

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

final class LogFiles {
    public static function defaultAndCustom(fileNames: Rest<String>): LogFiles {
        return new LogFiles(...fileNames.append(defaultLogFileName));
    }

    public final fileNames: Array<String>;

    public inline function new(fileNames: Rest<String>) {
        this.fileNames = fileNames.length == 0 ? [defaultLogFileName] : fileNames;

        for (fileName in this.fileNames) {
            LogFmt.safeCreateIfNotExists(fileName);
            File.saveContent(fileName, ""); // TODO: Must be checked.
        }
    }

    public function toString(): String {
        if (fileNames.contains(defaultLogFileName)) {
            if (fileNames.length == 1) {
                return 'Default: $defaultLogFileName.';
            }

            return 'DefaultAndCustom: ${fileNames.join(", ")}.';
        }

        return 'Custom: ${fileNames.join(", ")}.';
    }

    public inline function iterator(): ArrayIterator<String> {
        return fileNames.iterator();
    }
}
