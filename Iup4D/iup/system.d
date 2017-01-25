module iup.system;

import iup.c;
import iup.core;

import im.c.image;
import im.image;

import std.string;


final class Environment
{
    /**
    */
    final class IUP
    {
        /**
        Returns a string with the IUP version number.
        Returns: the version number including the bug fix. The defines only includes the major 
        and minor numbers. For example: "2.7.1".
        */
        @property static string ver() 
        { 
            char* v = iup.c.IupVersion();
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns the IUP's copyright.
        Ex: "Copyright (C) 1994-2014 Tecgraf/PUC-Rio".
        */
        @property static string copyright()
        {  
            char* v = iup.c.IupGetGlobal("COPYRIGHT");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Informs the current driver being used.
        Two drivers are available now, one for each platform: "GTK", "Motif" and "Win32".
        */
        @property static string driver() 
        { 
            char* v = iup.c.IupGetGlobal("DRIVER");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        */
        @property static string isUtf8Mode() 
        { 
            char* v = iup.c.IupGetGlobal(GlobalAttributes.Utf8Mode);
            return cast(string)std.string.fromStringz(v);
        }

        /**
        The language used by some pre-defined dialogs.
        Can have the values ENGLISH and PORTUGUESE. Default: ENGLISH. 
        Can also be set by IupSetLanguage.
        */
        @property
        {
            static string language() 
            { 
                char* v = iup.c.IupGetGlobal("LANGUAGE");
                return cast(string)std.string.fromStringz(v);
            }

            static void language(string lang)
            {
                iup.c.IupSetLanguage(std.string.toStringz(lang));
            }
        }
    }

    /**
    */
    final class OS
    {

        /**
        Informs the current operating system. On UNIX, it is equivalent to the command 
        "uname -s" (sysname). On Windows, it identifies if you are on Windows 2000, 
        Windows XP or Windows Vista. Some known names: 

        "MacOS" 
        "FreeBSD" 
        "Linux" 
        "SunOS" 
        "Solaris" 
        "IRIX" 
        "AIX" 
        "HP-UX" 
        "Win2K" 
        "WinXP" 
        "Vista" 
        "Win7" 
        "Win8" 

        Notice that "Windows 8.1" will normally be detected as "Windows 8", unless a special
        Manifest is used. See MSDN for more information.
        */
        @property static string name() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEM");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Informs the current operating system version number.

        On UNIX, it is equivalent to the command  "uname -r" (release). On Windows, it identifies
        the system version number and service pack version. On MacOSX is system version.
        */
        @property static string ver() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEMVERSION");
            return cast(string)std.string.fromStringz(v);
        }


        /**
        Returns a text with a description of the system language.
        */
        @property static string language() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEMLANGUAGE");
            return cast(string)std.string.fromStringz(v);
        }


        /**
        Returns a text with a description of the system locale.
        */
        @property static string locale() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEMLOCALE");
            return cast(string)std.string.fromStringz(v);
        }
    }


    /// Screen Information
    final class Screen
    {
        /**
        Returns the screen depth in bits per pixel.
        */
        @property static double depth() { return iup.c.IupGetDouble(null,GlobalAttributes.ScreenDepth);}

