module toolkit.drawing.color;

import std.math;
import std.format;
import std.conv;
import std.string;

/**
The Color structure, composed of a private, synchronized ScRgb (IEC 61966-2-2) value
a color context, composed of an ICC profile and the native color values.
*/
public struct Color 
{
    /// Color - sRgb legacy interface, assumes Rgb values are sRgb, 0x00RRGGBB
    public static Color fromUInt(uint argb)// internal legacy sRGB interface
    {
        Color c1;

        c1.sRgbColor.a = cast(ubyte)((argb & 0xff000000) >> 24);
        c1.sRgbColor.r = cast(ubyte)((argb & 0x00ff0000) >> 16);
        c1.sRgbColor.g = cast(ubyte)((argb & 0x0000ff00) >> 8);
        c1.sRgbColor.b = cast(ubyte)(argb & 0x000000ff);
        c1.scRgbColor.a = cast(float)c1.sRgbColor.a / 255.0f;
        c1.scRgbColor.r = sRgbToScRgb(c1.sRgbColor.r);  // note that context is undefined and thus unloaded
        c1.scRgbColor.g = sRgbToScRgb(c1.sRgbColor.g);
        c1.scRgbColor.b = sRgbToScRgb(c1.sRgbColor.b);
        //c1.context = null;

        c1.isFromScRgb = false;

        return c1;
    }

    ///<summary>
    /// FromScRgb
    ///</summary>
    public static Color fromScRgb(float a, float r, float g, float b)
    {
        Color c1;

        c1.scRgbColor.r = r;
        c1.scRgbColor.g = g;
        c1.scRgbColor.b = b;
        c1.scRgbColor.a = a;
        if (a < 0.0f)
        {
            a = 0.0f;
        }
        else if (a > 1.0f)
        {
            a = 1.0f;
        }

        c1.sRgbColor.a = cast(ubyte)((a * 255.0f) + 0.5f);
        c1.sRgbColor.r = ScRgbTosRgb(c1.scRgbColor.r);
        c1.sRgbColor.g = ScRgbTosRgb(c1.scRgbColor.g);
        c1.sRgbColor.b = ScRgbTosRgb(c1.scRgbColor.b);
        //c1.context = null;

        c1.isFromScRgb = true;

        return c1;
    }

    ///<summary>
    /// Color - sRgb legacy interface, assumes Rgb values are sRgb, alpha channel is linear 1.0 gamma
    ///</summary>
    public static Color fromArgb(ubyte a, ubyte r, ubyte g, ubyte b)// legacy sRGB interface, bytes are required to properly round trip
    {
        Color c1;

        c1.scRgbColor.a = cast(float)a / 255.0f;
        c1.scRgbColor.r = sRgbToScRgb(r);  // note that context is undefined and thus unloaded
        c1.scRgbColor.g = sRgbToScRgb(g);
        c1.scRgbColor.b = sRgbToScRgb(b);
        //c1.context = null;

        c1.sRgbColor.a = a;
        c1.sRgbColor.r = ScRgbTosRgb(c1.scRgbColor.r);
        c1.sRgbColor.g = ScRgbTosRgb(c1.scRgbColor.g);
        c1.sRgbColor.b = ScRgbTosRgb(c1.scRgbColor.b);

        c1.isFromScRgb = false;

        return c1;
    }

    ///<summary>
    /// Color - sRgb legacy interface, assumes Rgb values are sRgb
    ///</summary>
    public static Color fromRgb(ubyte r, ubyte g, ubyte b)// legacy sRGB interface, bytes are required to properly round trip
    {
        Color c1 = Color.fromArgb(cast(ubyte)0xFF, r, g, b);
        return c1;
    }


    /**
    #FF00DD0C or "r g b" or "r g b a"
    */
    public static Color parse(string color)
    {
        if(color.empty) 
            return Colors.Black;

        if(color[0] == '#') 
        {
            color = color[1..$];

            if(color.length == "00FF00".length)
                color = "FF" ~ color;

            uint hex = to!uint(color, 16);
            return fromUInt(hex);
        }
        else
        {
            string c = color;
            string[] parts = split(c, ' ');
            ubyte r, g, b, a;

            r = to!ubyte(parts[0], 10);
            g = to!ubyte(parts[1], 10);
            b = to!ubyte(parts[2], 10);

            if(parts.length == 4)
                a = to!ubyte(parts[3], 10);
            else
                a = 0xFF;

            return Color.fromArgb(a, r, g, b);
        }
    }

    //------------------------------------------------------
    //  Public Properties
    //------------------------------------------------------

    /**
    */
    @property 
    {
        public ubyte A() { return sRgbColor.a; }

        public void A(ubyte value) 
        {
            scRgbColor.a = cast(float)value / 255.0f;
            sRgbColor.a = value;
        }
    }

    /**
    The Red channel as a ubyte whose range is [0..255].
    the value is not allowed to be out of range
    */
    @property 
    {
        public ubyte R() { return sRgbColor.r; }

        public void R(ubyte value) 
        {
            scRgbColor.r = sRgbToScRgb(value);
            sRgbColor.r = value;
        }
    }

    /**
    The Green channel as a ubyte whose range is [0..255].
    the value is not allowed to be out of range
    */
    @property 
    {
        public ubyte G() { return sRgbColor.g; }

        public void G(ubyte value) 
        {
            scRgbColor.g = sRgbToScRgb(value);
            sRgbColor.g = value;
        }
    }


    /**
    The Blue channel as a ubyte whose range is [0..255].
    the value is not allowed to be out of range
    */
    @property 
    {
        public ubyte B() { return sRgbColor.b; }

        public void B(ubyte value) 
        {
            scRgbColor.b = sRgbToScRgb(value);
            sRgbColor.b = value;
        }
    }

