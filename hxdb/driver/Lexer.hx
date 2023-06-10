package hxdb.driver;

import hxdb.driver.Tokens.Token;
import hxdb.driver.Tokens.TokenType;
import hxdb.driver.Stream.Char;
import hxdb.driver.Stream.SpecificCharCodes;

private class LexerHelpTools {
    public final tokens: Array<Token> = [];
    public final chars: Array<Char>;
    public var position: Int = 0;

    public function new(chars: Array<Char>) {
        this.chars = chars;
    }

    public function peek(forwardOn: Int = 0): Char {
        var char = chars[position + forwardOn];
        return char != null ? char : 0;
    }

    public function addToken(text: String, type: TokenType): Void {
        var token = new Token(text, type);
        var length = text.length;

        if (type == TokenType.Str) {
            length += 2;
        }

        position++; // Must be checked!
    }
}

final class Lexer extends LexerHelpTools {
    private function lexSystemKeyword(): Void {

    }

    private function lexIdentifier(): Void {

    }

    private function lexNumber(): Void {

    }

    private function lexString(): Void {

    }

    public function new(code: String) {
        super(SpecificCharCodes.toChars(code));
    }

    public function lex(): Array<Token> {
        while (position <= chars.length) {
            var currentChar = peek();

            if (currentChar.isSystemKeyword()) {
                lexSystemKeyword();
            } else if (currentChar.isIdentifier()) {
                lexIdentifier();
            } else if (currentChar.isNumeric()) {
                lexNumber();
            } else if (currentChar.isQuote()) {
                lexString();
            } else if (currentChar.isWhite()) {
                position++;
            }
        }

        return tokens;
    }
}
