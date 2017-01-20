module iup.text;

import iup.control;
import iup.core;

import iup.c.core;
import iup.c.api;

import toolkit.event;

import std.string;
import std.conv;


/**
*/
public class IupTextBoxBase : IupStandardControl
{
    protected class IupCallbacks : super.IupCallbacks
    {
		enum Button = "BUTTON_CB";
        enum Caret = "CARET_CB";
        enum DropFiles = "DROPFILES_CB";
		enum Motion = "MOTION_CB";
        enum ValueChanged = "VALUECHANGED_CB";
    }

	class IupAttributes : super.IupAttributes
	{
        enum IupTextBoxBase = "IupTextBoxBase";
        enum AddFormatTag = "ADDFORMATTAG";
        enum AddFormatTagHandle = "ADDFORMATTAG_HANDLE";
        enum Alignment = "ALIGNMENT";
        enum Append = "APPEND";
        enum Border = "BORDER";
        enum Caret = "CARET";
        enum CaretPos = "CARETPOS";
        enum Clipboard = "CLIPBOARD";
        enum Count = "COUNT";
        enum Formatting = "FORMATTING";
        enum Insert = "INSERT"; 
        enum LineCount = "LINECOUNT";
        enum Mask = "MASK";
        enum Multiline = "MULTILINE";
        enum NC = "NC";
        enum NoHideSel = "NOHIDESEL";
        enum Overwrite = "OVERWRITE";
        enum ReadOnly = "READONLY";
        enum RemoveFormatting = "REMOVEFORMATTING";
        enum Selection = "SELECTION";
        enum SelectedText = "SELECTEDTEXT";
        enum SelectionPos = "SELECTIONPOS";
        enum ScrollToPos = "SCROLLTOPOS";
        enum Value = "VALUE";
        enum VisibleColumns = "VISIBLECOLUMNS";
        enum VisibleLines = "VISIBLELINES";
        enum WordWrap = "WORDWRAP";
	}

	this()
	{
        super();
	}

    //protected override Ihandle* createIupObject()
    //{
    //    //return iup.c.api.IupText(null); 
    //    return null;
    //}

    protected override void onCreated()
    {    
        super.onCreated();
        registerCaretMoveCallback(IupCallbacks.Caret);
        registerFileDroppedCallback(IupCallbacks.DropFiles);
        registerMouseClickCallback(IupCallbacks.Button);
        registerMouseMoveCallback(IupCallbacks.Motion);
        registerTextChangingCallback(IupCallbacks.Action);
        registerTextChangedCallback(IupCallbacks.ValueChanged);
    }   


    /* ************* Events *************** */

    /**
    Action generated when the caret/cursor position is changed. 

    lin, col: line and column number (start at 1).
    pos: 0 based character position.

    For single line controls lin is always 1, and pos is always "col-1".
    */
    mixin EventCallback!(IupTextBoxBase, "caretMove", int, int, int);


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
    mixin EventCallbackAdapter!(IupTextBoxBase, "fileDropped", const (char)*, int, int, int);
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
    mixin EventCallbackAdapter!(IupTextBoxBase, "mouseClick", int, int, int, int, const(char)*);
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
    mixin EventCallbackAdapter!(IupTextBoxBase, "mouseMove", int, int, const(char)*);
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

    /**
    Called after the value was interactively changed by the user. (since 3.0)
    */
    mixin EventCallback!(IupTextBoxBase, "textChanged");

    /**
    Action generated when the text is edited, but before its value is actually 
    changed. Can be generated when using the keyboard, undo system or from the clipboard.
    */
    public EventHandler!(CallbackEventArgs, int, string)  textChanging;
    mixin EventCallbackAdapter!(IupTextBoxBase, "textChanging", int, char *);

    /**
    c: valid alpha numeric character or 0.
    new_value: Represents the new text value.
    */
    private CallbackResult onTextChanging(int c, char *new_value) nothrow
    {
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            textChanging(this, callbackArgs, c, cast(string)std.string.fromStringz(new_value));
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }

    /**
    row, col: line and column number (start at 1).
    pos: 0 based character position.
    */
    //private void onCaretPositionChanged(int row, int col, int pos) nothrow
    //{
    //    try
    //    {
    //        //m_toggleState = cast(ToggleState)state;
    //        caretPositionChanged(this, cast(ToggleState)state);
    //    }
    //    catch(Exception ex) { /* do nothing. */ }
    //}




    /* ************* Properties *************** */