    /**
    The Alpha channel as a float whose range is [0..1].
    */
    @property 
    {
        public float ScA() { return scRgbColor.a; }

        public void ScA(float value) 
        {
            scRgbColor.a = value;
            if (value < 0.0f)
            {
                sRgbColor.a = 0;
            }
            else if (value > 1.0f)
            {
                sRgbColor.a = cast(ubyte)255;
            }
            else
            {
                sRgbColor.a = cast(ubyte)(value * 255f);
            }
        }
    }

    /**
    The Red channel as a float whose range is [0..1].
    */
    @property 
    {
        public float ScR() { return scRgbColor.r; }

        public void ScR(float value) 
        {
            scRgbColor.r = value;
            sRgbColor.r = ScRgbTosRgb(value);
        }
    }

    /**
    The Green channel as a float whose range is [0..1].
    */
    @property 
    {
        public float ScG() { return scRgbColor.g; }

        public void ScG(float value) 
        {
            scRgbColor.g = value;
            sRgbColor.g = ScRgbTosRgb(value);
        }
    }

    /**
    The Blue channel as a float whose range is [0..1].
    */
    @property 
    {
        public float ScB() { return scRgbColor.b; }

        public void ScB(float value) 
        {
            scRgbColor.b = value;
            sRgbColor.b = ScRgbTosRgb(value);
        }
    }

    /**
    #FF000000
    */
    string toString()
    {
        if(isFromScRgb)
        {
            enum separator = ",";
            return std.format.format("sc#%2$g%1$s %3$g%1$s %4$g%1$s %5$g",separator, scRgbColor.a,
                                     scRgbColor.r, scRgbColor.g, scRgbColor.b);
        }
        else
            return std.format.format("#%02X%02X%02X%02X", this.sRgbColor.a, this.sRgbColor.r, 
                                     this.sRgbColor.g, this.sRgbColor.b);
    }

    /**
    "255 255 255" or "FF FF FF" 
    */
    string toRgb(bool isHexadecimal = false)
    {
        if(isHexadecimal)
            return std.format.format("%02X %02X %02X", this.sRgbColor.r, this.sRgbColor.g, this.sRgbColor.b);
        else
            return std.format.format("%d %d %d", this.sRgbColor.r, this.sRgbColor.g, this.sRgbColor.b);
    }

    /**
    "255 255 255 128" or "FF FF FF 23" 
    */
    string toRgba(bool isHexadecimal = false)
    {
        if(isHexadecimal)
            return std.format.format("%02X %02X %02X %02X", this.sRgbColor.r, this.sRgbColor.g, this.sRgbColor.b, this.sRgbColor.a);
        else
            return std.format.format("%d %d %d %d", this.sRgbColor.r, this.sRgbColor.g, this.sRgbColor.b, this.sRgbColor.a);
    }


    uint toUInt()
    {
        uint r = sRgbColor.b;
        r = r + (sRgbColor.g << 8);
        r = r + (sRgbColor.r << 16);
        r = r + (sRgbColor.a << 24);

        return r;
    }

    //------------------------------------------------------
    //  Public Operators
    //------------------------------------------------------

    Color opBinary(string op)(Color c) if(op == "+")
    {
        Color c1 = fromScRgb(this.scRgbColor.a + c.scRgbColor.a,
                             this.scRgbColor.r + c.scRgbColor.r,
                             this.scRgbColor.g + c.scRgbColor.g,
                             this.scRgbColor.b + c.scRgbColor.b);
        return c1;
    }

    Color opBinary(string op)(Color c) if(op == "-")
    {
        Color c1 = fromScRgb(this.scRgbColor.a - c.scRgbColor.a,
                             this.scRgbColor.r - c.scRgbColor.r,
                             this.scRgbColor.g - c.scRgbColor.g,
                             this.scRgbColor.b - c.scRgbColor.b);
        return c1;
    }

    Color opBinary(string op)(float coefficient) if(op == "*")
    {
        Color c1 = fromScRgb(this.scRgbColor.a * coefficient,
                             this.scRgbColor.r * coefficient,
                             this.scRgbColor.g * coefficient,
                             this.scRgbColor.b * coefficient);
        return c1;
    }


    bool opEquals(in Color c)
    {
        if (this.scRgbColor.r != c.scRgbColor.r)
            return false;

        if (this.scRgbColor.g != c.scRgbColor.g)
            return false;

        if (this.scRgbColor.b != c.scRgbColor.b)
            return false;

        if (this.scRgbColor.a != c.scRgbColor.a)
            return false;

        return true;
    }

    //------------------------------------------------------
    //  Private Methods
    //------------------------------------------------------

    ///<summary>
    /// private helper function to set context values from a color value with a set context and ScRgb values
    ///</summary>
    private static float sRgbToScRgb(ubyte bval)
    {
        float val = (cast(float)bval / 255.0f);

        if (!(val > 0.0))       // Handles NaN case too. (Though, NaN isn't actually
            // possible in this case.)
        {
            return (0.0f);
        }
        else if (val <= 0.04045)
        {
            return (val / 12.92f);
        }
        else if (val < 1.0f)
        {
            return cast(float)pow((cast(double)val + 0.055) / 1.055, 2.4);
        }
        else
        {
            return (1.0f);
        }
    }

    ///<summary>
    /// private helper function to set context values from a color value with a set context and ScRgb values
    ///</summary>
    ///
    private static ubyte ScRgbTosRgb(float val)
    {
        if (!(val > 0.0))       // Handles NaN case too
        {
            return 0;
        }
        else if (val <= 0.0031308)
        {
            return cast(ubyte)((255.0f * val * 12.92f) + 0.5f);
        }
        else if (val < 1.0)
        {
            return cast(ubyte)((255.0f * ((1.055f * cast(float)pow(cast(double)val, (1.0 / 2.4))) - 0.055f)) + 0.5f);
        }
        else
        {
            return cast(ubyte)(255);
        }
    }


    private struct MILColorF // this structure is the "milrendertypes.h" structure and should be identical for performance
    {
        public float a, r, g, b;
    };


    private struct MILColor
    {
        public ubyte a, r, g, b;
    }

