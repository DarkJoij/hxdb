package hxdb;

import hxdb.Types.SafetyLevel;
import sys.FileSystem;
import sys.io.File;

import hxdb.Errors.UnexistingFileException;
import hxdb.Errors.ReadingFileException;
import hxdb.Errors.WritingFileException;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.LogLevel;

final class LogFmt {
    private static function safeRead(path: String): String {
        try {
            var buffer = File.read(path, false);
            return buffer.readAll()
                .toString();
        } catch (exception) {
            Logger.error('Failed to read file "$path". ${exception.toString()}');
            throw new ReadingFileException('Failed to read file "$path". ${exception.toString()}');
        }
    }

    private static function safeWrite(path: String, content: String): Void {
        // TODO: Later here must be added unsafe steps.
        if (!FileSystem.exists(path)) {
            switch (WrapperSettings.safetyLevel) {
                case SafetyLevel.Strict:
                    throw new UnexistingFileException('File "$path" does not exists.');
                case SafetyLevel.Soft:
                    Logger.warn('File "$path" not found. Creating new, with similar name...');
                    safeCreateIfNotExists(path);
                case SafetyLevel.Zero:
                    Logger.warn('File "$path" not found in zero-safety level, nothing will done.');
            }
        }
        
        try {
            var alreadyWritten = safeRead(path);
            var writingContent = alreadyWritten.length != 0
                ? alreadyWritten + "\n" + content
                : content;

            File.saveContent(path, writingContent);
        } catch (exception) {
            Logger.error('Failed to write file "$path". ${exception.toString()}');
            throw new WritingFileException('Failed to read file "$path". ${exception.toString()}');
        }
    }

    public static function safeCreateIfNotExists(fileName: String): Void {
        if (!FileSystem.exists(fileName)) {
            var buffer = File.write(fileName, false);
            buffer.close(); // Said in Std.

            Logger.info('Created new file "$fileName", which content root is "${Sys.getCwd()}".');
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
            safeWrite(fileName, formatLogLine(type, message));
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
