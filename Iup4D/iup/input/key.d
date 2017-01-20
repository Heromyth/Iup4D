module iup.input.key;

import std.string;

import iup.c.api;
import iup.core;

public class Keys
{
 	enum Space          = ' ';   /* 32 (0x20) */
	enum Exclam      = '!';   /* 33 */
	enum Quotedbl    = '\"';  /* 34 */
	enum NumberSign  = '#';   /* 35 */
	enum Dollar      = '$';   /* 36 */
	enum Percent     = '%';   /* 37 */
	enum Ampersand   = '&';   /* 38 */
	enum Apostrophe  = '\'';  /* 39 */
	enum LParent     = '(';   /* 40 */
	enum RParent     = ')';   /* 41 */
	enum Asterisk    = '*';   /* 42 */
	enum Plus        = '+';   /* 43 */
	enum Comma       = ';';   /* 44 */
	enum Minus       = '-';   /* 45 */
	enum Period      = '.';   /* 46 */
	enum Slash       = '/';   /* 47 */
	enum D0           = '0';   /* 48 (0x30) */
	enum D1           = '1';   /* 49 */
	enum D2           = '2';   /* 50 */
	enum D3           = '3';   /* 51 */
	enum D4           = '4';   /* 52 */
	enum D5           = '5';   /* 53 */
	enum D6           = '6';   /* 54 */
	enum D7           = '7';   /* 55 */
	enum D8           = '8';   /* 56 */
	enum D9           = '9';   /* 57 */
	enum Colon       = ':';   /* 58 */
	enum Semicolon   = ';';   /* 59 */
	enum Less        = '<';   /* 60 */
	enum Equal       = '=';   /* 61 */
	enum Greater     = '>';   /* 62 */
	enum Question    = '?';   /* 63 */
	enum At          = '@';   /* 64 */
	enum A           = 'A';   /* 65 (0x41) */
	enum B           = 'B';   /* 66 */
	enum C           = 'C';   /* 67 */
	enum D           = 'D';   /* 68 */
	enum E           = 'E';   /* 69 */
	enum F           = 'F';   /* 70 */
	enum G           = 'G';   /* 71 */
	enum H           = 'H';   /* 72 */
	enum I           = 'I';   /* 73 */
	enum J           = 'J';   /* 74 */
	enum K           = 'K';   /* 75 */
	enum L           = 'L';   /* 76 */
	enum M           = 'M';   /* 77 */
	enum N           = 'N';   /* 78 */
	enum O           = 'O';   /* 79 */
	enum P           = 'P';   /* 80 */
	enum Q           = 'Q';   /* 81 */
	enum R           = 'R';   /* 82 */
	enum S           = 'S';   /* 83 */
	enum T           = 'T';   /* 84 */
	enum U           = 'U';   /* 85 */
	enum V           = 'V';   /* 86 */
	enum W           = 'W';   /* 87 */
	enum X           = 'X';   /* 88 */
	enum Y           = 'Y';   /* 89 */
	enum Z           = 'Z';   /* 90 */
    enum LBracket    = '[';   /* 91 */
	enum BackSlash   = '\\';  /* 92 */
	enum RBracket    = ']';   /* 93 */
	enum Circum      = '^';   /* 94 */
	enum Underscore  = '_';   /* 95 */
	enum Grave       = '`';   /* 96 */
	enum a           = 'a';   /* 97 (0x61) */
	enum b           = 'b';   /* 98 */
	enum c           = 'c';   /* 99 */
	enum d           = 'd';   /* 100 */
	enum e           = 'e';   /* 101 */
	enum f           = 'f';   /* 102 */
	enum g           = 'g';   /* 103 */
	enum h           = 'h';   /* 104 */
	enum i           = 'i';   /* 105 */
	enum j           = 'j';   /* 106 */
	enum k           = 'k';   /* 107 */
	enum l           = 'l';   /* 108 */
	enum m           = 'm';   /* 109 */
	enum n           = 'n';   /* 110 */
	enum o           = 'o';   /* 111 */
	enum p           = 'p';   /* 112 */
	enum q           = 'q';   /* 113 */
	enum r           = 'r';   /* 114 */
	enum s           = 's';   /* 115 */
	enum t           = 't';   /* 116 */
	enum u           = 'u';   /* 117 */
	enum v           = 'v';   /* 118 */
	enum w           = 'w';   /* 119 */
	enum x           = 'x';   /* 120 */
	enum y           = 'y';   /* 121 */
	enum z           = 'z';   /* 122 */
	enum LBrace      = '{';   /* 123 */
	enum Bar         = '|';   /* 124 */
	enum RBrace      = '}';   /* 125 */
	enum Tilde       = '~';   /* 126 (0x7E) */