    private MILColorF scRgbColor;
    private MILColor sRgbColor;
    //private float[] nativeColorValue;
    private bool isFromScRgb;
    //private const string c_scRgbFormat = "R";
}


unittest
{

    Color c = Colors.Red + Colors.Yellow;
    string s = c.toString();
    //
    //c = Color.fromScRgb(0.6f, 0.3f, 1.0f, 0.25f);
    //s = c.toString();

    bool r;
    Color d = Colors.Yellow; // {#FFFFFF00}
    d = d*0.5;
    s = d.toString();
    c = Colors.Red;   // {#FFFF0000}
    s = c.toString();            

    assert(!(Colors.Red  == Colors.Yellow));
    assert(Colors.Red  == Color.fromArgb(255,255,0,0));

    assert(Colors.Red  == Color.parse("255 0 0"));

}


/// <summary>
/// Colors - A collection of well-known Colors
/// </summary>
public final class Colors
{

    // Colors only has static members, so it shouldn't be constructable.
    private this()
    {
    }


    /**
    Well-known color: AliceBlue
    */
    @property 
    {
        public static Color AliceBlue() { return Color.fromUInt(cast(uint)KnownColor.AliceBlue); }
    }

    /**
    Well-known color: AntiqueWhite
    */
    @property 
    {
        public static Color AntiqueWhite() { return Color.fromUInt(cast(uint)KnownColor.AntiqueWhite); }
    }

    /**
    Well-known color: Aqua
    */
    @property 
    {
        public static Color Aqua() { return Color.fromUInt(cast(uint)KnownColor.Aqua); }
    }

    /**
    Well-known color: Aquamarine
    */
    @property 
    {
        public static Color Aquamarine() { return Color.fromUInt(cast(uint)KnownColor.Aquamarine); }
    }

    /**
    Well-known color: Azure
    */
    @property 
    {
        public static Color Azure() { return Color.fromUInt(cast(uint)KnownColor.Azure); }
    }

    /**
    Well-known color: Beige
    */
    @property 
    {
        public static Color Beige() { return Color.fromUInt(cast(uint)KnownColor.Beige); }
    }

    /**
    Well-known color: Bisque
    */
    @property 
    {
        public static Color Bisque() { return Color.fromUInt(cast(uint)KnownColor.Bisque); }
    }

    /**
    Well-known color: Black
    */
    @property 
    {
        public static Color Black() { return Color.fromUInt(cast(uint)KnownColor.Black); }
    }

    /**
    Well-known color: BlanchedAlmond
    */
    @property 
    {
        public static Color BlanchedAlmond() { return Color.fromUInt(cast(uint)KnownColor.BlanchedAlmond); }
    }

    /**
    Well-known color: Blue
    */
    @property 
    {
        public static Color Blue() { return Color.fromUInt(cast(uint)KnownColor.Blue); }
    }

    /**
    Well-known color: BlueViolet
    */
    @property 
    {
        public static Color BlueViolet() { return Color.fromUInt(cast(uint)KnownColor.BlueViolet); }
    }

    /**
    Well-known color: Brown
    */
    @property 
    {
        public static Color Brown() { return Color.fromUInt(cast(uint)KnownColor.Brown); }
    }

    /**
    Well-known color: BurlyWood
    */
    @property 
    {
        public static Color BurlyWood() { return Color.fromUInt(cast(uint)KnownColor.BurlyWood); }
    }

    /**
    Well-known color: CadetBlue
    */
    @property 
    {
        public static Color CadetBlue() { return Color.fromUInt(cast(uint)KnownColor.CadetBlue); }
    }

    /**
    Well-known color: Chartreuse
    */
    @property 
    {
        public static Color Chartreuse() { return Color.fromUInt(cast(uint)KnownColor.Chartreuse); }
    }

    /**
    Well-known color: Chocolate
    */
    @property 
    {
        public static Color Chocolate() { return Color.fromUInt(cast(uint)KnownColor.Chocolate); }
    }

    /**
    Well-known color: Coral
    */
    @property 
    {
        public static Color Coral() { return Color.fromUInt(cast(uint)KnownColor.Coral); }
    }

    /**
    Well-known color: CornflowerBlue
    */
    @property 
    {
        public static Color CornflowerBlue() { return Color.fromUInt(cast(uint)KnownColor.CornflowerBlue); }
    }

    /**
    Well-known color: Cornsilk
    */
    @property 
    {
        public static Color Cornsilk() { return Color.fromUInt(cast(uint)KnownColor.Cornsilk); }
    }

    /**
    Well-known color: Crimson
    */
    @property 
    {
        public static Color Crimson() { return Color.fromUInt(cast(uint)KnownColor.Crimson); }
    }

    /**
    Well-known color: Cyan
    */
    @property 
    {
        public static Color Cyan() { return Color.fromUInt(cast(uint)KnownColor.Cyan); }
    }

    /**
    Well-known color: DarkBlue
    */
    @property 
    {
        public static Color DarkBlue() { return Color.fromUInt(cast(uint)KnownColor.DarkBlue); }
    }

    /**
    Well-known color: DarkCyan
    */
    @property 
    {
        public static Color DarkCyan() { return Color.fromUInt(cast(uint)KnownColor.DarkCyan); }
    }

    /**
    Well-known color: DarkGoldenrod
    */
    @property 
    {
        public static Color DarkGoldenrod() { return Color.fromUInt(cast(uint)KnownColor.DarkGoldenrod); }
    }

    /**
    Well-known color: DarkGray
    */
    @property 
    {
        public static Color DarkGray() { return Color.fromUInt(cast(uint)KnownColor.DarkGray); }
    }

    /**
    Well-known color: DarkGreen
    */
    @property 
    {
        public static Color DarkGreen() { return Color.fromUInt(cast(uint)KnownColor.DarkGreen); }
    }

    /**
    Well-known color: DarkKhaki
    */
    @property 
    {
        public static Color DarkKhaki() { return Color.fromUInt(cast(uint)KnownColor.DarkKhaki); }
    }