    /**
    Also the character position of the insertion point, but using a zero based character unique index "pos". 
    Useful for indexing the VALUE string. See the Notes below if using UTF-8 strings in GTK. (since 3.0)
    */
    @property 
	{
		public int caretIndex()  {  return getIntAttribute(IupAttributes.CaretPos); }
        public void caretIndex(int value) { setIntAttribute(IupAttributes.CaretPos, value);}
	}

    /**
    Valid only when MULTILINE=YES. If enabled will force a word wrap of lines that 
    are greater than the with of the control, and the horizontal scrollbar will 
    be removed. Default: NO. 
    (creation only)
    */
    @property 
	{
		public bool isWordWrap() { return getAttribute(IupAttributes.WordWrap) == FlagIdentifiers.Yes; }

        public void isWordWrap(bool value) 
        {
            setAttribute(IupAttributes.WordWrap,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    turns the overwrite mode ON or OFF. Works only when FORMATTING=YES. (since 3.0)
    */
    @property 
	{
		public bool isOverwrite() { return getAttribute(IupAttributes.Overwrite) == ToggleStateIdentifiers.On; }

        public void isOverwrite(bool value) 
        {
            setAttribute(IupAttributes.Overwrite,  value ? ToggleStateIdentifiers.On : ToggleStateIdentifiers.Off);
        }
	}

    /**
    Shows a border around the canvas. Default: "YES".
    */
    @property 
	{
		public bool hasBorder() { return getAttribute(IupAttributes.Border) == FlagIdentifiers.Yes; }

		public void hasBorder(bool value) {
            setAttribute(IupAttributes.Border, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
    }


    /**
    When enabled allow the use of text formatting attributes. In GTK is always enabled, but 
    only when MULTILINE=YES. Default: NO. (since 3.0)
    */
    @property 
    {
        public bool isFormatting() { return getAttribute(IupAttributes.Formatting) == FlagIdentifiers.Yes; }

        public void isFormatting(bool value)  {
            setAttribute(IupAttributes.Formatting, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    returns the number of lines in the text. When MULTILINE=NO returns always "1". (since 3.5)
    */
    @property 
	{
		public int lineCount()  {  return getIntAttribute(IupAttributes.LineCount); }
	}

    /**
    Defines a mask that will filter interactive text input.
    */
    @property 
	{
		public string mask()  {  return getAttribute(IupAttributes.Mask); }
        public void mask(string value) { setAttribute(IupAttributes.Mask, value);}
	}

    /**
    Maximum number of characters allowed for keyboard input, larger text can still be set 
    using attributes. The maximum value is the limit of the VALUE attribute. The "0" value
    is the same as maximum. Default: maximum.
    */
    @property 
	{
		public int maxLength()  {  return getIntAttribute(IupAttributes.NC); }
        public void maxLength(int value) { setIntAttribute(IupAttributes.NC, value);}
	}

    /**
    allows the edition of multiple lines. In single line mode some characters are invalid, like "\t", 
    "\r" and "\n". Default: NO. When set to Yes will also reset the SCROLLBAR attribute to Yes.
    */
    @property 
	{
		public bool multiline() { return getAttribute(IupAttributes.Multiline) == FlagIdentifiers.Yes; }
	}

    /**
    Allows the user only to read the contents, without changing it. Restricts keyboard input only, 
    text value can still be changed using attributes. Navigation keys are still available.
    Possible values: "YES", "NO". Default: NO.
    */
    @property 
	{
		public bool isReadOnly() { return getAttribute(IupAttributes.ReadOnly) == FlagIdentifiers.Yes; }

		public void isReadOnly(bool value) {
            setAttribute(IupAttributes.ReadOnly,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    Selection text. Returns NULL if there is no selection. When changed replaces the current selection. 
    Similar to INSERT, but does nothing if there is no selection.
    */
    @property 
	{
		public string selectedText()  {  return getAttribute(IupAttributes.SelectedText); }
        public void selectedText(string value) { setAttribute(IupAttributes.SelectedText, value);}
	}

    /**
    Text entered by the user. The '\n' character indicates a new line, valid only when MULTILINE=YES. 
    After the element is mapped and if there is no text will return the empty string "".
    */
    @property 
	{
		public string text()  {  return getAttribute(IupAttributes.Value); }
        public void text(string value) { 
            if(value is null)
                clearAttribute(IupAttributes.Value);
            else
                setAttribute(IupAttributes.Value, value);
        }
	}

    /**
    text alignment. Possible values: "ALEFT", "ARIGHT", "ACENTER". Default: "ALEFT". 
    In Motif, text is always left aligned.
    */
    @property 
    {
        public HorizontalAlignment textAlignment() { return m_textAlignment; }

        public void textAlignment(HorizontalAlignment value) 
        {
            m_textAlignment = value;
            setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
        }
        private HorizontalAlignment m_textAlignment; 
    }

    /**
    Returns the number of characters in the text, including the line breaks. (since 3.5)
    */
    @property 
	{
		public int textLength()  {  return getIntAttribute(IupAttributes.Count); }
	}

    /**
    Defines the number of visible columns for the Natural Size, 
    this means that will act also as minimum number of visible columns. 
    It uses a wider character size than the one used for the SIZE attribute 
    so strings will fit better without the need of extra columns. 
    As for SIZE you can set to NULL after map to use it as an initial value. 
    Default: 5 (since 3.0)
    */
    @property 
	{
		public int visibleColumns()  {  return getIntAttribute(IupAttributes.VisibleColumns); }
        public void visibleColumns(int value) { setIntAttribute(IupAttributes.VisibleColumns, value);}
	}

    /**
    When MULTILINE=YES defines the number of visible lines for the Natural Size, this means that will 
    act also as minimum number of visible lines. As for SIZE you can set to NULL after map to use it 
    as an initial value. Default: 1 (since 3.0)
    */
    @property 
	{
		public int visibleLines()  {  return getIntAttribute(IupAttributes.VisibleLines); }
        public void visibleLines(int value) { setIntAttribute(IupAttributes.VisibleLines, value);}
	}


    version(Windows)
    {
        /**
        hide the selection when the control loses its focus. Default: No.
        */
        @property 
        {
            public bool canHideSelection () { return getAttribute(IupAttributes.NoHideSel) == FlagIdentifiers.No; }

            public void canHideSelection (bool value)  {
                setAttribute(IupAttributes.NoHideSel, value ? FlagIdentifiers.No: FlagIdentifiers.Yes );
            }
        }
    }


    /* ************* Public methods *************** */

    /**
    Inserts a text at the end of the current text. In the Multiline, if APPENDNEWLINE=YES,
    a "\n" character will be automatically inserted before the appended text if the current
    text is not empty(APPENDNEWLINE default is YES). Ignored if set before map.
    */
    void append(string text)
    {
        setAttribute(IupAttributes.Append, text);
    }

    void convertPosToLinCol(int pos, ref int row, ref int col)
    {
        iup.c.api.IupTextConvertPosToLinCol(this.handle, pos, &row, &col);
    }

    int convertLinColToPos(int row, int col)
    {
        int pos;
        iup.c.api.IupTextConvertLinColToPos(this.handle, row, col, &pos);
        return pos;
    }

    /**
    clear, cut, copy or paste the selection to or from the clipboard. Values: "CLEAR", 
    "CUT", "COPY" or "PASTE". In Windows UNDO is also available, and REDO is available 
    when FORMATTING=YES. (since 3.0)
    */
    void copy()
    {
        setAttribute(IupAttributes.Clipboard, "COPY");
    }

    /// ditto
    void cut()
    {
        setAttribute(IupAttributes.Clipboard, "CUT");
    }

    /// ditto
    void del()
    {
        setAttribute(IupAttributes.Clipboard, "CLEAR");
    }

    /// ditto
    void paste()
    {
        setAttribute(IupAttributes.Clipboard, "PASTE");
    }

    version(Windows)
    {

        /// ditto
        void undo()
        {
            setAttribute(IupAttributes.Clipboard, "UNDO");
        }

        /// ditto
        void redo()
        {
            setAttribute(IupAttributes.Clipboard, "REDO");
        }
    }

    /**
    Converts a (x,y) coordinate in an item position.
    */
    int convertToPos(int x, int y)
    {
        return iup.c.api.IupConvertXYToPos(this.handle, x, y);
    }

    /**
    Inserts a text in the caret's position, also replaces the current selection if any. 
    Ignored if set before map.
    */
    void insert(string text)
    {
        setAttribute(IupAttributes.Insert, text);
    }

    /**
    */
    void removeFormatting()
    {
        //setAttribute(IupAttributes.RemoveFormatting, "");
        clearAttribute(IupAttributes.RemoveFormatting);
    }


    void scrollTo(int pos)
    {
        setIntAttribute(IupAttributes.ScrollToPos, pos);
    }

    /**
    Same as SELECTION but using a zero based character index "pos1:pos2". Useful for indexing the VALUE string. 
    The values ALL and NONE are also accepted. See the Notes below if using UTF-8 strings in GTK. (since 3.0)
    */
    void select(int start, int length)
    {
        iup.c.api.IupSetStrf(handle, IupAttributes.SelectionPos, "%d:%d", start, start+length);
    }

    void selectAll()
    {
        setAttribute(IupAttributes.Selection, "ALL");
    }

    void addFormatStyle(IupExternalElement style)
    {
        setPointerAttribute(IupAttributes.AddFormatTagHandle, style.handle);
    }



}

/**
Creates an editable text field.
*/
public class IupTextBox :IupTextBoxBase
{	
    protected class IupAttributes : super.IupAttributes
    {
        enum IupTextBox = "IupTextBox";
        enum CueBanner = "CUEBANNER";
    }

    this()
	{
        super();
	}

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupText(null);
	}


    /* ************* Properties *************** */


    /**
    Character position of the insertion point. Its format depends in MULTILINE=YES. The first 
    position, lin or col, is "1".
    */
    @property 
    {
        public string caretLocation() { return getAttribute(IupAttributes.Caret); }

        public void caretLocation(string value) 
        {
            setAttribute(IupAttributes.Caret, value);
        }
    }

    /**
    */
    @property 
	{
		public void multiline(bool value) {
            setAttribute(IupAttributes.Multiline,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}


    version(Windows)
    {
        /**
        a text that is displayed when there is no text at the control. It works as a textual cue, 
        or tip to prompt the user for input. Valid only for MULTILINE=NO, and works only when 
        Visual Styles are enabled. (since 3.0)
        */
        @property 
        {
            public string watermark()  {  return getAttribute(IupAttributes.CueBanner); }
            public void watermark(string value) { setAttribute(IupAttributes.CueBanner, value);}
        }
    }
}

deprecated alias IupText = IupTextBox;


/**
Creates an editable field with one or more lines.

Since IUP 3.0, IupText has support for multiple lines when the MULTILINE attribute is set to YES. 
Now when a IupMultiline element is created in fact a IupText element with MULTILINE=YES is created.
*/
public class IupMultiLine : IupTextBoxBase
{
    protected class IupAttributes : super.IupAttributes
    {
        enum IupMultiLine = "IupMultiLine";
        enum AutoHide = "AUTOHIDE";
        enum Filter = "FILTER";
        enum TabSize = "TABSIZE";
    }

    this()
	{
        super();
        m_scrollBar = new IupScrollBar(this);
	}

    protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupMultiLine(null);
	}


    /* ************* Properties *************** */


    /**
    scrollbars are shown only if they are necessary. Default: "YES".
    */
    @property 
    {
        public bool canAutoHideScrollbar() { return getAttribute(IupAttributes.AutoHide) == FlagIdentifiers.Yes; }

        public void canAutoHideScrollbar(bool value) {
            setAttribute(IupAttributes.AutoHide,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }


    /**
    Character position of the insertion point. Its format depends in MULTILINE=YES. The first 
    position, lin or col, is "1".

    a string with the "lin,col" format, where lin and col are integer numbers corresponding to 
    the caret's position.
    */
    @property 
    {
        public string caretLocation() { return getAttribute(IupAttributes.Caret); }

        public void caretLocation(string value) 
        {
            setAttribute(IupAttributes.Caret, value);
        }
    }

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
		public IupScrollBar scrollBars() { return m_scrollBar; }
		protected void scrollBars(IupScrollBar value) { m_scrollBar = value; }
        private IupScrollBar m_scrollBar; 
	}

    /**
    Same as SELECTION but using a zero based character index "pos1:pos2". Useful for indexing
    the VALUE string. The values ALL and NONE are also accepted. See the Notes below if using 
    UTF-8 strings in GTK. (since 3.0)
    */
    @property 
    {
        public string selectionPos() { return getAttribute(IupAttributes.SelectionPos); }

        public void selectionPos(string value) 
        {
            setAttribute(IupAttributes.SelectionPos, value);
        }
    }

    /**
    Valid only when MULTILINE=YES. Controls the number of characters for a tab stop. Default: 8.
    */
    @property 
	{
		public int tabSize()  {  return getIntAttribute(IupAttributes.TabSize); }
        public void tabSize(int value) { setIntAttribute(IupAttributes.TabSize, value);}
	}


    version(Windows)
    {
        /**
        allows a custom filter to process the characters: Can be LOWERCASE, UPPERCASE or 
        NUMBER (only numbers allowed). (since 3.0)
        */
        @property 
        {
            public TextFilterStyle filterStyle() { 
                string s = getAttribute(IupAttributes.Filter);
                return TextFilterStyleIdentifiers.convert(s); 
            }

            public void filterStyle(TextFilterStyle value) {
                setAttribute(IupAttributes.Filter, TextFilterStyleIdentifiers.convert(value));
            }
        }
    }

}


public class IupUpDown(T) 
if(is(T == int) || is(T == float) || is(T == double)) 
: IupStandardControl 
{
    protected class IupAttributes : super.IupAttributes
	{
        enum IupNumericBox = "IupNumericBox";
        enum Count = "COUNT";
        enum Mask = "MASK";
        enum ReadOnly = "READONLY";
        enum Spin = "SPIN";
        enum SpinValue = "SPINVALUE";
        enum SpinMax = "SPINMAX";
        enum SpinMin = "SPINMIN";
        enum SpinInc = "SPININC";
        enum SpinAlign = "SPINALIGN";
        enum SpinWrap = "SPINWRAP";
        enum SpinAuto = "SPINAUTO";
        enum Value = "VALUE";
	}

    protected class IupCallbacks : super.IupCallbacks
    {
        enum ValueChanged = "VALUECHANGED_CB";
        enum Spin = "SPIN_CB";
    }


	this()
	{
        super();
	}

    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupText(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerValueChangingCallback(IupCallbacks.Action);
        registerValueChangedCallback(IupCallbacks.ValueChanged);
        registerSpinnedCallback(IupCallbacks.Spin);

        setAttribute(IupAttributes.Spin, FlagIdentifiers.Yes);
    } 


    /* ************* Events *************** */

    /**
    Called after the value was interactively changed by the user. (since 3.0)
    */
    mixin EventCallback!(IupUpDown, "valueChanged");

    /**
    Called after the value was interactively changed by the user. (since 3.0)
    */
    mixin EventCallback!(IupUpDown, "spinned", T);

    /**
    Action generated when the text is edited, but before its value is actually 
    changed. Can be generated when using the keyboard, undo system or from the clipboard.
    */
    public EventHandler!(CallbackEventArgs, int, string)  valueChanging;
    mixin EventCallbackAdapter!(IupUpDown, "valueChanging", int, char *);

    /**
    c: valid alpha numeric character or 0.
    new_value: Represents the new text value.
    Returns: IUP_CLOSE will be processed, but the change will be ignored. If IUP_IGNORE, 
    the system will ignore the new value. If c is valid and returns a valid alpha numeric 
    character, this new character will be used instead. The VALUE attribute can be changed 
    only if IUP_IGNORE is returned.
    */
    private CallbackResult onValueChanging(int c, char *new_value) nothrow
    {
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            valueChanging(this, callbackArgs,c, cast(string)std.string.fromStringz(new_value));
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }


    /* ************* Properties *************** */

    /**
    enables the automatic update of the text contents. Default: YES. Use SPINAUTO=NO and 
    the VALUE attribute during SPIN_CB to control the text contents when the spin is incremented.
    (creation only)
    */
    @property 
	{
		public bool canAutomaticUpdate() { return getAttribute(IupAttributes.SpinAuto) == FlagIdentifiers.Yes; }

        public void canAutomaticUpdate(bool value) { 
            setAttribute(IupAttributes.SpinAuto, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    if the position reach a limit it continues from the opposite limit. Default: NO.
    */
    @property 
	{
		public bool canWrap() { return getAttribute(IupAttributes.SpinWrap) == FlagIdentifiers.Yes; }

        public void canWrap(bool value) { 
            setAttribute(IupAttributes.SpinWrap, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}


    /**
    Defines a mask that will filter interactive text input.
    */
    @property 
	{
		public string mask()  {  return getAttribute(IupAttributes.Mask); }
        public void mask(string value) { setAttribute(IupAttributes.Mask, value);}
	}

    /**
    the position of the spin. Can be LEFT or RIGHT. Default: RIGHT. In GTK is always RIGHT.
    (creation only)
    */
    @property 
	{
		public LeftRightAlignment spinAlignment()  {  
            string v = getAttribute(IupAttributes.SpinAlign);
            if(v == AlignmentIdentifiers.Left)
                return LeftRightAlignment.Left;
            else
                return LeftRightAlignment.Right;
        }

        public void spinAlignment(LeftRightAlignment value) { 
            setAttribute(IupAttributes.SpinAlign, toIupIdentifier(value));
        }
	}

    /**
    Text entered by the user. The '\n' character indicates a new line, valid only when MULTILINE=YES. 
    After the element is mapped and if there is no text will return the empty string "".
    */
    @property 
	{
		public string text()  {  return getAttribute(IupAttributes.Value); }
        public void text(string value) { 
                setAttribute(IupAttributes.Value, value);
        }
	}


    /**
    the increment value. Default: 1.
    */
    @property 
	{
		public T increment()  {  
            static if(is(T == int))
                return getIntAttribute(IupAttributes.SpinInc); 
            else if (is(T == float))
                return getFloatAttribute(IupAttributes.SpinInc); 
            else
                return getDoubleAttribute(IupAttributes.SpinInc); 
        }

        public void increment(T value) { 
            static if(is(T == int))
                setIntAttribute(IupAttributes.SpinInc, value);
            else if (is(T == float))
                setFloatAttribute(IupAttributes.SpinInc, value);
            else
                setDoubleAttribute(IupAttributes.SpinInc, value);
        }
	}


    /**
    the maximum value. Default: 100.
    */
    @property 
    {
        public T maximum() { 
            static if(is(T == int))
                return getIntAttribute(IupAttributes.SpinMax); 
            else if (is(T == float))
                return getFloatAttribute(IupAttributes.SpinMax); 
            else
                return getDoubleAttribute(IupAttributes.SpinMax); 
        }

        public void maximum(T value)  { 
            static if(is(T == int))
                setIntAttribute(IupAttributes.SpinMax, value);
            else if (is(T == float))
                setFloatAttribute(IupAttributes.SpinMax, value);
            else
                setDoubleAttribute(IupAttributes.SpinMax, value);
        }
    }

    /**
    the minimum value. Default: 0.
    */
    @property 
    {
        public T minimum() { 
            static if(is(T == int))
                return getIntAttribute(IupAttributes.SpinMin); 
            else if (is(T == float))
                return getFloatAttribute(IupAttributes.SpinMin); 
            else
                return getDoubleAttribute(IupAttributes.SpinMin);
        }

        public void minimum(T value) { 
            static if(is(T == int))
                setIntAttribute(IupAttributes.SpinMin, value);
            else if (is(T == float))
                setFloatAttribute(IupAttributes.SpinMin, value);
            else
                setDoubleAttribute(IupAttributes.SpinMin, value);
        }
    }

    /**
    the current value of the spin. The value is limited to the minimum and maximum values.
    */
    @property 
	{
		public T value()  { 
            static if(is(T == int))
                return getIntAttribute(IupAttributes.SpinValue); 
            else if (is(T == float))
                return getFloatAttribute(IupAttributes.SpinValue); 
            else
                return getDoubleAttribute(IupAttributes.SpinValue);
        }

        public void value(T v) { 
            static if(is(T == int))
                setIntAttribute(IupAttributes.SpinValue, v);
            else if (is(T == float))
                setFloatAttribute(IupAttributes.SpinValue, v);
            else
                setDoubleAttribute(IupAttributes.SpinValue, v);
        }
	}

}


/**
*/
public class IupIntegerUpDown : IupUpDown!(int)
{

	this()
	{
        super();
	}


    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();

        this.mask = NumberMaskStyle.Int;
    }   


    /* ************* Events *************** */



    /* ************* Properties *************** */

}

public class IupFloatUpDown : IupUpDown!(float)
{

	this()
	{
        super();
	}


    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();

        this.mask = NumberMaskStyle.Float;
    }   


    /* ************* Events *************** */



    /* ************* Properties *************** */

}


enum TextFilterStyle
{
    Lowercase,
    Uppercase,
    Number 
}

struct TextFilterStyleIdentifiers
{
    enum Lowercase = "LOWERCASE";
    enum Uppercase = "UPPERCASE";
    enum Number = "NUMBER";


    static string convert(TextFilterStyle d)
    {
        final switch(d)
        {
            case TextFilterStyle.Lowercase:
                return Lowercase;

            case TextFilterStyle.Uppercase:
                return Uppercase;

            case TextFilterStyle.Number:
                return Number;
        }
    }

    static TextFilterStyle convert(string s)
    { 
        if(s == Uppercase)
            return TextFilterStyle.Uppercase;
        else  if(s == Number)
            return TextFilterStyle.Number;

        return TextFilterStyle.Lowercase;
    }
}