package hxdb;

import hxdb.driver.Stream.Char;
import hxdb.Logging.ConsoleLogger;
import hxdb.Settings.WrapperSettings;
import hxdb.Types.LogLevel;

function prepare(): Void {
    WrapperSettings.loadDefault();
    WrapperSettings.setLogLevel(LogLevel.Nothing); // TODO: REMOVE ME LATER!

    ConsoleLogger.info("Logging stuff loaded. Loading database system...");
}

final class Main {
    public static function main(): Void {
        prepare(); 
        
        var tabC = new Char(9);
        var rEscC = new Char(13);
        var spaceC = new Char(32);

        var tab = "	";
        var rEsc = "\r";
        var space = " ";

        Sys.println(tabC == tab.charCodeAt(0));
        Sys.println(rEscC == rEsc.charCodeAt(0));
        Sys.println(spaceC == space.charCodeAt(0));
    }
}
