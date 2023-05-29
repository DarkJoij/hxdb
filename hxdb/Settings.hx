package hxdb;

import hxdb.Types.LogLevel;
import hxdb.Types.LogFiles;
import hxdb.Types.SafetyLevel;

final class WrapperSettings {
    public static var logLevel(default, null): LogLevel;
    public static var logFiles(default, null): LogFiles;
    public static var safetyLevel(default, null): SafetyLevel;

    public static function setLogLevel(newLogLevel: LogLevel): LogLevel {
        return logLevel = newLogLevel;
    }

    public static function setLogFiles(newLogFiles: LogFiles): LogFiles {
        return logFiles = newLogFiles;
    }

    public static function setSafetyLevel(newSafetyLevel: SafetyLevel): SafetyLevel {
        return safetyLevel = newSafetyLevel;
    }

    public static function loadDefault(): Void {
        setLogLevel(LogLevel.All);
        setLogFiles(new LogFiles());
        setSafetyLevel(SafetyLevel.Strict);
    }

    @:deprecated
    public static function toString(): String {
        return 'logLevel: $logLevel\nlogFiles: $logFiles\nsafetyLevel: $safetyLevel';
    }
}
