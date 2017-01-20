module iup.thread;


import iup.control;
import iup.core;

import iup.c.core;
import iup.c.api;

import std.string;

/**
Creates a timer which periodically invokes a callback when the time is up. 
Each timer should be destroyed using IupDestroy.
*/
public class IupTimer : IupDisposableObject
{
	protected class IupCallbacks 
	{
        enum Action = "ACTION_CB";
	}

	protected class IupAttributes : super.IupAttributes
	{
        enum IupTimer = "IupTimer";
        enum Run = "RUN";
        enum Time = "TIME";
	}

    this()
    {
        super();
    }

    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupTimer();
	}

    protected override void onCreated()
    {    
        super.onCreated();
        registerTickCallback(IupCallbacks.Action);
    }   

    /* ************* Events *************** */

    /**
    Called every time the defined time interval is reached. To stop the callback from being called 
    simply stop de timer with RUN=NO. Inside the callback the attribute ELAPSEDTIME returns the 
    time elapsed since the timer was started (since 3.15).
    */
    mixin EventCallback!(IupTimer, "tick");

    /* ************* Properties *************** */


    /**
    */
    @property 
	{
        public bool enabled() { return getAttribute(IupAttributes.Run) == FlagIdentifiers.Yes; }

        public void enabled(bool value)  {
            setAttribute(IupAttributes.Run, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    The time interval in milliseconds. In Windows the minimum value is 10ms.
    */
    @property 
	{
		public int interval()  {  return getIntAttribute(IupAttributes.Time); }
        public void interval(int value) { setIntAttribute(IupAttributes.Time, value);}
	}



    /* ************* Public methods *************** */
    void start()
    {
        setAttribute(IupAttributes.Run, FlagIdentifiers.Yes);
    }

    void stop()
    {
        setAttribute(IupAttributes.Run, FlagIdentifiers.No);
    }

}
