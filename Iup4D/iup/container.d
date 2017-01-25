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
import toolkit.drawing;


public class IupBackgroundBox : iup.canvas.IupCanvas
{
    //protected class IupAttributes : super.IupAttributes
    //{
    //    enum CANVASBOX = "CANVASBOX";
    //    enum CHILDOFFSET = "CHILDOFFSET";
    //}


    this()
    {
        super();
    }


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
		public IupControl  child(){ return m_child; }
		public void child(IupControl value)
        { 
            // 检查IupDialog是否只允许1个子控件
            if(m_child !is null)
                iup.c.IupDetach(m_child.handle);

            m_child = value;
            iup.c.IupAppend(handle, value is null ? null : m_child.handle);
        }
        private  IupControl m_child;
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

    this()
    {
        super();
    }

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
		public IupControl  child(){ return m_child; }
		public void child(IupControl value)
        { 
            // 检查IupDialog是否只允许1个子控件
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

    protected class IupAttributes : super.IupAttributes
	{
        enum Alignment = "ALIGNMENT";
		enum ClientSize = "CLIENTSIZE";
	}


    protected Array!IupControl children;

    this()
    {
        super();
        expandOrientation = ExpandOrientation.Both;
    }

	this(IupControl[] children...)
	{
        append(children);
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
Creates a native container, which draws a frame with a title around its child.
*/
public class IupGroupBox : IupContentControl
{
    protected class IupAttributes : super.IupAttributes
	{
        enum IupGroupBox = "IupGroupBox";
        enum IupFrame = "IupFrame";
        enum ChildOffset = "CHILDOFFSET";
        enum Sunken = "SUNKEN";
	}


    this()
    {
        super();
    }


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

    //override protected void onCreated()
    //{
    //    super.onCreated();
    //}


    /* ************* Properties *************** */


    /**
    Allow to specify a position offset for the child. Available for native containers only. 
    It will not affect the natural size, and allows to position controls outside the client 
    area. Format "dxxdy", where dx and dy are integer values corresponding to the horizontal
    and vertical offsets, respectively, in pixels. Default: 0x0. (since 3.14)
    */   
    @property 
	{
		public OffsetXY childOffset() 
        { 
            string s = getAttribute(IupAttributes.ChildOffset);
            return IupOffsetXY.parse(s); 
        }

		public void childOffset(OffsetXY value) 
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
		public bool isSunken()  {  return getAttribute(IupAttributes.Sunken) == FlagIdentifiers.Yes; }

        public void isSunken(bool value) { 
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
    protected class IupAttributes : super.IupAttributes
	{
        enum IupRadioBox = "IupRadioBox";
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
		return iup.c.IupRadio(null);
	}

    //override protected void onCreated()
    //{
    //    super.onCreated();
    //}
}

//alias IupRadio = IupRadioBox;
alias IupRadioGroup = IupRadioBox;


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

        void color(Color value)  { setAttribute(IupAttributes.Color, value.toRgb()); }

        void color(string value)  { setAttribute(IupAttributes.Color, value); }
    }

    /** 
    controls the size of the bar handler. Default: 5.
    */
    @property 
	{
		public int barSize()  {  return getIntAttribute(IupAttributes.BarSize); }
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

        public void cropRange(string value)  {
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
		public int proportion()  {  return getIntAttribute(IupAttributes.Value); }
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

        public void canShowClose(bool value)  {
            setAttribute(IupAttributes.ShowClose, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
     returns the number of tabs. Same value returned by IupGetChildCount. 
    */
    @property 
	{
		public int count()  {  return getIntAttribute(IupAttributes.Count); }
	}

    /**
    Changes the active tab by its name. The value passed must be the name of one of the
    elements contained in the tabs. Use IupSetHandle or IupSetAttributeHandle to associate
    a child to a name. In Lua you can also use the element reference directly.
    */
    @property 
    {
        public string currentTabName()  {  return getAttribute(IupAttributes.Value); }
        public void currentTabName(string value) { setAttribute(IupAttributes.Value, value); }
    }

    /**
    Changes the active tab by its position, starting at 0. When the tabs is created, the 
    first element inserted is set as the visible child. In GTK, inside the callback the 
    returned value is still the previous one.
    */
    @property 
	{
		public int currentTabIndex()  {  return getIntAttribute(IupAttributes.ValuePos); }
        public void currentTabIndex(int index) { setIntAttribute(IupAttributes.ValuePos, index); }
	}

    /**
    Changes the active tab by its handle. The value passed must be the handle of a child 
    contained in the tabs. When the tabs is created, the first element inserted is set
    as the visible child.
    */
    @property 
	{
		public IupControl currentTab()  {  
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

            public void isMultiline(bool value)  {
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