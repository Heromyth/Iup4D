module cd.canvas;

import cd.c.core;
import cd.c.driver;

import toolkit.drawing;

import iup.canvas;
import iup.core;
import std.string;


/**
*/
enum ContextDriver
{

    // Window-Base Drivers
    /// IUP Canvas 
    IUP,

    /// IUP Canvas 
    IupDBuffer,

    /// IUP Canvas 
    IupDBufferRGB,

    /// Native Window 
    NativeWindow,

    /// Native Window 
    GL,

    /// Clipboard
    Clipboard,

    // Device-Based Drivers
    /// Printer 
    Printer,

    /// Picture in memory 
    Picture,

    // Image-Based Drivers
    /// Server-Image Drawing 
    Image,

    /// Client-Image Drawing 
    ImageRGB,

    /// Offscreen Drawing 
    DBuffer,

    /// Client Offscreen Drawing 
    DBufferRGB,

    // File-Based Drivers  
    /// Adobe Portable Document Format
    PDF,

    /// PostScript File 
    PS,

    /// Scalable Vector Graphics 
    SVG,

    /// Internal CD Metafile 
    Metafile,

    /// Internal CD Debug Log 
    Debug,

    /// Computer Graphics Metafile ISO 
    CGM,

    /// MicroStation Design File 
    DGN,

    /// AutoCad Drawing Interchange File 
    DXF,

    /// Microsoft Windows Enhanced Metafile.Works only in MS Windows systems. 
    EMF,

    /// Microsoft Windows Metafile. Works only in MS Windows systems. 
    WMF
}



/**
The canvas represents the drawing surface. It could be anything: a file, a client area inside
a window in a Window System, a paper used by a printer, etc. Each canvas has its own attributes. 
*/
public class CanvasBase 
{
    static cdContext*[ContextDriver] contextDrivers;

    /**
    */
	@property 
	{
		public cdCanvas *  handle(){ return m_handle; }
		protected void handle(cdCanvas * value) { m_handle = value;}
        private cdCanvas * m_handle;
	}

    protected ContextDriver driver;

    protected this()
    {
    }

    //this(ContextDriver driver, void *data)
    //{
    //    this.driver = driver;
    //    handle = cdCreateCanvas(contextDrivers[driver], data);
    //}

    static this()
    {
        // TODO:
        contextDrivers[ContextDriver.IUP] = CD_IUP;
        contextDrivers[ContextDriver.IupDBuffer] = CD_IUPDBUFFER;
        contextDrivers[ContextDriver.IupDBufferRGB] = CD_IUPDBUFFERRGB;
        contextDrivers[ContextDriver.NativeWindow] = CD_NATIVEWINDOW;
        contextDrivers[ContextDriver.GL] = CD_GL;
        contextDrivers[ContextDriver.Clipboard] = CD_CLIPBOARD;
        contextDrivers[ContextDriver.Printer] = CD_PRINTER;
        contextDrivers[ContextDriver.Picture] = CD_PICTURE;
        contextDrivers[ContextDriver.Image] = CD_IMAGE;
        contextDrivers[ContextDriver.ImageRGB] = CD_IMAGERGB;
        contextDrivers[ContextDriver.DBuffer] = CD_DBUFFER;
        contextDrivers[ContextDriver.DBufferRGB] = CD_DBUFFERRGB;
        contextDrivers[ContextDriver.PDF] = CD_PDF;
        contextDrivers[ContextDriver.PS] = CD_PS;
        contextDrivers[ContextDriver.SVG] = CD_SVG;
        contextDrivers[ContextDriver.Metafile] = CD_METAFILE;
        contextDrivers[ContextDriver.Debug] = CD_DEBUG;
        contextDrivers[ContextDriver.CGM] = CD_CGM;
        contextDrivers[ContextDriver.DGN] = CD_DGN;
        contextDrivers[ContextDriver.DXF] = CD_DXF;
        contextDrivers[ContextDriver.EMF] = CD_EMF;
        contextDrivers[ContextDriver.WMF] = CD_WMF;
    }