    /**
    Well-known color: DarkMagenta
    */
    @property 
    {
        public static Color DarkMagenta() { return Color.fromUInt(cast(uint)KnownColor.DarkMagenta); }
    }

    /**
    Well-known color: DarkOliveGreen
    */
    @property 
    {
        public static Color DarkOliveGreen() { return Color.fromUInt(cast(uint)KnownColor.DarkOliveGreen); }
    }

    /**
    Well-known color: DarkOrange
    */
    @property 
    {
        public static Color DarkOrange() { return Color.fromUInt(cast(uint)KnownColor.DarkOrange); }
    }

    /**
    Well-known color: DarkOrchid
    */
    @property 
    {
        public static Color DarkOrchid() { return Color.fromUInt(cast(uint)KnownColor.DarkOrchid); }
    }

    /**
    Well-known color: DarkRed
    */
    @property 
    {
        public static Color DarkRed() { return Color.fromUInt(cast(uint)KnownColor.DarkRed); }
    }

    /**
    Well-known color: DarkSalmon
    */
    @property 
    {
        public static Color DarkSalmon() { return Color.fromUInt(cast(uint)KnownColor.DarkSalmon); }
    }

    /**
    Well-known color: DarkSeaGreen
    */
    @property 
    {
        public static Color DarkSeaGreen() { return Color.fromUInt(cast(uint)KnownColor.DarkSeaGreen); }
    }

    /**
    Well-known color: DarkSlateBlue
    */
    @property 
    {
        public static Color DarkSlateBlue() { return Color.fromUInt(cast(uint)KnownColor.DarkSlateBlue); }
    }

    /**
    Well-known color: DarkSlateGray
    */
    @property 
    {
        public static Color DarkSlateGray() { return Color.fromUInt(cast(uint)KnownColor.DarkSlateGray); }
    }

    /**
    Well-known color: DarkTurquoise
    */
    @property 
    {
        public static Color DarkTurquoise() { return Color.fromUInt(cast(uint)KnownColor.DarkTurquoise); }
    }

    /**
    Well-known color: DarkViolet
    */
    @property 
    {
        public static Color DarkViolet() { return Color.fromUInt(cast(uint)KnownColor.DarkViolet); }
    }

    /**
    Well-known color: DeepPink
    */
    @property 
    {
        public static Color DeepPink() { return Color.fromUInt(cast(uint)KnownColor.DeepPink); }
    }

    /**
    Well-known color: DeepSkyBlue
    */
    @property 
    {
        public static Color DeepSkyBlue() { return Color.fromUInt(cast(uint)KnownColor.DeepSkyBlue); }
    }

    /**
    Well-known color: DimGray
    */
    @property 
    {
        public static Color DimGray() { return Color.fromUInt(cast(uint)KnownColor.DimGray); }
    }

    /**
    Well-known color: DodgerBlue
    */
    @property 
    {
        public static Color DodgerBlue() { return Color.fromUInt(cast(uint)KnownColor.DodgerBlue); }
    }

    /**
    Well-known color: Firebrick
    */
    @property 
    {
        public static Color Firebrick() { return Color.fromUInt(cast(uint)KnownColor.Firebrick); }
    }

    /**
    Well-known color: FloralWhite
    */
    @property 
    {
        public static Color FloralWhite() { return Color.fromUInt(cast(uint)KnownColor.FloralWhite); }
    }

    /**
    Well-known color: ForestGreen
    */
    @property 
    {
        public static Color ForestGreen() { return Color.fromUInt(cast(uint)KnownColor.ForestGreen); }
    }

    /**
    Well-known color: Fuchsia
    */
    @property 
    {
        public static Color Fuchsia() { return Color.fromUInt(cast(uint)KnownColor.Fuchsia); }
    }

    /**
    Well-known color: Gainsboro
    */
    @property 
    {
        public static Color Gainsboro() { return Color.fromUInt(cast(uint)KnownColor.Gainsboro); }
    }

    /**
    Well-known color: GhostWhite
    */
    @property 
    {
        public static Color GhostWhite() { return Color.fromUInt(cast(uint)KnownColor.GhostWhite); }
    }


    /**
    Well-known color: Gold
    */
    @property 
    {
        public static Color Gold() { return Color.fromUInt(cast(uint)KnownColor.Gold); }
    }

    /**
    Well-known color: Goldenrod
    */
    @property 
    {
        public static Color Goldenrod() { return Color.fromUInt(cast(uint)KnownColor.Goldenrod); }
    }

    /**
    Well-known color: Gray
    */
    @property 
    {
        public static Color Gray() { return Color.fromUInt(cast(uint)KnownColor.Gray); }
    }

    /**
    Well-known color: Green
    */
    @property 
    {
        public static Color Green() { return Color.fromUInt(cast(uint)KnownColor.Green); }
    }

    /**
    Well-known color: GreenYellow
    */
    @property 
    {
        public static Color GreenYellow() { return Color.fromUInt(cast(uint)KnownColor.GreenYellow); }
    }

    /**
    Well-known color: Honeydew
    */
    @property 
    {
        public static Color Honeydew() { return Color.fromUInt(cast(uint)KnownColor.Honeydew); }
    }

    /**
    Well-known color: HotPink
    */
    @property 
    {
        public static Color HotPink() { return Color.fromUInt(cast(uint)KnownColor.HotPink); }
    }

    /**
    Well-known color: IndianRed
    */
    @property 
    {
        public static Color IndianRed() { return Color.fromUInt(cast(uint)KnownColor.IndianRed); }
    }

    /**
    Well-known color: Indigo
    */
    @property 
    {
        public static Color Indigo() { return Color.fromUInt(cast(uint)KnownColor.Indigo); }
    }

    /**
    Well-known color: Ivory
    */
    @property 
    {
        public static Color Ivory() { return Color.fromUInt(cast(uint)KnownColor.Ivory); }
    }


