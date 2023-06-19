package hxdb.backend;

private function tokenContainerToString(container: TokenContainer): String {
    return switch (container) {
        case TokenContainer.OnlyType(type):
            'OnlyType($type)';
        case TokenContainer.WithText(type, text):
            'WithText($type, "$text")';
    }
}

enum TokenType {
    // Types:
    Str;
    Num;
    // Helpers-keywords:
    Is;
    To;
    Where;
    // General calls:
    Create;
    Insert;
    Select;
    Update;
    SelectAll;
    // Values:
    Numeric;
    Identifier;
    // Core important:
    Eof;
    TypeDeclarator;
    Broken(object: Any);
}

enum TokenContainer {
    OnlyType(type: TokenType);
    WithText(type: TokenType, text: String);
}

final class Token {
    public final container: TokenContainer;

    public function new(type: TokenType, text: String = null) {
        if (text == null) {
            this.container = TokenContainer.OnlyType(type);
        }

        this.container = TokenContainer.WithText(type, text);
    }

    public function toString(): String {
        return tokenContainerToString(container);
    }
}