    /* ************* Properties *************** */


    ///
    @property bool isValid() { return handle !is null;}

    /**
    Configures a new current foreground color and returns the previous one. This
    color is used in all primitives (lines, areas, marks and text). 
    Default value: CD_BLACK. Value CD_QUERY simply returns the current value.
    */
    @property 
    {
        public Color foreground() { 
            uint hex =cast(uint)cdCanvasBackground(handle, CD_QUERY);
            return Color.fromUInt(hex); 
        }

        public void foreground(Color value)  { cdCanvasSetForeground(handle, encodeColor(value)); }
    }

    /**
    Configures the new current background color and returns the previous one. 
    However, it does not automatically change the background of a canvas. For 
    such, it is necessary to call the Clear function. The background color 
    only makes sense for Clear and for primitives affected by the background 
    opacity attribute. Default value: CD_WHITE. Value CD_QUERY simply returns 
    the current value.
    */
    @property 
    {
        public Color background() { 
            uint hex =cast(uint)cdCanvasForeground(handle, CD_QUERY);
            return Color.fromUInt(hex); 
        }

        public void background(Color value)  { cdCanvasSetBackground(handle, encodeColor(value)); }
    }


    /**
    Selects a text font. The font type can be one of the standard type faces or other driver dependent type face. 
    Since font face names are not a standard between drivers, a few names are specially handled to improve application 
    portability. If you want to use names that work for all systems we recommend using: "Courier", "Times" and "Helvetica".

    The style can be a combination of: CD_PLAIN, CD_BOLD, CD_ITALIC, CD_UNDERLINE or CD_STRIKEOUT. Only the Windows and 
    PDF drivers support underline and strikeout. The size is provided in points (1/72 inch) or in pixels (using negative values). 

    Default values: "System", CD_PLAIN, 12. 
    */
    @property 
    {
        Font font() { 
            char[128] buffer;
            int style =  CD_PLAIN;
            int size;
            cdCanvasGetFont(handle, buffer.ptr, &style, &size);
            Font f = new Font(cast(string)fromStringz(buffer.ptr).idup,
                              FontStyle(cast(ubyte)style), size);
            return f;

        }

        void font(Font f)  { 
            cdCanvasFont(handle, std.string.toStringz(f.name), f.style.value, f.size); 
        }
    }

    /**
    Configures the width of the current line (in pixels). Returns the previous value. Default value: 1.
    Valid width interval: >= 1.
    */
    @property 
    {
        int lineWidth() { return cdCanvasLineWidth(handle, CD_QUERY); }
        void lineWidth(int value)  { cdCanvasLineWidth(handle, value); }
    }

    /**
    Configures the current line style for: CD_CONTINUOUS, CD_DASHED, CD_DOTTED, CD_DASH_DOT, CD_DASH_DOT_DOT,
    or CD_CUSTOM. Returns the previous value. Default value: CD_CONTINUOUS. Value CD_QUERY simply returns 
    the current value. When CD_CUSTOM is used the cdLineStyleDahes function must be called before to initialize
    the custom dashes. The spaces are drawn with the background color, except when back opacity is transparent 
    then the background is left unchanged.
    */
    @property 
    {
        LineStyle lineStyle() { return cast(LineStyle)cdCanvasLineStyle(handle, CD_QUERY); }
        void lineStyle(LineStyle value)  { cdCanvasLineStyle(handle, cast(int)value); }
    }

    /**
    Selects a font based on a string description. The description can depend on the driver and the platform, 
    but a common definition is available for all drivers. It does not need to be stored by the application, 
    as it is internally replicated by the library. The string is case sensitive. It returns the previous string. 

    The string is parsed and the font typeface, style and size are set according to the parsed values, as if 
    cdCanvasFont was called. The native font string is cleared when a font is set using cdCanvasFont.
    */
    @property 
    {
        string nativeFont() { 
            char* font = cdCanvasNativeFont(handle, cast(char*)CD_QUERY);
            return std.string.fromStringz(font).idup; 
        }

        void nativeFont(string value)  { cdCanvasNativeFont(handle, std.string.toStringz(value)); }
    }

