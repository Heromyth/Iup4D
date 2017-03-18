module iup.list;

import iup.control;
import iup.core;
import iup.image;

import iup.c.core;
import iup.c.api;

import toolkit.container;
import toolkit.drawing;
import toolkit.event;

import std.string;
import std.conv;


/**
Creates an interface element that displays a list of items. The list can be visible or can be dropped down. 
It also can have an edit box for text input. So it is a 4 in 1 element. In native systems the dropped down 
case is called Combo Box.
*/
public class IupListControl : IupStandardControl
{
    protected class IupCallbacks : super.IupCallbacks
    {
		enum Button = "BUTTON_CB";
		enum DragDrop = "DRAGDROP_CB";
		enum DoubleClick = "DBLCLICK_CB";
		enum Motion = "MOTION_CB";
		enum ValueChanged = "VALUECHANGED_CB";
    }

	class IupAttributes : super.IupAttributes
	{
        enum IupListControl = "IupListControl";
        enum AppendItem = "APPENDITEM";
        enum AutoHide = "AUTOHIDE";
        enum AUTOREDRAW = "AUTOREDRAW";
        enum Count = "COUNT";
        enum DRAGDROPLIST   = "DRAGDROPLIST";
        enum DROPFILESTARGET = "DROPFILESTARGET";
        enum IMAGE = "IMAGE";
        enum InsertItem   = "INSERTITEM";
        enum RemoveItem   = "REMOVEITEM";
        enum SCROLLBAR = "SCROLLBAR";
        enum SHOWDRAGDROP   = "SHOWDRAGDROP";
        //enum SHOWDROPDOWN = "SHOWDROPDOWN";
        enum SHOWIMAGE   = "SHOWIMAGE";
        enum SIZE = "SIZE";
        enum SORT   = "SORT";
        enum TopItem = "TOPITEM";
        enum Spacing   = "SPACING";
        enum ValueString = "VALUESTRING";
        enum VALUEMASKED = "VALUEMASKED";
        enum VisibleItems   = "VISIBLEITEMS";
        enum VisibleColumns = "VISIBLECOLUMNS";
        enum VisibleLines   = "VISIBLELINES";

        enum DropDown   = "DROPDOWN";
        enum EditBox   = "EDITBOX";
	}


	this()
	{
        m_items = new StringItemCollection();
		super();
	}

    this(string[] items...)
    {
        m_items = new StringItemCollection(items);
		super();

        for(int i=0; i<items.length; i++)
            setAttribute(to!string(i+1),  items[i]);
    }

    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupList(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        m_items.appended += &itemsAdded;
        m_items.inserted += &itemsInserted;
        m_items.removed += &itemsRemoved;
        m_items.updated += &itemUpdated;
        m_items.cleared += &itemsCleared;

        registerDoubleClickCallback(IupCallbacks.DoubleClick);
        registerMouseClickCallback(IupCallbacks.Button);
        registerMouseMoveCallback(IupCallbacks.Motion);
        registerSelectedItemChangedCallback(IupCallbacks.Action);
        registerSelectedValueChangedCallback(IupCallbacks.ValueChanged);

        m_scrollBar = new IupScrollBar(this);
    }

    private void itemUpdated(Object sender, int index, string newValue)
    {
        setAttribute(to!string(index+1), newValue);
    }

    private void itemsCleared(Object sender)
    {
        //clearAttribute("1");
        setAttribute(IupAttributes.RemoveItem, "ALL");
    }

    private void itemsAdded(Object sender, string[] items)
    {
        foreach(string c ; items)
        {
            setAttribute(IupAttributes.AppendItem, c);
        }
    }

    /**
    Inserts an item before the given index position.
    */
    private void itemsInserted(Object sender, int index, string[] items)
    {
        for(int i=0; i<items.length; i++)
        {
            // inserts an item before the given id position. id starts at 1. If id=COUNT+1 then it will
            // append after the last item. Ignored if out of bounds. Ignored if set before map.
            //iup.c.IupSetAttributeId(this.handle, std.string.toStringz(IupAttributes.InsertItem),
            //                        index+1+i, std.string.toStringz(items[i]));

            setIdAttribute(IupAttributes.InsertItem, index+1+i, items[i]);
        }
    }

    /**
    to be removed
    */
    private void itemsRemoved(Object sender, int index, int count)
    {
        string id = to!string(index+1);
        for(int i=0; i<count; i++)
        {
            setAttribute(IupAttributes.RemoveItem, id);
        }
    }


    /* ************* Events *************** */

    /**
    Action generated when the user double click an item. Called only when DROPDOWN=NO. (since 3.0)

    item: Number of the selected item starting at 0.
    text: Text of the selected item.
    */
    EventHandler!(CallbackEventArgs, int, string)  doubleClick;
    mixin EventCallbackAdapter!(IupListBox, "doubleClick", int, const(char)*);
    private IupElementAction onDoubleClick(int index, const(char) *text) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(text);
            doubleClick(this, callbackArgs, index - 1, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }


