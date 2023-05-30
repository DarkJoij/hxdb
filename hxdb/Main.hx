package hxdb;

import hxdb.driver.Connections.Connections;
import hxdb.driver.Connections.Connection;
import hxdb.Logging.ConsoleLogger;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.ConnectionMode;

function prepare(): Void {
    WrapperSettings.loadDefault();
    
    ConsoleLogger.info("Logging stuff loaded. Loading database system...");
}

final class Main {
    public static function main(): Void {
        prepare();

        new Connection("mydb.hxdb");
        new Connection("anotherdb.hxdb", ConnectionMode.Writable);

        Sys.println(Connections);
    }
}