    /**
    */
    @property 
    {
        WriteMode writeMode() { return cast(WriteMode)cdCanvasWriteMode(handle, CD_QUERY); }
        void writeMode(WriteMode value)  { cdCanvasWriteMode(handle, cast(int)value); }
    }

    /**
    Defines the vertical and horizontal alignment of a text 
    */
    @property 
    {
        TextAlignment textAlignment() { return cast(TextAlignment)cdCanvasTextAlignment(handle, CD_QUERY); }
        void textAlignment(TextAlignment value)  { cdCanvasTextAlignment(handle, cast(int)value); }
    }

    /**
    Defines the text orientation, which is an angle provided in degrees relative to the horizontal 
    line according to which the text is drawn. The default value is 0.
    */
    @property 
    {
        double textOrientation() { return cdCanvasTextOrientation(handle, CD_QUERY); }
        void textOrientation(double angle)  { cdCanvasTextOrientation(handle, angle); }
    }

    /* ************* Public methods *************** */

    void activate() { cdCanvasActivate(handle); }

    void clear() { cdCanvasClear(handle); }

    void getSize(out int width, out int height, out double width_mm, out double height_mm)
    {
        cdCanvasGetSize(handle, &width, &height, &width_mm, &height_mm);
    }

    /**
    Returns the maximum width of a character, the line's height, the ascent and descent of the characters of the currently selected font.
    The line's height is the sum of the ascent and descent of a given additional space (if this is the case). 
    All values are given in pixels and are positive. 
    */
    FontDimension getFontDimension()
    {
        FontDimension dim;
        cdCanvasGetFontDim(handle, &dim.width, &dim.height, &dim.ascent, &dim.descent);
        return dim;
    }

    /**
    Returns the text size independent from orientation.
    */
    Size getTextSize(string text)
    {
        Size size;
        cdCanvasGetTextSize(handle, std.string.toStringz(text), &size.width, &size.height);
        return size;
    }

    /**
    Returns the oriented bounding rectangle occupied by a text at a given position. The rectangle has the same 
    dimentions returned by GetTextSize. The rectangle corners are returned in counter-clock wise order starting 
    with the bottom left corner, arranged (x0,y0,x1,y1,x2,y2,x3,y3).
    */
    //Size getTextSize(string text)
    //{
    //    Size size;
    //    cdCanvasGetTextBounds(handle, std.string.toStringz(text), &size.width, &size.height);
    //    return size;
    //}


    /**
    Returns the horizontal bounding rectangle occupied by a text at a given position. If orientation is not 0 then
    its area is always larger than the area of the rectangle returned by GetTextBounds. 
    */
    //Size getTextSize(string text)
    //{
    //    Size size;
    //    cdCanvasGetTextBox(handle, std.string.toStringz(text), &size.width, &size.height);
    //    return size;
    //}


    void flush() {cdCanvasFlush(handle); }

    /**
    Puts, in a specified area of the canvas, an image with its red, green and blue components defined in the three matrices 
    stored in byte arrays. The (i,j) component of these matrices is at the address (j*iw+i). The pixel (0,0) is at the bottom 
    left corner, and the pixel (iw-1,ih-1) is that the upper right corner of the image rectangle. 
    Parameters w and h refer to the target rectangle of the canvas, so that it is possible to reduce or expand the image drawn. 
    If w and h are 0, the size of the image is assumed (iw and ih). 
    It also allows specifying a rectangle inside the image to be drawn, if xmin, xmax, ymin and ymax are 0 then the whole image is assumed. 
    */
    void putImageRectRGB(int iw, int ih, const(ubyte)[][] matrixData,
                          int x, int y, int w, int h, 
                          int xmin, int xmax, int ymin, int ymax)
    {
        assert(matrixData.length >= 3);
        cdCanvasPutImageRectRGB(handle, iw, ih, matrixData[0].ptr, matrixData[1].ptr, matrixData[2].ptr,
                                x, y, w, h, xmin, xmax, ymin, ymax);
    }

