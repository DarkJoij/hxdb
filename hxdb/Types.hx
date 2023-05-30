package hxdb;

import haxe.iterators.ArrayIterator;
import haxe.Rest;

using hxdb.Logging.LogFmt;

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

final class LogFiles {
    // Maybe here some other static-news needed?
    public static function defaultAndCustom(fileNames: Rest<String>): LogFiles {
        return new LogFiles(...fileNames.append(defaultLogFileName));
    }

    public final fileNames: Array<String>;

    public function new(fileNames: Rest<String>) {
        this.fileNames = fileNames.length == 0 ? [defaultLogFileName] : fileNames;

        for (fileName in this.fileNames) {
            // TODO: Later here must be added unsafe steps.
            LogFmt.safeCreateIfNotExists(fileName);
        }
    }

    public function toString(): String {
        // Cause type of LogFiles must be defined strictly.
        if (this.fileNames.contains(defaultLogFileName)) {
            if (this.fileNames.length == 1) {
                return 'Default: $defaultLogFileName.';
            }

            return 'DefaultAndCustom: ${this.fileNames.join(", ")}.';
        }

        return 'Custom: ${this.fileNames.join(", ")}.';
    }

    public inline function iterator(): ArrayIterator<String> {
        return fileNames.iterator();
    }
}

// Not implemented fully.
enum SafetyLevel {
    Strict;
    Soft;
    Zero;
}