    enum Backspace   = '\b';       /* 8 */
    enum Tab         = '\t';       /* 9 */
    enum LineFeed    = '\n';       /* 10 (0x0A) not a real key, is a combination of CR with a modifier, just to document */
    enum Enter       = '\r';       /* 13 (0x0D) */

    enum LF          = '\n';       /* 10 (0x0A) */
    enum CR          = '\r';       /* 13 (0x0D) */

    enum Pause    = 0xFF13;
	enum ESC      = 0xFF1B;
	enum Home     = 0xFF50;
	enum Left     = 0xFF51;
	enum Up       = 0xFF52;
	enum Right    = 0xFF53;
	enum Down     = 0xFF54;
	enum PageUp     = 0xFF55;
	enum PageDown     = 0xFF56;
	enum End      = 0xFF57;
	enum Middle   = 0xFF0B;
	enum Print    = 0xFF61;
	enum Insert      = 0xFF63;
	enum Menu     = 0xFF67;
	enum Delete      = 0xFFFF;
	enum F1       = 0xFFBE;
	enum F2       = 0xFFBF;
	enum F3       = 0xFFC0;
	enum F4       = 0xFFC1;
	enum F5       = 0xFFC2;
	enum F6       = 0xFFC3;
	enum F7       = 0xFFC4;
	enum F8       = 0xFFC5;
	enum F9       = 0xFFC6;
	enum F10      = 0xFFC7;
	enum F11      = 0xFFC8;
	enum F12      = 0xFFC9;

	/* no Shift/Ctrl/Alt */
	enum LShift   = 0xFFE1;
	enum RShift   = 0xFFE2;
	enum LCtrl    = 0xFFE3;
	enum RCtrl    = 0xFFE4;
	enum LAlt     = 0xFFE9;
	enum RAlt     = 0xFFEA;

	enum NumLock      = 0xFF7F;
	enum Scroll   = 0xFF14;
	enum CapsLock     = 0xFFE5;

	/* Also; these are the same as the Latin-1 definition */

	enum ccedilla  = 0x00E7;
	enum Ccedilla  = 0x00C7;
	enum acute     = 0x00B4;  /* no Shift/Ctrl/Alt */
	enum diaeresis = 0x00A8;

    static bool isShiftXkey(dchar _c)  { return _c & ModifierKeys.Shift; }
    static bool isCtrlXkey(dchar _c)   { return _c & ModifierKeys.Control; }
    static bool isAltXkey(dchar _c)    { return _c & ModifierKeys.Alt; }
    static bool isSysXkey(dchar _c)    { return _c & ModifierKeys.Windows; }

    static dchar getBase(dchar c)     { return c & 0x0FFF_FFFF; }
    static dchar combinateShift(dchar c)    { return c | ModifierKeys.Shift; }   /* Shift  */
    static dchar combinateCtrl(dchar c)     { return c | ModifierKeys.Control; }   /* Ctrl   */
    static dchar combinateAlt(dchar c)      { return c | ModifierKeys.Alt; }   /* Alt    */
    static dchar combinateWindows(dchar c)      { return c | ModifierKeys.Windows; }   /* Sys (Win or Apple) */


    /**
    They return true if the respective key or button is pressed, and false otherwise.
    */
    static bool hasShift(string s) {
        return s[0] == 'S';
    }

    static bool hasControl(string s){
        return s[1]=='C';
    }

    static bool hasButton1(string s){
        return s[2]=='1';
    }

    static bool hasButton2(string s){
        return s[3]=='2';
    }

    static bool hasButton3(string s){
        return s[4]=='3';
    }

    static bool hasDouble(string s){
        return s[5]=='D';
    }

    static bool hasAlt(string s){
        return s[6]=='A';
    }

    static bool hasSys(string s){
        return s[7]=='Y';
    }

    static bool hasButton4(string s){
        return s[8]=='4';
    }

    static bool hasButton5(string s){
        return s[9]=='5';
    }

    static string getModifierKeyState() { 
        char* state = iup.c.api.IupGetGlobal(GlobalAttributes.ModifierKeyState);  
        return cast(string)std.string.fromStringz(cast(const(char)*) state);
    }

    static string toName(int c)
    {
       char* name = iup.c.api.iupKeyCodeToName(c);
        return cast(string)std.string.fromStringz(cast(const(char)*)name);
    }


}


//
// Summary:
//     Specifies the set of modifier keys.

public enum ModifierKeys
{
    //
    // Summary:
    //     No modifiers are pressed.
    None = 0,
        //
        // Summary:
        //     The ALT key.
        Alt = 0x4000_0000,
        //
        // Summary:
        //     The CTRL key.
        Control = 0x2000_0000,
        //
        // Summary:
        //     The SHIFT key.
        Shift = 0x1000_0000,
        //
        // Summary:
        //     Sys (Win or Apple).
        Windows = 0x8000_0000
}
