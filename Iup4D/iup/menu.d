module iup.menu;


import std.stdio;

import iup.c.core;
import iup.c.api;

import iup.control;
import iup.core;

import toolkit.container;
import toolkit.drawing;
import toolkit.event;

import std.algorithm;
import std.container.array;
import std.string;
import std.traits;


alias MenuItemCollection = ItemCollection!IupMenuElement;

/**
*/
public class IupMenu : IupElement
{
	protected class IupCallbacks : super.IupCallbacks
	{
		enum MenuOpen = "OPEN_CB";
        enum MenuClose = "MENUCLOSE_CB";
	}

	protected class IupAttributes : super.IupAttributes
	{
        enum Radio = "RADIO";
	}

	this(IupMenuElement[] children...)
	{
        super();
        m_items.append(children); 
	}


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupMenu(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        m_items = new MenuItemCollection();
        m_items.appended += &itemsAppended;
        m_items.inserted += &itemsInserted;
        m_items.removed += &itemsRemoved;

        registerOpenedCallback(IupCallbacks.MenuOpen);
        registerClosedCallback(IupCallbacks.MenuClose);
    }   

    private void itemsAppended(Object sender, IupMenuElement[] items)
    {
        foreach(IupMenuElement c ; items)
        {
            if(c is null) continue;
            iup.c.IupAppend(handle, c.handle);
        }
    }

    /**
    Inserts an interface element before another child of the container. Valid for any element 
    that contains other elements like dialog, frame, hbox, vbox, zbox, menu, etc.
    */
    private void itemsInserted(Object sender, size_t index, IupMenuElement[] items)
    {
        IupMenuElement current = m_items[index+items.length];
        foreach(IupMenuElement c ; items)
        {
            if(c is null) continue;
            iup.c.IupInsert(handle, current.handle, c.handle);
        }
    }
    
    /**
    to be removed
    */
    private void itemsRemoved(Object sender, size_t index, size_t count)
    {
        for(size_t i=index; i<index+count; i++)
        {
            IupMenuElement c = m_items[index];
            if(c is null) continue;
            iup.c.IupDestroy(c.handle);
        }
    }


    /* ************* Properties *************** */