    /**
    Well-known color: Khaki
    */
    @property 
    {
        public static Color Khaki() { return Color.fromUInt(cast(uint)KnownColor.Khaki); }
    }

    /**
    Well-known color: Lavender
    */
    @property 
    {
        public static Color Lavender() { return Color.fromUInt(cast(uint)KnownColor.Lavender); }
    }

    /**
    Well-known color: LavenderBlush
    */
    @property 
    {
        public static Color LavenderBlush() { return Color.fromUInt(cast(uint)KnownColor.LavenderBlush); }
    }

    /**
    Well-known color: LawnGreen
    */
    @property 
    {
        public static Color LawnGreen() { return Color.fromUInt(cast(uint)KnownColor.LawnGreen); }
    }

    /**
    Well-known color: LemonChiffon
    */
    @property 
    {
        public static Color LemonChiffon() { return Color.fromUInt(cast(uint)KnownColor.LemonChiffon); }
    }

    /**
    Well-known color: LightBlue
    */
    @property 
    {
        public static Color LightBlue() { return Color.fromUInt(cast(uint)KnownColor.LightBlue); }
    }

    /**
    Well-known color: LightCoral
    */
    @property 
    {
        public static Color LightCoral() { return Color.fromUInt(cast(uint)KnownColor.LightCoral); }
    }

    /**
    Well-known color: LightCyan
    */
    @property 
    {
        public static Color LightCyan() { return Color.fromUInt(cast(uint)KnownColor.LightCyan); }
    }

    /**
    Well-known color: LightGoldenrodYellow
    */
    @property 
    {
        public static Color LightGoldenrodYellow() { return Color.fromUInt(cast(uint)KnownColor.LightGoldenrodYellow); }
    }

    /**
    Well-known color: LightGray
    */
    @property 
    {
        public static Color LightGray() { return Color.fromUInt(cast(uint)KnownColor.LightGray); }
    }


    /**
    Well-known color: LightGreen
    */
    @property 
    {
        public static Color LightGreen() { return Color.fromUInt(cast(uint)KnownColor.LightGreen); }
    }

    /**
    Well-known color: LightPink
    */
    @property 
    {
        public static Color LightPink() { return Color.fromUInt(cast(uint)KnownColor.LightPink); }
    }

    /**
    Well-known color: LightSalmon
    */
    @property 
    {
        public static Color LightSalmon() { return Color.fromUInt(cast(uint)KnownColor.LightSalmon); }
    }

    /**
    Well-known color: LightSeaGreen
    */
    @property 
    {
        public static Color LightSeaGreen() { return Color.fromUInt(cast(uint)KnownColor.LightSeaGreen); }
    }

    /**
    Well-known color: LightSkyBlue
    */
    @property 
    {
        public static Color LightSkyBlue() { return Color.fromUInt(cast(uint)KnownColor.LightSkyBlue); }
    }

    /**
    Well-known color: LightSlateGray
    */
    @property 
    {
        public static Color LightSlateGray() { return Color.fromUInt(cast(uint)KnownColor.LightSlateGray); }
    }

    /**
    Well-known color: LightSteelBlue
    */
    @property 
    {
        public static Color LightSteelBlue() { return Color.fromUInt(cast(uint)KnownColor.LightSteelBlue); }
    }

    /**
    Well-known color: LightYellow
    */
    @property 
    {
        public static Color LightYellow() { return Color.fromUInt(cast(uint)KnownColor.LightYellow); }
    }

    /**
    Well-known color: Lime
    */
    @property 
    {
        public static Color Lime() { return Color.fromUInt(cast(uint)KnownColor.Lime); }
    }

    /**
    Well-known color: LimeGreen
    */
    @property 
    {
        public static Color LimeGreen() { return Color.fromUInt(cast(uint)KnownColor.LimeGreen); }
    }


    /**
    Well-known color: Linen
    */
    @property 
    {
        public static Color Linen() { return Color.fromUInt(cast(uint)KnownColor.Linen); }
    }

    /**
    Well-known color: Magenta
    */
    @property 
    {
        public static Color Magenta() { return Color.fromUInt(cast(uint)KnownColor.Magenta); }
    }

    /**
    Well-known color: Maroon
    */
    @property 
    {
        public static Color Maroon() { return Color.fromUInt(cast(uint)KnownColor.Maroon); }
    }

    /**
    Well-known color: MediumAquamarine
    */
    @property 
    {
        public static Color MediumAquamarine() { return Color.fromUInt(cast(uint)KnownColor.MediumAquamarine); }
    }

    /**
    Well-known color: MediumBlue
    */
    @property 
    {
        public static Color MediumBlue() { return Color.fromUInt(cast(uint)KnownColor.MediumBlue); }
    }

    /**
    Well-known color: MediumOrchid
    */
    @property 
    {
        public static Color MediumOrchid() { return Color.fromUInt(cast(uint)KnownColor.MediumOrchid); }
    }

    /**
    Well-known color: MediumPurple
    */
    @property 
    {
        public static Color MediumPurple() { return Color.fromUInt(cast(uint)KnownColor.MediumPurple); }
    }

    /**
    Well-known color: MediumSeaGreen
    */
    @property 
    {
        public static Color MediumSeaGreen() { return Color.fromUInt(cast(uint)KnownColor.MediumSeaGreen); }
    }

    /**
    Well-known color: MediumSlateBlue
    */
    @property 
    {
        public static Color MediumSlateBlue() { return Color.fromUInt(cast(uint)KnownColor.MediumSlateBlue); }
    }

    /**
    Well-known color: MediumSpringGreen
    */
    @property 
    {
        public static Color MediumSpringGreen() { return Color.fromUInt(cast(uint)KnownColor.MediumSpringGreen); }
    }


    /**
    Well-known color: MediumTurquoise
    */
    @property 
    {
        public static Color MediumTurquoise() { return Color.fromUInt(cast(uint)KnownColor.MediumTurquoise); }
    }

