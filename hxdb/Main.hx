package hxdb;

import hxdb.Logging.Logger;
import hxdb.Logging.FileLogger;
import hxdb.Settings.WrapperSettings;

function prepare(): Void {
    WrapperSettings.loadDefault();

    Logger.info("Logging stuff loaded. Loading database system...");
}

final class Main {
    public static function main(): Void {
        prepare();
        
        Logger.info("All's good!");
        FileLogger.info("Testing file logging system.");
    }
}