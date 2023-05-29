package hxdb;

import haxe.iterators.ArrayIterator;
import haxe.Rest;
import sys.FileSystem;
import sys.io.File;

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
    public static function defaultAndCustom(fileNames: Rest<String>): LogFiles {
        return new LogFiles(...fileNames.append(defaultLogFileName));
    }

    public final fileNames: Array<String>;

    public function new(fileNames: Rest<String>) {
        this.fileNames = fileNames.length == 0 ? [defaultLogFileName] : fileNames;

        for (fileName in this.fileNames) { // Fucking "this" keyword. It's just a son of a slut!
            // TODO: Later here must be added unsafe steps.
            if (!FileSystem.exists(fileName)) {
                File.write(fileName, false);
            }
        }
    }

    public function toString(): String {
        // Cause type of LogFiles must be defined strictly.
        if (this.fileNames.contains(defaultLogFileName)) {
            if (this.fileNames.length == 1) {
                return 'Default: ${this.fileNames[0]}.';
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