        /**
        Returns the screen size in pixels available for dialogs, i.e. not including menu bars, 
        task bars, etc. In Motif has the same value as the FULLSIZE attribute. The main screen 
        size does not include additional monitors.

        String in the "widthxheight" format.
        */
        @property static string size()
        { 
            char* v = iup.c.IupGetGlobal(GlobalAttributes.ScreenSize);
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns the full screen size in pixels.
        String in the "widthxheight" format.
        */
        @property static string fullSize() 
        { 
            char* v = iup.c.IupGetGlobal(GlobalAttributes.FullSize);
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns a real value with the screen resolution in pixels per inch (same as 
        dots per inch - DPI).
        */
        @property static double dpi() { return iup.c.IupGetDouble(null, GlobalAttributes.ScreenDpi);}


        /**
        Returns the virtual screen position and size in pixels. It is the virtual 
        space defined by all monitors in the system.

        String in the "x y width height" format.
        */
        @property static string virtualScreen() 
        { 
            char* v = iup.c.IupGetGlobal("VIRTUALSCREEN");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns the position and size in pixels of all monitors. Each monitor information is
        terminated by a "\n" character.

        String in the "x y width height\nx y width height\n..." format.
        */
        @property static string monitorsInfo() 
        { 
            char* v = iup.c.IupGetGlobal("MONITORSINFO");
            return cast(string)std.string.fromStringz(v);
        }
    }

    /**
    Returns the hostname.
    */
    @property static string computerName() 
    { 
        char* v = iup.c.IupGetGlobal("COMPUTERNAME");
        return cast(string)std.string.fromStringz(v);
	}


    /**
    Returns the user logged in.
    */
    @property static string userName() 
    { 
        char* v = iup.c.IupGetGlobal("USERNAME");
        return cast(string)std.string.fromStringz(v);
	}


    /**
    */
    @property static string defaultFont() 
    { 
        char* v = iup.c.IupGetGlobal("DEFAULTFONT");
        return cast(string)std.string.fromStringz(v);
	}
}



/**
Creates an element that allows access to the clipboard. Each clipboard should be 
destroyed using IupDestroy, but you can use only one for the entire application 
because it does not store any data inside. Or you can simply create and destroy 
every time you need to copy or paste.
*/
public final static class IupClipboard 
{
    private static Ihandle* handle;

	protected struct IupAttributes
	{
        enum AddFormat = "ADDFORMAT";
        enum Format = "FORMAT";
        enum FormatAvailable = "FORMATAVAILABLE";
        enum FormatData = "FORMATDATA";
        enum FormatDataSize = "FORMATDATASIZE";
        enum ImageAvailable = "IMAGEAVAILABLE";
        enum NativeImage = "NATIVEIMAGE";
        enum Image = "IMAGE";
        enum Text = "TEXT";
        enum TextAvailable = "TEXTAVAILABLE";

        version(Windows)
        {
            enum EmfAvailable = "EMFAVAILABLE";
            enum SaveEmf = "SAVEEMF";
            enum SaveWmf = "SAVEWMF";
            enum WmfAvailable = "WMFAVAILABLE";
        }

	}

    //static this()
    //{
    //    iup.c.api.IupOpen(null, null);
    //    handle = iup.c.api.IupClipboard();
    //}

    //static ~this()
    //{
    //    iup.c.IupDestroy(handle);  // BUG?
    //}

    static void open()
    {
        // IupOpen must be run firstly.
        if(handle is null)
            handle = iup.c.api.IupClipboard();
    }

    static void dispose()
    {
        if(handle is null)
            return;

        iup.c.IupDestroy(handle);
        handle = null;
    }

    /* ************* Properties *************** */


    /**
    */
    @property 
	{ 
		public static bool isTextAvailable() { return cast(bool)getIntAttribute(IupAttributes.TextAvailable); }
		public static bool isFormatAvailable() { return cast(bool)getIntAttribute(IupAttributes.FormatAvailable); }
		public static bool isImageAvailable() { return cast(bool)getIntAttribute(IupAttributes.ImageAvailable); }
	}


    /* ************* Public methods *************** */

    /**
    register a custom format for clipboard data given its name. The registration remains 
    valid even after the element is destroyed. A new format must be added before used. (since 3.7)
    */
    public static void addFormat(string name)
    {
        setAttribute(IupAttributes.AddFormat, name);
    }    

    /**
    set the current format to be used by the FORMATAVAILABLE and FORMATDATA attributes. (since 3.7)
    */
    public static void setFormat(string name)
    {
        setAttribute(IupAttributes.Format, name);
    }

    /**
    sets or retrieves the data from the clipboard in the format defined by the FORMAT 
    attribute. If FORMAT is not set returns NULL. If set to NULL clears the clipboard 
    data. When set the FORMATDATASIZE attribute must be set before with the data size. 
    When retrieved FORMATDATASIZE will be set and available after data is retrieved. (since 3.7)
    */
    @property 
	{ 
        public static void* formatData()
        {
            return gePointertAttribute(IupAttributes.FormatData);
        }

        public static void formatData(void* data)
        {
            setPointerAttribute(IupAttributes.FormatData, data);
        }
    }

    /**
    size of the data on the clipboard. Used by the FORMATDATA attribute processing. (since 3.7)
    */
    @property 
	{ 
        public static int formatDataSize()
        {
            return getIntAttribute(IupAttributes.FormatDataSize); 
        }

        public static void formatDataSize(int size)
        {
            setIntAttribute(IupAttributes.FormatDataSize, size);
        }
    }

    /**
    copy or paste text to or from the clipboard. If set to NULL clears the clipboard data.
    */
    @property 
	{
        public static string text()
        {
            return getAttribute(IupAttributes.Text);
        }

        public static void text(string text)
        {
            if(text.empty)
                setPointerAttribute(IupAttributes.Text, null);
            else
                setAttribute(IupAttributes.Text, text);
        }
    }


    /**
    native handle of an image to copy or paste, to or from the clipboard. In Win32 is a HANDLE of a DIB. In GTK is a GdkPixbuf*. 
    In Motif is a Pixmap. If set to NULL clears the clipboard data. The returned handle in a paste must be released after 
    used (GlobalFree(handle), g_object_unref(pixbuf) or XFreePixmap(display, pixmap)). After copy, do NOT release the given 
    handle. See IUP-IM Functions for utility functions on image native handles. (GTK 2.6)
    */
    public static ImImage getNativeImage()
    {
        im.c.image.imImage* imageHandle = IupGetNativeHandleImage(gePointertAttribute(IupAttributes.NativeImage));
        return  new ImImage(imageHandle);
    }

    /// ditto
    public static void setNativeImage(ImImage image)
    {
        setPointerAttribute(IupAttributes.NativeImage, IupGetImageNativeHandle(image.image));
    }


    version(Windows)
    {
        /// informs if there is a Windows Enhanced Metafile available at the clipboard. (Since 3.2)
		public static bool isEmfAvailable() { return cast(bool)getIntAttribute(IupAttributes.EmfAvailable); }

        /// informs if there is a Windows Metafile available at the clipboard. (Since 3.2)
		public static bool isWmfAvailable() { return cast(bool)getIntAttribute(IupAttributes.WmfAvailable); }

    }


    private static string getAttribute(string name) 
    {
        auto v = iup.c.api.IupGetAttribute(handle, std.string.toStringz(name));
        return std.string.fromStringz(v).idup;
        //return cast(string)std.string.fromStringz(v);
    }

    private static void* gePointertAttribute(string name) 
    {
        return cast(void*)iup.c.api.IupGetAttribute(handle, std.string.toStringz(name));
    }


    /**
    this function automatically creates a non conflict name and associates the name with the attribute.
    */
    private static setPointerAttribute(string name, void* value)
    {
        iup.c.api.IupSetAttribute(handle, std.string.toStringz(name), cast(char*)value);
    }

    /**
    this function automatically creates a non conflict name and associates the name with the attribute.
    */
    private static setAttribute(string name, string value)
    {
        iup.c.api.IupSetStrAttribute (handle, std.string.toStringz(name), std.string.toStringz(value));
    }

    /**
    */
    private static void setIntAttribute(string name, int v)
    {
        iup.c.api.IupSetInt(handle, std.string.toStringz(name), v);
    }

    private static int getIntAttribute(string name)
    {
        return iup.c.api.IupGetInt(handle, std.string.toStringz(name));
    }
}


/**
Specifies the formats used with text-related methods of the Clipboard.
*/
public enum TextFormat
{
    // Summary:
    //     Specifies the standard ANSI text format.
    Text = 0,
        //
        // Summary:
        //     Specifies the standard Windows Unicode text format.
        UnicodeText = 1,
        //
        // Summary:
        //     Specifies text consisting of rich text format (RTF) data.
        Rtf = 2,
        //
        // Summary:
        //     Specifies text consisting of HTML data.
        Html = 3,
        //
        // Summary:
        //     Specifies a comma-separated value (CSV) format, which is a common interchange
        //     format used by spreadsheets.
        CommaSeparatedValue = 4,
}


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