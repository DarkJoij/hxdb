package hxdb.driver;

import hxdb.Errors.CharTypeException;

abstract Char(Int) {
    @:from
    public static function fromInt(number: Int): Char {
        if (number < 0 && number > 127) {
            throw new CharTypeException('Value for data type "Char" must be in range from 0 to 127.');
        }

        return new Char(number);
    }

    @:to
    public function toString(): String {
        return String.fromCharCode(this);
    }

    public inline function new(code: Int) {
        this = code;
    }

    public function isSystemKeyword(): Bool {
        return this > 65 && this < 90;
    }

    public function isIdentifier(): Bool {
        return this > 97 && this < 122 
            || SpecificCharCodes.identifierExt.contains(this);
    }

    public function isNumeric(): Bool {
        return this > 48 && this < 57;
    }

    public function isQuote(): Bool {
        return this == 34;
    }

    public function isWhite(): Bool {
        return SpecificCharCodes.whiteCodes.contains(this);
    }

    public function isEof(): Bool {
        return this == 0;
    }

    public function equal(letter: String): Bool {
        return letter == toString();
    }
}

final class SpecificCharCodes {
    public static final whiteCodes: Array<Char> = [9, 13, 32];
    public static final identifierExt: Array<Char> = [45, 95];

    public static function toChars(code: String): Array<Char> {
        var chars: Array<Char> = [];
    
        for (charCode in StringTools.iterator(code)) {
            chars.push(charCode);
        }
    
        return chars;
    }

    @:deprecated
    public static function getType(char: Char): CharType {
        return CharType.Eof;
    }
}

enum CharType {
    SystemKeyword;
    Identifier;
    Numeric;
    Quote;
    White;
    Eof;
}
