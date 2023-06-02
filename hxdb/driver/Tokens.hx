package hxdb.driver;

enum TokenType {
    // Types:
    Str;
    Num;
    // General calls:
    Create;
    Insert;
    Select;
    Update;
    SelectAll;
    // Helpers-keywords:
    Is;
    To;
    Where;
    // Values:
    Numeric;
    Identifier;
    // Core important:
    Eof;
    Empty;
    TypeDeclarator;
}

final class Token {
    public final text: String;
    public final type: TokenType;

    public function new(text: String, type: TokenType) {
        this.text = text;
        this.type = type;
    }

    public function toString(): String {
        return 'T("$text": $type)';
    }
}
