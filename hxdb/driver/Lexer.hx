package hxdb.driver;

import hxdb.driver.Tokens.Token;
import hxdb.driver.Tokens.TokenType;

final class Char {
    private final reference: String;

    public function new(reference: String) {
        this.reference = reference;
    }

    public function toString(): String {
        return '';
    }

    public function isEof(): Bool {
        return reference == "\\0";
    }
}

private class LexerHelpTools {
    private final code: String;
    private var position: Int = 0;

    public final tokens: Array<Token> = [];

    public function new(code: String) {
        this.code = code;
    }

    public function peek(forwardOn: Int = 0): Char {
        var letter = code.charAt(position + forwardOn);

        return letter == null
            ? new Char("\\0")
            : new Char(letter);
    }
}

final class Lexer extends LexerHelpTools {
    public function new(code: String) {
        super(code);
    }

    public function lex(): Array<Token> {
        while (position <= code.length) {
            var currentChar = peek();

            if (currentChar.isEof()) {
                Sys.println('Eof');
            }
        }

        return tokens;
    }
}
