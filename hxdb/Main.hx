package hxdb;

import hxdb.Connections.Connection;
import hxdb.Logging.ConsoleLogger;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.ConnectionMode;

function prepare(): Void {
    WrapperSettings.loadDefault(); // Using default settings - the best way.

    ConsoleLogger.info("Logging stuff loaded. Loading database system...");
}

final class Main {
    public static function main(): Void {
        prepare(); 

        new Connection("mydb.hxdb");
        new Connection("mydb.hxdb", ConnectionMode.Writable);
    }
}
