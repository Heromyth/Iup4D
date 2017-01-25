module iup.datetime;


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
public class IupDatePicker : IupStandardControl
{

	protected class IupAttributes : super.IupAttributes
	{
        enum IupDatePick = "IupDatePick";
        enum CalendarWeekNumbers = "CALENDARWEEKNUMBERS";
        enum Format = "FORMAT";
        enum MonthShortNames = "MONTHSHORTNAMES";
        enum Order = "ORDER";
        enum Separator   = "SEPARATOR";
        enum Today = "TODAY";
        enum ZeroPreced   = "ZEROPRECED";
	}

    protected class IupCallbacks : super.IupCallbacks
    {
		enum ValueChanged = "VALUECHANGED_CB";
    }


	this()
	{
        super();
    }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupDatePick();
	}

    protected override void onCreated()
    {    
        super.onCreated();
        registerValueChangedCallback(IupCallbacks.ValueChanged);
    }

    /* ************* Events *************** */

    mixin EventCallback!(IupDatePicker, "valueChanged");


    /* ************* Properties *************** */

    /**
    Day and month numbers will be preceded by a zero. Must be set before ORDER in Windows. Default: No.
    */
    @property 
	{
		public bool isZeroPreceded()  { return getAttribute(IupAttributes.ZeroPreced) == FlagIdentifiers.Yes; }
        public void isZeroPreceded(bool value)  { 
            setAttribute(IupAttributes.ZeroPreced, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    version(Windows)
    {
        /**
        Flexible format for the date in Windows. For more information see "About Date and Time Picker Control" 
        in the Windows SDK. The Windows control was configured to display date only without any time options. 
        Default: "d'/'M'/'yyyy". See Noted bellow.
        */
        @property 
        {
            public string format()  {  return getAttribute(IupAttributes.Format); }
            public void format(string value) { setAttribute(IupAttributes.Format, value);}
        }
    }

    /**
    Shows the number of the week along the year in the calendar. Default: NO.
    */
    @property 
	{
		public bool hasWeekNumbers ()  { return getAttribute(IupAttributes.CalendarWeekNumbers) == FlagIdentifiers.Yes; }
        public void hasWeekNumbers (bool value)  { 
            setAttribute(IupAttributes.CalendarWeekNumbers, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Day, month and year order. Can be any combination of "D", "M" and "Y" without repetition, 
    and with all three letters. It will set the FORMAT attribute in Windows. It will NOT affect 
    the VALUE attribute order. Default: "DMY". 
    */
    @property 
	{
		public string order()  {  return getAttribute(IupAttributes.Order); }
        public void order(string value) { setAttribute(IupAttributes.Order, value);}
	}

    /**
    Separator between day, month and year. Must be set before ORDER in Windows. Default: "/".
    */
    @property 
	{
		public string separator ()  {  return getAttribute(IupAttributes.Separator); }
        public void separator (string value) { setAttribute(IupAttributes.Separator, value);}
	}

    /**
    Returns the date corresponding to today in VALUE format.
    */
    @property 
	{
		public string today()  {  return getAttribute(IupAttributes.Today); }
	}

    version(Windows)
    {
        /**
        Month display will use a short name instead of numbers. Must be set before ORDER. Default: NO. 
        Names will be in the language of the system.
        */
        @property 
        {
            public bool useShortName ()  { return getAttribute(IupAttributes.MonthShortNames) == FlagIdentifiers.Yes; }
            public void useShortName (bool value)  { 
                setAttribute(IupAttributes.MonthShortNames, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

    /**
    the current date always in the format "year/month/day" ("%d/%d/%d" in C). Can be set to "TODAY". 
    Default value is the today date.
    */
    @property 
	{
		public string value()  {  return getAttribute(IupAttributes.Value); }
        public void value(string v) { setAttribute(IupAttributes.Value, v);}
	}

}


/**
Creates a month calendar interface element, where the user can select a date.

GTK and Windows only. NOT available in Motif.
*/
public class IupCalendar : IupStandardControl
{

	class IupAttributes : super.IupAttributes
	{
        enum IupCalendar = "IupCalendar";
        enum WeekNumbers = "WEEKNUMBERS";
        enum Today = "TODAY";
	}

    class IupCallbacks : super.IupCallbacks
    {
		enum ValueChanged = "VALUECHANGED_CB";
    }

	this() { super(); }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupCalendar();
	}

    protected override void onCreated()
    {    
        super.onCreated();
        registerValueChangedCallback(IupCallbacks.ValueChanged);
    }

    /* ************* Events *************** */

    mixin EventCallback!(IupCalendar, "valueChanged");


    /* ************* Properties *************** */

    /**
    Shows the number of the week along the year. Default: NO.
    */
    @property 
    {
        public bool showWeekNumbers ()  {
            return getAttribute(IupAttributes.WeekNumbers) == FlagIdentifiers.Yes; 
        }

        public void showWeekNumbers (bool value)  { 
            setAttribute(IupAttributes.WeekNumbers, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Returns the date corresponding to today in VALUE format.
    */
    @property 
	{
		public string today()  {  return getAttribute(IupAttributes.Today); }
	}

    /**
    the current date always in the format "year/month/day" ("%d/%d/%d" in C). Can be set to "TODAY". 
    Default value is the today date.
    */
    @property 
	{
		public string value()  {  return getAttribute(IupAttributes.Value); }
        public void value(string v) { setAttribute(IupAttributes.Value, v);}
	}
}