    /// ditto
    void putImageRectRGBA(int iw, int ih, const(ubyte)[][] matrixData,
                          int x, int y, int w, int h, 
                          int xmin, int xmax, int ymin, int ymax)
    {
        assert(matrixData.length >= 4);
        cdCanvasPutImageRectRGBA(handle, iw, ih, matrixData[0].ptr, matrixData[1].ptr, matrixData[2].ptr, matrixData[3].ptr,
                                 x, y, w, h, xmin, xmax, ymin, ymax);
    }

    void putImageRectMap(int iw, int ih, const(ubyte)[] linearData,
                          int x, int y, int w, int h, 
                          int xmin, int xmax, int ymin, int ymax)
    {
        //cdCanvasPutImageRectMap(handle, iw, ih, linearData.ptr,
        //                         x, y, w, h, xmin, xmax, ymin, ymax);
        assert(false, "TODO:");
    }

    void saveState()
    {
        auto state = cdCanvasSaveState(handle);
    }

    void dispose()
    {
        cdKillCanvas(handle);
    }


    /**
    Defines a transformation matrix with 6 elements. If the matrix is NULL (nil in Lua), 
    the transformation is reset to the identity. Default value: NULL.
    */
    void transform(const(double)[] matrix)
    {
        cdCanvasTransform(handle, matrix.ptr);
    }

    /**
    Applies a scale to the current transformation.
    */
    void transformScale(double sx, double sy)
    {
        cdCanvasTransformScale(handle, sx, sy);
    }

    /**
    Applies a translation to the current transformation.
    */
    void transformTranslate(double dx, double dy)
    {
        cdCanvasTransformTranslate(handle, dx, dy);
    }


    /* ************* Static methods *************** */

    static int encodeColor(Color c)
    {
        return cdEncodeColor(c.R, c.G, c.B);
    }

}


enum WriteMode
{
    Replace = CD_REPLACE,
    Xor =    CD_XOR,
    NotXor =     CD_NOT_XOR
}


enum TextAlignment
{
    North = CD_NORTH,
    South = CD_SOUTH,
    East = CD_EAST,
    West = CD_WEST,
    NorthEast = CD_NORTH_EAST,
    NorthWest = CD_NORTH_WEST,
    SouthEast = CD_SOUTH_EAST,
    SouthWest = CD_SOUTH_WEST,
    Center = CD_CENTER,
    BaseLeft = CD_BASE_LEFT,
    BaseCenter = CD_BASE_CENTER,
    BaseRight = CD_BASE_RIGHT
}

enum LineStyle
{
    Continuous = CD_CONTINUOUS,
    Dashed = CD_DASHED,
    Dotted = CD_DOTTED,
    DashDot = CD_DASH_DOT,
    DashDotDot = CD_DASH_DOT_DOT,
    Custom = CD_CUSTOM
}


struct FontDimension
{
    int width;
    int height;
    int ascent;
    int descent;
}


/**
*/
public class WdCanvas : CanvasBase
{
    this(CanvasBase canvas)
    {
        this.handle = canvas.handle;
    }


    /**
    Configures a window in the world coordinate system to be used to convert world coordinates
    (with values in real numbers) into canvas coordinates (with values in integers). The default
    window is the size in millimeters of the whole canvas.

    Queries the current window in the world coordinate system being used to convert world 
    coordinates into canvas coordinates (and the other way round). It is not necessary to provide
    all return pointers, you can provide only the desired values.
    */
    @property 
    {
        Rectangle!double window() {
            Rectangle!double r;
            wdCanvasGetWindow(handle, &r.x1, &r.x2, &r.y1, &r.y2);
            return r; 
        }

        void window(Rectangle!double r)  { 
            wdCanvasWindow(handle, r.x1, r.x2, r.y1, r.y2);
        }
    }