    /**
    enables the automatic toggle of one child item. When a child item is selected the other item 
    is automatically deselected. The menu acts like a IupRadio for its children. Submenus and 
    their children are not affected.
    */
    @property 
	{
		public bool isRadio() { return getAttribute(IupAttributes.Radio) == FlagIdentifiers.Yes; }

		public void isRadio(bool value) 
		{
            setAttribute(IupAttributes.Radio,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
    }

    /**
    */
    @property MenuItemCollection items() { return m_items; }
    protected MenuItemCollection m_items;

    /* ************* Events *************** */

    /**
    Called just before the menu is opened.
    */
    mixin EventCallback!(IupMenu, "opened");

    /**
    Called just after the menu is closed.
    */
    mixin EventCallback!(IupMenu, "closed");


    /* ************* Public methods *************** */

    /**
    Shows a dialog or menu and restricts user interaction only to the specified element. It is 
    equivalent of creating a Modal dialog is some toolkits.

    If another dialog is shown after IupPopup using IupShow, then its interaction will not be 
    inhibited. Every IupPopup call creates a new popup level that inhibits all previous dialogs
    interactions, but does not disable new ones (even if they were disabled by the Popup, calling 
    IupShow will re-enable the dialog because it will change its popup level). IMPORTANT: The 
    popup levels must be closed in the reverse order they were created or unpredictable results 
    will occur.

    For a dialog this function will only return the control to the application after a callback 
    returns IUP_CLOSE, IupExitLoop is called, or when the popup dialog is hidden, for example
    using IupHide. For a menu it returns automatically after a menu item is selected. IMPORTANT: 
    If a menu item callback returns IUP_CLOSE, it will also ends the current popup level dialog. 
    */
    int popup(int x, int y) { return iup.c.IupPopup(handle, x, y); }

    /// ditto
    int popup(ScreenPostionH x, ScreenPostionV y) { return iup.c.IupPopup(handle, x, y); }

    /// ditto
    int popup() { 
        return iup.c.IupPopup(handle, ScreenPostionH.MousePos, ScreenPostionV.MousePos);
    }
}


/**
*/
public class IupMenuElement : IupElement
{	
    protected class IupCallbacks : super.IupCallbacks
    {
        enum Highlight = "HIGHLIGHT_CB";
    }

	protected class IupAttributes : super.IupAttributes
	{
		enum AutoToggle = "AUTOTOGGLE";
        enum Image = "IMAGE";
	}

    this(string title = "")
    {
        super(title);
    }


    protected override void onCreated()
    {    
        super.onCreated();
        registerHighlightedCallback(IupCallbacks.Highlight);
    }   

    /* ************* Events *************** */

    /**
    Action generated when the item is highlighted.
    */
    mixin EventCallback!(IupMenuElement, "highlighted");


    /* ************* Properties *************** */

    /**
    enables the automatic toggle of VALUE state when the item is activated. Default: NO. (since 3.0)
    */
    @property 
	{
		public bool canAutoToggle() { return getAttribute(IupAttributes.AutoToggle) == FlagIdentifiers.Yes; }

		public void canAutoToggle(bool value) 
		{
            setAttribute(IupAttributes.AutoToggle,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
    }

    /**
    Image name of the check mark image when VALUE=OFF. In Windows, an item in a menu bar cannot 
    have a check mark. Ignored if item in a menu bar. A recommended size would be 16x16 to fit 
    the image in the menu item. In Windows, if larger than the check mark area it will be cropped.
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

} 


/**
Creates a menu item that, when selected, opens another menu.
*/
public class IupSubmenu : IupMenuElement
{

    this()
    {
        m_menu = null;
        super("Submenu");
    }

	this(string title , IupMenu menu)
	{
        super(title);
        this.childMenu = menu;
	}

    protected override Ihandle* createIupObject()
    {
		return iup.c.api.IupSubmenu("Submenu", null);
    }

    /**
    */
	@property 
	{
		public iup.menu.IupMenu childMenu() { return m_menu; }

		private void childMenu(iup.menu.IupMenu value) 
		{
			m_menu = value;
			iup.c.api.IupAppend(handle, value is null ? null : value.handle);
		}
        private iup.menu.IupMenu m_menu; 
	}
}


/**
*/
public class IupMenuItem : IupMenuElement
{

	protected class IupAttributes : super.IupAttributes
	{
		enum HideMark  =        "HIDEMARK";
		enum ImPress =        "IMPRESS";
		enum TitleImage  =        "TITLEIMAGE";
		enum Value =          "VALUE";
	}

	protected class IupCallbacks : super.IupCallbacks
	{
        enum Action = "ACTION";
	}

	this(string title = "")
	{
        //m_checked = false;
        super(title);
		onCreated();
	}


	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupItem("", null);
	}


    protected override void onCreated()
    {
        //registerAttribute!IupObject(this);
        super.onCreated();
		registerClickCallback(IupCallbacks.Action);
    }


    /* ************* Events *************** */

	//
	mixin EventCallback!(IupMenuItem,  "click");


    /* ************* Properties *************** */

    /**
    If enabled the item cannot be checked, since the check box will not be shown. If all 
    items in a menu enable it, then no empty space will be shown in front of the items.
    Normally the unmarked check box will not be shown, but since GTK 2.14 the unmarked 
    check box is always shown. If your item will not be marked you must set HIDEMARK=YES, 
    since this is the most common case we changed the default value to YES for this version 
    of GTK, but if VALUE is defined the default goes back to NO. Default: NO. (since 3.0)
    */
    @property 
	{
		public bool canHideMark() { return getAttribute(IupAttributes.HideMark) == FlagIdentifiers.Yes; }

		public void canHideMark(bool value) 
		{
            setAttribute(IupAttributes.HideMark, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    Indicates the item's state. When the value is ON, a mark will be displayed to the left of
    the item. Default: OFF. An item in a menu bar cannot have a check mark. When IMAGE is used, 
    the checkmark is not shown. See the item AUTOTOGGLE attribute and the menu RADIO attribute.
    */
    @property 
	{
		public bool checked() { return getAttribute(IupAttributes.Value) == ToggleStateIdentifiers.On; }

		public void checked(bool value) 
		{
            setAttribute(IupAttributes.Value, value ? ToggleStateIdentifiers.On : ToggleStateIdentifiers.Off);
		}
	}

    /**
    Image name of the check mark image when VALUE=ON.
    */
    @property 
    {
        public string imagePressed() { return getAttribute(IupAttributes.ImPress); }

        public void imagePressed(string value) 
        {
            setAttribute(IupAttributes.ImPress, value);
        }

        public void imagePressed(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ImPress, value);
        }
    }

    /**
    Image name of the title image. In Windows, it appears before of the title text and after
    the check mark area (so both title and title image can be visible). In Motif, it must
    be at least defined during map, it replaces the text, and only images will be possible
    to set (TITLE will be hidden). In GTK, it will appear on the check mark area. (since 3.0)
    */
    @property 
    {
        public string titleImage() { return getAttribute(IupAttributes.TitleImage); }

        public void titleImage(string value) 
        {
            setAttribute(IupAttributes.TitleImage, value);
        }

        public void titleImage(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.TitleImage, value);
        }
    }
}

alias IupItem = IupMenuItem ;


/**
*/
public class IupMenuSeparator : IupMenuElement
{
    //this()
    //{
    //    super();
    //}

    protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupSeparator();
	}
}
//alias IupSeparator = IupMenuSeparator;


