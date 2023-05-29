package hxdb;

import haxe.Exception; // TODO: Replace me with specific exception.

import sys.FileSystem;
import sys.io.File;

import hxdb.Errors.UnexistingFileException;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.LogLevel;

private final class LogFmt {
    private static function readContent(path: String): String {
        // Thinks file is 100% existing.
        try {
            var buffer = File.read(path, false);
            return buffer.readAll()
                .toString();
        } catch (exception) {
            Logger.info('CRITICAL: Failed to read file "$path". Excetion: ${exception.toString()}');
            throw new Exception("");
        }
    }

    private static function saveWrite(path: String, content: String): Void {
        // TODO: Later here must be added unsafe steps.
        if (!FileSystem.exists(path)) {
            throw new UnexistingFileException('File "$path" does not exists. Later safe solution will appear.');
        }

        // Actually this is oversafety.
        try {
            var alreadyWritten = readContent(path);
            File.saveContent(path, alreadyWritten + "\n" + content);
        } catch (exception) {
            Logger.info('CRITICAL: Failed to write file "$path". Excetion: ${exception.toString()}');
            // throw new Exception("");
        }
    }

    public static function formatLogLine(type: String, message: String): String {
        return '${Date.now()} $type $message';
    }
  
    public static function printLogLine(type: String, message: String): Void {
        Sys.println(formatLogLine(type, message));
    }

    public static function writeToFiles(type: String, message: String): Void {
        for (fileName in WrapperSettings.logFiles) {
            saveWrite(fileName, formatLogLine(type, message));
        }
    }
}

// Colors must be added later.
final class Logger {
    public static function info(message: String): Void {
        if (WrapperSettings.logLevel == LogLevel.All) {
            LogFmt.printLogLine("I", message);
        }
    }

    public static function warn(message: String): Void {
        var warnActiveLevels = [LogLevel.NotInfo, LogLevel.All];

        if (warnActiveLevels.contains(WrapperSettings.logLevel)) {
            LogFmt.printLogLine("W", message);
        }
    }

    public static function error(message: String): Void {
        if (WrapperSettings.logLevel != LogLevel.Nothing) {
            LogFmt.printLogLine("E", message);
        }
    }
}

final class FileLogger {
    public static function info(message: String): Void {
        if (WrapperSettings.logLevel == LogLevel.All) {
            LogFmt.writeToFiles("I", message);
        }
    }

    public static function warn(message: String): Void {
        var warnActiveLevels = [LogLevel.NotInfo, LogLevel.All];

        if (warnActiveLevels.contains(WrapperSettings.logLevel)) {
            LogFmt.writeToFiles("W", message);
        }
    }

    public static function error(message: String): Void {
        if (WrapperSettings.logLevel != LogLevel.Nothing) {
            LogFmt.writeToFiles("E", message);
        }
    }
}
