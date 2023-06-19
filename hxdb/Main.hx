package hxdb;

import hxdb.backend.Tokenizer.Lexer;
import hxdb.frontend.Logging.ConsoleLogger;
import hxdb.frontend.Settings.WrapperSettings;
import hxdb.frontend.Types.LogLevel;

function prepare(): Void {
    WrapperSettings.loadDefault();
    WrapperSettings.setLogLevel(LogLevel.Nothing); // TODO: REMOVE ME LATER!

    ConsoleLogger.info("Logging stuff loaded. Loading database system...");
}

final class Main {
    public static function main(): Void {
        prepare(); 
        
        var lexer = new Lexer("SELECT");
        var tokens = lexer.lex();

        Sys.println(tokens);
    }
}
