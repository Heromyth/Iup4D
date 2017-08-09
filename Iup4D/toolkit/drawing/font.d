module toolkit.drawing.font;

import std.string;
import std.format;
import std.conv;
import std.algorithm;


//
// Summary:
//     Defines a particular format for text, including font face, size, and style attributes.
//     This class cannot be inherited.
public class Font
{

    this()
    {
        version(Windows)
        {
            m_name = "Segoe UI";
            m_style = FontStyles.Plain;
            m_size = 9;
        }
    }

    this(string faceName, FontStyle style, int size)
    {
        m_name = faceName;
        m_style = style;
        m_size = size;
    }


    /* ************* Properties *************** */

    /**
    Font face is the font face name, and can be any name. Although only names recognized by the system will be actually used. 
    The names Helvetica, Courier and Times are always accepted in all systems.
    */
    @property 
	{
		string name() { return m_name; }
		void name(string value) { m_name = value; }
        private string m_name; 
	}

    /**
    The supported font style is a combination of: Bold, Italic, Underline and Strikeout. The Pango format include many other 
    definitions not supported by the common format, they are supported only by the GTK driver. Unsupported values are simply 
    ignored. The names must be in the same case describe here.
    */
    @property 
	{
		FontStyle style() { return m_style; }
		void style(FontStyle value) { m_style = value; }
        private FontStyle m_style; 
	}

    /**
    Font size is in points (1/72 inch) or in pixels (using negative values).
    */
    @property 
	{
		int size() { return m_size; }
		void size(int value) { m_size = value; }
        private int m_size; 
	}

    /**
    It is defined as having 3 parts: "<font face>, <font styles> <font size>". 
    */
    override string toString()
    {
        string s = style.toString();
        string r;
        if(s.empty)
            r = name ~ ", " ~ to!string(size);
        else
            r = name ~ ", " ~ s ~ " " ~ to!string(size);
        return r;
    }

    static Font parse(string font)
    {
        //auto fontParts = std.algorithm.splitter(font, ",");
        //string fontName = fontParts[0];
        //
        //fontParts = std.algorithm.splitter(fontParts[1], " ");
        //FontStyle style = FontStyles.Plain;
        //int size = to!int(fontParts[$]);
        //
        //if(fontParts.length > 1)
        //{
        //}

        ptrdiff_t styleIndex = font.indexOf(',');
        string fontName = font[0..styleIndex];
        styleIndex++;

        ptrdiff_t sizeIndex = font.lastIndexOf(' ');

        FontStyle style = FontStyles.Plain;
        if(sizeIndex > styleIndex)
        {
            string s = font[styleIndex .. sizeIndex];
            style = FontStyle.parse(s);
        }

        sizeIndex++;
        string sizeValue = font[sizeIndex .. $];
        int size = to!int(sizeValue);

        Font f = new Font(fontName, style, size);
        return f;
    }

}


/**
Specifies style information applied to text.
*/
struct FontStyle
{
	@property public ubyte value() { return m_value; }
    private ubyte m_value; 

    @disable this();
    
    this(ubyte value)  { 
        assert(value>=0 && value <= 0x0F);
        this.m_value = value; }


    //------------------------------------------------------
    //  Public Operators
    //------------------------------------------------------

    FontStyle opBinary(string op)(FontStyle c) if(op == "|")
    {
        FontStyle r = FontStyle(0);
        r.m_value = (this.value | c.value);  
        return r;
    }


    bool opEquals(ref FontStyle f)
    {
        return value == f.value;
    }


    //------------------------------------------------------
    //  Public methods
    //------------------------------------------------------

    string toString()
    {
        string s = "";
        if((m_value & 1 )== 1)
            s = Bold;

        if((m_value & 2) == 2)
        {
            if(s.length > 0) s ~= " ";
            s ~= Italic;
        }

        if((m_value & 4) == 4)
        {
            if(s.length > 0) s ~= " ";
            s ~= Underline;
        }

        if((m_value & 8) == 8)
        {
            if(s.length > 0) s ~= " ";
            s ~= Strikeout;
        }

        return s;
    }

    static FontStyle parse(string s)
    {
        FontStyle r = FontStyles.Plain;

        auto styles = std.algorithm.splitter(s, " ");
        foreach(item ; styles)
        {
            if(item == Bold)
                r = r | FontStyles.Bold;
            else if(item == Italic)
                r = r | FontStyles.Italic;
            else if(item == Underline)
                r = r | FontStyles.Underline;
            else if(item == Strikeout)
                r = r | FontStyles.Strikeout;
        }

        return r;
    }

    enum Plain = "Plain";
    enum Bold = "Bold";
    enum Italic = "Italic";
    enum Underline = "Underline";
    enum Strikeout = "Strikeout";
}


/**
*/
struct FontStyles
{
    /// Normal text.
    static @property FontStyle Plain() { return FontStyle(0); }

    /// Bold text.
    static @property FontStyle Bold() { return FontStyle(1); }

    /// Italic text.
    static @property FontStyle Italic() { return FontStyle(2); }

    /// Underlined text.
    static @property FontStyle Underline() { return FontStyle(4); }

    /// Text with a line through the middle.
    static @property FontStyle Strikeout() { return FontStyle(8); }
}



unittest
{
    FontStyle style = FontStyles.Bold | FontStyles.Italic;
    string str = style.toString();
    assert(str == "Bold Italic");
    assert(FontStyle.parse(str) == style);

}