    /**
    Well-known color: MediumVioletRed
    */
    @property 
    {
        public static Color MediumVioletRed() { return Color.fromUInt(cast(uint)KnownColor.MediumVioletRed); }
    }

    /**
    Well-known color: MidnightBlue
    */
    @property 
    {
        public static Color MidnightBlue() { return Color.fromUInt(cast(uint)KnownColor.MidnightBlue); }
    }

    /**
    Well-known color: MintCream
    */
    @property 
    {
        public static Color MintCream() { return Color.fromUInt(cast(uint)KnownColor.MintCream); }
    }

    /**
    Well-known color: MistyRose
    */
    @property 
    {
        public static Color MistyRose() { return Color.fromUInt(cast(uint)KnownColor.MistyRose); }
    }

    /**
    Well-known color: Moccasin
    */
    @property 
    {
        public static Color Moccasin() { return Color.fromUInt(cast(uint)KnownColor.Moccasin); }
    }

    /**
    Well-known color: NavajoWhite
    */
    @property 
    {
        public static Color NavajoWhite() { return Color.fromUInt(cast(uint)KnownColor.NavajoWhite); }
    }

    /**
    Well-known color: Navy
    */
    @property 
    {
        public static Color Navy() { return Color.fromUInt(cast(uint)KnownColor.Navy); }
    }

    /**
    Well-known color: OldLace
    */
    @property 
    {
        public static Color OldLace() { return Color.fromUInt(cast(uint)KnownColor.OldLace); }
    }

    /**
    Well-known color: Olive
    */
    @property 
    {
        public static Color Olive() { return Color.fromUInt(cast(uint)KnownColor.Olive); }
    }


    /**
    Well-known color: OliveDrab
    */
    @property 
    {
        public static Color OliveDrab() { return Color.fromUInt(cast(uint)KnownColor.OliveDrab); }
    }

    /**
    Well-known color: Orange
    */
    @property 
    {
        public static Color Orange() { return Color.fromUInt(cast(uint)KnownColor.Orange); }
    }

    /**
    Well-known color: OrangeRed
    */
    @property 
    {
        public static Color OrangeRed() { return Color.fromUInt(cast(uint)KnownColor.OrangeRed); }
    }

    /**
    Well-known color: Orchid
    */
    @property 
    {
        public static Color Orchid() { return Color.fromUInt(cast(uint)KnownColor.Orchid); }
    }

    /**
    Well-known color: PaleGoldenrod
    */
    @property 
    {
        public static Color PaleGoldenrod() { return Color.fromUInt(cast(uint)KnownColor.PaleGoldenrod); }
    }

    /**
    Well-known color: PaleGreen
    */
    @property 
    {
        public static Color PaleGreen() { return Color.fromUInt(cast(uint)KnownColor.PaleGreen); }
    }

    /**
    Well-known color: PaleTurquoise
    */
    @property 
    {
        public static Color PaleTurquoise() { return Color.fromUInt(cast(uint)KnownColor.PaleTurquoise); }
    }

    /**
    Well-known color: PaleVioletRed
    */
    @property 
    {
        public static Color PaleVioletRed() { return Color.fromUInt(cast(uint)KnownColor.PaleVioletRed); }
    }

    /**
    Well-known color: PapayaWhip
    */
    @property 
    {
        public static Color PapayaWhip() { return Color.fromUInt(cast(uint)KnownColor.PapayaWhip); }
    }

    /**
    Well-known color: PeachPuff
    */
    @property 
    {
        public static Color PeachPuff() { return Color.fromUInt(cast(uint)KnownColor.PeachPuff); }
    }


    /**
    Well-known color: Peru
    */
    @property 
    {
        public static Color Peru() { return Color.fromUInt(cast(uint)KnownColor.Peru); }
    }

    /**
    Well-known color: Pink
    */
    @property 
    {
        public static Color Pink() { return Color.fromUInt(cast(uint)KnownColor.Pink); }
    }

    /**
    Well-known color: Plum
    */
    @property 
    {
        public static Color Plum() { return Color.fromUInt(cast(uint)KnownColor.Plum); }
    }

    /**
    Well-known color: PowderBlue
    */
    @property 
    {
        public static Color PowderBlue() { return Color.fromUInt(cast(uint)KnownColor.PowderBlue); }
    }

    /**
    Well-known color: Purple
    */
    @property 
    {
        public static Color Purple() { return Color.fromUInt(cast(uint)KnownColor.Purple); }
    }

    /**
    Well-known color: Red
    */
    @property 
    {
        public static Color Red() { return Color.fromUInt(cast(uint)KnownColor.Red); }
    }

    /**
    Well-known color: RosyBrown
    */
    @property 
    {
        public static Color RosyBrown() { return Color.fromUInt(cast(uint)KnownColor.RosyBrown); }
    }

    /**
    Well-known color: RoyalBlue
    */
    @property 
    {
        public static Color RoyalBlue() { return Color.fromUInt(cast(uint)KnownColor.RoyalBlue); }
    }

    /**
    Well-known color: SaddleBrown
    */
    @property 
    {
        public static Color SaddleBrown() { return Color.fromUInt(cast(uint)KnownColor.SaddleBrown); }
    }

    /**
    Well-known color: Salmon
    */
    @property 
    {
        public static Color Salmon() { return Color.fromUInt(cast(uint)KnownColor.Salmon); }
    }


    /**
    Well-known color: SandyBrown
    */
    @property 
    {
        public static Color SandyBrown() { return Color.fromUInt(cast(uint)KnownColor.SandyBrown); }
    }

    /**
    Well-known color: SeaGreen
    */
    @property 
    {
        public static Color SeaGreen() { return Color.fromUInt(cast(uint)KnownColor.SeaGreen); }
    }

    /**
    Well-known color: SeaShell
    */
    @property 
    {
        public static Color SeaShell() { return Color.fromUInt(cast(uint)KnownColor.SeaShell); }
    }