    /**
    Configures a viewport in the canvas coordinate system to be used to convert world 
    coordinates (with values in real numbers) into canvas coordinates (with values in 
    integers). The default viewport is the whole canvas (0,w-1,0,h-1). If the canvas 
    size is changed, the viewport will not be automatically updated. 

    Queries the current viewport in the world coordinate system being used to convert 
    world coordinates into canvas coordinates (and the other way round). It is not 
    necessary to provide all return pointers, you can provide only the desired values
    and NULL for the others.
    */
    @property 
    {
        Rectangle!int viewport() {
            Rectangle!int r;
            wdCanvasGetViewport(handle, &r.x1, &r.x2, &r.y1, &r.y2);
            return r; 
        }

        void viewport(Rectangle!int r)  { 
            wdCanvasViewport(handle, r.x1, r.x2, r.y1, r.y2);
        }
    }

    /**
    Draws the arc of an ellipse aligned with the axis, using the current foreground color and line width and style.

    The coordinate (xc,yc) defines the center of the ellipse. Dimensions w and h define 
    the elliptic axes X and Y, respectively. 
    */
    void drawArc(double xc, double yc, double w, double h, double angle1, double angle2)
    {
        wdCanvasArc(handle, xc, yc, w, h, angle1, angle2);
    }

    /**
    Fills a rectangle according to the current interior style. All points in the interval 
    x_min<=x<=x_max, y_min<=y<=y_max will be painted. When the interior style CD_HOLLOW is 
    defined, the function behaves like its equivalent cdRect.
    */
    void drawBox(Rectangle!double r)
    {
        wdCanvasBox(handle, r.x1, r.x2, r.y1, r.y2);
    }

    /**
    Line are segments that connects 2 or more points. The Line function includes the 2 given points and draws the line 
    using the foreground color. Line thickness is controlled by the LineWidth function. By using function LineStyle 
    you can draw dashed lines with some variations. Lines with a style other than continuous are affected by the back 
    opacity attribute and by the background color.

    Draws a line from (x1,y1) to (x2,y2) using the current foreground color and line width and style. Both points 
    are included in the line. 
    */   
    void drawLine(double x1, double y1, double x2, double y2)
    {
        wdCanvasLine(handle, x1, y1, x2, y2);
    }

    /**
    Draws a rectangle with no filling. All points in the limits of interval x_min<=x<=x_max, 
    y_min<=y<=y_max will be painted. It is affected by line attributes and the foreground color. 
    If the active driver does not include this primitive, it will be simulated using the cdLine primitive.
    */
    void drawRect(Rectangle!double r)
    {
        wdCanvasRect(handle, r.x1, r.x2, r.y1, r.y2);
    }

    /**
    Fills the arc of an ellipse aligned with the axis, according to the current interior 
    style, in the shape of a pie. 

    The coordinate (xc,yc) defines the center of the ellipse. Dimensions w and h define 
    the elliptic axes X and Y, respectively. 
    */
    void drawSector(double xc, double yc, double w, double h, double angle1, double angle2)
    {
        wdCanvasSector(handle, xc, yc, w, h, angle1, angle2);
    }

    /**
    A raster text using a font with styles. The position the text is drawn depends on the text alignment attribute. 
    */
    void drawText(double x, double y, string text)
    {
        wdCanvasText(handle, x, y, std.string.toStringz(text));
    }


    /// Vector Text

