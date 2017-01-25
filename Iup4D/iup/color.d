module iup.color;

import iup.canvas;
import iup.control;
import iup.core;

import iup.c;

import std.string;

import toolkit.drawing;


/**
Creates an element for selecting a color. The selection is done using a cylindrical 
projection of the RGB cube. The transformation defines a coordinate color system 
called HSI, that is still the RGB color space but using cylindrical coordinates.

This is an additional control that depends on the CD library. It is included in the 
IupControls library.

For a dialog that simply returns the selected color, you can use function IupGetColor or IupColorDlg.
*/
public class IupColorBrowser : IupCanvasBase
{
	class IupAttributes : super.IupAttributes
	{
        enum IupColorBrowser = "IupColorBrowser";
        enum RGB = "RGB";
        enum HSI = "HSI";
	}

    class IupCallbacks : super.IupCallbacks
    {
		enum Change = "CHANGE_CB";
		enum Drag = "DRAG_CB";
		enum ValueChanged = "VALUECHANGED_CB";
    }

	this() { super(); }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.IupColorBrowser();
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerMouseUpCallback(IupCallbacks.Change);
        registerMouseMoveCallback(IupCallbacks.Drag);
        registerValueChangedCallback(IupCallbacks.ValueChanged);
    }


    /* ************* Events *************** */

    /**
    Called when the user releases the left mouse button over the control, defining the 
    selected color.

    r, g, b: color value.
    */
    mixin EventCallback!(IupColorBrowser, "mouseUp", ubyte, ubyte, ubyte);

    /**
    Called several times while the color is being changed by dragging the mouse over 
    the control.

    r, g, b: color value.
    */
    mixin EventCallback!(IupColorBrowser, "mouseMove", ubyte, ubyte, ubyte);

    /**
    Called after the value was interactively changed by the user. It is called whenever
    a CHANGE_CB or a DRAG_CB would also be called, it is just  called after them. 
    */
    mixin EventCallback!(IupColorBrowser, "valueChanged");


    /* ************* Properties *************** */

    /**
    the color selected in the control, in the "r g b" format; r, g and b are integers 
    ranging from 0 to 255. Default: "255 0 0".
    */
    @property 
	{
        Color rgb()  {  
            string c = getAttribute(IupAttributes.RGB);
            return Color.parse(c);
        }

        void rgb(Color value) { 
            setAttribute(IupAttributes.RGB, value.toRgb());
        }

        void rgb(string value) { 
            setAttribute(IupAttributes.RGB, value);
        }
	}

    /**
    the color selected in the control, in the "h s i" format; h, s and i are floating
    point numbers ranging from 0-360, 0-1 and 0-1 respectively. 
    */
    @property 
	{
        HsiColor hsi()  {  
            string c = getAttribute(IupAttributes.HSI);
            return HsiColor.parse(c);
        }

        void hsi(HsiColor value) { 
            setAttribute(IupAttributes.HSI, value.toString());
        }

        void hsi(string value) { 
            setAttribute(IupAttributes.HSI, value);
        }
	}
}