    /**
    Well-known color: Sienna
    */
    @property 
    {
        public static Color Sienna() { return Color.fromUInt(cast(uint)KnownColor.Sienna); }
    }

    /**
    Well-known color: Silver
    */
    @property 
    {
        public static Color Silver() { return Color.fromUInt(cast(uint)KnownColor.Silver); }
    }

    /**
    Well-known color: SkyBlue
    */
    @property 
    {
        public static Color SkyBlue() { return Color.fromUInt(cast(uint)KnownColor.SkyBlue); }
    }

    /**
    Well-known color: SlateBlue
    */
    @property 
    {
        public static Color SlateBlue() { return Color.fromUInt(cast(uint)KnownColor.SlateBlue); }
    }

    /**
    Well-known color: SlateGray
    */
    @property 
    {
        public static Color SlateGray() { return Color.fromUInt(cast(uint)KnownColor.SlateGray); }
    }

    /**
    Well-known color: Snow
    */
    @property 
    {
        public static Color Snow() { return Color.fromUInt(cast(uint)KnownColor.Snow); }
    }

    /**
    Well-known color: SpringGreen
    */
    @property 
    {
        public static Color SpringGreen() { return Color.fromUInt(cast(uint)KnownColor.SpringGreen); }
    }


    /**
    Well-known color: SteelBlue
    */
    @property 
    {
        public static Color SteelBlue() { return Color.fromUInt(cast(uint)KnownColor.SteelBlue); }
    }

    /**
    Well-known color: Tan
    */
    @property 
    {
        public static Color Tan() { return Color.fromUInt(cast(uint)KnownColor.Tan); }
    }

    /**
    Well-known color: Teal
    */
    @property 
    {
        public static Color Teal() { return Color.fromUInt(cast(uint)KnownColor.Teal); }
    }

    /**
    Well-known color: Thistle
    */
    @property 
    {
        public static Color Thistle() { return Color.fromUInt(cast(uint)KnownColor.Thistle); }
    }

    /**
    Well-known color: Tomato
    */
    @property 
    {
        public static Color Tomato() { return Color.fromUInt(cast(uint)KnownColor.Tomato); }
    }

    /**
    Well-known color: Transparent
    */
    @property 
    {
        public static Color Transparent() { return Color.fromUInt(cast(uint)KnownColor.Transparent); }
    }

    /**
    Well-known color: Turquoise
    */
    @property 
    {
        public static Color Turquoise() { return Color.fromUInt(cast(uint)KnownColor.Turquoise); }
    }

    /**
    Well-known color: Violet
    */
    @property 
    {
        public static Color Violet() { return Color.fromUInt(cast(uint)KnownColor.Violet); }
    }

    /**
    Well-known color: Wheat
    */
    @property 
    {
        public static Color Wheat() { return Color.fromUInt(cast(uint)KnownColor.Wheat); }
    }

    /**
    Well-known color: White
    */
    @property 
    {
        public static Color White() { return Color.fromUInt(cast(uint)KnownColor.White); }
    }


    /**
    Well-known color: WhiteSmoke
    */
    @property 
    {
        public static Color WhiteSmoke() { return Color.fromUInt(cast(uint)KnownColor.WhiteSmoke); }
    }

    /**
    Well-known color: Yellow
    */
    @property 
    {
        public static Color Yellow() { return Color.fromUInt(cast(uint)KnownColor.Yellow); }
    }

    /**
    Well-known color: YellowGreen
    */
    @property 
    {
        public static Color YellowGreen() { return Color.fromUInt(cast(uint)KnownColor.YellowGreen); }
    }



    /// Enum containing handles to all known colors
    /// Since the first element is 0, second is 1, etc, we can use this to index
    /// directly into an array
    enum KnownColor : uint
    {
        // We've reserved the value "1" as unknown.  If for some odd reason "1" is added to the
        // list, redefined UnknownColor

