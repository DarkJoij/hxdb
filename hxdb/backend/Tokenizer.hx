package hxdb.backend;

import hxdb.backend.Tokens.Token;
import hxdb.backend.Tokens.TokenType;
import hxdb.backend.Stream.Char;
import hxdb.backend.Stream.SpecificCharCodes;
import hxdb.frontend.Errors.UnknownLexingException;

private final class SpecificTokens {
    public static function defineSystemKeywordType(keyword: String): TokenType {
        return switch (keyword) {
            case "IS":
                TokenType.Is;
            case "TO":
                TokenType.To;
            case "WHERE":
                TokenType.Where;
            case "CREATE":
                TokenType.Create;
            case "INSERT":
                TokenType.Insert;
            case "SELECT":
                TokenType.Select;
            case "UPDATE":
                TokenType.Update;
            case "SELECTALL":
                TokenType.SelectAll;
            default:
                TokenType.Broken(keyword);
        }
    }
}

private class LexerHelpTools {
    public final tokens: Array<Token> = [];
    public final chars: Array<Char>;
    public var position: Int = 0;

    public function new(chars: Array<Char>) {
        this.chars = chars;
    }

    public function next(): Char {
        position++;
        return peek();
    }

    public function peek(forwardOn: Int = 0): Char {
        var char = chars[position + forwardOn];
        return char != null ? char : 0;
    }

    public function addToken(type: TokenType, text: String = null): Void {
        tokens.push(new Token(type, text));
    }
}

final class Lexer extends LexerHelpTools {
    private function lexSystemKeyword(): Void {
        var buffer = new StringBuf();
        var currentChar = peek();

        while (true) {
            if (!currentChar.isSystemKeyword()) {
                break;
            }

            buffer.addChar(currentChar); // Implict cast needed.
            currentChar = next();
        }

        var keyword = buffer.toString();
        addToken(SpecificTokens.defineSystemKeywordType(keyword));
    }

    private function lexIdentifier(): Void {
        var buffer = new StringBuf();
        var currentChar = peek();
    }

    private function lexNumber(): Void {

    }

    private function lexString(): Void {

    }

    public function new(code: String) {
        super(SpecificCharCodes.toChars(code));
    }

    public function lex(): Array<Token> {
        Sys.println(chars);

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
            } else {
                break;
                // throw new UnknownLexingException('Unknown symbol found: $currentChar.');
            }
        }

        return tokens;
    }
}
