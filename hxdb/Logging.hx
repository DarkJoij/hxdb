package hxdb;

import sys.FileSystem;
import sys.io.File;

import hxdb.Errors.UnexistingFileException;
import hxdb.Errors.ReadingFileException;
import hxdb.Errors.WritingFileException;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.LogLevel;
import hxdb.Types.SafetyLevel;

private final warnActiveLevels = [LogLevel.NotInfo, LogLevel.All];

final class LogFmt {
    private static function safeRead(path: String): String {
        try {
            var buffer = File.read(path, false);
            return buffer.readAll()
                .toString();
        } catch (exception) {
            throw new ReadingFileException('Failed to read file "$path". ${exception.toString()}');
        }
    }

    private static function safeWrite(path: String, content: String): Void {
        if (!FileSystem.exists(path)) {
            switch (WrapperSettings.safetyLevel) {
                case SafetyLevel.Strict:
                    throw new UnexistingFileException('File "$path" does not exists.');
                case SafetyLevel.Soft:
                    ConsoleLogger.warn('File "$path" not found. Creating new, with similar name...');
                    safeCreateIfNotExists(path);
                case SafetyLevel.Zero:
                    return ConsoleLogger.warn('File "$path" not found in zero-safety level, nothing will done.');
            }
        }
        
        try {
            var alreadyWritten = safeRead(path);
            var writingContent = alreadyWritten.length != 0
                ? alreadyWritten + "\n" + content
                : content;

            File.saveContent(path, writingContent);
        } catch (exception) {
            throw new WritingFileException('Failed to read file "$path". ${exception.toString()}');
        }
    }

    public static function safeCreateIfNotExists(fileName: String): Void {
        if (!FileSystem.exists(fileName)) {
            var buffer = File.write(fileName, false);
            buffer.close();

            ConsoleLogger.info('Created new file "$fileName", which content root is "${Sys.getCwd()}".');
        }
    }

    public static function formatLogLine(type: String, message: String): String {
        return '${Date.now()} $type $message';
    }

    public static function writeToFiles(type: String, message: String): Void {
        for (fileName in WrapperSettings.logFiles) {
            safeWrite(fileName, formatLogLine(type, message));
        }
    }
}

final class ConsoleLogger {
    public static function info(message: String): Void {
        if (WrapperSettings.logLevel == LogLevel.All) {
            Sys.println(LogFmt.formatLogLine("I", message));
        }
    }

    public static function warn(message: String): Void {
        if (warnActiveLevels.contains(WrapperSettings.logLevel)) {
            Sys.println(LogFmt.formatLogLine("W", message));
        }
    }

    public static function error(message: String): Void {
        if (WrapperSettings.logLevel != LogLevel.Nothing) {
            Sys.println(LogFmt.formatLogLine("E", message));
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

final class GeneralLogger {
    public static function info(message: String): Void {
        ConsoleLogger.info(message);
        FileLogger.info(message);
    }

    public static function warn(message: String): Void {
        ConsoleLogger.warn(message);
        FileLogger.warn(message);
    }

    public static function error(message: String): Void {
        ConsoleLogger.error(message);
        FileLogger.error(message);
    }
}