        AliceBlue = 0xFFF0F8FF,
        AntiqueWhite = 0xFFFAEBD7,
        Aqua = 0xFF00FFFF,
        Aquamarine = 0xFF7FFFD4,
        Azure = 0xFFF0FFFF,
        Beige = 0xFFF5F5DC,
        Bisque = 0xFFFFE4C4,
        Black = 0xFF000000,
        BlanchedAlmond = 0xFFFFEBCD,
        Blue = 0xFF0000FF,
        BlueViolet = 0xFF8A2BE2,
        Brown = 0xFFA52A2A,
        BurlyWood = 0xFFDEB887,
        CadetBlue = 0xFF5F9EA0,
        Chartreuse = 0xFF7FFF00,
        Chocolate = 0xFFD2691E,
        Coral = 0xFFFF7F50,
        CornflowerBlue = 0xFF6495ED,
        Cornsilk = 0xFFFFF8DC,
        Crimson = 0xFFDC143C,
        Cyan = 0xFF00FFFF,
        DarkBlue = 0xFF00008B,
        DarkCyan = 0xFF008B8B,
        DarkGoldenrod = 0xFFB8860B,
        DarkGray = 0xFFA9A9A9,
        DarkGreen = 0xFF006400,
        DarkKhaki = 0xFFBDB76B,
        DarkMagenta = 0xFF8B008B,
        DarkOliveGreen = 0xFF556B2F,
        DarkOrange = 0xFFFF8C00,
        DarkOrchid = 0xFF9932CC,
        DarkRed = 0xFF8B0000,
        DarkSalmon = 0xFFE9967A,
        DarkSeaGreen = 0xFF8FBC8F,
        DarkSlateBlue = 0xFF483D8B,
        DarkSlateGray = 0xFF2F4F4F,
        DarkTurquoise = 0xFF00CED1,
        DarkViolet = 0xFF9400D3,
        DeepPink = 0xFFFF1493,
        DeepSkyBlue = 0xFF00BFFF,
        DimGray = 0xFF696969,
        DodgerBlue = 0xFF1E90FF,
        Firebrick = 0xFFB22222,
        FloralWhite = 0xFFFFFAF0,
        ForestGreen = 0xFF228B22,
        Fuchsia = 0xFFFF00FF,
        Gainsboro = 0xFFDCDCDC,
        GhostWhite = 0xFFF8F8FF,
        Gold = 0xFFFFD700,
        Goldenrod = 0xFFDAA520,
        Gray = 0xFF808080,
        Green = 0xFF008000,
        GreenYellow = 0xFFADFF2F,
        Honeydew = 0xFFF0FFF0,
        HotPink = 0xFFFF69B4,
        IndianRed = 0xFFCD5C5C,
        Indigo = 0xFF4B0082,
        Ivory = 0xFFFFFFF0,
        Khaki = 0xFFF0E68C,
        Lavender = 0xFFE6E6FA,
        LavenderBlush = 0xFFFFF0F5,
        LawnGreen = 0xFF7CFC00,
        LemonChiffon = 0xFFFFFACD,
        LightBlue = 0xFFADD8E6,
        LightCoral = 0xFFF08080,
        LightCyan = 0xFFE0FFFF,
        LightGoldenrodYellow = 0xFFFAFAD2,
        LightGreen = 0xFF90EE90,
        LightGray = 0xFFD3D3D3,
        LightPink = 0xFFFFB6C1,
        LightSalmon = 0xFFFFA07A,
        LightSeaGreen = 0xFF20B2AA,
        LightSkyBlue = 0xFF87CEFA,
        LightSlateGray = 0xFF778899,
        LightSteelBlue = 0xFFB0C4DE,
        LightYellow = 0xFFFFFFE0,
        Lime = 0xFF00FF00,
        LimeGreen = 0xFF32CD32,
        Linen = 0xFFFAF0E6,
        Magenta = 0xFFFF00FF,
        Maroon = 0xFF800000,
        MediumAquamarine = 0xFF66CDAA,
        MediumBlue = 0xFF0000CD,
        MediumOrchid = 0xFFBA55D3,
        MediumPurple = 0xFF9370DB,
        MediumSeaGreen = 0xFF3CB371,
        MediumSlateBlue = 0xFF7B68EE,
        MediumSpringGreen = 0xFF00FA9A,
        MediumTurquoise = 0xFF48D1CC,
        MediumVioletRed = 0xFFC71585,
        MidnightBlue = 0xFF191970,
        MintCream = 0xFFF5FFFA,
        MistyRose = 0xFFFFE4E1,
        Moccasin = 0xFFFFE4B5,
        NavajoWhite = 0xFFFFDEAD,
        Navy = 0xFF000080,
        OldLace = 0xFFFDF5E6,
        Olive = 0xFF808000,
        OliveDrab = 0xFF6B8E23,
        Orange = 0xFFFFA500,
        OrangeRed = 0xFFFF4500,
        Orchid = 0xFFDA70D6,
        PaleGoldenrod = 0xFFEEE8AA,
        PaleGreen = 0xFF98FB98,
        PaleTurquoise = 0xFFAFEEEE,
        PaleVioletRed = 0xFFDB7093,
        PapayaWhip = 0xFFFFEFD5,
        PeachPuff = 0xFFFFDAB9,
        Peru = 0xFFCD853F,
        Pink = 0xFFFFC0CB,
        Plum = 0xFFDDA0DD,
        PowderBlue = 0xFFB0E0E6,
        Purple = 0xFF800080,
        Red = 0xFFFF0000,
        RosyBrown = 0xFFBC8F8F,
        RoyalBlue = 0xFF4169E1,
        SaddleBrown = 0xFF8B4513,
        Salmon = 0xFFFA8072,
        SandyBrown = 0xFFF4A460,
        SeaGreen = 0xFF2E8B57,
        SeaShell = 0xFFFFF5EE,
        Sienna = 0xFFA0522D,
        Silver = 0xFFC0C0C0,
        SkyBlue = 0xFF87CEEB,
        SlateBlue = 0xFF6A5ACD,
        SlateGray = 0xFF708090,
        Snow = 0xFFFFFAFA,
        SpringGreen = 0xFF00FF7F,
        SteelBlue = 0xFF4682B4,
        Tan = 0xFFD2B48C,
        Teal = 0xFF008080,
        Thistle = 0xFFD8BFD8,
        Tomato = 0xFFFF6347,
        Transparent = 0x00FFFFFF,
        Turquoise = 0xFF40E0D0,
        Violet = 0xFFEE82EE,
        Wheat = 0xFFF5DEB3,
        White = 0xFFFFFFFF,
        WhiteSmoke = 0xFFF5F5F5,
        Yellow = 0xFFFFFF00,
        YellowGreen = 0xFF9ACD32,
        UnknownColor = 0x00000001
    }
}


/**
The Hue in the HSI coordinate system defines a plane that it is a triangle in the RGB
cube. But the maximum saturation in this triangle is different for each Hue because 
of the geometry of the cube. In ColorBrowser this point is fixed at the center of the
I axis. So the I axis is not completely linear, it is linear in two parts, one from 0
to 0.5, and another from 0.5 to 1.0. Although the selected values are linear specified 
you can notice that when Hue is changed the gray scale also changes, visually compacting
values above or below the I=0.5 line according to the selected Hue.

the color is in the "h s i" format; h, s and i are floating
point numbers ranging from 0-360, 0-1 and 0-1 respectively. 
*/
struct HsiColor 
{
    float H;
    float S;
    float I;

    static HsiColor parse(string color, char seperator = ' ')
    {
        //if(color.empty) 
        //    return Colors.Black;

        string c = color;
        string[] parts = split(c, seperator);
        float h, s, i;

        h = to!float(parts[0]);
        s = to!float(parts[1]);
        i = to!float(parts[2]);

        return HsiColor(h, s, i);
    }

    string toString(char seperator = ' ')
    {
        return std.format.format("%f%c%f%c%f", this.H, seperator, this.S, seperator, this.I);
    }
}