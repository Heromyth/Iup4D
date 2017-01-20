module iup.image;

import iup.c.core;
import iup.c.api;
import iup.c.image;
import im;

import iup.core;

import std.string;
import std.format;
import std.conv;

import toolkit.drawing;


public class IupImage : IupDisposableObject
{

	protected class IupAttributes
	{
		enum IupImage =       "IupImage";
		enum AutoScale =       "AUTOSCALE";
		enum BgColor =       "BGCOLOR";
		enum BPP =       "BPP";
		enum Channels =       "CHANNELS";
		enum Height =       "HEIGHT";
		enum HotSpot =       "HOTSPOT";
		enum RasterSize =       "RASTERSIZE";
		enum Width =       "WIDTH";
	}

    private string fileName;
    private ImImage imImage;

    /**
    Vector containing the value of each pixel. IupImage uses 1 value per pixel, IupImageRGB uses 3 values 
    and  IupImageRGBA uses 4 values per pixel. Each value is always 8 bit. Origin is at the top-left 
    corner and data is oriented top to bottom, and left to right. The pixels array is duplicated 
    internally so you can discard it after the call.
    */
    protected const(ubyte)[] pixels;
    /// ditto
    protected int m_width, m_height;


    this()
    {
        super();
    }


    //~this()
    //{
    //    dispose();  // BUG? Access violation
    //}

    /**
    Functions to load/save an IupImage from/to a file using the IM library. The function can load or save the formats: BMP, 
    JPEG, GIF, TIFF, PNG, PNM, PCX, ICO and others. For more information about the IM library see http://www.tecgraf.puc-rio.br/im.
    */
	static IupImage create(string fileName)
    {
        IupImage image = new IupImage();
        image.handle = iup.c.image.IupLoadImage(std.string.toStringz(fileName));
        return image;
    }

    static IupImage create(ImImage imImage)
    {
        IupImage image = new IupImage();
        image.handle = iup.c.image.IupImageFromImImage(imImage.image);
        return image;
    }


    /* ************* Protected methods *************** */

    override protected Ihandle* createIupObject()
	{
        return null;
	}


    /* ************* Properties *************** */

    /**
    */
	@property 
	{
		public string title(){ return m_title; }
		public void title(string value) { m_title = value; }
        private string m_title; 
	}


    /**
    The color used for transparency. If not defined uses the BGCOLOR of the control that contains the image.
    */
    @property 
    {
        Color background() { 
            string c = getAttribute(IupAttributes.BgColor);
            // string c= "#FF0080";
            ubyte ri, gi, bi;
            if(c[0] == '#')
            {
                string hex = c[1..3];
                ri = to!ubyte(hex, 16);
                hex = c[3..5];
                gi = to!ubyte(hex, 16);
                hex = c[5..7];
                bi = to!ubyte(hex, 16);
            }
            else
                formattedRead(c, "%d %d %d", &ri, &gi, &bi);

            return Color.fromRgb(ri, gi, bi); 
        }
    }

    /**
    returns the number of channels in the image. Images created with IupImage returns 1, 
    with IupImageRGB returns 3 and with IupImageRGBA returns 4. (since 3.0)
    */
    @property 
	{
		public int channelNumber() { return getIntAttribute(IupAttributes.Channels); }
	}

    /**
    returns the number of bits per pixel in the image. Images created with IupImage returns 8, 
    with IupImageRGB returns 24 and with IupImageRGBA returns 32. (since 3.0)
    */
    @property 
	{
		public int bpp() { return getIntAttribute(IupAttributes.BPP); }
	}

    /**
    Image height in pixels.
    */
    @property 
	{
		public int height() { return getIntAttribute(IupAttributes.Height); }
	}

    /**
    Hotspot is the position inside a cursor image indicating the mouse-click spot. 
    Its value is given by the x and y coordinates inside a cursor image. Its value
    has the format "x:y", where x and y are integers defining the coordinates in 
    pixels. Default: "0:0".
    */
    @property 
	{
		public Point!int hotspot() 
        { 
            string s = getAttribute(IupAttributes.HotSpot);
            Point!int p;
            std.format.formattedRead(s, "%d:%d", &p.x, &p.y);
            return p; 
        }

        public void hotspot(Point!int p) 
        { 
            string s =  std.format.format("%d:%d", p.x, p.y);
            setAttribute(IupAttributes.HotSpot, s);
        }
	}

    /**
    returns the image size in pixels.
    */
    @property 
	{
		public Size rasterSize() 
        { 
            string s = getAttribute(IupAttributes.RasterSize);
            return IupSize.parse(s); 
        }
	}

    /**
    Image width in pixels.
    */
    @property 
	{
		public int width() { return getIntAttribute(IupAttributes.Width); }
	}
}


/**
IupImage uses 1 value per pixel. Each value is always 8 bit. 
*/
public class IupImage8 : IupImage
{

    /**
    The pixels array is duplicated internally so you can discard it after the call.
    */
    this(int width, int height,  const(ubyte)[] pixels)
    {
        assert(pixels.length == width*height, "Bad image format");

        this.m_width = width;
        this.m_height = height;
        this.pixels = pixels;
        this.title = "Untitled";
        //this.name = name;
        super();
    }

    override protected Ihandle* createIupObject()
	{
        return iup.c.api.IupImage(m_width, m_height, pixels.ptr); 
	}



    /**
    The indices can range from 0 to 255. The total number of colors is limited to 256 colors. 
    Notice that in Lua the first index in the array is "1", the index "0" is ignored in IupLua.
    Be careful when setting colors, since they are attributes they follow the same storage 
    rules for standard attributes.
    */
    void setColor(int index, Color color)
    {
        assert(index>=0 && index<=255, "Out of range");
        string s = color.toString();
        setAttribute(to!string(index), color.toRgb()); 
    }

    void useBackground(int index)
    {
        setAttribute(to!string(index), "BGCOLOR"); 
    }
}


/**
IupImageRGB uses 3 values. Each value is always 8 bit.  
*/
public class IupImage24 : IupImage
{

    /**
    The pixels array is duplicated internally so you can discard it after the call.
    */
    this(int width, int height,  const(ubyte)[] pixels)
    {
        assert(pixels.length == width*height*3, "Bad image format");

        this.m_width = width;
        this.m_height = height;
        this.pixels = pixels;
        this.title = "Untitled";
        //this.name = name;
        super();
    }

    override protected Ihandle* createIupObject()
	{
        return iup.c.api.IupImageRGB(m_width, m_height, pixels.ptr); 
	}
}


/**
IupImageRGBA uses 4 values per pixel. Each value is always 8 bit. 
*/
public class IupImage32 : IupImage
{

    /**
    The pixels array is duplicated internally so you can discard it after the call.
    */
    this(int width, int height,  const(ubyte)[] pixels)
    {
        assert(pixels.length == width*height*4, "Bad image format");

        this.m_width = width;
        this.m_height = height;
        this.pixels = pixels;
        this.title = "Untitled";
        super();
    }

    override protected Ihandle* createIupObject()
	{
        return iup.c.api.IupImageRGBA(m_width, m_height, pixels.ptr); 
	}
}
