module iup.control;


import iup.c.core;
import iup.c.api;

import iup.core;

import std.string;
import std.conv;
import std.format;

import toolkit.drawing;



version(Windows)
{
	import std.windows.charset;
}


/**
*/
public class IupControl : IupElement
{

	protected class IupCallbacks  : super.IupCallbacks
	{
        enum EnterWindow = "ENTERWINDOW_CB";
        enum GetGocus = "GETFOCUS_CB";
        enum KillFocus = "KILLFOCUS_CB";
        enum LeaveWindow = "LEAVEWINDOW_CB";
        enum Tips = "TIPS_CB";
    }

	///
	class IupAttributes : super.IupAttributes
	{
        enum Background = "BACKGROUND";
        enum CanFocus = "CANFOCUS";
		enum CharSize =           "CHARSIZE";
        //enum Color =          "COLOR";
		enum Expand =  "EXPAND";
		enum ExpandWeight =  "EXPANDWEIGHT";
		enum Floating =         "FLOATING";
		enum FrameColor =     "FRAMECOLOR";
		enum Font =           "FONT";
		enum FontStyle =     "FONTSTYLE";
		enum FontSize =           "FONTSIZE";
		enum FontFace =           "FONTFACE";
		enum Foundry =           "FOUNDRY";
		enum MaxSize =           "MAXSIZE";
		enum MinSize =           "MINSIZE";
		enum RasterSize =     "RASTERSIZE";
		enum ScreenPosition =           "SCREENPOSITION";
		enum Size =           "SIZE";
		enum Wid =            "WID";
		enum Value =          "VALUE";
		enum Visible =        "VISIBLE";
	}

    this()
    {
        super();
    }

	this(string title)
    {
		super(title);
    }


    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();
        //registerAttribute!IupObject(this);
        m_tooltip = new IupTooltip(this);
        
