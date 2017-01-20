module iup.slider;

import iup.control;
import iup.core;

import iup.c.core;
import iup.c.api;

import toolkit.event;

import std.string;

/**
Creates a Valuator control. Selects a value in a limited interval. Also known as Scale or Trackbar in native systems.
*/
public class IupSlider : IupStandardControl
{
    protected class IupCallbacks : super.IupCallbacks
    {
        //enum ButtonPress = "BUTTON_PRESS_CB";
        //enum ButtonRelease = "BUTTON_RELEASE_CB";
        //enum MouseMove = "MOUSEMOVE_CB";
		enum ValueChanged = "VALUECHANGED_CB";
    }


	class IupAttributes : super.IupAttributes
	{
        enum IupSlider = "IupSlider";
        enum Inverted = "INVERTED";
        enum Max = "MAX";
        enum Min = "MIN";
        enum Orientation = "ORIENTATION";
        enum PageStep   = "PAGESTEP";
        enum Showticks = "SHOWTICKS";
        enum Step   = "STEP";
        enum TicksPos = "TICKSPOS";
	}


	this()
	{
        m_maximum = 1.0;
        m_pageStep = 0.1;
        m_step = 0.01;
		super();
	}


	this(Orientation orientation)
	{
        m_maximum = 1.0;
        m_pageStep = 0.1;
        m_step = 0.01;
		super();
        this.orientation = orientation;
	}


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupVal(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        //registerButtonPressCallback(IupCallbacks.ButtonPress);
        //registerButtonReleaseCallback(IupCallbacks.ButtonRelease);
        //registerMouseMoveCallback(IupCallbacks.MouseMove);

        registerValueChangedCallback(IupCallbacks.ValueChanged);
    }


    /* ************* Events *************** */

    /// Called after the value was interactively changed by the user.
    mixin EventCallback!(IupSlider, "valueChanged");

    // The old callbacks are still supported but called only if the VALUECHANGED_CB callback is not defined. 

    ///**
    //The BUTTON_PRESS_CB callback is called only when the user press a key that changes the position of the handler. 
    //*/
    //mixin EventCallback!(IupSlider, "buttonPress", double);
    //
    ///**
    //The BUTTON_RELEASE_CB callback is called only when the user release the mouse button after moving the handler.
    //*/
    //mixin EventCallback!(IupSlider, "buttonRelease", double);
    //
    ///**
    //The MOUSEMOVE_CB callback is only called when the user moves the handler using the mouse. 
    //*/
    //mixin EventCallback!(IupSlider, "mouseMove", double);


    /* ************* Properties *************** */

    /**
    Invert the minimum and maximum positions on screen. When INVERTED=YES maximum is at top 
    and left (minimum is bottom and right), when INVERTED=NO maximum is at bottom and right 
    (minimum is top and left). The initial value depends on ORIENTATION passed as parameter 
    on creation, if ORIENTATION=VERTICAL default is YES, if ORIENTATION=HORIZONTAL default 
    is NO. (since 3.0)
    */
    @property 
	{
		public bool isInverted()  { return getAttribute(IupAttributes.Inverted) == FlagIdentifiers.Yes; }
        public void isInverted(bool value)  { 
            setAttribute(IupAttributes.Inverted, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    */
    @property 
    {
        public double maximum() { return m_maximum; }

        public void maximum(double value) 
        {
            m_maximum = value;
            setDoubleAttribute(IupAttributes.Max, value);
        }
        private double m_maximum; 
    }

    /**
    */
    @property 
    {
        public double minimum() { return m_minimum; }

        public void minimum(double value) 
        {
            m_minimum = value;
            setDoubleAttribute(IupAttributes.Min, value);
        }
        private double m_minimum; 
    }

    /**
    Informs whether the valuator is "VERTICAL" or "HORIZONTAL". Vertical valuators are bottom to up, and horizontal 
    valuators are left to right variations of min to max (but can be inverted using INVERTED). Default: "HORIZONTAL".
    */
    @property 
	{
		public Orientation orientation() { 
            string s = getAttribute(IupAttributes.Orientation); 
            return OrientationIdentifiers.convert(s);
        }

		public void orientation(Orientation value) {
			setAttribute(IupAttributes.Orientation, OrientationIdentifiers.convert(value));
		}
	}

    /**
    Controls the increment for pagedown and pageup keys. It is not the size of the increment. 
    The increment size is "pagestep*(max-min)", so it must be 0<pagestep<1. Default is "0.1".
    */
    @property 
    {
        public double pageStep() { return m_pageStep; }

        public void pageStep(double value) 
        {
            m_pageStep = value;
            setDoubleAttribute(IupAttributes.PageStep, value);
        }
        private double m_pageStep; 
    }

    /**
    Controls the increment for keyboard control and the mouse wheel. It is not the size of the increment. 
    The increment size is "step*(max-min)", so it must be 0<step<1. Default is "0.01".
    */
    @property 
    {
        public double step() { return getDoubleAttribute(IupAttributes.Step); }

        public void step(double value) 
        {
            m_step = value;
            setDoubleAttribute(IupAttributes.Step, value);
        }
        private double m_step; 
    }

    /**
    The number of tick marks along the valuator trail. Minimum value is "2". Default is "0", 
    in this case the ticks are not shown. It can not be changed to 0 from a non zero value, 
    or vice-versa, after the control is mapped. GTK does not support ticks.
    */
    @property 
	{
		public int tickNumber()  {  return getIntAttribute(IupAttributes.Showticks); }
        public void tickNumber(int value) { setIntAttribute(IupAttributes.Showticks, value);}
	}

    /**
    Allows to position the ticks in both sides (BOTH) or in the reverse side (REVERSE).
    Default: NORMAL. The normal position for horizontal orientation is at the top of the 
    control, and for vertical orientation is at the left of the control. In Motif, the ticks
    position is always normal. (since 3.0)
    */
    @property 
	{
		public TickPosition tickPosition()  {  
            string v = getAttribute(IupAttributes.TicksPos); 
            return TickPositionIdentifiers.convert(v);
        }

        public void tickPosition(TickPosition value) { 
            setAttribute(IupAttributes.TicksPos, TickPositionIdentifiers.convert(value));
        }
	}

    /**
    Contains a number between MIN and MAX, indicating the valuator position. Default: "0.0".
    */
    @property 
	{
		public double value()  {  return getDoubleAttribute(IupAttributes.Value); }
        public void value(double v) { setDoubleAttribute(IupAttributes.Value, v);}
	}


    struct TickPositionIdentifiers
    {
        enum Normal = "BOTH";
        enum Reverse = "REVERSE";
        enum Both = "NORMAL";


        static string convert(TickPosition pos)
        {
            switch(pos)
            {
                case TickPosition.Normal:
                    return TickPositionIdentifiers.Normal;

                case TickPosition.Reverse:
                    return TickPositionIdentifiers.Reverse;

                case TickPosition.Both:
                    return TickPositionIdentifiers.Both;

                default:
                    assert(0, "Not support");
            }
        }

        static TickPosition convert(string pos)
        {
            switch(pos)
            {
                case TickPositionIdentifiers.Normal:
                    return TickPosition.Normal;

                case TickPositionIdentifiers.Reverse:
                    return TickPosition.Reverse;

                case TickPositionIdentifiers.Both:
                    return TickPosition.Both;

                default:
                    assert(0, "Not support");
            }
        }
    }

}

alias IupVal = IupSlider;
alias IupTrackbar = IupSlider;

enum TickPosition
{
    Normal,
    Reverse,
    Both
}