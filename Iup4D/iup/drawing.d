module iup.drawing;

import iup.canvas;
import iup.core;
import iup.image;

import iup.c;

import toolkit.drawing;

import std.string;


/**
A group of functions to draw in a IupCanvas or a IupBackgroundBox. They are simple functions 
designed to help the drawing of custom controls based on these two controls. It is NOT a 
complete set of drawing functions, for that you should still use another toolkit like CD.

IMPORTANT: all functions can be used only in IupCanvas or IupBackgroundBox and inside the 
ACTION callback. To force a redraw anytime use the functions IupUpdate or IupRedraw.
*/
public class IupDraw
{
    private Ihandle * m_handle;

    this(IupObject obj)
    {
        attatchedObject = obj;
    }

    /* ************* Properties *************** */

    /**
    */
    @property 
    {
        public IupObject attatchedObject() { return m_attatchedObject; }

        protected void attatchedObject(IupObject value) 
        {
            m_attatchedObject = value;
            m_handle = value.handle;
        }
        private IupObject m_attatchedObject; 
    }


    /* ************* Public methods *************** */

    /**
    Initialize the drawing process.
    */
    void begin()
    {
        iup.c.api.IupDrawBegin(m_handle);
    }

    /**
    Terminates the drawing process.
    */
    void end()
    {
        iup.c.api.IupDrawEnd(m_handle);
    }

    /**
    Defines a rectangular clipping region.
    */
    void setClipRect(int x1, int y1, int x2, int y2)
    {
        iup.c.api.IupDrawSetClipRect(m_handle, x1, y1, x2, y2);
    }

    /**
    Reset the clipping area to none.
    */
    void resetClip()
    {
        iup.c.api.IupDrawResetClip(m_handle);
    }

    /**
    Fills the canvas with the native parent background color.
    */
    void useParentBackground()
    {
        iup.c.api.IupDrawParentBackground(m_handle);
    }

    /**
    Draws a line including start and end points.
    */
    void drawLine(int x1, int y1, int x2, int y2)
    {
        iup.c.api.IupDrawLine(m_handle, x1, y1, x2, y2);
    }

    /**
    Draws a rectangle including start and end points.
    */
    void drawRectangle(int x1, int y1, int x2, int y2)
    {
        iup.c.api.IupDrawRectangle(m_handle, x1, y1, x2, y2);
    }

    /**
    Draws an arc inside a rectangle between the two angles in degrees. When filled will 
    draw a pie shape with the vertex at the center of the rectangle.
    */
    void drawArc(int x1, int y1, int x2, int y2, double a1, double a2)
    {
        iup.c.api.IupDrawArc(m_handle, x1, y1, x2, y2, a1, a2);
    }

    /**
    Draws a polygon. Coordinates are stored in the array in the sequence: x1, y1, x2, y2, ...
    */
    void drawPolygon(Point!int[] points)
    {
        size_t count = points.length;
        int[] p = new int[count * 2];
        int j= 0;
        for(size_t i=0; i<count; i++)
        {
            p[j] = points[i].x;
            p[j+1] = points[i].y;
            j += 2;
        }
        iup.c.api.IupDrawPolygon(m_handle, p.ptr, cast(int)count);
    }

    /**
    Draws a text in the given position using the current FONT. The size of the string is 
    used only in C. Can be 0 so strlen is used internally. The coordinates are relative 
    the top-left corner of the text.
    */
    void drawText(string str, int x, int y)
    {
        iup.c.api.IupDrawText(m_handle, str.ptr, cast(int) str.length, x, y);
    }

    /**
    Draws an image given its name. The coordinates are relative the top-left corner of 
    the image. The image name follows the same behavior as the IMAGE attribute used by
    many controls. Use IupSetHandle or IupSetAttributeHandle to associate an image to 
    a name. See also IupImage. In Lua, the name parameter can be the actual image handle. 
    The make_inactive parameter will draw the same image in inactive state.
    */
    void drawImage(string name, int make_inactive, int x, int y)
    {
        iup.c.api.IupDrawImage(m_handle, std.string.toStringz(name), make_inactive, x, y);
    }

    /// ditto
    void drawImage(iup.image.IupImage image, int make_inactive, int x, int y)
    {
        IupSetHandle("DrawImage", image.handle);
        iup.c.api.IupDrawImage(m_handle, "DrawImage", make_inactive, x, y);
    }

    /**
    Draws a selection rectangle.
    */
    void drawSelectRect(int x1, int y1, int x2, int y2)
    {
        iup.c.api.IupDrawSelectRect(m_handle, x1, y1, x2, y2);
    }

    /**
    Draws a focus rectangle.
    */
    void drawFocusRect(int x1, int y1, int x2, int y2)
    {
        iup.c.api.IupDrawFocusRect(m_handle, x1, y1, x2, y2);
    }

    /**
    Returns the drawing area size. In C unwanted values can be NULL.
    */
    Size getSize()
    {
        int w, h;
        iup.c.api.IupDrawGetSize(m_handle, &w, &h);
        return Size(w, h);
    }

    /**
    Returns the given text size using the current FONT. In C unwanted values can be NULL.
    */
    Size getTextSize(string text)
    {
        Size s;
        iup.c.api.IupDrawGetTextSize(m_handle, std.string.toStringz(text), &s.width, &s.height);
        return s;
    }

    /**
    Returns the given image size and bits per pixel. bpp can be 8, 24 or 32.  
    In C unwanted values can be NULL.
    */
    ImageInfo getImageInfo(string name)
    {
        ImageInfo info = new ImageInfo();
        iup.c.api.IupDrawGetImageInfo(std.string.toStringz(name),
                                      &info.width, &info.height, &info.bpp);
        return info;
    }
}

