module iup.container;

import iup.canvas;
import iup.control;
import iup.core;
import iup.image;

import iup.c;

import std.container.array;
import std.conv;
import std.string;

import toolkit.container;
import toolkit.event;
import toolkit.drawing;


/**
Creates a simple native container with no decorations. Useful for controlling children 
visibility for IupZbox or IupExpander. It inherits from IupCanvas. 
*/
public class IupBackgroundBox : IupCanvasBase
{
    class IupAttributes : super.IupAttributes
    {
        enum CanvasBox = "CANVASBOX";
        enum ChildOffset = "CHILDOFFSET";
    }

    this() { super(); }

	this(IupControl child)
	{
        super();
        this.child = child;
	}

    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupBackgroundBox(null);
	}


    /* ************* Properties *************** */

    /**
    */
	@property 
	{
		IupControl child() { return m_child; }
		
        void child(IupControl value)
        { 
            if(m_child !is null)
                iup.c.IupDetach(m_child.handle);

            m_child = value;
            iup.c.IupAppend(handle, value is null ? null : m_child.handle);
        }
        private IupControl m_child;
	}

    /**
    enable the behavior of a canvas box instead of a regular container. Can be Yes or No.
    Default: No.
    */
    @property 
	{
		bool enableCanvasBox() { return getAttribute(IupAttributes.CanvasBox) == FlagIdentifiers.Yes; }

		void enableCanvasBox(bool value) 
		{
            setAttribute(IupAttributes.CanvasBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    Allow to specify a position offset for the child. Available for native containers only. 
    It will not affect the natural size, and allows to position controls outside the client
    area. Format "dxxdy", where dx and dy are integer values corresponding to the horizontal
    and vertical offsets, respectively, in pixels. Default: 0x0.
    */
    @property 
	{
		OffsetXY childOffset() 
        {
            OffsetXY offset;
            getIntIntAttribute(IupAttributes.ChildOffset, offset.dx, offset.dy);
            return offset; 
        }

		void childOffset(OffsetXY offset) 
		{
			setAttribute(IupAttributes.ChildOffset, offset.dx, offset.dy);
		}
	}
}


/**
*/
public class IupContentControl : IupControl
{  
	protected class IupAttributes : super.IupAttributes
	{
		enum ClientSize = "CLIENTSIZE";
        enum Gap = "GAP";
        enum Margin = "MARGIN";
		enum Menu = "MENU";
		enum UserSize = "USERSIZE";
	}

    this() { super(); }

    this(string title)
    {
        super(title);
    }

	this(IupControl child)
	{
        super();
        this.child = child;
	}

    override protected void onCreated()
	{
        super.onCreated();
        this.canExpand = true;
    }


    /* ************* Properties *************** */

    /**
    */
	@property 
	{
		public IupControl child() { return m_child; }

		public void child(IupControl value)
        { 
            if(m_child !is null)
                iup.c.IupDetach(m_child.handle);

            m_child = value;
            iup.c.IupAppend(handle, value is null ? null : value.handle);
        }
        private  IupControl m_child;
	}

    /**
    Returns the client area size of a container. It is the space available for positioning 
    and sizing children, see the Layout Guide. It is the container Current size excluding 
    the decorations (if any). 
    */
    @property 
	{
		public Size clientSize() 
        { 
            string s = getAttribute(IupAttributes.ClientSize);
            return IupSize.parse(s); 
        }

		public void clientSize(Size value) 
		{
			setAttribute(IupAttributes.ClientSize, IupSize.format(value));
		}
	}

    /**
    * Defines a vertical space in pixels between the children, CGAP is in the same units of 
    the SIZE attribute for the height. Default: "0". (CGAP since 3.0)
    */
    @property 
	{
		public int gap() { return m_gap; }

		public void gap(int value) 
		{
			m_gap = value;
			const(char) * str = iupToStringz(value);
			iup.c.IupSetAttribute(handle, IupAttributes.Gap, str);
		}
        private int m_gap; 
	}

    /**
    */
    @property 
	{
		public Size margin() 
        { 
            string s = getAttribute(IupAttributes.Margin);
            return IupSize.parse(s); 
        }

		public void margin(Size value) 
		{
			setAttribute(IupAttributes.Margin, IupSize.format(value));
		}
	}

    /**
    */
	@property 
	{
		public Size userSize() 
        { 
            string s = getAttribute(IupAttributes.UserSize);
            return IupSize.parse(s); 
        }

		public void userSize(Size value) 
		{
			setAttribute(IupAttributes.UserSize, IupSize.format(value));
		}
	}

    /**
    */
    @property 
	{
		public iup.menu.IupMenu menu() { return m_menu; }

		public void menu(iup.menu.IupMenu value) 
		{
			m_menu = value;
			setHandleAttribute(IupAttributes.Menu, value);
		}
        private iup.menu.IupMenu m_menu; 
	}


	/**
	The SIZE attribute will also work as a minimum size, so we reset the USERSIZE attribute, 
	after the dialog is shown, to avoid this limitation.
	*/
	void resetUserSize()
	{
		setAttribute(IupAttributes.UserSize, "");
	}
}


/**
*/
public class IupContainerControl : IupControl
{

    class IupAttributes : super.IupAttributes
	{
        enum Alignment = "ALIGNMENT";
		enum ClientSize = "CLIENTSIZE";
	}

    protected Array!IupControl children;

    this() { super(); }

	this(IupControl[] children...)
	{
        append(children);
	}

    override protected void onCreated()
	{
        super.onCreated();
        expandOrientation = ExpandOrientation.Both;
    }


    /* ************* Public methods *************** */

    /**
    */
    void append(IupControl[] children...)
    {
        this.children.insert(children);
        foreach(IupControl c ; children)
        {
            if(c is null) continue;
            iup.c.IupAppend(handle, c.handle);
        }
    }

    protected IupControl getChild(Ihandle* childHandle)
    {
        foreach(c; children)
        {
            if(c.handle == childHandle)
                return c;
        }
        return null;
    }


    /* ************* Properties *************** */

    /**
    Returns the client area size of a container. It is the space available for positioning 
    and sizing children, see the Layout Guide. It is the container Current size excluding 
    the decorations (if any). 
    */
    @property 
	{
		public Size clientSize() 
        { 
            string s = getAttribute(IupAttributes.ClientSize);
            return IupSize.parse(s); 
        }

		public void clientSize(Size value) 
		{
			setAttribute(IupAttributes.ClientSize, IupSize.format(value));
		}
	}
}


/**
Creates a void container that can interactively show or hide its child.

It does not have a native representation, but it contains also several elements to implement
the bar handler.
*/
public class IupExpander : IupContentControl
{
    class IupCallbacks : super.IupCallbacks
    {
        enum Action = "ACTION";
		enum OpenClose = "OPENCLOSE_CB";
		enum ExtraButton = "EXTRABUTTON_CB";
    }

    class IupAttributes : super.IupAttributes
	{
        enum IupExpander = "IupExpander";
        enum AutoShow = "AUTOSHOW";
        enum Animation = "ANIMATION";
        enum BackColor = "BACKCOLOR";
        enum BarPosition = "BARPOSITION";
        enum BarSize = "BARSIZE";
        enum ExtraButtons = "EXTRABUTTONS";
        enum ImageExtra = "IMAGEEXTRA";
        enum ImageExtraPress = "IMAGEEXTRAPRESS";
        enum ImageExtraHighlight = "IMAGEEXTRAHIGHLIGHT";
        enum ForeColor = "FORECOLOR";
        enum OpenColor = "OPENCOLOR";
        enum HighColor = "HIGHCOLOR";
        enum Image = "IMAGE";
        enum ImageOpen = "IMAGEOPEN";
        enum ImageHighlight = "IMAGEHIGHLIGHT";
        enum ImageOpenhighlight = "IMAGEOPENHIGHLIGHT";
        enum State = "STATE";
        enum StateRefresh = "STATEREFRESH";
        enum TitleImage = "TITLEIMAGE";
        enum TitleImageOpen = "TITLEIMAGEOPEN";
        enum TitleImageHighlight = "TITLEIMAGEHIGHLIGHT";
        enum TitleImageOpenHighlight = "TITLEIMAGEOPENHIGHLIGHT";
        enum TitleExpand = "TITLEEXPAND";
	}

    this() { super(); }

    this(string title)
    {
        super(title);
    }

	this(IupControl child)
	{
		super(child);
	}


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupExpander(null);
	}

    override protected void onCreated()
    {
        super.onCreated();

        registerExtraMouseClickCallback(IupCallbacks.ExtraButton);
        registerStateChangingCallback(IupCallbacks.OpenClose);
        registerStateChangedCallback(IupCallbacks.Action);
    }


    /* ************* Events *************** */

    /**
    Action generated when any mouse button is pressed or released.

    button: identifies the extra button. can be 1, 2 or 3. (this is not the same as BUTTON_CB)
    pressed: indicates the state of the button
    */
    EventHandler!(CallbackEventArgs, int, MouseState)  extraMouseClick;
    mixin EventCallbackAdapter!(IupExpander, "extraMouseClick", int, int);
    private IupElementAction onExtraMouseClick(int button, int pressed) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            extraMouseClick(this, callbackArgs, button, 
                       cast(MouseState)pressed);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /**
    Action generated after the expander state is interactively changed.
    */
    mixin EventCallback!(IupExpander, "stateChanged");

    /**
    Action generated before the expander state is interactively changed.

    state: new state to be applied. 
    Returns: if return IUP_IGNORE the new state is ignored.
    */
    EventHandler!(CallbackEventArgs, ExpanderState)  stateChanging;
    mixin EventCallbackAdapter!(IupExpander, "stateChanging", int);
    private IupElementAction onStateChanging(int state) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            stateChanging(this, callbackArgs, cast(ExpanderState)state);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }


    /* ************* Properties *************** */

    /**
    enable animation during open/close. Works only for BARPOSITION=TOP and does not works 
    for AUTOSHOW. Also the child must be a native container like IupTabs, IupFrame, 
    IupBackgroundBox, or IupScrollBox, or it will not work accordantly. Values can be SLIDE 
    (child controls slide down), CURTAIN (child controls appears as if a curtain is being 
    pulled) or NO. Default: NO. 
    */
    @property 
    {
        ExpanderAnimationStyle animationStyle() { 
            string v = getAttribute(IupAttributes.Animation); 
            return ExpanderAnimationStyleIdentifiers.convert(v);
        }

        void animationStyle(ExpanderAnimationStyle value) {
            setAttribute(IupAttributes.Animation, ExpanderAnimationStyleIdentifiers.convert(value));
        }
    }

    /**
    when state is changed IupRefresh is automatically called. Can be Yes or No. Default: Yes. 
    */
    @property 
    {
        bool canAutoRefresh() { return getAttribute(IupAttributes.StateRefresh) == FlagIdentifiers.Yes; }

        void canAutoRefresh(bool value) {
            setAttribute(IupAttributes.StateRefresh, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    enables the automatic show of the child when mouse is over the handler for more 
    than 1 second. Default: No.
    */
    @property 
    {
        bool canAutoShow() { return getAttribute(IupAttributes.AutoShow) == FlagIdentifiers.Yes; }

        void canAutoShow(bool value) {
            setAttribute(IupAttributes.AutoShow, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    enable the expand/collapse action also at the tile. Default: NO.
    */
    @property 
    {
        bool canTitleExpand() { return getAttribute(IupAttributes.TitleExpand) == FlagIdentifiers.Yes; }

        void canTitleExpand(bool value) {
            setAttribute(IupAttributes.TitleExpand, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    background color of the bar handler. If not defined it will use the background color of
    the native parent. 
    */
    @property 
    {
        Color barBackground() { 
            string c = getAttribute(IupAttributes.BackColor);
            return Color.parse(c); 
        }

        void barBackground(Color value) { setAttribute(IupAttributes.BackColor, value.toRgb()); }

        void barBackground(string value) { setAttribute(IupAttributes.BackColor, value); }
    }

    /**
    indicates the bar handler position. Possible values are "TOP", "BOTTOM", "LEFT" or 
    "RIGHT". Default: "TOP".
    */
    @property 
	{
		Position barPosition() {  
            return PositionIdentifiers.convert(getAttribute(IupAttributes.BarPosition)); 
        }

        void barPosition(Position value) { 
            setAttribute(IupAttributes.BarPosition, PositionIdentifiers.convert(value));
        }
	}

    /**
    controls the size of the bar handler. Default: the height or width that fits all its 
    internal elements according to BARPOSITION.
    */
    @property 
	{
        int barSize() {  return getIntAttribute(IupAttributes.BarSize); }

        void barSize(int value) { 
            setIntAttribute(IupAttributes.BarSize, value);
        }
	}

    /**
    sets the number of extra image buttons at right when BARPOSITION=TOP. The maximum number
    of buttons is 3. See the EXTRABUTTON_CB callback. Default: 0.
    */
    @property 
	{
		int extraButtonsCount() {  return getIntAttribute(IupAttributes.ExtraButtons); }

        void extraButtonsCount(int value) { 
            assert(value>=1 && value <=3);
            setIntAttribute(IupAttributes.ExtraButtons, value);
        }
	}

    /**
    title text color. Default: the global attribute DLGFGCOLOR.
    */
    @property 
    {
        Color titleForceColor() { 
            string c = getAttribute(IupAttributes.ForeColor);
            return Color.parse(c); 
        }

        void titleForceColor(Color value) { setAttribute(IupAttributes.ForeColor, value.toRgb()); }

        void titleForceColor(string value) { setAttribute(IupAttributes.ForeColor, value); }
    }

    /**
    title text color when STATE=OPEN. Defaults to the FORECOLOR if not defined.
    */
    @property 
    {
        Color titleOpenColor() { 
            string c = getAttribute(IupAttributes.OpenColor);
            return Color.parse(c); 
        }

        void titleOpenColor(Color value) { setAttribute(IupAttributes.OpenColor, value.toRgb()); }

        void titleOpenColor(string value) { setAttribute(IupAttributes.OpenColor, value); }
    }

    /**
    title text color when STATE=OPEN. Defaults to the FORECOLOR if not defined.
    */
    @property 
    {
        Color titleHighlightColor() { 
            string c = getAttribute(IupAttributes.HighColor);
            return Color.parse(c); 
        }

        void titleHighlightColor(Color value) { setAttribute(IupAttributes.HighColor, value.toRgb()); }

        void titleHighlightColor(string value) { setAttribute(IupAttributes.HighColor, value); }
    }

    /**
    image name to replace the arrow image by a custom image when STATE=CLOSE. Works
    only when BARPOSITION=TOP. Use IupSetHandle or IupSetAttributeHandle to associate 
    an image to a name.
    */
    @property 
    {
        string arrowImage() { 
            return getAttribute(IupAttributes.Image);
        }

        void arrowImage(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.Image, image);
        }

        void arrowImage(string image) {
            setAttribute(IupAttributes.Image, image);
        }
    }

    /**
    image name used when STATE=OPEN.
    */
    @property 
    {
        string arrowImageOpen() { 
            return getAttribute(IupAttributes.ImageOpen);
        }

        void arrowImageOpen(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.ImageOpen, image);
        }

        void arrowImageOpen(string image) {
            setAttribute(IupAttributes.ImageOpen, image);
        }
    }

    /**
    image name used when mouse is over the bar handler and STATE=CLOSE.
    */
    @property 
    {
        string arrowImageCloseHighlight() { 
            return getAttribute(IupAttributes.ImageHighlight);
        }

        void arrowImageCloseHighlight(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.ImageHighlight, image);
        }

        void arrowImageCloseHighlight(string image) {
            setAttribute(IupAttributes.ImageHighlight, image);
        }
    }

    /**
    image name used when mouse is over the bar handler and STATE=OPEN.
    */
    @property 
    {
        string arrowImageOpenHighlight() { 
            return getAttribute(IupAttributes.ImageOpenhighlight);
        }

        void arrowImageOpenHighlight(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.ImageOpenhighlight, image);
        }

        void arrowImageOpenHighlight(string image) {
            setAttribute(IupAttributes.ImageOpenhighlight, image);
        }
    }

    /**
    Show or hide the container elements. Possible values: "OPEN" (expanded) or "CLOSE" 
    (collapsed). Default: OPEN. Setting this attribute will automatically change the 
    layout of the entire dialog so the child can be recomposed.
    */
    @property 
    {
        ExpanderState state() { 
            string s = getAttribute(IupAttributes.State);
            return ExpanderStateIdentifiers.convert(s);
        }

        void state(ExpanderState s) {
            setAttribute(IupAttributes.State, ExpanderStateIdentifiers.convert(s));
        }
    }

    /**
    title image, shown in the bar handler near the expand/collapse button. When set it
    will reset TITLE (image and text title are mutually exclusive). Shown only when 
    BARPOSITION=TOP.
    */
    @property 
    {
        string titleImage() { 
            return getAttribute(IupAttributes.TitleImage);
        }

        void titleImage(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.TitleImage, image);
        }

        void titleImage(string image) {
            setAttribute(IupAttributes.TitleImage, image);
        }
    }

    /**
    image name used when STATE=OPEN.
    */
    @property 
    {
        string titleImageOpen() { 
            return getAttribute(IupAttributes.TitleImageOpen);
        }

        void titleImageOpen(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.TitleImageOpen, image);
        }

        void titleImageOpen(string image) {
            setAttribute(IupAttributes.TitleImageOpen, image);
        }
    }

    /**
    image name used when mouse is over the bar handler and STATE=CLOSE.
    */
    @property 
    {
        string titleImageCloseHighlight() { 
            return getAttribute(IupAttributes.TitleImageHighlight);
        }

        void titleImageCloseHighlight(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.TitleImageHighlight, image);
        }

        void titleImageCloseHighlight(string image) {
            setAttribute(IupAttributes.TitleImageHighlight, image);
        }
    }

    /**
    image name used when mouse is over the bar handler and STATE=OPEN.
    */
    @property 
    {
        string titleImageOpenHighlight() { 
            return getAttribute(IupAttributes.TitleImageOpenHighlight);
        }

        void titleImageOpenHighlight(iup.image.IupImage image) {
            setHandleAttribute(IupAttributes.TitleImageOpenHighlight, image);
        }

        void titleImageOpenHighlight(string image) {
            setAttribute(IupAttributes.TitleImageOpenHighlight, image);
        }
    }


    /* ************* Public methods *************** */

    /**
    image name used for the button. id can be 1, 2 or 3. 1 is the rightmost button, and count
    from right to left.
    */
    void setExtraButtonImage(int index, string image)
    {
        assert(index>=1 && index <=3);
        setIdAttribute(IupAttributes.ImageExtra, index, image);
    }

    /// ditto
    void setExtraButtonImage(int index, iup.image.IupImage image)
    {
        assert(index>=1 && index <=3);
        setHandleAttribute(IupAttributes.ImageExtra ~ to!string(index), image);
    }

    /// ditto
    string getExtraButtonImage(int index)
    {
        assert(index>=1 && index <=3);
        return getIdAttributeAsString(IupAttributes.ImageExtra, index);
    }

    /**
    image name used for the button when pressed.
    */
    void setExtraButtonPressedImage(int index, string image)
    {
        assert(index>=1 && index <=3);
        setIdAttribute(IupAttributes.ImageExtraPress, index, image);
    }

    /// ditto
    void setExtraButtonPressedImage(int index, iup.image.IupImage image)
    {
        assert(index>=1 && index <=3);
        setHandleAttribute(IupAttributes.ImageExtraPress ~ to!string(index), image);
    }

    /// ditto
    string getExtraButtonPressedImage(int index)
    {
        assert(index>=1 && index <=3);
        return getIdAttributeAsString(IupAttributes.ImageExtraPress, index);
    }

    /**
    image name for the button used when mouse is over the button area.
    */
    void setExtraButtonHighlightImage(int index, string image)
    {
        assert(index>=1 && index <=3);
        setIdAttribute(IupAttributes.ImageExtraHighlight, index, image);
    }

    /// ditto
    void setExtraButtonHighlightImage(int index, iup.image.IupImage image)
    {
        assert(index>=1 && index <=3);
        setHandleAttribute(IupAttributes.ImageExtraHighlight ~ to!string(index), image);
    }

    /// ditto
    string getExtraButtonHighlightImage(int index)
    {
        assert(index>=1 && index <=3);
        return getIdAttributeAsString(IupAttributes.ImageExtraHighlight, index);
    }
}


enum ExpanderAnimationStyle
{
    Slide,
    Curtain,
    None
}

struct ExpanderAnimationStyleIdentifiers
{
    enum Slide = "SLIDE";
    enum Curtain = "CURTAIN";
    enum None = "NO";

    static string convert(ExpanderAnimationStyle t)
    {
        switch(t)
        {
            case ExpanderAnimationStyle.Slide:
                return Slide;

            case ExpanderAnimationStyle.Curtain:
                return Curtain;

            default:
                return None;
        }
    }

    static ExpanderAnimationStyle convert(string v)
    {
        if(v == Slide)
            return ExpanderAnimationStyle.Slide;
        else if(v == Curtain)
            return ExpanderAnimationStyle.Curtain;
        else
            return ExpanderAnimationStyle.None;
    }
}

enum ExpanderState
{
    Open,
    Close
}


struct ExpanderStateIdentifiers
{
    enum Open = "Open";
    enum Close = "Close";

    static string convert(ExpanderState t)
    {
        switch(t)
        {
            case ExpanderState.Open:
                return Open;

            default:
                return Close;
        }
    }

    static ExpanderState convert(string v)
    {
        if(v == Open)
            return ExpanderState.Open;
        else
            return ExpanderState.Close;
    }
}


/**
Creates a native container, which draws a frame with a title around its child.
*/
public class IupGroupBox : IupContentControl
{
    class IupAttributes : super.IupAttributes
	{
        enum IupGroupBox = "IupGroupBox";
        enum IupFrame = "IupFrame";
        enum ChildOffset = "CHILDOFFSET";
        enum Sunken = "SUNKEN";
	}

    this() { super(); }

    this(string title)
    {
        super(title);
    }

	this(IupControl child)
	{
		super(child);
	}


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupFrame(null);
	}


    /* ************* Properties *************** */

    /**
    Allow to specify a position offset for the child. Available for native containers only. 
    It will not affect the natural size, and allows to position controls outside the client 
    area. Format "dxxdy", where dx and dy are integer values corresponding to the horizontal
    and vertical offsets, respectively, in pixels. Default: 0x0. (since 3.14)
    */   
    @property 
	{
		OffsetXY childOffset() 
        { 
            string s = getAttribute(IupAttributes.ChildOffset);
            return IupOffsetXY.parse(s); 
        }

		void childOffset(OffsetXY value) 
		{
			setAttribute(IupAttributes.ChildOffset, IupOffsetXY.format(value));
		}
	}

    /**
    When not using a title, the frame line defines a sunken area (lowered area). Valid 
    values: YES or NO. Default: NO.
    */    
    @property 
	{
		bool isSunken() {  return getAttribute(IupAttributes.Sunken) == FlagIdentifiers.Yes; }

        void isSunken(bool value) { 
            setAttribute(IupAttributes.Sunken, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}
}

//alias IupFrame = IupGroupBox;


/**
Creates a void container for grouping mutual exclusive toggles. Only one of its descendent toggles will be active at a time.
The toggles can be at any composition.

It does not have a native representation. 
*/
public class IupRadioBox : IupContentControl
{
    class IupAttributes : super.IupAttributes
	{
        enum IupRadioBox = "IupRadioBox";
	}

    this() { super(); }

	this(IupControl child)
	{
		super(child);
	}


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupRadio(null);
	}
}

//alias IupRadio = IupRadioBox;
alias IupRadioGroup = IupRadioBox;


/**
Creates a native container that allows its child to be scrolled.
*/
public class IupScrollBox : IupCanvasBase
{
    class IupAttributes : super.IupAttributes
    {
        enum IupScrollBox = "IupScrollBox";
        enum CanvasBox = "CANVASBOX";
        enum ChildOffset = "CHILDOFFSET";
        enum LayoutDrag = "LAYOUTDRAG";
        enum ScrollTo = "SCROLLTO";
        enum ScrollToChild = "SCROLLTOCHILD";
        enum ScrollToChildHandle = "SCROLLTOCHILD_HANDLE";
    }

    this() { super(); }

	this(IupControl child)
	{
        super();
        this.child = child;
	}

    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupScrollBox(null);
	}


    /* ************* Properties *************** */

    /**
    */
	@property 
	{
		IupControl  child() { return m_child; }

        void child(IupControl value)
        { 
            if(m_child !is null)
                iup.c.IupDetach(m_child.handle);

            m_child = value;
            iup.c.IupAppend(handle, value is null ? null : m_child.handle);
        }
        private  IupControl m_child;
	}

    /**
    enable the behavior of a canvas box instead of a regular container. Can be Yes or No.
    Default: No.
    */
    @property 
	{
		bool enableCanvasBox() { return getAttribute(IupAttributes.CanvasBox) == FlagIdentifiers.Yes; }

		void enableCanvasBox(bool value) 
		{
            setAttribute(IupAttributes.CanvasBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    Allow to specify a position offset for the child. Available for native containers only. 
    It will not affect the natural size, and allows to position controls outside the client
    area. Format "dxxdy", where dx and dy are integer values corresponding to the horizontal
    and vertical offsets, respectively, in pixels. Default: 0x0.
    */
    @property 
	{
		OffsetXY childOffset() 
        {
            OffsetXY offset;
            getIntIntAttribute(IupAttributes.ChildOffset, offset.dx, offset.dy);
            return offset; 
        }

		void childOffset(OffsetXY offset) 
		{
			setAttribute(IupAttributes.ChildOffset, offset.dx, offset.dy);
		}
	}


    version(Windows)
    {
        /**
        When the scrollbar is moved automatically update the children layout. Default: YES. 
        If set to NO then the layout will be updated only when the mouse drag is released. 
        */
        @property 
        {
            bool canAutoUpdateLayout() { 
                return getAttribute(IupAttributes.LayoutDrag) == FlagIdentifiers.Yes; 
            }

            void canAutoUpdateLayout(bool value) {
                setAttribute(IupAttributes.LayoutDrag, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

    /* ************* Public methods *************** */

    /**
    position the scroll at the given x,y coordinates relative to the box top-left corner. 
    Format "x,y". Value can also be TOP or BOTTOM for a vertical scroll to the top or to
    the bottom of the scroll range.
    */
    void scrollTo(int x, int y)
    {
        setAttribute(IupAttributes.ScrollTo, x, y);
    }

    /// ditto
    void scrollTo(Position pos)
    {
        setAttribute(IupAttributes.ScrollTo, PositionIdentifiers.convert(pos));
    }

    /**
    position the scroll at the top-left corner of the given child. The child must be 
    contained in the Scrollbox hierarchy. 
    */
    void scrollToChild(IupControl child)
    {
        setHandleAttribute(IupAttributes.ScrollToChildHandle, child);
    }

}


/**
This functions will create a control set with a vertical box containing two buttons, one with
an up arrow and the other with a down arrow, to be used to increment and decrement values.

Unlike the SPIN attribute of the IupText element, the IupSpin element can NOT automatically 
increment the value and it is NOT inserted inside the IupText area. But they can be used with 
any element.
*/
public class IupSpinBox : IupContentControl
{

	protected class IupCallbacks : super.IupCallbacks
	{
		enum Spin = "SPIN_CB";
    }

    protected class IupAttributes : super.IupAttributes
	{
        enum IupSpinBox = "IupSpinBox";
	}

    this()
    {
        super();
    }

	this(IupControl child)
	{
		super(child);
	}


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupSpinbox(null);
	}

    override protected void onCreated()
	{
        super.onCreated();
        registerSpinnedCallback(IupCallbacks.Spin);

    }


    /* ************* Events *************** */

    /**
    Called each time the user clicks in the buttons. It will increment 1 and decrement -1 by 
    default. Holding the Shift key will set a factor of 2, holding Ctrl a factor of 10, and 
    both a factor of 100.
    */
    mixin EventCallback!(IupSpinBox, "spinned", int);

}


/**
Creates a void container that split its client area in two. Allows the provided controls
to be enclosed in a box that allows expanding and contracting the element size in one 
direction, but when one is expanded the other is contracted.

It does not have a native representation, but it contains also a IupCanvas to implement
the bar handler.
*/
public class IupSplitContainer : IupControl
{
    protected class IupCallbacks : super.IupCallbacks
    {
		enum ValueChanged = "VALUECHANGED_CB";
    }

    protected class IupAttributes : super.IupAttributes
	{
        enum IupSplitContainer = "IupSplitContainer";
        enum AutoHide = "AUTOHIDE";
        enum BarSize = "BARSIZE";
        enum Color =  "COLOR";
        enum Orientation = "ORIENTATION";
        enum LayoutDrag = "LAYOUTDRAG";
        enum MinMax = "MINMAX";
        enum ShowGrip = "SHOWGRIP";
	}

	this(IupControl child1, IupControl child2)
	{
        this.m_child1 = child1;
        this.m_child2 = child2;

		super();
	}


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupSplit(m_child1.handle, m_child2.handle);
	}

    override protected void onCreated()
	{
        super.onCreated();
        registerSplitterMovedCallback(IupCallbacks.ValueChanged);
    }


    /* ************* Events *************** */
    mixin EventCallback!(IupSplitContainer, "splitterMoved");


    /* ************* Properties *************** */

    /**
    Changes the color of the bar grip affordance. The value should be given in "R G B" 
    color style. Default: "192 192 192".
    */
    @property 
    {
        Color color() { 
            string c = getAttribute(IupAttributes.Color);
            return Color.parse(c); 
        }

        void color(Color value) { setAttribute(IupAttributes.Color, value.toRgb()); }

        void color(string value) { setAttribute(IupAttributes.Color, value); }
    }

    /** 
    controls the size of the bar handler. Default: 5.
    */
    @property 
	{
		public int barSize() {  return getIntAttribute(IupAttributes.BarSize); }
        public void barSize(int value) { setIntAttribute(IupAttributes.BarSize, value);}
	}

    /**
    if the child client area is smaller than the bar size, then automatically hide the 
    child. Default: NO.
    */
    @property 
    {
        public bool canAutoHide() { return getAttribute(IupAttributes.AutoHide) == FlagIdentifiers.Yes; }

        public void canAutoHide(bool value) {
            setAttribute(IupAttributes.AutoHide, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    */
    @property 
    {
        public bool canShowGrip() { return getAttribute(IupAttributes.ShowGrip) == FlagIdentifiers.Yes; }

        public void canShowGrip (bool value) {
            setAttribute(IupAttributes.ShowGrip, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    When the bar is moved automatically update the children layout. Default: YES. If set 
    to NO then the layout will be updated only when the mouse drag is released.
    */
    @property 
    {
        public bool canUpdateLayout() { return getAttribute(IupAttributes.LayoutDrag) == FlagIdentifiers.Yes; }

        public void canUpdateLayout(bool value) {
            setAttribute(IupAttributes.LayoutDrag, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Identifier of an interface element that will be at left or top. It can be NULL 
    */
	@property 
	{
		public IupControl  child1(){ return m_child1; }
		protected void child1(IupControl value) {  m_child1 = value; }
        private  IupControl m_child1;
	}

    /**
    Identifier of an interface element that will be at right or bottom.
    */
	@property 
	{
		public IupControl  child2(){ return m_child2; }
		protected void child2(IupControl value) {  m_child2 = value; }
        private  IupControl m_child2;
	}

    /**
    sets minimum and maximum crop values for VALUE, in the format "%d:%d" [min:max]. The min 
    value can not be less than 0, and the max value can not be larger than 1000. This will 
    constrain the interactive change of the bar handler. Default: "0:1000". (Since 3.2)
    */
    @property 
	{
        public string cropRange() { return getAttribute(IupAttributes.MinMax); }

        public void cropRange(string value) {
            setAttribute(IupAttributes.MinMax, value);
        }
	}

    /**
    Indicates the orientation of the bar handler. The direction of the resize is 
    perpendicular to the orientation. Possible values are "VERTICAL" or "HORIZONTAL".
    Default: "VERTICAL".
    */
    @property 
	{
		public Orientation orientation() { 
            string s = getAttribute(IupAttributes.Orientation); 
            return OrientationIdentifiers.convert(s);
        }

		public void orientation(Orientation o) {
			setAttribute(IupAttributes.Orientation, OrientationIdentifiers.convert(o));
		}
	}

    /**
    The proportion of the left or top (child1) client area relative to the full available area.
    It is an integer between 0 and 1000. If not defined or set to NULL, the Native size of the 
    two children will define its initial size.
    */
    @property 
	{
		public int proportion() {  return getIntAttribute(IupAttributes.Value); }
        public void proportion(int value) { setIntAttribute(IupAttributes.Value, value);}
	}

}

//alias IupSplit = IupSplitContainer;


public class IupContainerControlBase(T) : IupControl
{
    alias ContainerItemCollection = ItemCollection!T;

    this() { super(); }

	this(T[] children...)
	{
        super();
        m_items.append(children); 
	}

    protected override void onCreated()
    {    
        super.onCreated();

        m_items = new ContainerItemCollection();
        m_items.appended += &itemsAppended;
        m_items.inserted += &itemsInserted;
        m_items.removed += &itemsRemoved;
    }   

    protected void itemsAppended(Object sender, T[] items)
    {
        foreach(T c ; items)
        {
            if(c !is null) iup.c.IupAppend(handle, c.handle);
        }
    }

    /**
    Inserts an interface element before another child of the container. Valid for any element 
    that contains other elements like dialog, frame, hbox, vbox, zbox, menu, etc.
    */
    protected void itemsInserted(Object sender, int index, T[] items)
    {
        T current = m_items[index+items.length];
        foreach(T c ; items)
        {
            if(c !is null) iup.c.IupInsert(handle, current.handle, c.handle);
        }
    }

    /**
    All the specified items will be removed and destroyed.
    */
    protected void itemsRemoved(Object sender, int index, int count)
    {
        for(int i=index; i<index+count; i++)
        {
            T c = m_items[index];
            if(c !is null) iup.c.IupDestroy(c.handle);
        }
    }


    /* ************* Properties *************** */

    /**
    */
    @property ContainerItemCollection items() { return m_items; }
    protected ContainerItemCollection m_items;


    /* ************* Public methods *************** */
}


/**
Creates a native container for composing elements in hidden layers with only one layer visible 
(just like IupZbox), but its visibility can be interactively controlled. The interaction is 
done in a line of tabs with titles and arranged according to the tab type. Also known as 
Notebook in native systems. 
*/
public class IupTabControl : IupContainerControlBase!IupControl
{
    protected class IupCallbacks : IupControl.IupCallbacks
    {
        enum TabChange = "TABCHANGE_CB";
        enum TabChangePos = "TABCHANGEPOS_CB";
        enum TabClose = "TABCLOSE_CB";
        enum RightClick = "RIGHTCLICK_CB";
    }

    class IupAttributes : IupControl.IupAttributes
    {
        enum IupTabControl = "IupTabControl";
        enum ChildOffset = "CHILDOFFSET";
        enum Count = "COUNT";
        enum Multiline = "MULTILINE";
        enum ShowClose = "SHOWCLOSE";
        enum TabImage = "TABIMAGE";
        enum TabOrientation = "TABORIENTATION";
        enum TabPadding = "TABPADDING";
        enum TabVisible = "TABVISIBLE";
        enum TabTitle = "TABTITLE";
        enum TabType = "TABTYPE";
        enum ValueHandle = "VALUE_HANDLE";
        enum ValuePos = "VALUEPOS";
    }

	this(IupControl[] children...)
	{
        super();
        m_items.append(children); 
	}


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupTabs(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerSelectedIndexChangedCallback(IupCallbacks.TabChangePos);
        registerTabClosingCallback(IupCallbacks.TabClose);
        registerTabRightClickCallback(IupCallbacks.RightClick);
    }


    /* ************* Events *************** */

    /**
    Callback called when the user shifts the active tab. Called only when TABCHANGE_CB is not defined.

    new_pos: the new tab position selected by the user 
    old_pos: the previously selected tab position
    */
    mixin EventCallback!(IupTabControl, "selectedIndexChanged", int, int);

    /**
    Callback called when the user clicks on the close button (since 3.10). Called only when SHOWCLOSE=Yes.

    pos: the tab position
    */
    mixin EventCallback!(IupTabControl, "tabClosing", int);

    /**
    Callback called when the user clicks on some tab using the right mouse button

    pos: the tab position
    */
    mixin EventCallback!(IupTabControl, "tabRightClick", int);


    /* ************* Properties *************** */

    /**
    enables the close button on each tab. Default value: "NO". In Windows the close button 
    imply the classic visual for the control. By default when closed the tab is hidden. 
    The change that behavior use the TABCLOSE_CB callback. 
    */
    @property 
    {
        public bool canShowClose() { 
            return getAttribute(IupAttributes.ShowClose) == FlagIdentifiers.Yes; 
        }

        public void canShowClose(bool value) {
            setAttribute(IupAttributes.ShowClose, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
     returns the number of tabs. Same value returned by IupGetChildCount. 
    */
    @property 
	{
		public int count() {  return getIntAttribute(IupAttributes.Count); }
	}

    /**
    Changes the active tab by its name. The value passed must be the name of one of the
    elements contained in the tabs. Use IupSetHandle or IupSetAttributeHandle to associate
    a child to a name. In Lua you can also use the element reference directly.
    */
    @property 
    {
        public string currentTabName() {  return getAttribute(IupAttributes.Value); }
        public void currentTabName(string value) { setAttribute(IupAttributes.Value, value); }
    }

    /**
    Changes the active tab by its position, starting at 0. When the tabs is created, the 
    first element inserted is set as the visible child. In GTK, inside the callback the 
    returned value is still the previous one.
    */
    @property 
	{
		public int currentTabIndex() {  return getIntAttribute(IupAttributes.ValuePos); }
        public void currentTabIndex(int index) { setIntAttribute(IupAttributes.ValuePos, index); }
	}

    /**
    Changes the active tab by its handle. The value passed must be the handle of a child 
    contained in the tabs. When the tabs is created, the first element inserted is set
    as the visible child.
    */
    @property 
	{
		public IupControl currentTab() {  
            int index = getIntAttribute(IupAttributes.ValuePos);
            return m_items[index]; 
        }

        public void currentTab(IupControl tabPage) { 
            setHandleAttribute(IupAttributes.ValueHandle, tabPage);
        }
	}

    /**
    Indicates the orientation of tab text, which can be "HORIZONTAL" or "VERTICAL". Default
    is "HORIZONTAL". VERTICAL is supported only in GTK and in Windows. In Windows, it can 
    NOT be set, it is dependent on the TABTYPE attribute, if TABTYPE=LEFT or TABTYPE=RIGHT 
    then TABORIENTATION=VERTICAL, if TABTYPE=TOP or TABTYPE=BOTTOM then TABORIENTATION=HORIZONTAL. 
    */
    @property 
    {
        public Orientation tabOrientation() { 
            string v = getAttribute(IupAttributes.TabOrientation); 
            return OrientationIdentifiers.convert(v);
        }

        public void tabOrientation(Orientation o) {
            setAttribute(IupAttributes.TabOrientation, OrientationIdentifiers.convert(o));
        }
    }

    /**
    internal margin of the tab title. Works just like the MARGIN attribute of the IupHbox and
    IupVbox containers, but uses a different name to avoid inheritance problems. Default value: "0x0". 
    */
    @property 
	{
		public Size tabPadding() { 
            string s = getAttribute(IupAttributes.TabPadding);
            return IupSize.parse(s); 
        }

		public void tabPadding(Size value) {
			setAttribute(IupAttributes.TabPadding, IupSize.format(value));
		}
	}

    /**
    Indicates the type of tab, which can be "TOP", "BOTTOM", "LEFT" or "RIGHT". Default is 
    "TOP". In Windows, if LEFT or RIGHT then MULTILINE=YES and TABORIENTATION=VERTICAL are 
    set, if TOP or BOTTOM then TABORIENTATION=HORIZONTAL is set. In Windows, when not TOP, 
    then visual style is removed from tabs.

    Notice: creation only in Windows
    */
    @property 
    {
        public Position tabPosition() { 
            string v = getAttribute(IupAttributes.TabType); 
            return PositionIdentifiers.convert(v);
        }

        public void tabPosition(Position p) {
            setAttribute(IupAttributes.TabType, PositionIdentifiers.convert(p));
        }
    }


    version(Windows)
    {
        /**
        Enable multiple lines of tab buttons. This will hide the tab scroll and fits to 
        make all tab buttons visible. Can be "YES" or "NO". Default "NO". It is always 
        enabled when TABTYPE=LEFT or TABTYPE=RIGHT.
        */
        @property 
        {
            public bool isMultiline() { return getAttribute(IupAttributes.Multiline) == FlagIdentifiers.Yes; }

            public void isMultiline(bool value) {
                setAttribute(IupAttributes.Multiline, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

    /* ************* Public methods *************** */

    /**
    */
    void addTabPage(IupControl child, string title)
    { 
        assert(child !is null);
        this.m_items.append(child);

        this.setTabTitle(this.count-1, title);
        child.map();
        this.refresh(); /* update children layout */
    }

    /**
    Contains the text to be shown in the respective tab title. n starts at 0. If this
    value is NULL, it will remain empty. The "&" character can be used to define a 
    mnemonic, the next character will be used as key. Use "&&" to show the "&" character
    instead on defining a mnemonic. The button can be activated from any control in the 
    dialog using the "Alt+key" combination. (mnemonic support since 3.3). When set after
    map will update the TABTITLE attribute on the respective child.
    */
    void setTabTitle(int index, string title)
    {
        setIdAttribute(IupAttributes.TabTitle, index, title);
    }

    /// ditto
    string getTabTitle(int index)
    {
        return getIdAttributeAsString(IupAttributes.TabTitle, index);
    }

    /**
    Allows to hide a tab. n starts at 0. When a tab is hidden the tabs indices are not 
    changed. Can be Yes or No. Default: Yes.
    */
    void setTabVisible(int index, bool isVisible)
    {
        setIdAttribute(IupAttributes.TabVisible, index, isVisible ? FlagIdentifiers.Yes : FlagIdentifiers.No);
    }

    /// ditto
    bool getTabVisible(int index)
    {
        return cast(bool)getIdAttributeAsInt(IupAttributes.TabVisible, index);
    }

    /**
    image name to be used in the respective tab. Use IupSetHandle or IupSetAttributeHandle
    to associate an image to a name. n starts at 0. See also IupImage. In Motif, the image
    is shown only if TABTITLEn is NULL. In Windows and Motif set the BGCOLOR attribute 
    before setting the image. When set after map will update the TABIMAGE attribute on 
    the respective child. 
    */
    void setTabImage(int index, iup.image.IupImage image)
    {
        setHandleAttribute(IupAttributes.TabImage ~ to!string(index), image);

        //setIdAttribute(IupAttributes.Image, id, image.handle);
    }

    /// ditto
    void setTabImage(int index, string imageName)
    {
        setIdAttribute(IupAttributes.TabImage, index, imageName);
    }

    /// ditto
    string getTabImageName(int index)
    {
        return getAttribute(IupAttributes.TabImage ~ to!string(index));
    }

}


alias IupNotebook = IupTabControl;