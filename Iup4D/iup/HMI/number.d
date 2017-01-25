module iup.HMI.number;

import iup.canvas;
import iup.control;
import iup.core;

import iup.c;

import std.string;


/**
Creates a dial for regulating a given angular variable. 

This is an additional control that depends on the CD library. It is included in the 
IupControls library.

When the keyboard arrows are pressed and released the mouse press and the mouse release
callbacks are called in this order. If you hold the key down the mouse move callback is
also called for every repetition.

When the wheel is rotated only the mouse move callback is called, and it increments the 
last angle the dial was rotated.

In all cases the value is incremented or decremented by PI/10 (18 degrees). 

If you press Shift while using the arrow keys the increment is reduced to PI/100 (1.8 
degrees). Press the Home key in the circular dial to reset to 0. 
*/
public class IupDial : IupCanvasBase
{
	class IupAttributes : super.IupAttributes
	{
        enum IupDial = "IupDial";
        enum Density = "DENSITY";
        enum Orientation = "ORIENTATION";
        enum Unit = "UNIT";
	}

    class IupCallbacks : super.IupCallbacks
    {
		enum ButtonPress = "BUTTON_PRESS_CB";
		enum ButtonRelease = "BUTTON_RELEASE_CB";
		enum MouseMove = "MOUSEMOVE_CB";
		enum ValueChanged = "VALUECHANGED_CB";
    }

	this() { super(); }

	this(DialLayoutOrientation orientation) 
    { 
        super(); 
        this.orientation = orientation;
    }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.IupDial(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerMouseDownCallback(IupCallbacks.ButtonPress);
        registerMouseUpCallback(IupCallbacks.ButtonRelease);
        registerMouseMoveCallback(IupCallbacks.MouseMove);
        //registerValueChangedCallback(IupCallbacks.ValueChanged);
    }


    /* ************* Events *************** */

    /**
    Called when the user presses the left mouse button over the dial. The angle here 
    is always zero, except for the circular dial.

    angle: the dial value converted according to UNIT.
    */
    mixin EventCallback!(IupDial, "mouseDown", double);

    /**
    Called when the user releases the left mouse button after pressing it over the dial.

    angle: the dial value converted according to UNIT.
    */
    mixin EventCallback!(IupDial, "mouseUp", double);

    /**
    Called each time the user moves the dial with the mouse button pressed. The angle the 
    dial rotated since it was initialized is passed as a parameter.

    angle: the dial value converted according to UNIT.
    */
    mixin EventCallback!(IupDial, "mouseMove", double);

    /**
    Called after the value was interactively changed by the user. It is called whenever a 
    BUTTON_PRESS_CB, a BUTTON_RELEASE_CB or a MOUSEMOVE_CB would also be called, but if 
    defined those callbacks will not be called.
    */
    //mixin EventCallback!(IupDial, "valueChanged");


    /* ************* Properties *************** */

    /**
    number of lines per pixel in the handle of the dial. Default is "0.2".
    */
    @property 
	{
		public float density()  {  return getFloatAttribute(IupAttributes.Density); }
        public void density(float value) { setFloatAttribute(IupAttributes.Density, value);}
	}

    /**
    dial layout configuration "VERTICAL", "HORIZONTAL" or "CIRCULAR". Default: "HORIZONTAL".
    */
    @property 
	{
		public DialLayoutOrientation orientation()  {  
            string v = getAttribute(IupAttributes.Orientation); 
            return DialLayoutOrientationIdentifiers.convert(v);
        }

        public void orientation(DialLayoutOrientation v) { 
            setAttribute(IupAttributes.Orientation, DialLayoutOrientationIdentifiers.convert(v));
        }
	}

    /**
    unit of the angle. Can be "DEGREES" or "RADIANS". Default is "RADIANS". Used only in the callbacks.
    */
    @property 
	{
		public IupAngleUnit unit()  {  
            string v = getAttribute(IupAttributes.Unit); 
            return IupAngleUnitIdentifiers.convert(v);
        }

        public void unit(IupAngleUnit v) { 
            setAttribute(IupAttributes.Unit, IupAngleUnitIdentifiers.convert(v));
        }
	}
}



/**
*/
enum DialLayoutOrientation
{
    Horizontal,
    Vertical,
    Circular
}

/// ditto
struct DialLayoutOrientationIdentifiers
{
	enum Horizontal  =	"HORIZONTAL";
	enum Vertical  =	"VERTICAL";
	enum Circular  =	"CIRCULAR";

    static DialLayoutOrientation convert(string id)
    {
        switch(id)
        {
            case Horizontal:
                return DialLayoutOrientation.Horizontal;

            case Vertical:
                return DialLayoutOrientation.Vertical;

            case Circular:
                return DialLayoutOrientation.Circular;

            default:
                assert(0,"Identifier is Not supported: " ~ id);
        }
    }

    static string convert(DialLayoutOrientation d)
    {
        final switch(d)
        {
            case DialLayoutOrientation.Horizontal:
                return Horizontal;

            case DialLayoutOrientation.Vertical:
                return Vertical;

            case DialLayoutOrientation.Circular:
                return Circular;
        }
    }
}


/**
*/
enum IupAngleUnit
{
    Degrees,
    Radians
}

/// ditto
struct IupAngleUnitIdentifiers
{
	enum Degrees  =	"DEGREES";
	enum Radians  =	"RADIANS";

    static IupAngleUnit convert(string id)
    {
        switch(id)
        {
            case Degrees:
                return IupAngleUnit.Degrees;

            case Radians:
                return IupAngleUnit.Radians;

            default:
                assert(0,"Identifier is Not supported: " ~ id);
        }
    }

    static string convert(IupAngleUnit d)
    {
        final switch(d)
        {
            case IupAngleUnit.Degrees:
                return Degrees;

            case IupAngleUnit.Radians:
                return Radians;
        }
    }
}