    /**
    Draws a vector text in position (x,y), respecting the alignment defined by cdTextAlignment. It ignores the configuration 
    cdBackOpacity, being always transparent. It accepts strings with multiple lines using '\n'. It is ESSENTIAL to call 
    cdVectorTextSize or cdVectorCharSize before using this function.

    The wdCanvasVectorText is the only function that actually depends on World Coordinates. The other Vector Text functions 
    although use the "wd" prefix they do not depend on World Coordinates. They are kept with these names for backward 
    compatibility. The correct prefix would be "cdf".
    */
    void drawVectorText(double x, double y, string text)
    {
        wdCanvasVectorText(handle, x, y, std.string.toStringz(text));
    }

    /**
    Defines the text direction by means of two points, (x1,y1) and (x2,y2). The default direction is horizontal from left to 
    right. It is independent from the transformation matrix.
    */
    void setVectorTextDirection(Point!double p1, Point!double p2)
    {
        wdCanvasVectorTextDirection(handle, p1.x, p1.y, p2.x, p2.y);
    }


}


/**
*/
public class CdCanvas : CanvasBase
{
    protected this()
    {
    }


    /**
    Draws the arc of an ellipse aligned with the axis, using the current foreground color and line width and style.

    The coordinate (xc,yc) defines the center of the ellipse. Dimensions w and h define 
    the elliptic axes X and Y, respectively. 
    */
    void drawArc(int xc, int yc, int w, int h, double angle1, double angle2)
    {
        cdCanvasArc(handle, xc, yc, w, h, angle1, angle2);
    }

    /**
    Fills a rectangle according to the current interior style. All points in the interval 
    x_min<=x<=x_max, y_min<=y<=y_max will be painted. When the interior style CD_HOLLOW is 
    defined, the function behaves like its equivalent cdRect.
    */
    void drawBox(int xmin, int xmax, int ymin, int ymax)
    {
        cdCanvasBox(handle, xmin, xmax, ymin, ymax);
    }

    /**
    Line are segments that connects 2 or more points. The Line function includes the 2 given points and draws the line 
    using the foreground color. Line thickness is controlled by the LineWidth function. By using function LineStyle 
    you can draw dashed lines with some variations. Lines with a style other than continuous are affected by the back 
    opacity attribute and by the background color.

    Draws a line from (x1,y1) to (x2,y2) using the current foreground color and line width and style. Both points 
    are included in the line. 
    */
    void drawLine(int x1, int y1, int x2, int y2)
    {
        cdCanvasLine(handle, x1, y1, x2, y2);
    }    

    /// ditto
    void drawLine(double x1, double y1, double x2, double y2)
    {
        cdfCanvasLine(handle, x1, y1, x2, y2);
    }

    /**
    Draws a rectangle with no filling. All points in the limits of interval x_min<=x<=x_max, 
    y_min<=y<=y_max will be painted. It is affected by line attributes and the foreground color. 
    If the active driver does not include this primitive, it will be simulated using the cdLine primitive.
    */
    void drawRect(Rectangle!int r)
    {
        cdCanvasRect(handle, r.x1, r.x2, r.y1, r.y2);
    }

    /// ditto
    void drawRect(Rectangle!double r)
    {
        cdfCanvasRect(handle, r.x1, r.x2, r.y1, r.y2);
    }

    /**
    Fills the arc of an ellipse aligned with the axis, according to the current interior 
    style, in the shape of a pie. 

    The coordinate (xc,yc) defines the center of the ellipse. Dimensions w and h define 
    the elliptic axes X and Y, respectively. 
    */
    void drawSector(int xc, int yc, int w, int h, double angle1, double angle2)
    {
        cdCanvasSector(handle, xc, yc, w, h, angle1, angle2);
    }

    /**
    A raster text using a font with styles. The position the text is drawn depends on the text alignment attribute. 
    */
    void drawText(int x, int y, string text)
    {
        cdCanvasText(handle, x, y, std.string.toStringz(text));
    }

    /// ditto
    void drawText(double x, double y, string text)
    {
        cdfCanvasText(handle, x, y, std.string.toStringz(text));
    }


