module iup.progression;

import iup.control;
import iup.core;

import iup.c.core;
import iup.c.api;

import toolkit.event;

import std.string;

/**
Creates a date editing interface element, which can displays a calendar for selecting a date.

In Windows is a native element. In GTK and Motif is a custom element. In Motif is not 
capable of displaying the calendar.
*/
public class IupProgressBar : IupStandardControl
{

	protected class IupAttributes : super.IupAttributes
	{
        enum IupProgressBar = "IupProgressBar";
        enum Dashed = "DASHED";
        enum Marquee = "MARQUEE";
        enum Max = "MAX";
        enum Min   = "MIN";
        enum Orientation = "ORIENTATION";
	}


	this()
	{
        super();
    }	
    
    this(Orientation orientation)
	{
		super();
        this.orientation = orientation;
	}


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupProgressBar();
	}

    protected override void onCreated()
    {    
        super.onCreated();
    }

    /* ************* Events *************** */



    /* ************* Properties *************** */

    /**
    */
    @property 
	{
		public bool isDashed()  { return getAttribute(IupAttributes.Dashed) == FlagIdentifiers.Yes; }
        public void isDashed(bool value)  { 
            setAttribute(IupAttributes.Dashed, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}


    /**
    displays an undefined state. Default: NO. You can set the attribute after map but 
    only to start or stop the animation. In Windows it will work only if using Visual Styles.
    (creation only)
    */
    @property 
	{
		public bool isMarqueeStyle()  { return getAttribute(IupAttributes.Marquee) == FlagIdentifiers.Yes; }

        public void isMarqueeStyle(bool value)  { 
            setAttribute(IupAttributes.Marquee, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}


    /**
    */
    @property 
    {
        public int maximum() { return getIntAttribute(IupAttributes.Max); }

        public void maximum(int value) 
        {
            setIntAttribute(IupAttributes.Max, value);
        }
    }

    /**
    */
    @property 
    {
        public int minimum() { return getIntAttribute(IupAttributes.Min); }

        public void minimum(int value) 
        {
            setIntAttribute(IupAttributes.Min, value);
        }
    }

    /**
    can be "VERTICAL" or "HORIZONTAL". Default: "HORIZONTAL". Horizontal goes from left to 
    right, and vertical from bottom to top.
    (creation only)
    */
    @property 
    {
        public Orientation orientation() { 
            string v = getAttribute(IupAttributes.Orientation); 
            return OrientationIdentifiers.convert(v);
        }

        public void orientation(Orientation value) {
            setAttribute(IupAttributes.Orientation, OrientationIdentifiers.convert(value));
        }
    }

    /**
    Contains a number between MIN and MAX, indicating the valuator position. Default: "0.0".
    */
    @property 
	{
		public int value()  {  return getIntAttribute(IupAttributes.Value); }
        public void value(int v) { setIntAttribute(IupAttributes.Value, v);}
	}

}