        registerKeyPressCallback(IupCallbacks.Key);
        registerGotFocusCallback(IupCallbacks.GetGocus);
        registerLostFocusCallback(IupCallbacks.KillFocus);
        registerMouseEnterCallback(IupCallbacks.EnterWindow);
        registerMouseLeaveCallback(IupCallbacks.LeaveWindow);
        registerTipPopupCallback(IupCallbacks.Tips);
    }   


    /* ************* Events *************** */

    /**
    */
    mixin EventCallback!(IupControl, "keyPress", int);

    /**
    Action generated when an element is given keyboard focus. This callback is called after 
    the KILLFOCUS_CB of the element that loosed the focus. The IupGetFocus function during 
    the callback returns the element that loosed the focus.
    All elements with user interaction, except menus.
    */
    mixin EventCallback!(IupControl, "gotFocus");

    /**
    Action generated when an element loses keyboard focus. This callback is called before 
    the GETFOCUS_CB of the element that gets the focus.
    All elements with user interaction, except menus.

    In Windows, there are restrictions when using this callback. From MSDN on WM_KILLFOCUS: "While 
    processing this message, do not make any function calls that display or activate a window. 
    This causes the thread to yield control and can cause the application to stop responding to messages."
    */
    mixin EventCallback!(IupControl, "lostFocus");

    /**
    Action generated when the mouse enters the native element. 
    When the cursor is moved from one element to another, the call order in all platforms 
    will be first the LEAVEWINDOW_CB callback of the old control followed by the ENTERWINDOW_CB
    callback of the new control. (since 3.14) 
    */
    mixin EventCallback!(IupControl, "mouseEnter");

    /**
    Action generated when the mouse leaves the native element.
    When the cursor is moved from one element to another, the call order in all platforms 
    will be first the LEAVEWINDOW_CB callback of the old control followed by the ENTERWINDOW_CB 
    callback of the new control. (since 3.14)
    */
    mixin EventCallback!(IupControl, "mouseLeave");

    /**
    Action before a tip is displayed.
    x, y: cursor position relative to the top-left corner of the element
    */
    mixin EventCallback!(IupControl, "tipPopup", int, int);


    /* ************* Properties *************** */

    /**
    Dialog background color or image. Can be a non inheritable alternative to BGCOLOR or 
    can be the name of an image to be tiled on the background. See also the screenshots 
    of the sample.c results with normal background, changing the dialog BACKGROUND, the 
    dialog BGCOLOR and the children BGCOLOR. Not working in GTK 3. 
    */
    @property 
    {
        string backgroundImage() { 
            return getAttribute(IupAttributes.Background);
        }

        void backgroundImage(iup.image.IupImage image)  {
            setHandleAttribute(IupAttributes.Background, image);
        }

        void backgroundImage(string image)  {
            setAttribute(IupAttributes.Background, image);
        }
    }

    /**
    If User size is not defined, then when inside a IupHbox/IupGridBox EXPAND is HORIZONTAL, 
    when inside a IupVbox EXPAND is VERTICAL. If User size is defined then EXPAND is NO.
    */
    @property 
	{
		public bool canExpand() { return getAttribute(IupAttributes.Expand) == FlagIdentifiers.Yes; }

		public void canExpand(bool value) 
		{
            setAttribute(IupAttributes.Expand, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    enables the focus traversal of the control. In Windows the control will still get the 
    focus when clicked.  Default: YES. (since 3.0)
    */
    @property 
    {
        public bool canFocus() { return getAttribute(IupAttributes.CanFocus) == FlagIdentifiers.Yes; }

        public void canFocus(bool value) 
        {
            setAttribute(IupAttributes.CanFocus, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    If a child defines the expand weight, then it is used to multiply the free space used for expansion. (since 3.1) 
    */
    @property 
	{
		public float expandWeight()  {  return getFloatAttribute(IupAttributes.ExpandWeight); }
        public void expandWeight(float value) { setFloatAttribute(IupAttributes.ExpandWeight, value);}
	}

    /**
    Allows the element to expand, fulfilling empty spaces inside its container.
    */
    @property 
	{
		public ExpandOrientation expandOrientation() { 
            string s = getAttribute(IupAttributes.Expand);
            return ExpandOrientationIdentifiers.convert(s); 
        }

		public void expandOrientation(ExpandOrientation value) {
			setAttribute(IupAttributes.Expand, ExpandOrientationIdentifiers.convert(value));
		}
	}

    /**
    Character font of the text shown in the element. Although it is an inheritable attribute, 
    it is defined only on elements that have a native representation, but other elements are 
    affected because it affects the SIZE attribute.

    Font description containing typeface, style and size. Default: the global attribute DEFAULTFONT.

    The common format definition is similar to the the Pango library Font Description, used 
    by GTK+. It is defined as having 3 parts: "<font face>, <font styles> <font size>". 
    */
    @property 
	{
        public Font font() {
            string f = getAttribute(IupAttributes.Font);
            return Font.parse(f); 
        }

        public void font(Font value) { 
            setAttribute(IupAttributes.Font, value.toString());
        }

        public void font(string value) { setAttribute(IupAttributes.Font, value);}
	}


    /**
    Replaces or returns the face name of the current FONT attribute.
    */
    @property 
    {
        public string fontFace()  {  return getAttribute(IupAttributes.FontFace); }
        public void fontFace(string value) { setAttribute(IupAttributes.FontFace, value);}
    }

    /**
    Replaces or returns the size of the current FONT attribute.
    */
    @property 
	{
		public int fontSize()  {  return getIntAttribute(IupAttributes.FontSize); }
        public void fontSize(int value) { setIntAttribute(IupAttributes.FontSize, value);}
	}

    /**
    */
    @property 
    {
        public FontStyle fontStyle()  {  
            string s = getAttribute(IupAttributes.FontStyle); 
            return FontStyle.parse(s);
        }

        public void fontStyle(FontStyle value) { 
            setAttribute(IupAttributes.FontStyle, value.toString());
        }
    }


    /**
    Returns the absolute horizontal and/or vertical position of the top left corner of the 
    client area relative to the origin of the main screen in pixels. It is similar to POSITION
    but relative to the origin of the main screen, instead of the origin of the client area. 
    The origin of the main screen is at the upper left corner, in Windows it is affected by 
    the position of the Start Menu when it is at the top or left side of the screen. 

    For the dialog, it is the position of the top left corner of the window, NOT the client area. 
    It is the same position used in IupShowXY and IupPopup. In GTK, if the dialog is hidden the 
    values can be outdated.
    */
    @property 
	{
		public Point!int location()  
        {  
            string s = getAttribute(IupAttributes.ScreenPosition);
            Point!int p;
            std.format.formattedRead(s, "%d,%d", &p.x, &p.y);
            return p; 
        }

        public void location(Point!int value) 
        { 
            string s = std.format.format("%d,%d", value.x, value.y);
            setAttribute(IupAttributes.ScreenPosition, s);
        }
	}

    /**
    Specifies the element maximum size in pixels during the layout process.
    See the Layout Guide for more details on sizes.

    "widthxheight", where width and height are integer values corresponding to the horizontal
    and vertical size, respectively, in pixels.

    The limits are applied during the layout computation. It will limit the Natural size and
    the Current size. 

    If the element can be expanded, then its empty space will NOT be occupied by other controls
    although its size will be limited.
    */
    @property 
	{
		public Size maxSize() 
        { 
            string s = getAttribute(IupAttributes.MaxSize);
            return IupSize.parse(s); 
        }

		public void maxSize(Size value) {
			setAttribute(IupAttributes.MaxSize, IupSize.format(value));
		}
	}

    /**
    Specifies the element minimum size in pixels during the layout process.

    See the Layout Guide for more details on sizes.

    "widthxheight", where width and height are integer values corresponding to the horizontal
    and vertical size, respectively, in pixels.

    The limits are applied during the layout computation. It will limit the Natural size and
    the Current size. 

    If the element can be expanded, then its empty space will NOT be occupied by other controls
    although its size will be limited.
    */
    @property 
	{
		public Size minSize() 
        { 
            string s = getAttribute(IupAttributes.MinSize);
            return IupSize.parse(s); 
        }

		public void minSize(Size value) {
			setAttribute(IupAttributes.MinSize, IupSize.format(value));
		}
	}

    /**
    Specifies the element User size, and returns the Current size, in pixels.
    When this attribute is consulted the Current size of the control is returned. When this attribute is set, 
    it resets the SIZE attribute. So changes to the FONT attribute will not affect the User size of the element.
    To obtain the last computed Natural size of the control in pixels, use the read-only attribute NATURALSIZE. (Since 3.6)
    To obtain the User size of the element in pixels after it is mapped, use the attribute USERSIZE. (Since 3.12)
    */
    @property 
	{
		public Size rasterSize() 
        { 
            string s = getAttribute(IupAttributes.RasterSize);
            return IupSize.parse(s); 
        }

		public void rasterSize(Size value) { 
			setAttribute(IupAttributes.RasterSize, IupSize.format(value));
		}
	}

    /**
    The size units observes the following heuristics:

    Width in 1/4's of the average width of a character for the current FONT of each control. 
    Height in 1/8's of the average height of a character for the current FONT of each control. 
    So, a SIZE="4x8" means 1 character width and 1 character height.
    */
    @property 
	{
		public Size size() { return m_size; }

		public void size(Size value) 
		{
			m_size = value;
			setAttribute(IupAttributes.Size, IupSize.format(value));
		}
        private Size m_size; 
	}

    /**
    Text to be shown when the mouse lies over the element.
    */
    @property 
    {
        public string tipText() { return m_tooltip.text; }
        public void tipText(string value)  {  m_tooltip.text = value; }
    }

    /**
    Text to be shown when the mouse lies over the element.
    */
    @property 
	{
		public IupTooltip tooltip() { return m_tooltip; }
		protected void tooltip(IupTooltip value) { m_tooltip = value; }
        private IupTooltip m_tooltip; 
	}

    

    /**
    If an element has FLOATING=YES then its size and position will be ignored by the layout processing in IupVbox, 
    IupHbox and IupZbox. But the element size and position will still be updated in the native system allowing 
    the usage of SIZE/RASTERSIZE and POSITION to manually position and size the element. And must ensure that the element 
    will be on top of other using ZORDER, if there is overlap.

    This is useful when you do not want that an invisible element to be computed in the box size.
    If the value IGNORE is used then it will behave as YES, but also it will not update the the size and position in the native system. (since 3.3)

    All elements, except menus.
    */
    @property 
	{
        public bool isFloating() { return getAttribute(IupAttributes.Floating) == FlagIdentifiers.Yes; }

        public void isFloating(bool value)  {
            setAttribute(IupAttributes.Floating, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}


    /**
    Shows or hides the element.
    An interface element is only visible if its native parent is also visible.
    All controls that have visual representation, except menus.
    */
    @property 
	{
        public bool isVisible() { return getAttribute(IupAttributes.Visible) == FlagIdentifiers.Yes; }

        public void isVisible(bool value)  {
            setAttribute(IupAttributes.Visible, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}


    /* ************* Public methods *************** */

    /**
    Sets the interface element that will receive the keyboard focus, i.e., the element that
    will receive keyboard events. But this will be processed only after the control actually
    receive the focus.

    The value returned by IupGetFocus will be updated only after the main loop regain the 
    control and the control actually receive the focus. So if you call IupGetFocus right 
    after IupSetFocus the return value will be different. You could call IupFlush between 
    the two functions to obtain the same value in both calls.
    */
    void focus()
    {
        iup.c.api.IupSetFocus(handle);
    }

    /**
    Force the element and its children to be redrawn immediately.

    children: flag to update its children.
    */
    void redraw(bool childrenFlag)
    {
        iup.c.api.IupRedraw(handle, childrenFlag);
    }

    /**
    Mark the element or its children to be redraw when the control returns to the system.
    */
    void update()
    {
        iup.c.api.IupUpdate(handle);
    }

    /// ditto
    void updateChildren()
    {
        iup.c.api.IupUpdateChildren(handle);
    }
}


/**
*/
public class IupStandardControl : IupControl
{	
    class IupCallbacks : super.IupCallbacks
    {
        enum IupStandardControl = "IupStandardControl";
        enum Action = "ACTION";
    }
    
    class IupAttributes : super.IupAttributes
    {
        enum Cursor = "CURSOR";
        enum Padding = "PADDING";
    }


    this()
    {
        super();
    }

    this(string title)
    {
        super(title);
    }


    /* ************* Properties *************** */

    /**
    */
    @property 
    {
        public string cursor() { return getAttribute(IupAttributes.Cursor); }

        public void cursor(string value) 
        {
            setStrAttribute(IupAttributes.Cursor, value);
        }

        public void cursor(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.Cursor, value);
        }
    }

    /**
    internal margin. Works just like the MARGIN attribute of the IupHbox and IupVbox containers, 
    but uses a different name to avoid inheritance problems. Default value: "0x0".
    */
    @property 
	{
		public Size padding() 
        { 
            string s = getAttribute(IupAttributes.Padding);
            return IupSize.parse(s); 
        }

		public void padding(Size value) 
		{
			setAttribute(IupAttributes.Padding, IupSize.format(value));
		}
	}

}


/**
Associates a horizontal and/or vertical scrollbar to the element.
*/
public class IupScrollBar : IupAuxiliaryObject
{
    protected class IupAttributes : super.IupAttributes
	{
        //enum AutoHide = "AUTOHIDE";
		enum ScrollBar = "SCROLLBAR";
        enum Dx = "DX";
        enum Dy = "DY";
        enum PosX = "POSX";
        enum PosY = "POSY";
        enum XMin = "XMIN";
        enum XMax = "XMAX";
        enum YMin = "YMIN";
        enum YMax = "YMAX";
        enum LineX = "LINEX";
        enum LineY = "LINEY";
        enum XAutoHide = "XAUTOHIDE";
        enum YAutoHide = "YAUTOHIDE";
    }


    this(IupElement control)
    {
        super(control);
    }

    /* ************* Properties *************** */

    /**
    Associates a horizontal and/or vertical scrollBar to the canvas. Default: "NO". The 
    secondary attributes are all non inheritable.
    */
    @property 
	{
		public ScrollBarsVisibility visibility()  {  
            return ScrollbarVisibilityIdentifiers.convert(getAttribute(IupAttributes.ScrollBar)); 
        }

        public void visibility(ScrollBarsVisibility value) { 
            setAttribute(IupAttributes.ScrollBar, ScrollbarVisibilityIdentifiers.convert(value));
        }
	}

    /**
    Size of the thumb in the horizontal scrollbar. Also the horizontal page size. Default: "0.1".
    */
    @property 
	{
		public float dx()  {  return getFloatAttribute(IupAttributes.Dx); }
        public void dx(float value) { setFloatAttribute(IupAttributes.Dx, value);}
	}


    /**
    Size of the thumb in the vertical scrollbar. Also the vertical page size. Default: "0.1".
    */
    @property 
	{
		public float dy()  {  return getFloatAttribute(IupAttributes.Dy); }
        public void dy(float value) { setFloatAttribute(IupAttributes.Dy, value);}
	}

    /**
    Position of the thumb in the horizontal scrollbar. Default: "0.0".
    */
    @property 
	{
		public float posX()  {  return getFloatAttribute(IupAttributes.PosX); }
        public void posX(float value) { setFloatAttribute(IupAttributes.PosX, value);}
	}

    /**
    Position of the thumb in the vertical scrollbar. Default: "0.0".
    */
    @property 
	{
		public float posY()  {  return getFloatAttribute(IupAttributes.PosY); }
        public void posY(float value) { setFloatAttribute(IupAttributes.PosY, value);}
	}

    /**
    Maximum value of the horizontal scrollbar. Default: "1.0".
    */
    @property 
	{
		public float xMax()  {  return getFloatAttribute(IupAttributes.XMax); }
        public void xMax(float value) { setFloatAttribute(IupAttributes.XMax, value);}
	}

    /**
    Minimum value of the horizontal scrollbar, in any unit. Default: "0.0"
    */
    @property 
	{
		public float xMin()  {  return getFloatAttribute(IupAttributes.XMin); }
        public void xMin(float value) { setFloatAttribute(IupAttributes.XMin, value);}
	}

    /**
    Minimum value of the vertical scrollbar. Default: "0.0".
    */
    @property 
	{
		public float yMin()  {  return getFloatAttribute(IupAttributes.YMin); }
        public void yMin(float value) { setFloatAttribute(IupAttributes.YMin, value);}
	}

    /**
    Maximum value of the vertical scrollbar. Default: "1.0".
    */
    @property 
	{
		public float yMax()  {  return getFloatAttribute(IupAttributes.YMax); }
        public void yMax(float value) { setFloatAttribute(IupAttributes.YMax, value);}
	}

    /**
    The amount the thumb moves when an horizontal step is performed. Default: 1/10th of DX. (since 3.0)
    */
    @property 
	{
		public float lineX()  {  return getFloatAttribute(IupAttributes.LineX); }
        public void lineX(float value) { setFloatAttribute(IupAttributes.LineX, value);}
	}

    /**
    The amount the thumb moves when a vertical step is performed. Default: 1/10th of DY. (since 3.0)
    */
    @property 
	{
		public float lineY()  {  return getFloatAttribute(IupAttributes.LineY); }
        public void lineY(float value) { setFloatAttribute(IupAttributes.LineY, value);}
	}

    /**
    When enabled, if DX >= XMAX-XMIN then the horizontal  is hidden. Default: "YES". (since 3.0)
    */
    @property 
	{
		public bool xAutoHide()  {  return getAttribute(IupAttributes.XAutoHide) == FlagIdentifiers.Yes;  }
        public void xAutoHide(bool value)  { 
            setAttribute(IupAttributes.XAutoHide, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    When enabled, if DY >= YMAX-YMIN then the vertical  is hidden. Default: "YES". (since 3.0)
    */
    @property 
	{
		public bool yAutoHide()  {  return getAttribute(IupAttributes.YAutoHide) == FlagIdentifiers.Yes; }
        public void yAutoHide(bool value) { 
            setAttribute(IupAttributes.YAutoHide, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

}


/**
*/
public class IupTooltip : IupAuxiliaryObject
{
    protected class IupAttributes : super.IupAttributes
	{
		enum Tip =  "TIP";
        enum Balloon = "TIPBALLOON";
		enum BalloonTitle = "TIPBALLOONTITLE";
		enum BalloonTitleIcon = "TIPBALLOONTITLEICON";
		enum BgColor =  "TIPBGCOLOR";
		enum Delay =  "TIPDELAY";
		enum FgColor =  "TIPFGCOLOR";
		enum Font =  "TIPFONT";
		enum Icon =  "TIPICON";
		enum Markup =  "TIPMARKUP";
		enum Rect =  "TIPRECT";
		enum Visible =  "TIPVISIBLE";
    }

    this(IupElement control)
    {
        super(control);
    }


    /* ************* Properties *************** */

    /**
    The tip background color. Default: "255 255 225" (Light Yellow)
    */
    @property 
    {
        Color backgroundColor() { 
            string c = getAttribute(IupAttributes.BgColor);
            return Color.parse(c); 
        }

        void backgroundColor(Color value)  { setAttribute(IupAttributes.BgColor, value.toRgb()); }

        void backgroundColor(string value)  { setAttribute(IupAttributes.BgColor, value); }
    }


    /**
    Time the tip will remain visible. Default: "5000". In Windows the maximum value 
    is 32767 milliseconds.
    */
    @property 
	{
		public int delay()  {  return getIntAttribute(IupAttributes.Delay); }
        public void delay(int value) { setIntAttribute(IupAttributes.Delay, value);}
	}

    /**
    The font for the tip text. If not defined the font used for the text is the same 
    as the FONT attribute for the element. If the value is SYSTEM then, no font is 
    selected and the default system font for the tip will be used.
    */
    @property 
	{
        Font font()  {
            string f = getAttribute(IupAttributes.Font);
            return Font.parse(f); 
        }

        void font(Font value) { 
            setAttribute(IupAttributes.Font, value.toString());
        }

        void font(string value) { 
            setAttribute(IupAttributes.Font, value);
        }
	}

    /**
    The tip text color. Default: "0 0 0" (Black)
    */
    @property 
    {
        Color foregroundColor() { 
            string c = getAttribute(IupAttributes.FgColor);
            return Color.parse(c); 
        }

        void foregroundColor(Color value)  { setAttribute(IupAttributes.FgColor, value.toRgb()); }

        void foregroundColor(string value)  { setAttribute(IupAttributes.FgColor, value); }
    }

    /**
    Shows or hides the tip under the mouse cursor. Use values "YES" or "NO". In GTK will 
    only trigger the tip state, the given value will be ignored. Returns the current visible 
    state. (GTK 2.12) (get since 3.5)
    */
    @property 
	{
        public bool isVisible() { return getAttribute(IupAttributes.Visible) == FlagIdentifiers.Yes; }

        public void isVisible(bool value)  {
            setAttribute(IupAttributes.Visible, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Specifies a rectangle inside the element where the tip will be activated. 
    Format: "%d %d %d %d"="x1 y1 x2 y2". Default: all the element area. (GTK 2.12)
    */
    @property 
	{
        public Rectangle!int rectangle() { 
            string s = getAttribute(IupAttributes.Rect);
            return IupRectangleConverter.convert(s);
        }

        public void rectangle(Rectangle!int value)  {
            setAttribute(IupAttributes.Rect, IupRectangleConverter.convert(value));
        }
	}

    /**
    Text to be shown when the mouse lies over the element.
    */
    @property 
	{
		public string text() { return getAttribute(IupAttributes.Tip); }

		public void text(string value) {
			setStrAttribute(IupAttributes.Tip, value);
		}
	}

    version(Windows)
    {
        /**
        The tip window will have the appearance of a cartoon "balloon" with rounded corners and 
        a stem pointing to the item. Default: NO.
        */
        @property 
        {
            public bool hasBalloon() { return getAttribute(IupAttributes.Balloon) == FlagIdentifiers.Yes; }

            public void hasBalloon(bool value)  {
                setAttribute(IupAttributes.Balloon, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
        */
        @property 
        {
            public BalloonIco balloonIco() { 
                int code = getIntAttribute(IupAttributes.BalloonTitleIcon);
                return cast(BalloonIco)code;
            }

            public void balloonIco(BalloonIco value) 
            {
                setIntAttribute(IupAttributes.BalloonTitleIcon, cast(int)value);
            }
        }

        /**
        When using the balloon format, the tip can also has a title in a separate area.
        */
        @property 
        {
            public string balloonTitle() { return m_balloonTitle; }

            public void balloonTitle(string value) {
                m_balloonTitle = value;
                setAttribute(IupAttributes.BalloonTitle, value);
            }
            private string m_balloonTitle; 
        }

    }
    else version(GTK)
    {

        /**
        name of an image to be displayed in the TIP. See IupImage. (GTK 2.12)
        */
        @property 
        {
            //public string ico() { return getAttribute(IupAttributes.Icon); }
            //
            //public void ico(string value) 
            //{
            //    setAttribute(IupAttributes.Icon, value);
            //}

            public void ico(iup.image.IupImage value) 
            {
                setHandleAttribute(IupAttributes.Icon, value);
            }
        }

        /**
        allows the tip string to contains Pango markup commands. Can be "YES" or "NO". 
        Default: "NO". Must be set before setting the TIP attribute. (GTK 2.12)
        */
        @property 
        {
            public bool allowMarkup() { return getAttribute(IupAttributes.Markup) == FlagIdentifiers.Yes; }

            public void allowMarkup(bool value)  {
                setAttribute(IupAttributes.Markup, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

}

enum BalloonIco
{
    None = 0,
    Info = 1,
    Warning = 2,
    Error = 3
}


//
// Summary:
//     Specifies constants that define which mouse button was pressed.
public enum MouseButtons
{
    //
    // Summary:
    //     The left mouse button was pressed.
    Left = IUP_BUTTON1,
        //
        // Summary:
        //     The middle mouse button was pressed.
        Middle = IUP_BUTTON2,
        //
        // Summary:
        //     The right mouse button was pressed.
        Right = IUP_BUTTON3
}


/**
the state of the button
*/
public enum MouseState
{
    Released = 0,
        Pressed = 1
}

