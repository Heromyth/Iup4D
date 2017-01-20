module iup.label;

import iup.control;
import iup.core;
import iup.image;

import iup.c.core;
import iup.c.api;

import toolkit.event;

import std.string;

/**
Creates a label interface element, which displays a separator, a text or an image.
*/
public class IupLabel : IupStandardControl
{
	protected class IupCallbacks  : super.IupCallbacks
	{
		enum Button = "BUTTON_CB";
		enum Motion = "MOTION_CB";
        enum DropFiles = "DROPFILES_CB";
    }

	protected class IupAttributes : super.IupAttributes
	{
        enum IupLabel = "IupLabel";
        enum Alignment = "ALIGNMENT";
        enum Ellipsis = "ELLIPSIS";
        enum Image = "IMAGE";
        enum ImInactive = "IMINACTIVE";
        enum MarkUp = "MARKUP";
        enum WordWrap = "WORDWRAP";
	}

    this() { super(); }


	this(string title = "label")
	{
		super(title);
	}

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupLabel("");
	}

    protected override void onCreated()
    {    
        super.onCreated();
        registerMouseClickCallback(IupCallbacks.Button);
        registerMouseMoveCallback(IupCallbacks.Motion);
        registerFileDroppedCallback(IupCallbacks.DropFiles);
    }   


    /* ************* Events *************** */

    /**
    Action called when a file is "dropped" into the control. When several files are dropped at once, 
    the callback is called several times, once for each file. 
    If defined after the element is mapped then the attribute DROPFILESTARGET must be set to YES.

    filename: Name of the dropped file.
    num: Number index of the dropped file. If several files are dropped, 
    num is the index of the dropped file starting from "total-1" to "0".
    x: X coordinate of the point where the user released the mouse button.
    y: Y coordinate of the point where the user released the mouse button.

    Returns: If IUP_IGNORE is returned the callback will NOT be called for the next dropped files,
    and the processing of dropped files will be interrupted.
    */
    public EventHandler!(CallbackEventArgs, string, int, int, int)  fileDropped;
    mixin EventCallbackAdapter!(IupLabel, "fileDropped", const (char)*, int, int, int);

    private CallbackResult onFileDropped(const (char)* fileName, int num, int x, int y) nothrow
    {
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            fileDropped(this, callbackArgs, 
                        cast(string)std.string.fromStringz(fileName), num, x, y);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /**
    Action generated when a mouse button is pressed or released.
    */
    public EventHandler!(CallbackEventArgs, MouseButtons, MouseState, int, int, string)  mouseClick;
    mixin EventCallbackAdapter!(IupLabel, "mouseClick", int, int, int, int, const(char)*);
    private CallbackResult onMouseClick(int button, int pressed, int x, int y, const(char) *status) nothrow
    {       
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(status);

            mouseClick(this, callbackArgs, cast(MouseButtons)button, 
                       cast(MouseState)pressed, x, y, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /** 
    Action generated when the mouse moves.
    x, y: position in the canvas where the event has occurred, in pixels.
    status: status of mouse buttons and certain keyboard keys at the moment the event was generated. 
    The same macros used for BUTTON_CB can be used for this status.
    */
    public EventHandler!(CallbackEventArgs, int, int, string)  mouseMove;
    mixin EventCallbackAdapter!(IupLabel, "mouseMove", int, int, const(char)*);
    private CallbackResult onMouseMove(int x, int y, const(char) *status) nothrow
    {       
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(status);
            mouseMove(this, callbackArgs, x, y, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /* ************* Properties *************** */

    version(GTK) {
        /**
        allows the title string to contains pango markup commands. Works only if a mnemonic is 
        NOT defined in the title. Can be "YES" or "NO". Default: "NO". 
        */
        @property 
        {
            public bool canMarkup () { return getAttribute(IupAttributes.Markup) == FlagIdentifiers.Yes; }

            public void canMarkup (bool value) 
            {
                setAttribute(IupAttributes.Markup, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

    /**
    enables or disable the wrapping of lines that does not fits in the label. Can be 
    "YES" or "NO". Default: "NO". Can only set WORDWRAP=YES if ALIGNMENT=ALEFT. 
    */
    @property 
	{
		public bool canWordWrap() { return getAttribute(IupAttributes.WordWrap) == FlagIdentifiers.Yes; }

        public void canWordWrap(bool value) 
        {
            setAttribute(IupAttributes.WordWrap,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Add an ellipsis: "..." to the text if there is not enough space to render the entire string. 
    Can be "YES" or "NO". Default: "NO". 
    */
    @property 
	{
		public bool hasEllipsis() { return getAttribute(IupAttributes.Ellipsis) == FlagIdentifiers.Yes; }

        public void hasEllipsis(bool value) 
        {
            setAttribute(IupAttributes.Ellipsis,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Image name. If set before map defines the behavior of the label to contain an image. 
    The natural size will be size of the image in pixels.
    */
    @property 
    {
        public string image() { return getAttribute(IupAttributes.Image); }

        public void image(string value) 
        {
            setAttribute(IupAttributes.Image, value);
        }

        public void image(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.Image, value);
        }
    }


    /**
    Image name of the element when inactive. If it is not defined then the IMAGE is 
    used and the colors will be replaced by a modified version of the background color
    creating the disabled effect. GTK will also change the inactive image to look 
    like other inactive objects.
    */
    @property 
    {
        public string imageInactive() { return getAttribute(IupAttributes.ImInactive); }

        public void imageInactive(string value) 
        {
            setAttribute(IupAttributes.ImInactive, value);
        }

        public void imageInactive(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ImInactive, value);
        }
    }

    /**
    */
    @property 
    {
        public ContentAlignment textAlignment() { return m_textAlignment; }

        public void textAlignment(ContentAlignment value) 
        {
            m_textAlignment = value;
            setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
        }
        private ContentAlignment m_textAlignment; 
    }

}


public class IupSeparator : IupStandardControl
{

	protected class IupAttributes : super.IupAttributes
	{
        enum IupSeparator = "IupSeparator";
        enum Separator = "SEPARATOR";
	}

    this() { super(); }

    this(Orientation orientation)
    {
        super();
        this.orientation = orientation;
    }

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupLabel("");
	}


    /* ************* Properties *************** */

    /**
    Turns the label into a line separator. Possible values: "HORIZONTAL" or "VERTICAL". 
    When changed before mapping the EXPAND attribute is set to "HORIZONTALFREE" or 
    "VERTICALFREE" accordingly. (Since 3.11 changed to FREE based expand)
    */
    @property 
	{
		public Orientation orientation() { 
            string s = getAttribute(IupAttributes.Separator); 
            return OrientationIdentifiers.convert(s);
        }

		public void orientation(Orientation value) {
			setAttribute(IupAttributes.Separator, OrientationIdentifiers.convert(value));
		}
	}
}


/**
Creates an animated label interface element, which displays an image that is changed periodically.

It uses an animation that is simply an IupUser with several IupImage as children.
*/
public class IupAnimatedLabel : IupLabel
{
	protected class IupAttributes : super.IupAttributes
	{
        enum IupAnimatedLabel = "IupAnimatedLabel";
        enum Start = "START";
        enum Stop = "STOP";
        enum StopWhenHidden = "STOPWHENHIDDEN";
        enum Running = "RUNNING";
        enum FrameTtime = "FRAMETIME";
        enum FrameCount = "FRAMECOUNT";
        enum Animation = "ANIMATION";
        enum AnimationHandle = "ANIMATION_HANDLE";
	}

    this() { super(); }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupAnimatedLabel(null);
	}

    /* ************* Properties *************** */


    /**
    the name of the element that contains the list of images. The value passed must be the
    name of an IupUser element with several IupImage as children. Use IupSetHandle or 
    IupSetAttributeHandle to associate a child to a name. In Lua you can also use the 
    element reference directly. 
    */
    @property 
	{
		public string animation()  {  return getAttribute(IupAttributes.Animation); }
        public void animation(string value) { setAttribute(IupAttributes.Animation, value);}
	}

    /**
    automatically stops the animation when the label is hidden. Default: Yes.
    */
    @property 
	{
		public bool canStopOnHidden() { return getAttribute(IupAttributes.StopWhenHidden) == FlagIdentifiers.Yes; }

		public void canStopOnHidden(bool value) 
		{
            setAttribute(IupAttributes.StopWhenHidden, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    number of frames in the animation. It is simply IupGetChildCount of the given IupUser element.
    */
    @property 
	{
		public int frameCount()  {  return getIntAttribute(IupAttributes.FrameCount); }
	}

    /**
    The time between each frame. If the IupUser element has a FRAMETIME attribute it will be used to 
    set the IupAnimatedLabel FRAMETIME attribute, but it can be overwritten later on.
    */
    @property 
	{
		public int frameTime()  {  return getIntAttribute(IupAttributes.FrameTtime); }
        public void frameTime(int value) { setIntAttribute(IupAttributes.FrameTtime, value);}
	}

    /**
    return YES if the animation is running.
    */
    @property 
	{
		public bool isRunning() { return getAttribute(IupAttributes.Running) == FlagIdentifiers.Yes; }
	}



    /* ************* Public methods *************** */

    /**
    starts the animation. The value is ignored. By default the animation is stopped.
    */
    void start()
    {
        setAttribute(IupAttributes.Start, FlagIdentifiers.Yes);
    }

    /**
    stops the animation. The value is ignored.
    */
    void stop()
    {
        setAttribute(IupAttributes.Stop, FlagIdentifiers.Yes);
    }
}


/**
Creates a label that displays an underlined clickable text. It inherits from IupLabel. 
*/
public class IupLinkLabel : IupLabel
{
	protected class IupAttributes : super.IupAttributes
	{
        enum IupLinkLabel = "IupLinkLabel";
        enum Url = "URL";
	}

    this() { super(); }

	this(string url, string title)
	{
		super(title);
        this.url = url;
	}


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupLink(null, null);
	}

    protected override void onCreated()
    {    
        super.onCreated();
        registerLinkClickedCallback(IupCallbacks.Action);
    }

    /* ************* Properties *************** */

    /**
    the default value is "".
    */
    @property 
    {
        public string url() { return getAttribute(IupAttributes.Url); }

        public void url(string value) 
        {
            setAttribute(IupAttributes.Url, value);
        }
    }


    /* ************* Events *************** */

    /**
    Action generated when the link is activated.

    url: the destination address of the link.
    */
    EventHandler!(CallbackEventArgs, string)  linkClicked;
    mixin EventCallbackAdapter!(IupLinkLabel, "linkClicked", char*);
    private CallbackResult onLinkClicked(char *url) nothrow
    {       
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(url);
            linkClicked(this, callbackArgs, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }
}