    /// Vector Text

    /**
    Draws a vector text in position (x,y), respecting the alignment defined by cdTextAlignment. It ignores the configuration 
    cdBackOpacity, being always transparent. It accepts strings with multiple lines using '\n'. It is ESSENTIAL to call 
    cdVectorTextSize or cdVectorCharSize before using this function.

    The wdCanvasVectorText is the only function that actually depends on World Coordinates. The other Vector Text functions 
    although use the "wd" prefix they do not depend on World Coordinates. They are kept with these names for backward 
    compatibility. The correct prefix would be "cdf".
    */
    void drawVectorText(int x, int y, string text)
    {
        cdCanvasVectorText(handle, x, y, std.string.toStringz(text));
    }

    /**
    Defines the text direction by means of two points, (x1,y1) and (x2,y2). The default direction is horizontal from left to 
    right. It is independent from the transformation matrix.
    */
    void setVectorTextDirection(Point!int p1, Point!int p2)
    {
        cdCanvasVectorTextDirection(handle, p1.x, p1.y, p2.x, p2.y);
    }
}


/**
*/
public class IupCdCanvas : CdCanvas
{

    this(IupCanvas canvas)
    {
        this.driver = ContextDriver.IUP;
        handle = cdCreateCanvas(CD_IUP, canvas.handle);
    }
}


/**
The canvas is created by means of a call to the function cdCreateCanvas(CD_IMAGERGB, Data), 
after which other functions in the CD library can be called as usual. The function creates 
an RGB image, and then a CD canvas. 
*/
public class IupImageRgbCanvas : CdCanvas
{
     // Color color, 
    this(int width, int height, ubyte[][] imageData, double resolution )
    {
        this.driver = ContextDriver.ImageRGB;
        if(imageData.length == 4)
        {
            handle = cdCreateCanvasf(CD_IMAGERGB, "%dx%d %p %p %p %p -r%g -a", 
                                     width, height, imageData[0].ptr,  
                                     imageData[1].ptr, imageData[2].ptr,  imageData[3].ptr, resolution);
        }
        else
        {
            //string data = format("%dx%d 0%s 0%s 0%s -r%g\0", 
            //                  width, height, imageData[0].ptr, imageData[1].ptr, imageData[2].ptr, resolution);
            //
            //handle = cdCreateCanvas(CD_IMAGERGB, cast(void*)data.ptr);
            handle = cdCreateCanvasf(CD_IMAGERGB, "%dx%d %p %p %p -r%g", 
                                     width, height, cast(void*)imageData[0].ptr,  
                                     cast(void*)imageData[1].ptr, cast(void*)imageData[2].ptr, resolution);
        }

    }
}


/**
*/
public class IupDBufferCdCanvas : CdCanvas
{

    this(IupCanvas canvas)
    {
        this.driver = ContextDriver.IupDBuffer;
        handle = cdCreateCanvas(CD_IUPDBUFFER, canvas.handle);
    }
}


/**
*/
public class IupDBufferRgbCdCanvas : CdCanvas
{

    this(IupCanvas canvas)
    {
        this.driver = ContextDriver.IupDBufferRGB;
        handle = cdCreateCanvas(CD_IUPDBUFFERRGB, canvas.handle);
    }
}


/**
*/
public class PrinterCdCanvas : CdCanvas
{
    /**
    name is an optional document name that will appear in the printer queue. Optionally, -d displays the system pre-defined 
    printer dialog before starting to print, allowing you to configure the printer's parameters. When using this parameter 
    and the return canvas is NULL, one must assume that the print was canceled by the user.
    */
    this(string title, bool isDialogEnabled = true)
    {
        this.driver = ContextDriver.Printer;
        string data = title;
        if(isDialogEnabled)
            data = title ~ " -d\0";
        else
            data = title ~ "\0";

        handle = cdCreateCanvas(CD_PRINTER, cast(void*)data.ptr);
    }


}