    /**
    Action generated when a mouse button is pressed or released.
    */
    EventHandler!(CallbackEventArgs, MouseButtons, MouseState, int, int, string)  mouseClick;
    mixin EventCallbackAdapter!(IupListControl, "mouseClick", int, int, int, int, const(char)*);
    private IupElementAction onMouseClick(int button, int pressed, int x, int y, const(char) *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
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
    EventHandler!(CallbackEventArgs, int, int, string)  mouseMove;
    mixin EventCallbackAdapter!(IupListControl, "mouseMove", int, int, const(char)*);
    private IupElementAction onMouseMove(int x, int y, const(char) *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
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

    /**
    Called after the value was interactively changed by the user. Called when the selection
    is changed or when the text is edited. (since 3.0)
    */
    mixin EventCallback!(IupListControl, "selectedValueChanged");

    /**
    Action generated when the state of an item in the list is changed. Also provides 
    information on the changed item

    text: Text of the changed item.
    item: Number of the changed item starting at 1.
    state: Equal to 1 if the option was selected or to 0 if the option was deselected.

    The state=0 is simulated internally by IUP in all systems. If you add or remove items to/from 
    the list and you count on the state=0 value, then after adding/removing items set the VALUE 
    attribute to ensure proper state=0 value.
    */
    EventHandler!(CallbackEventArgs, int, string, bool) selectedItemChanged;
    mixin EventCallbackAdapter!(IupListControl, "selectedItemChanged", const(char)*,int, int);
    private IupElementAction onSelectedItemChanged(const(char) *text, int index, int state) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(text);
            selectedItemChanged(this, callbackArgs, index - 1, s, state == 1);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /* ************* Properties *************** */

    /**
    returns the number of items. Before mapping it counts the number of non NULL items before the first NULL item. (since 3.0)
    */
	//@property int itemsCount()  { return getIntAttribute(IupAttributes.Count); }


    /**
    scrollbars are shown only if they are necessary. Default: "YES".
    */
    @property 
    {
        bool autoHideScrollbar() { return getAttribute(IupAttributes.AutoHide) == FlagIdentifiers.Yes; }

        void autoHideScrollbar(bool value) {
            setAttribute(IupAttributes.AutoHide,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }


    /**
    Changes the appearance of the list for the user: only the selected item is shown beside a button with the 
    image of an arrow pointing down. To select another option, the user must press this button, which displays 
    all items in the list. Can be "YES" or "NO". Default "NO".
    */
    @property 
	{
		bool hasDropDown() { return getAttribute(IupAttributes.DropDown) == FlagIdentifiers.Yes; }

		protected void hasDropDown(bool value) {
            setAttribute(IupAttributes.DropDown,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}


    /**
    Adds an edit box to the list. Can be "YES" or "NO". Default "NO".
    */
    @property 
	{
		bool hasEditBox()  {  return getAttribute(IupAttributes.EditBox) == FlagIdentifiers.Yes; }

        protected void hasEditBox(bool value) { 
            setAttribute(IupAttributes.EditBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    */
    @property StringItemCollection items() { return m_items; }
    protected StringItemCollection m_items;

    /**
    Valid only when MULTILINE=YES. Associates an automatic horizontal and/or vertical scrollbar
    to the multiline. Can be: "VERTICAL", "HORIZONTAL", "YES" (both) or "NO" (none). Default: 
    "YES". For all systems, when SCROLLBAR!=NO the natural size will always include its size 
    even if the native system hides the scrollbar. If AUTOHIDE=YES scrollbars are visible only
    if they are necessary, by default AUTOHIDE=NO. In Windows when FORMATTING=NO, AUTOHIDE is 
    not supported. In Motif AUTOHIDE is not supported.
    */
    @property 
	{
		IupScrollBar scrollBars() { return m_scrollBar; }
		protected void scrollBars(IupScrollBar value) { m_scrollBar = value; }
        private IupScrollBar m_scrollBar; 
	}

    /**
    internal padding for each item. Notice that vertically the distance between each item 
    will be actually 2x the spacing. It also affects the horizontal margin of the item. 
    In Windows, the text is aligned at the top left of the item always. Valid only when 
    DROPDOWN=NO. (since 3.0)
    */
    @property 
	{
		int spacing()  {  return getIntAttribute(IupAttributes.Spacing); }
        void spacing(int value) { setIntAttribute(IupAttributes.Spacing, value);}
	}

    /**
    Depends on the DROPDOWN+EDITBOX combination:

    EDITBOX=YES: Text entered by the user. 
    DROPDOWN=YES or MULTIPLE=NO: Integer number representing the selected item in the list (begins at 1). It can be zero if there is no selected item. The value can be NULL for no item selected (since 3.0) (In Motif when DROPDOWN=YES there is always an item selected, except only when the list is empty). 
    MULTIPLE=YES: Sequence of '+' and '-' symbols indicating the state of each item. When setting this value, the user must provide the same amount of '+' and '-' symbols as the amount of items in the list, otherwise the specified items will be deselected. 
    Obs: always returns a non NULL value, event if the list is empty or the text box is empty. 
    */
    @property 
	{
		string text()  {  
            if(hasDropDown && !hasEditBox)
                return getAttribute(IupAttributes.ValueString); 
            else
                return getAttribute(IupAttributes.Value); 
        }

        void text(string value) { 
            if(hasDropDown && !hasEditBox)
                setAttribute(IupAttributes.ValueString, value);
            else
                setAttribute(IupAttributes.Value, value);
        }
	}

    /**
    Defines the number of visible columns for the Natural Size, this means that will act also 
    as minimum number of visible columns. It uses a wider character size then the one used 
    for the SIZE attribute so strings will fit better without the need of extra columns. 
    Set this attribute to speed Natural Size computation for very large lists. (since 3.0)
    */
    @property 
	{
		int visibleColumns()  {  return getIntAttribute(IupAttributes.VisibleColumns); }
        void visibleColumns(int value) { setIntAttribute(IupAttributes.VisibleColumns, value);}
	}

    /**
    Number of items that are visible when DROPDOWN=YES is used for the dropdown list. Default: 5.
    */
    @property 
	{
		int visibleItems()  {  return getIntAttribute(IupAttributes.VisibleItems); }
        void visibleItems(int value) { setIntAttribute(IupAttributes.VisibleItems, value);}
	}

    /**
    When DROPDOWN=NO defines the number of visible lines for the Natural Size, this means that
    will act also as minimum number of visible lines. (since 3.0)
    */
    @property 
	{
		int visibleLines()  {  return getIntAttribute(IupAttributes.VisibleLines); }
        void visibleLines(int value) { setIntAttribute(IupAttributes.VisibleLines, value);}
	}


    /* ************* Public methods *************** */

    /**
    Converts a (x,y) coordinate in an item position.
    */
    int convertToPos(int x, int y)
    {
        return iup.c.api.IupConvertXYToPos(this.handle, x, y);
    }

    /**
    position the given item at the top of the list or near to make it visible. Valid only
    when DROPDOWN=NO. (since 3.0)
    */
    void scrollToItem(int index)
    {
        setIntAttribute(IupAttributes.TopItem, index+1);
    }

    //void convertPosToLinCol(int pos, ref int row, ref int col)
    //{
    //    iup.c.api.IupTextConvertPosToLinCol(this.handle, pos, &row, &col);
    //}
    //
    //int convertLinColToPos(int row, int col)
    //{
    //    int pos;
    //    iup.c.api.IupTextConvertLinColToPos(this.handle, row, col, &pos);
    //    return pos;
    //}

    /**
    inserts an item after the last item. Ignored if set before map. (since 3.0)
    */
    //void appendItem(string value)
    //{
    //    setAttribute(IupAttributes.AppendItem,  value);
    //}

    /**
    The values can be any text. 
    */
    //void updateItem(int index, string value)
    //{
    //    if(value.empty)
    //        clearAttribute(to!string(index+1));
    //    else
    //        setAttribute(to!string(index+1),  value);
    //}

    //void clearAll()
    //{
    //    clearAttribute("1");
    //}
}


/**
*/
public class IupComboBox : IupListControl
{

    protected class IupCallbacks : super.IupCallbacks
    {
        enum Caret = "CARET_CB";
		enum Edit = "EDIT_CB";
		enum DropDown = "DROPDOWN_CB";
    }

    class IupAttributes : super.IupAttributes
	{
        enum Append = "APPEND";
        enum Caret = "CARET";
        enum DropExpand = "DROPEXPAND";
        enum ReadOnly = "READONLY";
        enum ShowDropDown = "SHOWDROPDOWN";
        enum ValueMasked = "VALUEMASKED";
    }

    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();
        dropDownStyle = ComboBoxStyle.DropDown;

        registerCaretMoveCallback(IupCallbacks.Caret);
        registerDropDownCallback(IupCallbacks.DropDown);
        registerTextChangingCallback(IupCallbacks.Edit);
    }


    /**
    */
    this()  { super(); }

    /**
    */
    this(string[] items...) { super(items); }


    /* ************* Events *************** */

    /**
    Action generated when the caret/cursor position is changed.  Valid only when EDITBOX=YES.
    
    lin, col: line and column number (start at 1).
    pos: 0 based character position.

    For lists lin is always 1, and pos is always "col-1".
    */
    mixin EventCallback!(IupComboBox, "caretMove", int, int, int);

    /**
    Action generated when the list of a dropdown is shown or hidden. Called only when 
    DROPDOWN=YES. (since 3.0)

    state: state of the list 1=shown, 0=hidden.
    */
    mixin EventCallback!(IupComboBox, "dropDown", bool);

    /**
    Action generated when the text in the text box is manually changed by the user, but 
    before its value is actually updated. Valid only when EDITBOX=YES.
    */
    EventHandler!(CallbackEventArgs, int, string)  textChanging;
    mixin EventCallbackAdapter!(IupComboBox, "textChanging", int, const(char)*);

    /**
    c: valid alpha numeric character or 0.
    new_value: Represents the new text value.
    */
    private IupElementAction onTextChanging(int c, const char *newValue) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(newValue);
            textChanging(this, callbackArgs, c, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }


    /* ************* Properties *************** */

    version(Windows)
    {
        /**
        When DROPDOWN=Yes the size of the dropped list will expand to include the largest text. 
        Can be "YES" or "NO". Default: "YES".
        */
        @property 
        {
            bool canDropExpand() { return getAttribute(IupAttributes.DropExpand) == FlagIdentifiers.Yes; }

            void canDropExpand(bool value) {
                setAttribute(IupAttributes.DropExpand,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

    /**
    Character position of the insertion point. Its format depends in MULTILINE=YES. The first 
    position, lin or col, is "1".
    */
    @property 
    {
        int caretLocation() { return getIntAttribute(IupAttributes.Caret); }

        void caretLocation(int value) 
        {
            setIntAttribute(IupAttributes.Caret, value);
        }
    }


    /**
    */
    @property 
	{
		ComboBoxStyle dropDownStyle()  {
            //bool m_hasDropDown = this.hasDropDown;
            //bool m_hasEditBox = this.hasEditBox;

            if(!this.hasDropDown) return ComboBoxStyle.Simple;
            if(!this.hasEditBox) return ComboBoxStyle.DropDownList;

            return ComboBoxStyle.DropDown;
        }

        void dropDownStyle(ComboBoxStyle value) { 
            if(value == ComboBoxStyle.Simple)
            {
                this.hasEditBox = true;
                this.hasDropDown = false;
            }
            else if(value == ComboBoxStyle.DropDown)
            {
                this.hasEditBox = true;
                this.hasDropDown = true;
            }
            else if(value == ComboBoxStyle.DropDownList)
            {
                this.hasEditBox = false;
                this.hasDropDown = true;
            }
            //setIntAttribute(IupAttributes.VisibleItems, value);
        }
	}

    /**
    Allows the user only to read the contents, without changing it. Restricts keyboard input only, 
    text value can still be changed using attributes. Navigation keys are still available.
    Possible values: "YES", "NO". Default: NO.
    */
    @property 
	{
		bool isReadOnly() { return getAttribute(IupAttributes.ReadOnly) == FlagIdentifiers.Yes; }

		void isReadOnly(bool value) {
            setAttribute(IupAttributes.ReadOnly,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    */
    @property 
	{
		int selectedIndex()  {  
            if(hasEditBox)
                return 0;
            else
                return getIntAttribute(IupAttributes.Value) - 1; 
        }

        void selectedIndex(int value) { setIntAttribute(IupAttributes.Value, value+1);}
	}


    /* ************* Public methods *************** */


    /**
    Inserts a text at the end of the current text. In the Multiline, if APPENDNEWLINE=YES,
    a "\n" character will be automatically inserted before the appended text if the current
    text is not empty(APPENDNEWLINE default is YES). Ignored if set before map.
    */
    void appendText(string text)
    {
        setAttribute(IupAttributes.Append, text);
    }

    /**
    opens or closes the dropdown list. Can be "YES" or "NO". Valid only when DROPDOWN=YES. 
    Ignored if set before map. 
    */
    void toggleDropdown() { setAttribute(IupAttributes.ShowDropDown, FlagIdentifiers.Yes); }

    /// ditto
    //void openDropdown() { setAttribute(IupAttributes.ShowDropDown, FlagIdentifiers.Yes); }

    /**
    sets VALUE but first checks if it is validated by MASK. If not does nothing. Works only 
    when EDITBOX=YES. (since 3.13)
    */
    void setMask(string text)
    {
        setAttribute(IupAttributes.ValueMasked, text);
    }

}

//alias IupList = IupComboBox;

// Summary:
//     Specifies the System.Windows.Forms.ComboBox style.
enum ComboBoxStyle
{
    // Summary:
    //     Specifies that the list is always visible and that the text portion is editable.
    //     This means that the user can enter a new value and is not limited to selecting
    //     an existing value in the list.
    Simple = 0,
        //
        // Summary:
        //     Specifies that the list is displayed by clicking the down arrow and that
        //     the text portion is editable. This means that the user can enter a new value
        //     and is not limited to selecting an existing value in the list. When using
        //     this setting, the System.Windows.Forms.AutoCompleteMode.Append value of System.Windows.Forms.ComboBox.AutoCompleteMode
        //     works the same as the System.Windows.Forms.AutoCompleteMode.SuggestAppend
        //     value. This is the default style.
        DropDown = 1,
        //
        // Summary:
        //     Specifies that the list is displayed by clicking the down arrow and that
        //     the text portion is not editable. This means that the user cannot enter a
        //     new value. Only values already in the list can be selected. The list displays
        //     only if System.Windows.Forms.ComboBox.AutoCompleteMode is System.Windows.Forms.AutoCompleteMode.Suggest
        //     or System.Windows.Forms.AutoCompleteMode.SuggestAppend.
        DropDownList = 2,
}


/**
*/
public class IupListBox : IupListControl
{

    protected class IupCallbacks : super.IupCallbacks
    {
        enum MultiSelect  = "MULTISELECT_CB";
    }


    protected class IupAttributes : super.IupAttributes
	{
        enum Multiple = "MULTIPLE";
        enum EditBox   = "EDITBOX";
    }

    /**
    */
    this()  { super(); }

    /**
    */
    this(string[] items...) { super(items); }



    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();

        registerMultiSelectedCallback(IupCallbacks.MultiSelect);
    }

    /* ************* Events *************** */

    /**
    Action generated when the state of an item in the multiple selection list is changed.
    But it is called only when the interaction is over.
    */
    EventHandler!(CallbackEventArgs, string)  multiSelected;
    mixin EventCallbackAdapter!(IupListBox, "multiSelected", const(char)*);

    /**
    value: Similar to the VALUE attribute for a multiple selection list. Items selected are
    marked with '+', items deselected are marked with '-', and non changed items are marked
    with an 'x'.
    */
    private IupElementAction onMultiSelected(const char *value) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(value);
            multiSelected(this, callbackArgs, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }


    /* ************* Properties *************** */

    /**
    Allows selecting several items simultaneously (multiple list). Default: "NO". Only valid 
    when EDITBOX=NO and DROPDOWN=NO.
    */
    @property 
    {
        bool isMultiSelectable() { return getAttribute(IupAttributes.Multiple) == FlagIdentifiers.Yes; }

        void isMultiSelectable(bool value) {
            setAttribute(IupAttributes.Multiple,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }


    /**
    */
    @property 
	{
		int selectedIndex()  {  
            return getIntAttribute(IupAttributes.Value) - 1; 
        }

        void selectedIndex(int value) { setIntAttribute(IupAttributes.Value, value+1);}
	}

}


/**
*/
public class IupTree : IupStandardControl
{

    protected class IupCallbacks : super.IupCallbacks
    {
		enum Button = "BUTTON_CB";
        enum Selection = "SELECTION_CB";
		enum Motion = "MOTION_CB";
        enum MultiSelection = "MULTISELECTION_CB";
        enum MultiUnselection = "MULTIUNSELECTION_CB";
        enum BranchOpen = "BRANCHOPEN_CB";
        enum BranchClose = "BRANCHCLOSE_CB";
        enum ExecuteLeaf = "EXECUTELEAF_CB";
        enum ShowRename = "SHOWRENAME_CB";
        enum Rename = "RENAME_CB";
        enum DragDrop = "DRAGDROP_CB";
        enum NodeRemoved = "NODEREMOVED_CB";
        enum RightClick = "RIGHTCLICK_CB";
		enum ToggleValue = "TOGGLEVALUE_CB";
    }

	class IupAttributes : super.IupAttributes
	{
        enum IupTree = "IupTree";
        enum AddExpanded = "ADDEXPANDED";
        enum AddRoot = "ADDROOT";
        enum AutoRedraw = "AUTOREDRAW";
        enum Count = "COUNT";
        enum DragDropTree = "DRAGDROPTREE";
        enum DropEqualDrag  = "DROPEQUALDRAG ";
        enum EmptyAs3State  = "EMPTYAS3STATE ";
        enum HideLines = "HIDELINES";
        enum HideButtons = "HIDEBUTTONS";
        enum HlColor = "HLCOLOR";
        enum Indentation = "INDENTATION";
        enum InfoTip = "INFOTIP";
        enum ShowDragDrop = "SHOWDRAGDROP";
        enum ShowToggle = "SHOWTOGGLE";
        enum Spacing = "SPACING";
        enum TopItem = "TOPITEM";

        enum Image = "IMAGE";
        enum ImageExpanded = "IMAGEEXPANDED";
        enum ImageLeaf = "IMAGELEAF";
        enum ImageBranchCollapsed = "IMAGEBRANCHCOLLAPSED";
        enum ImageBranchExpanded = "IMAGEBRANCHEXPANDED";

        enum Mark = "MARK";
        enum Marked = "MARKED";
        enum MarkedNodes = "MARKEDNODES";
        enum MarkMode = "MARKMODE";
        enum MarkStart = "MARKSTART";

        enum Rename = "RENAME";
        enum RenameCaret = "RENAMECARET";
        enum RenameSelection = "RENAMESELECTION";
        enum ShowRename = "SHOWRENAME";
    }


	struct NodesAttributes
	{
        enum ChildCount = "CHILDCOUNT";
        enum Color = "COLOR";
        enum Depth = "DEPTH";
        enum Kind = "KIND";
        enum Parent = "PARENT";
        enum State = "STATE";
        enum Title = "TITLE";
        enum TitleFont = "TITLEFONT";
        enum ToggleValue = "TOGGLEVALUE";
        enum ToggleVisible = "TOGGLEVISIBLE";
        enum TotalChildCount = "TOTALCHILDCOUNT";
        enum UserData = "USERDATA";
    }

    struct HierarchyAttributes
	{
        enum AddLeaf = "ADDLEAF";
        enum AddBranch = "ADDBRANCH";
        enum CopyNode = "COPYNODE";
        enum DelNode = "DELNODE";
        enum ExpandAll = "EXPANDALL";
        enum InsertLeaf = "INSERTLEAF";
        enum InsertBranch = "INSERTBRANCH";
        enum Movenode = "MOVENODE";
    }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupTree();
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerBranchCollapsedCallback(IupCallbacks.BranchClose);
        registerBranchExpandedCallback(IupCallbacks.BranchOpen);
        registerDragDropCallback(IupCallbacks.DragDrop);
        registerExecuteLeafCallback(IupCallbacks.ExecuteLeaf);
        registerMouseClickCallback(IupCallbacks.Button);
        registerMouseMoveCallback(IupCallbacks.Motion);
        registerMultipleSelectedCallback(IupCallbacks.MultiSelection);
        registerNodeRemovedCallback(IupCallbacks.NodeRemoved);
        registerNodeRenamedCallback(IupCallbacks.Rename);
        registerNodeRenamingCallback(IupCallbacks.ShowRename);
        registerRightClickCallback(IupCallbacks.RightClick);
        registerSelectionStateChangedCallback(IupCallbacks.Selection);
        registerToggleStateChangedCallback(IupCallbacks.ToggleValue);
    }

    /* ************* Events *************** */

    /**
    Action generated when a branch is collapsed. This action occurs when the user clicks 
    the "-" sign on the left of the branch, or when double clicks the branch, or hits 
    Enter on an expanded branch. 

    id: node identifier. 
    */
    mixin EventCallback!(IupTree, "branchCollapsed", int);

    /**
    Action generated when a branch is expanded. This action occurs when the user clicks 
    the "+" sign on the left of the branch, or when double clicks the branch, or hits 
    Enter on a collapsed branch.

    id: node identifier. 
    */
    mixin EventCallback!(IupTree, "branchExpanded", int);

    /**
    Action generated when an internal drag & drop is executed. Only active if SHOWDRAGDROP=YES.

    drag_id: Identifier of the clicked node where the drag start. 
    drop_id: Identifier of the clicked node where the drop were executed. -1 indicates a 
    drop in a blank area.
    isshift: flag indicating the shift key state. 
    iscontrol: flag indicating the control key state.

    Returns: if returns IUP_CONTINUE, or if the callback is not defined and SHOWDRAGDROP=YES, 
    then the node is moved to the new position. If Ctrl is pressed then the node is copied 
    instead of moved. If the drop node is a branch and it is expanded, then the drag node 
    is inserted as the first child of the node. If the branch is not expanded or the node 
    is a leaf, then the drag node is inserted as the next brother of the drop node.
    */
    mixin EventCallback!(IupTree, "dragDrop", int, int, bool, bool);

    /**
    Action generated when a leaf is to be executed. This action occurs when the user 
    double clicks a leaf, or hits Enter on a leaf. 

    id: node identifier. 
    */
    mixin EventCallback!(IupTree, "executeLeaf", int);


    /**
    Action generated when a mouse button is pressed or released.
    */
    EventHandler!(CallbackEventArgs, MouseButtons, MouseState, int, int, string)  mouseClick;
    mixin EventCallbackAdapter!(IupTree, "mouseClick", int, int, int, int, const(char)*);
    private IupElementAction onMouseClick(int button, int pressed, int x, int y, const(char) *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
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
    EventHandler!(CallbackEventArgs, int, int, string)  mouseMove;
    mixin EventCallbackAdapter!(IupTree, "mouseMove", int, int, const(char)*);
    private IupElementAction onMouseMove(int x, int y, const(char) *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
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

    /**
    Action generated after a continuous range of nodes is selected in one single operation.
    If not defined the SELECTION_CB with status=1 will be called for all nodes in the range. 
    The range is always completely included, independent if some nodes were already marked. 
    That single operation also guaranties that all other nodes outside the range are already 
    not selected. Called only if MARKMODE=MULTIPLE.

    ids: Array of node identifiers. This array is kept for backward compatibility, the range
    is simply defined by ids[0] to ids[n-1], where ids[i+1]=ids[i]+1.
    */
    EventHandler!(CallbackEventArgs, int[])  multipleSelected;
    /// ditto
    mixin EventCallbackAdapter!(IupTree, "multipleSelected", int*, int);
    /// ditto
    private IupElementAction onMultipleSelected(int* ids, int n) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            int[] idList = new int[n];
            for(int i=0; i<n; i++)
                idList[i] = ids[i];

            auto callbackArgs = new CallbackEventArgs();
            multipleSelected(this, callbackArgs, idList);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }

    /**
    Action generated when a node is going to be removed. It is only a notification, the 
    action can not be aborted. No node dependent attribute can be consulted during the 
    callback. Not called when the tree is unmapped. It is useful to remove memory allocated 
    for the userdata.

    userdata/userid: USERDATA attribute in C, or userid object in Lua.
    */
    mixin EventCallback!(IupTree, "nodeRemoved", void*);

    /**
    Action generated after a node was renamed in place. It occurs when the user press 
    Enter after editing the name, or when the text box looses it focus. Called only 
    if SHOWRENAME=YES.
    */
    EventHandler!(CallbackEventArgs, int, string)  nodeRenamed;
    /// ditto
    mixin EventCallbackAdapter!(IupTree, "nodeRenamed", int, char*);
    /// ditto
    private IupElementAction onNodeRenamed(int id, char *title) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            nodeRenamed(this, callbackArgs, id, cast(string)std.string.fromStringz(title));
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }

    /**
    Action generated when a node is about to be renamed. It occurs when the user clicks
    twice the node or press F2. Called only if SHOWRENAME=YES.

    id: node identifier. 
    Returns: if IUP_IGNORE is returned, the rename is canceled (in GTK the rename continuous
    but the edit box is read-only).
    */
    mixin EventCallback!(IupTree, "nodeRenaming", int);

    /**
    Action generated when the right mouse button is pressed over a node.

    id: node identifier. 
    */
    mixin EventCallback!(IupTree, "rightClick", int);

    /**
    Action generated when a node is selected or deselected. This action occurs when 
    the user clicks with the mouse or uses the keyboard with the appropriate combination 
    of keys. It may be called more than once for the same node with the same status.

    id: Node identifier.
    status: 1=node selected, 0=node unselected. 
    */
    mixin EventCallback!(IupTree, "selectionStateChanged", int, bool);

    /**
    Action generated when the toggle's state was changed. The callback also receives 
    the new toggle's state.

    id: node identifier. 
    state: 1 if the toggle's state was shifted to ON; 0 if it was shifted to OFF. If 
    SHOW3STATE=YES, −1 if it was shifted to NOTDEF.
    */
    EventHandler!(CallbackEventArgs, int, ToggleState)  toggleStateChanged;
    mixin EventCallbackAdapter!(IupTree, "toggleStateChanged", int, int);

    private IupElementAction onToggleStateChanged(int id, int state) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            toggleStateChanged(this, callbackArgs, id, cast(ToggleState)state);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }


    /* ************* Properties *************** */

    /**
    automatically adds an empty branch as the first node when the tree is mapped. Default: "YES".
    */
    @property 
	{
        bool canAddRoot() { return getAttribute(IupAttributes.AddRoot) == FlagIdentifiers.Yes; }

        void canAddRoot(bool value)  {
            setAttribute(IupAttributes.AddRoot, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    automatically redraws the tree when something has change. Set to NO to add many items to
    the tree without updating the display. Default: "YES".
    */
    @property 
	{
        bool canAutoRedraw() { return getAttribute(IupAttributes.AutoRedraw) == FlagIdentifiers.Yes; }

        void canAutoRedraw(bool value)  {
            setAttribute(IupAttributes.AutoRedraw, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    */
    @property 
	{
        bool canHideButtons() { return getAttribute(IupAttributes.HideButtons) == FlagIdentifiers.Yes; }

        void canHideButtons(bool value)  {
            setAttribute(IupAttributes.HideButtons, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    */
    @property 
	{
        bool canHideLines() { return getAttribute(IupAttributes.HideLines) == FlagIdentifiers.Yes; }

        void canHideLines(bool value)  {
            setAttribute(IupAttributes.HideLines, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Enables the internal drag and drop of nodes, and enables the DRAGDROP_CB callback. 
    Default: "NO". Works only if MARKMODE=SINGLE.
    */
    @property 
	{
        bool canDragDrop() { return getAttribute(IupAttributes.ShowDragDrop) == FlagIdentifiers.Yes; }

        void canDragDrop(bool value)  {
            setAttribute(IupAttributes.ShowDragDrop, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Allows the in place rename of a node. Default: "NO". Since IUP 3.0, F2 and clicking 
    twice only starts to rename a node if SHOWRENAME=Yes. In Windows must be set to YES 
    before map, but can be changed later (since 3.3).
    */
    @property 
	{
        bool canRename() { return getAttribute(IupAttributes.ShowRename) == FlagIdentifiers.Yes; }

        void canRename(bool value)  {
            setAttribute(IupAttributes.ShowRename, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    enables the use of toggles for all nodes of the tree. Can be "YES", "3STATE" or NO". 
    Default: "NO". In Motif Versions 2.1.x and 2.2.x, the images are disabled (toggle and 
    text only are drawn in nodes of the tree). (since 3.6)
    */
    @property 
	{
        bool canToggle() { return getAttribute(IupAttributes.ShowToggle) == FlagIdentifiers.Yes; }

        void canToggle(bool value)  {
            setAttribute(IupAttributes.ShowToggle, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    */
    @property 
	{
		int currentNodeId()  {  return getIntAttribute(IupAttributes.Value); }
        void currentNodeId(int value) { setIntAttribute(IupAttributes.Value, value);}
	}

    /**
    the background color of the selected node. Default: TXTHLCOLOR global attribute.
    */
    @property 
    {
        Color highlightColor() { 
            string c = getAttribute(IupAttributes.HlColor);
            return Color.parse(c); 
        }

        void highlightColor(Color value)  { setAttribute(IupAttributes.HlColor, value.toRgb()); }
        void highlightColor(string value)  { setAttribute(IupAttributes.HlColor, value); }
    }

    /** 
    */
    @property 
	{
		int indentation()  {  return getIntAttribute(IupAttributes.Indentation); }
        void indentation(int value) { setIntAttribute(IupAttributes.Indentation, value);}
	}

    /**
    Defines if branches will be expanded when created. The branch will be actually expanded when 
    it receives the first child. Possible values: "YES" = The branches will be created expanded; 
    "NO" = The branches will be created collapsed. Default: "YES".
    */
    @property 
	{
        bool isAddExpanded() { return getAttribute(IupAttributes.AddExpanded) == FlagIdentifiers.Yes; }

        void isAddExpanded(bool value)  {
            setAttribute(IupAttributes.AddExpanded, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    */
    @property 
	{
        bool isDropDragEqual() { return getAttribute(IupAttributes.DropEqualDrag) == FlagIdentifiers.Yes; }

        void isDropDragEqual(bool value)  {
            setAttribute(IupAttributes.DropEqualDrag, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    defines how the nodes can be selected. Can be: SINGLE or MULTIPLE. Default: SINGLE.
    */
    @property 
    {
        NodeSelectionMode selectionMode()  { 
            string v = getAttribute(IupAttributes.MarkMode); 
            return NodeMarkModeIdentifiers.convert(v);
        }

        void selectionMode(NodeSelectionMode value) { 
            setAttribute(IupAttributes.MarkMode, NodeMarkModeIdentifiers.convert(value));
        }
    }

    /** 
    returns the total number of nodes in the tree.
    */
    @property 
	{
		int nodeCount()  {  return getIntAttribute(IupAttributes.Count); }
        void nodeCount(int value) { setIntAttribute(IupAttributes.Count, value);}
	}

    /**
    vertical internal padding for each node. Notice that the distance between each node will 
    be actually 2x the spacing. (since 3.0)
    */
    @property 
	{
		int spacing()  {  return getIntAttribute(IupAttributes.Spacing); }
        void spacing(int value) { setIntAttribute(IupAttributes.Spacing, value);}
	}

    /**
    enables the use of toggles for all nodes of the tree. Can be "YES", "3STATE" or NO". 
    Default: "NO". In Motif Versions 2.1.x and 2.2.x, the images are disabled (toggle and 
    text only are drawn in nodes of the tree).
    */
    @property 
    {
        ToggleButtonVisibility toggleMode()  {  
            string v = getAttribute(IupAttributes.ShowToggle); 
            return ToggleButtonVisibilityIdentifiers.convert(v);
        }

        void toggleMode(ToggleButtonVisibility value) { 
            setAttribute(IupAttributes.ShowToggle, ToggleButtonVisibilityIdentifiers.convert(value));
        }
    }


    version(Windows)
    {
        /**
        the TIP is shown every time an item is highlighted. This is the default behavior for 
        TIPs in native tree controls in Windows, if set to No then it will use the regular 
        TIP behavior. Default: Yes. 
        */
        @property 
        {
            bool canShowInfoTip() { return getAttribute(IupAttributes.InfoTip) == FlagIdentifiers.Yes; }

            void canShowInfoTip(bool value)  {
                setAttribute(IupAttributes.InfoTip, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }


    /* ************* Public methods *************** */

    /**
    the first node
    */
    void gotoFirst()
    {
        setAttribute(IupAttributes.Value, "FIRST");
    }

    /**
    the last visible node
    */
    void gotoLast()
    {
        setAttribute(IupAttributes.Value, "LAST");
    }

    /**
    the next visible node, one node after the focus node. If at the last does nothing
    */
    void gotoNext()
    {
        setAttribute(IupAttributes.Value, "NEXT");
    }

    /**
    the previous visible node, one node before the focus node. If at the first does nothing
    */
    void gotoPrevious()
    {
        setAttribute(IupAttributes.Value, "PREVIOUS");
    }

    /**
    the next visible node, ten nodes node after the focus node. If at the last does nothing
    */
    void scrollDown()
    {
        setAttribute(IupAttributes.Value, "PGDN");
    }

    /**
    the previous visible node, ten nodes before the focus node. If at the first does nothing
    */
    void scrollUp()
    {
        setAttribute(IupAttributes.Value, "PGUP");
    }

    /**
    Same as ADDLEAF for branches. Branches can be created expanded or collapsed depending on
    ADDEXPANDED. Ignored if set before map. 
    */
    void addBranch(string value)
    {
        setStrAttribute(HierarchyAttributes.AddBranch, value);
    }

    /// ditto
    void addBranch(int id, string value)
    {
        //setStrAttribute(HierarchyAttributes.AddBranch ~ to!string(id), value);
        setIdAttribute(HierarchyAttributes.AddBranch, id, value);
    }

    /**
     Adds a new leaf after the reference node, where id is the reference node identifier.
    Use id=-1 to add before the first node. The value is used as the text label of the 
    new node. The id of the new node will be the id of the reference node + 1. The attribute 
    LASTADDNODE is set to the new id. The reference node is marked and all others unmarked. 
    The reference node position remains the same. If the reference node does not exist, nothing
    happens. If the reference node is a branch then the depth of the new node is one depth 
    increment from the depth of the reference node, if the reference node is a leaf then the 
    new node has the same depth. If you need to add a node after a specified node but at a 
    different depth use INSERTLEAF. Ignored if set before map.
    */
    void addLeaf(string value)
    {
        setStrAttribute(HierarchyAttributes.AddLeaf, value);
    }

    /// ditto
    void addLeaf(int id, string value)
    {
        setIdAttribute(HierarchyAttributes.AddLeaf, id, value);
    }

    /**
    expand or contracts all nodes. Can be YES (expand all), or NO (contract all). (since 3.0)
    */
    void collapseAll()
    {
        setAttribute(HierarchyAttributes.ExpandAll, FlagIdentifiers.No);
    }

    /// ditto
    void expandAll()
    {
        setAttribute(HierarchyAttributes.ExpandAll, FlagIdentifiers.Yes);
    }

    /**
    Converts a (x,y) coordinate in an item position.
    */
    int convertToPos(int x, int y)
    {
        return iup.c.api.IupConvertXYToPos(this.handle, x, y);
    }

    /**
    deletes all the selected nodes (and all their children)
    */
    void deleteSelectedNodes()
    {
        setAttribute(HierarchyAttributes.DelNode, "MARKED");
    }

    /**
    returns the depth of the specified node. The first node has depth=0, its immediate
    children has depth=1, their children has depth=2 and so on.
    */
    int getNodeDepth(int id)
    {
        return getIdAttributeAsInt(NodesAttributes.Depth, id);
    }

    /**
    returns the kind of the specified node.
    */
    TreeNodeKind getNodeKind(int id)
    {
        string v = getIdAttributeAsString(NodesAttributes.Kind, id);
        if(v == "BRANCH")
            return TreeNodeKind.Branch;
        return TreeNodeKind.Leaf;
    }

    /**
    Same as ADDLEAF and ADDBRANCH but the depth of the new node is always the same of 
    the reference node. If the reference node is a leaf, then the id of the new node 
    will be the id of the reference node + 1. If the reference node is a branch the 
    id of the new node will be the id of the reference node + 1 + the total number of
    child nodes of the reference node. (since 3.0)
    */
    void insertBranch(int id, string value)
    {
        setIdAttribute(HierarchyAttributes.InsertBranch, id, value);
    }

    /// ditto
    void insertLeaf(int id, string value)
    {
        setIdAttribute(HierarchyAttributes.InsertLeaf, id, value);
    }

    /**
    Forces a rename action to take place. Valid only when SHOWRENAME=YES.
    */
    void renameNode()
    {
        setAttribute(IupAttributes.Rename, FlagIdentifiers.Yes);
    }

    /**
    */
    void removeAll()
    {
        setAttribute(HierarchyAttributes.DelNode, "ALL");
    }

    /**
    deletes only the children of the specified node
    */
    void removeChildren()
    {
        setAttribute(HierarchyAttributes.DelNode, "CHILDREN");
    }

    /**
    deletes all the selected nodes (and all their children), id is ignored
    */
    void removeMarkedNodes()
    {
        setAttribute(HierarchyAttributes.DelNode, "MARKED");
    }

    /**
    deletes the specified node and its children
    */
    void removeSelectedNodes()
    {
        setAttribute(HierarchyAttributes.DelNode, "SELECTED");
    }

    /**
    text foreground color of the specified node. The value should be a string in the format
    "R G B" where R, G, B are numbers from 0 to 255.
    */
    void setNodeColor(int id, Color color)
    {
        setIdAttribute(NodesAttributes.Color, id, color.toRgb());
    }

    /// ditto
    void setNodeColor(int id, string color)
    {
        setIdAttribute(NodesAttributes.Color, id, color);
    }

    /// ditto
    string getNodeColorAsRGB(int id)
    {
       return getIdAttributeAsString(NodesAttributes.Color, id);
    }

    /// ditto
    Color getNodeColor(int id)
    {
        string c = getIdAttributeAsString(NodesAttributes.Color, id);
        return Color.parse(c);
    }

    /**
    image name to be used in the specified node, where id is the specified node identifier. 
    Use IupSetHandle or IupSetAttributeHandle to associate an image to a name. See also 
    IupImage. In Windows and Motif set the BGCOLOR attribute before setting the image. 
    If node is a branch it is used when collapsed.
    */
    void setNodeImage(int id, iup.image.IupImage image)
    {
        setHandleAttribute(IupAttributes.Image ~ to!string(id), image);

        //setIdAttribute(IupAttributes.Image, id, image.handle);
    }

    /// ditto
    string getNodeImageName(int id)
    {
        return getAttribute(IupAttributes.Image ~ to!string(id));
    }

    /**
    returns the identifier of the specified node.
    */
    int getNodeParentId(int id)
    {
        return getIdAttributeAsInt(NodesAttributes.Parent, id);
    }

    /**
    returns the immediate children count of the specified branch. It does not count children
    of child that are branches. 
    */
    int getNodeChildCount(int id)
    {
        return getIdAttributeAsInt(NodesAttributes.ChildCount, id);
    }

    /**
    the image name that will be shown for all collapsed branches. Default: "IMGCOLLAPSED". If
    BGCOLOR is set the image is automatically updated.
    */
    string getCollapsedBranchesImageName()
    {
        return getAttribute(IupAttributes.ImageBranchCollapsed);
    }

    /**
    the image name that will be shown for all expanded branches. Default: "IMGEXPANDED". If 
    BGCOLOR is set the image is automatically updated.
    */
    string getExpandedBranchesImageName()
    {
        return getAttribute(IupAttributes.ImageBranchExpanded);
    }

    /**
    the image name that will be shown for all leaves. Default: "IMGLEAF". Internal values 
    "IMGBLANK" and "IMGPAPER" are also available. If BGCOLOR is set the image is automatically
    updated. This image defines the available space for the image in all nodes.
    */
    string getLeafImageName()
    {
        return getAttribute(IupAttributes.ImageLeaf);
    }

    /**
    The focus node identifier. When retrieved but there isn't a node with focus it returns
    0 if there are any nodes, and returns -1 if there are no nodes. When changed and 
    MARKMODE=SINGLE the node is also selected. The tree is always scrolled so the node
    becomes visible. In Motif the tree will also receive the focus.
    */
    void setCurrentNode(int id)
    {
        setAttribute(IupAttributes.Value, to!string(id));
    }

    /**
    The selection state of the specified node, where id is the specified node identifier. 
    If id is empty or invalid, then the focus node is used as reference node. Can be: YES 
    or NO. Default: NO
    */
    void setNodeSelectionState(int id, bool isSelected)
    {
        setIdAttribute(IupAttributes.Marked, id, 
                       isSelected ? FlagIdentifiers.Yes: FlagIdentifiers.No);
    }

    /**
    the state of the specified branch. Returns NULL for a LEAF. In Windows, it will be 
    effective only if the branch has children. In GTK, it will be effective only if the 
    parent is expanded. Possible values: 
    */
    void setNodeState(int id, NodeState state)
    {
        if(getNodeKind(id) == TreeNodeKind.Branch) 
            setIdAttribute(NodesAttributes.State, id, NodeStateIdentifiers.convert(state));
    }

    /// ditto
    NodeState getNodeState(int id)
    {
        if(getNodeKind(id) == TreeNodeKind.Leaf)
            return NodeState.Collapsed;

        string v = getIdAttributeAsString(NodesAttributes.State, id);
        return NodeStateIdentifiers.convert(v);
    }

    //NodeState getCurrentNodeState()
    //{
    //    //if(getNodeKind(id) == TreeNodeKind.Leaf)
    //    //    return NodeState.Collapsed;
    //
    //    string v = getAttribute(NodesAttributes.State);
    //    return NodeStateIdentifiers.convert(v);
    //}

    /**
    the text label of the specified node.
    */
    void setNodeTitle(int id, string title)
    {
        //setStrAttribute(NodesAttributes.Title ~ to!string(id), title);
        setIdAttribute(NodesAttributes.Title, id, title);
    }
    /// ditto
    string getNodeTitle(int id)
    {
        return getIdAttributeAsString(NodesAttributes.Title, id);
    }

    /**
    defines the toggle state. Values can be "ON" or "OFF". If SHOW3STATE=YES then can also be 
    "NOTDEF". Default: "OFF". (Since 3.6)
    */
    void setNodeToggleState(int id, ToggleState state)
    {
        setIdAttribute(NodesAttributes.ToggleValue, id, ToggleStateIdentifiers.convert(state));
    }

    /**
    defines the toggle visible state. Values can be "Yes" or "No". Default: "Yes". (Since 3.8)
    */
    void setNodeToggleVisible(int id, bool isVisible)
    {
        setIdAttribute(NodesAttributes.ToggleVisible, id, 
                       isVisible ? FlagIdentifiers.Yes : FlagIdentifiers.No);
    }

    /**
    the user data associated with the specified node. (since 3.0)
    */
    void setNodeUserData(int id, void* data)
    {
        setPointerAttribute(NodesAttributes.UserData ~ to!string(id), data);
    }


    /**
    Clear the selection of all nodes
    */
    void clearAllSelection()
    {
        setAttribute(IupAttributes.Mark, "CLEARALL");
    }

    /**
    */
    void invertCurrentSelection()
    {
        setAttribute(IupAttributes.Mark, "INVERT");
    }

    /**
    Inverts the selection of all nodes
    */
    void invertAllSelection()
    {
        setAttribute(IupAttributes.Mark, "INVERTALL");
    }

    /**
    Selects all nodes between the focus node and the initial block-marking node defined by MARKSTART
    */
    void selectBlock()
    {
        setAttribute(IupAttributes.Mark, "BLOCK");
    }

    /**
    Selects all nodes
    */
    void selectAll()
    {
        setAttribute(IupAttributes.Mark, "MARKALL");
    }

    struct NodeStateIdentifiers
    {
        enum Expanded = "EXPANDED";
        enum Collapsed = "COLLAPSED";

        static string convert(NodeState t)
        {
            switch(t)
            {
                case NodeState.Expanded:
                    return Expanded;

                default:
                    return Collapsed;
            }
        }

        static NodeState convert(string v)
        {
            if(v == Expanded)
                return NodeState.Expanded;
            else
                return NodeState.Collapsed;
        }
    }

}

enum NodeState
{
    Expanded,
    Collapsed,
    //Leaf
}


enum NodeSelectionMode
{
    Single,
    Multiple
}

struct NodeMarkModeIdentifiers
{
    enum Single = "SINGLE";
    enum Multiple = "MULTIPLE";

    static string convert(NodeSelectionMode t)
    {
        final switch(t)
        {
            case NodeSelectionMode.Single:
                return Single;

            case NodeSelectionMode.Multiple:
                return Multiple;
        }
    }

    static NodeSelectionMode convert(string v)
    {
        if(v == Multiple)
            return NodeSelectionMode.Multiple;
        else
            return NodeSelectionMode.Single;
    }
}


enum ToggleButtonVisibility
{
    Yes,
    No,
    TreeState
}

struct ToggleButtonVisibilityIdentifiers
{
    enum Yes = "YES";
    enum No = "NO";
    enum TreeState = "3STATE";

    static string convert(ToggleButtonVisibility t)
    {
        switch(t)
        {
            case ToggleButtonVisibility.Yes:
                return Yes;

            case ToggleButtonVisibility.TreeState:
                return TreeState;

            default:
                return No;
        }
    }

    static ToggleButtonVisibility convert(string v)
    {
        if(v == Yes)
            return ToggleButtonVisibility.Yes;
        else if(v == TreeState)
            return ToggleButtonVisibility.TreeState;
        else
            return ToggleButtonVisibility.No;
    }
}


enum TreeNodeKind
{
    Leaf,
    Branch
}
