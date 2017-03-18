module iup.grid;

import iup.canvas;
import iup.control;
import iup.core;
import iup.image;
import cd.canvas;

import cd.c.core;
import iup.c;

import toolkit.container;
import toolkit.drawing;
import toolkit.event;

import std.string;
import std.conv;
import std.format;
import std.stdio;


/**
Creates a grid widget (set of cells) that enables several application-specific drawing,
such as: chess tables, tiles editors, degrade scales, drawable spreadsheets and so forth. 
*/
public class IupCells : IupCanvasBase
{
    class IupCallbacks  : super.IupCallbacks
	{
        enum Draw =  "DRAW_CB";
        enum Height =  "HEIGHT_CB";
        enum HSpan =  "HSPAN_CB";
        enum MouseClick =  "MOUSECLICK_CB";
        enum MouseMotion =  "MOUSEMOTION_CB";
        enum NCols =  "NCOLS_CB";
        enum NLines =  "NLINES_CB";
        enum Scrolling =  "SCROLLING_CB";
        enum VSpan =  "VSPAN_CB";
        enum Width =  "WIDTH_CB";
    }

    class IupAttributes : super.IupAttributes
    {
        enum IupCells = "IupCells";
        enum Boxed = "BOXED";
        enum Bufferize = "BUFFERIZE";
        enum Canvas = "CANVAS";
        enum Clipped = "CLIPPED";
        enum FirstCol = "FIRST_COL";
        enum FirstLine = "FIRST_LINE";
        enum FullVisible = "FULL_VISIBLE";
        enum ImageCanvas = "IMAGE_CANVAS";
        enum Limits = "LIMITS";
        enum NonScrollableLines = "NON_SCROLLABLE_LINES";
        enum NonScrollableCols = "NON_SCROLLABLE_COLS";
        enum Origin = "ORIGIN";
        enum Repaint = "REPAINT";
    }

    this() { super(); }


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupCells();
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerColumnCountNeededCallback(IupCallbacks.NCols);
        registerColumnWidthNeededCallback(IupCallbacks.Width);
        registerHorizontalSpanNeededCallback(IupCallbacks.HSpan);
        registerMouseClickCallback(IupCallbacks.MouseClick);
        registerMouseMoveCallback(IupCallbacks.MouseMotion);
        registerPaintCallback(IupCallbacks.Draw);
        registerRowCountNeededCallback(IupCallbacks.NLines);
        registerRowHeightNeededCallback(IupCallbacks.Height);
        registerScrollingCallback(IupCallbacks.Scrolling);
        registerVerticalSpanNeededCallback(IupCallbacks.VSpan);
    }


    /* ************* Events *************** */

    /**
    called when then controls needs to know its number of columns.

    Returns: an integer that specifies the number of columns. Default is 10 columns.
    */
    mixin IupEventHandler!(IupCells, "columnCountNeeded", CallbackResult!(int, 10));

    /**
    called when the controls needs to know the column width

    column: the column index
    Returns: an integer that specifies the desired width (in pixels). Default is 60 pixels.
    */
    mixin IupEventHandler!(IupCells, "columnWidthNeeded", CallbackResult!(int, 60), int);

    /**
    called when the control needs to know if a cell should be horizontally spanned.

    line, column: the line and column indexes (in grid coordinates)
    Returns: an integer that specifies the desired span. Default is 1 (no span).
    */
    mixin IupEventHandler!(IupCells, "horizontalSpanNeeded", CallbackResult!(int, 1), int, int);

    /**
    called when the controls needs to know a (eventually new) line height.

    line: the line index
    Returns: an integer that specifies the desired height (in pixels). Default is 30 pixels.
    */
    mixin IupEventHandler!(IupCells, "rowHeightNeeded", CallbackResult!(int, 30), int);

    /**
    called when a color is selected. The primary color is selected with the left mouse 
    button, and if existent the secondary is selected with the right mouse button.

    button: identifies the activated mouse button.
    pressed: indicates the state of the button.
    x, y: position in the canvas where the event has occurred, in pixels.
    status: status of the mouse buttons and some keyboard keys at the moment the event is generated.
    line, column: the grid position in the control where the event has occurred, in grid coordinates.
    */
    EventHandler!(ActionCallbackResult, MouseButtons, MouseState, int, int, int, int, string) mouseClick;
    mixin EventCallbackAdapter!(IupCells, "mouseClick", int, int, int, int, int, int, const(char)*);
    private IupElementAction onMouseClick(int button, int pressed, int line, 
                                        int column, int x, int y, const(char) *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new DefaultActionCallbackResult();
            string s = cast(string)std.string.fromStringz(status);

            mouseClick(this, callbackArgs, cast(MouseButtons)button, 
                       cast(MouseState)pressed, line, column, x, y, s);
            r = callbackArgs.value;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }

    /** 
    called when the mouse moves over the control.

    x, y: position in the canvas where the event has occurred, in pixels.
    status: status of mouse buttons and certain keyboard keys at the moment the event was generated. 
    line, column: the grid position in the control where the event has occurred, in grid coordinates.
    */
    EventHandler!(ActionCallbackResult, int, int, int, int, string)  mouseMove;
    mixin EventCallbackAdapter!(IupCells, "mouseMove", int, int, int, int, const(char)*);
    private IupElementAction onMouseMove(int line, int column, int x, int y, const(char) *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new DefaultActionCallbackResult();
            string s = cast(string)std.string.fromStringz(status);
            mouseMove(this, callbackArgs, line, column, x, y, s);
            r = callbackArgs.value;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }


    /**
    called when a specific cell needs to be redrawn.

    line, column: the grid position inside the control that is being redrawn, in grid coordinates.

    xmin, xmax, ymin, ymax: the raster bounding box of the redrawn cells, where the application 
    can use CD functions to draw anything. If the attribute IUP_CLIPPED is set (the default), 
    all CD graphical primitives is clipped to the bounding region.

    canvas: internal canvas CD used to draw the cells.
    */
    EventHandler!(ActionCallbackResult, int, int, RectangleInt, IupCdCanvas) paint;

    mixin EventCallbackAdapter!(IupCells, "paint", int, int, int, int, int, int, cdCanvas*);

    private IupElementAction onPaint(int line, int column, int xmin, int xmax,
                                     int ymin, int ymax, cdCanvas* canvas) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            RectangleInt rect = RectangleInt(xmin, ymin, xmax, ymax);

            auto callbackArgs = new DefaultActionCallbackResult();
            paint(this, callbackArgs, line, column, rect, new IupCdCanvas(canvas));
            r = callbackArgs.value;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }

    /**
    called when then controls needs to know its number of lines.

    Returns: an integer that specifies the number of lines. Default is 10 lines.
    */
    mixin IupEventHandler!(IupCells, "rowCountNeeded", CallbackResult!(int, 10));

    /**
    called when the scrollbars are activated.

    line, column: the first visible line and column indexes (in grid coordinates)
    Returns: If IUP_IGNORE the cell is not redrawn. By default the cell is always redrawn.
    */
    mixin IupEventHandler!(IupCells, "scrolling", DefaultActionCallbackResult, int, int);

    /**
    called when the control needs to know if a cell should be vertically spanned.

    line, column: the line and column indexes (in grid coordinates)

    Returns: an integer that specifies the desired span. Default is 1 (no span).
    */
    mixin IupEventHandler!(IupCells, "verticalSpanNeeded", CallbackResult!(int, 1), int, int);


    /* ************* Properties *************** */

    /**
    Disables the automatic redrawing of the control, so many attributes can be changed 
    without many redraws. Default: "NO". When set to "NO" the control is redrawn.
    */
    @property 
    {
        bool canAutoRedraw() { 
            return getAttribute(IupAttributes.Bufferize) == FlagIdentifiers.Yes; 
        }

        void canAutoRedraw(bool value) {
            setAttribute(IupAttributes.Bufferize, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Determines if the bounding cells' regions should be drawn with black lines. It can be
    "YES" or "NO". Default: "YES". If the span attributes are used, set this attribute to
    "NO" to avoid grid drawing over spanned cells.
    */
    @property 
    {
        bool isBoxed() { 
            return getAttribute(IupAttributes.Boxed) == FlagIdentifiers.Yes; 
        }

        void isBoxed(bool value) {
            setAttribute(IupAttributes.Boxed, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Determines if, before cells drawing, each bounding region should be clipped. This 
    attribute should be changed in few specific cases.  It can be "YES" or "NO". Default: "YES".
    */
    @property 
    {
        bool isClipped() { 
            return getAttribute(IupAttributes.Clipped) == FlagIdentifiers.Yes; 
        }

        void isClipped(bool value) {
            setAttribute(IupAttributes.Clipped, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Returns the internal IUP CD canvas. This attribute should be used only in specific cases
    and by experienced CD programmers.
    */
    @property 
	{
        IupCdCanvas imageCanvas() { 
            if(m_imageCanvas is null)
            {
                auto cdHandle = cast(cdCanvas* )getPointerAttribute(IupAttributes.Canvas);
                m_imageCanvas = new IupCdCanvas(cdHandle);
            }
            return m_imageCanvas; 
        }

        private IupCdCanvas m_imageCanvas;
	}

    /**
    Returns the internal IUP CD canvas. This attribute should be used only in specific cases
    and by experienced CD programmers.
    */
    @property 
	{
        IupCdCanvas iupCanvas() { 
            if(m_iupCanvas is null)
            {
                auto cdHandle = cast(cdCanvas* )getPointerAttribute(IupAttributes.Canvas);
                m_iupCanvas = new IupCdCanvas(cdHandle);
            }
            return m_iupCanvas; 
        }

        private IupCdCanvas m_iupCanvas;
	}

    /**
    Determines the number of non-scrollable columns (horizontal headers) that should always
    be visible despite the horizontal scrollbar position. It can be any non-negative integer
    value. Default: "0"
    */
    @property 
	{
        int frozenColumnsCount() { return getIntAttribute(IupAttributes.NonScrollableCols); }
	}

    /**
    Determines the number of non-scrollable lines (vertical headers) that should always be 
    visible despite the vertical scrollbar position. It can  be any non-negative integer 
    value. Default: "0"
    */
    @property 
	{
        int frozenRowsCount() { return getIntAttribute(IupAttributes.NonScrollableLines); }
	}

    /**
    Returns the number of the first visible column.
    */
    @property 
	{
        int visibleColumnsCount() { return getIntAttribute(IupAttributes.FirstCol); }
	}

    /**
    Returns the number of the first visible line. 
    */
    @property 
	{
        int visibleRowsCount() { return getIntAttribute(IupAttributes.FirstLine); }
	}


    /* ************* Public methods *************** */

    RectangleInt getCellRegion(int row, int col)
    {
        string v = getAttribute(IupAttributes.Clipped);
        RectangleInt r;
        sscanf(v.ptr, "%d:%d:%d:%d", &r.x1, &r.x2, &r.y1, &r.y2);
        return r;
    }

    /**
    When set with any value, provokes the control to be redrawn.
    */
    void repaint()
    {
        setAttribute(IupAttributes.Repaint, "0");
    }

    /**
    Tries to show completely a specific cell (considering any vertical or horizontal header
    or scrollbar position) .This attribute is set by a formatted string "%d:%d" (C syntax), 
    where each "%d" represent the line and column integer indexes respectively.
    */
    void setCellFullVisible(int row, int col)
    {
        setAttribute(IupAttributes.FullVisible, formatAddress(row, col));
    }

    /**
    Sets the first visible line and column positions. This attribute is set by a formatted 
    string "%d:%d" (C syntax), where each "%d" represent the line and column integer
    indexes respectively.
    */
    void setOriginCell(int row, int col)
    {
        setAttribute(IupAttributes.Origin, formatAddress(row, col));
    }

    static string formatAddress(int row, int col)
    { 
        return std.format.format("%d:%d", row, col); 
    }
}


/**
Creates a matrix of alphanumeric fields. Therefore, all values of the matrix fields are
strings. The matrix is not a grid container like many systems have.

SeeAlso: 
https://www.codeproject.com/articles/681771/simple-grid-a-win-message-based-grid-control
*/
public class IupMatrix : IupCanvasBase
{
    class IupCallbacks : super.IupCallbacks
	{
        enum Action =  "ACTION_CB";
        enum Click =  "CLICK_CB";
        enum ColResize =  "COLRESIZE_CB";
        enum Release =  "RELEASE_CB";
        enum ResizeMatrix =  "RESIZEMATRIX_CB";
        enum MouseMove =  "MOUSEMOVE_CB";
        enum EnterItem =  "ENTERITEM_CB";
        enum LeaveItem =  "LEAVEITEM_CB";
        enum ScrollTop =  "SCROLLTOP_CB";
    }

    class IupAttributes : super.IupAttributes
    {
        enum IupMatrix = "IupMatrix";

        enum Cursor = "CURSOR";
        enum DropImage = "DROPIMAGE";
        enum FocusCell = "FOCUSCELL";
        enum HideFocus = "HIDEFOCUS";
        enum HiddenTextMarks = "HIDDENTEXTMARKS";
        enum HlColor = "HLCOLOR";
        enum HlColorAlpha = "HLCOLORALPHA";
        enum Origin = "ORIGIN";
        enum OriginOffset = "ORIGINOFFSET";
        enum Readonly = "READONLY";
        enum ShowFillValue = "SHOWFILLVALUE";
        enum ToggleCentered = "TOGGLECENTERED";
        enum ToggleImageOn = "TOGGLEIMAGEON";
        enum ToggleImageOff = "TOGGLEIMAGEOFF";
        enum TypeColorInactive = "TYPECOLORINACTIVE";
        enum Align = "ALIGN";
        enum Type = "TYPE";
        enum FrameColor = "FRAMECOLOR";
        enum FrameVertColor = "FRAMEVERTCOLOR";
        enum FrameHorizColor = "FRAMEHORIZCOLOR";
        enum FrameTitleHighlight = "TOGGLEIMAGEOFF";
        enum ResizeMatrixColor = "RESIZEMATRIXCOLOR";

        enum Cell = "CELL";
        enum ToggleValue = "TOGGLEVALUE";
        enum CellBgColor = "CELLBGCOLOR";
        enum CellFgColor = "CELLFGCOLOR";
        enum CellOffset = "CELLOFFSET";
        enum CellSize = "CELLSIZE";

        enum Alignment = "ALIGNMENT";
        enum AlignmentLin = "ALIGNMENTLIN";
        enum LineAlignment = "LINEALIGNMENT";
        enum SortSign = "SORTSIGN";
        enum SortImageDown = "SORTIMAGEDOWN";
        enum SortImageUp = "SORTIMAGEUP";

        enum LimitExpand = "LIMITEXPAND";
        enum ResizeMatrix = "RESIZEMATRIX";
        enum UseTitleSize = "USETITLESIZE";
        enum RasterWidth = "RASTERWIDTH";
        enum Width = "WIDTH";
        enum WidthDef = "WIDTHDEF";
        enum Height = "HEIGHT";
        enum HeightDef = "HEIGHTDEF";
        enum RasterHeight = "RASTERHEIGHT";

        enum AddCol = "ADDCOL";
        enum AddLin = "ADDLIN";
        enum DelCol = "DELCOL";
        enum DelLin = "DELLIN";
        enum NumCol = "NUMCOL";
        enum NumColVisible = "NUMCOL_VISIBLE";
        enum NumColVisibleLast = "NUMCOL_VISIBLE_LAST";
        enum NumColNoScroll = "NUMCOL_NOSCROLL";
        enum NumLin = "NUMLIN";
        enum NumLinVisible = "NUMLIN_VISIBLE";
        enum NumLinVisibleLast = "NUMLIN_VISIBLE_LAST";
        enum NumLinNoScroll = "NUMLIN_NOSCROLL";

        enum MarkArea = "MARKAREA";
        enum MarkAtTitle = "MARKATTITLE";
        enum MarkMode = "MARKMODE";
        enum Mmark = "MARK";
        enum Mmarked = "MARKED";
        enum MmarkMultiple = "MARKMULTIPLE";

        enum EditMode = "EDITMODE";
        enum EditAlign = "EDITALIGN";
        enum EditCell = "EDITCELL";
        enum EditFitValue = "EDITFITVALUE";
        enum EditHideOnFocus = "EDITHIDEONFOCUS";
        enum Editing = "EDITING";
        enum EditNext = "EDITNEXT";
        enum EditText = "EDITTEXT";
        enum EditValue = "EDITVALUE";

        enum Caret = "CARET";
        enum Insert = "INSERT";
        enum Mask = "MASK";
        enum Multiline = "MULTILINE";
        enum Selection = "SELECTION";
    }

    class IupActionAttributes
    {
        enum ClearAttrib = "CLEARATTRIB";
        enum ClearValue = "CLEARVALUE";
        enum CopyCol = "COPYCOL";
        enum CopyLin = "COPYLIN";
        enum FitToSize = "FITTOSIZE";
        enum FitToText = "FITTOTEXT";
        enum MoveCol = "MOVECOL";
        enum MoveLin = "MOVELIN";
        enum Redraw = "REDRAW";
        enum Show = "SHOW";
    }

    this() { super(); }


    /* ************* Protected methods *************** */

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupMatrix(null);
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
        bool canHighlightFrameTitle() { 
            return getAttribute(IupAttributes.FrameTitleHighlight) == FlagIdentifiers.Yes; 
        }

        void canHighlightFrameTitle(bool value) {
            setAttribute(IupAttributes.FrameTitleHighlight, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    when text is greater than cell space, it is normally cropped, but when set to YES
    a "..." mark will be added at the crop point to indicate that there is more text
    not visible. Default: NO.
    */
    @property 
    {
        bool canShowTextMark() { 
            return getAttribute(IupAttributes.HiddenTextMarks) == FlagIdentifiers.Yes; 
        }

        void canShowTextMark(bool value) {
            setAttribute(IupAttributes.HiddenTextMarks, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    do not show the focus mark when drawing the matrix. Default is NO.
    */
    @property 
    {
        bool canShowFocusMark() { 
            return getAttribute(IupAttributes.HideFocus) == FlagIdentifiers.Yes; 
        }

        void canShowFocusMark(bool value) {
            setAttribute(IupAttributes.HideFocus, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    enable the display of the numeric percentage in the cell when TYPE* is FILL. Default: NO.
    */
    @property 
    {
        bool canShowPercentage() { 
            return getAttribute(IupAttributes.ShowFillValue) == FlagIdentifiers.Yes; 
        }

        void canShowPercentage(bool value) {
            setAttribute(IupAttributes.ShowFillValue, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Defines the number of lines in the matrix. Must be an integer number. Default: "0". 
    It does not include the title line. If changed after map will add empty cells or 
    discard cells at the end.
    */
    @property 
	{
		int columnCount()  {  return getIntAttribute(IupAttributes.NumCol); }
        void columnCount(int value) { setIntAttribute(IupAttributes.NumCol, value);}
	}

    /**
    complements the ORIGIN attribute by specifying the drag offset of the top left cell. 
    Returns the current value. Has the format "X:Y" or "%d:%d" in C. When changing this 
    attribute must change also ORIGIN right after. (since 3.5)
    */
    @property 
	{
		string dragOffset() { return getAttribute(IupAttributes.OriginOffset); }
		void dragOffset(string value) { setAttribute(IupAttributes.OriginOffset, value); }
	}

    /**
    drop image 
    */
    @property 
    {
        string dropImage() { 
            return getAttribute(IupAttributes.DropImage);
        }

        void dropImage(iup.image.IupImage image)  {
            setHandleAttribute(IupAttributes.DropImage, image);
        }

        void dropImage(string image)  {
            setAttribute(IupAttributes.DropImage, image);
        }
    }

    /**
    disables the editing of all cells. EDITION_CB and VALUE_EDIT_CB will not be called
    anymore. The L:C attribute will still be able to change the cell value.
    */
    @property 
    {
        bool isReadonly() { 
            return getAttribute(IupAttributes.Readonly) == FlagIdentifiers.Yes; 
        }

        void isReadonly(bool value) {
            setAttribute(IupAttributes.Readonly, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    center the toggle and use the cell value in place of TOGGLEVALUEL:C. No text will be drawn.
    */
    @property 
    {
        bool isToggleCentered() { 
            return getAttribute(IupAttributes.ToggleCentered) == FlagIdentifiers.Yes; 
        }

        void isToggleCentered(bool value) {
            setAttribute(IupAttributes.ToggleCentered, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    when inactive the color of the cell for TYPE*=COLOR will be attenuated as everything 
    else. Default: Yes.
    */
    @property 
    {
        bool isTypeColorInactive() { 
            return getAttribute(IupAttributes.TypeColorInactive) == FlagIdentifiers.Yes; 
        }

        void isTypeColorInactive(bool value) {
            setAttribute(IupAttributes.TypeColorInactive, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    the overlay color for the selected cells. Default: TXTHLCOLOR global attribute. 
    If set to "" will only use the attenuation process. The color is composited using
    HLCOLORALPHA attribute as alpha value (default is 128). 
    */
    @property 
    {
        Color overlayColor() { 
            string c = getAttribute(IupAttributes.HlColor);
            return Color.parse(c); 
        }

        void overlayColor(Color value)  { setAttribute(IupAttributes.HlColor, value.toRgb()); }

        void overlayColor(string value)  { setAttribute(IupAttributes.HlColor, value); }
    }

    /// ditto
    @property 
	{
		int overlayColorAlpha()  {  return getIntAttribute(IupAttributes.HlColorAlpha); }
        void overlayColorAlpha(int value) { setIntAttribute(IupAttributes.HlColorAlpha, value); }
	}

    /**
    color used by the column resize feedback. Default: "102 102 102". 
    */
    @property 
    {
        Color resizeMatrixColor() { 
            string c = getAttribute(IupAttributes.ResizeMatrixColor);
            return Color.parse(c); 
        }

        void resizeMatrixColor(Color value)  { 
            setAttribute(IupAttributes.ResizeMatrixColor, value.toRgb()); 
        }

        void resizeMatrixColor(string value)  { 
            setAttribute(IupAttributes.ResizeMatrixColor, value); 
        }
    }

    /**
    Defines the number of lines in the matrix. Must be an integer number. Default: "0". 
    It does not include the title line. If changed after map will add empty cells or 
    discard cells at the end.
    */
    @property 
	{
		int rowCount()  {  return getIntAttribute(IupAttributes.NumLin); }
        void rowCount(int value) { setIntAttribute(IupAttributes.NumLin, value); }
	}

    /**
    Title of the area between the line and column titles.
    */
    @property 
	{
		string topLeftCellTitle() {
            return getAttribute("0:0"); 
        }

		void topLeftCellTitle(string value) { 
            setAttribute("0:0", value); 
        }
	}

    /**
    toggle image.
    */
    @property 
    {
        string toggleImageOff() { return getAttribute(IupAttributes.ToggleImageOff); }

        void toggleImageOff(string value) 
        {
            setStrAttribute(IupAttributes.ToggleImageOff, value);
        }

        void toggleImageOff(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ToggleImageOff, value);
        }
    }

    /// ditto
    @property 
    {
        string toggleImageOn() { return getAttribute(IupAttributes.ToggleImageOn); }

        void toggleImageOn(string value) 
        {
            setStrAttribute(IupAttributes.ToggleImageOn, value);
        }

        void toggleImageOn(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ToggleImageOn, value);
        }
    }

    @property 
    {
        string currentCellAddress()  {  return getAttribute(IupAttributes.FocusCell); }
        //void rowCountAlpha(int value) { setIntAttribute(IupAttributes.HlColorAlpha, value);}
    }


    /* ************* Public methods *************** */

    /**
    Defines the current cell. Two numbers in the "L:C" format,  (L>0 and C>0, a title cell 
    can NOT be the current cell). Default: "1:1".
    */
    void focusCell(int row, int col)
    {
        assert(row>0 && col>0);
        setAttribute(IupAttributes.FocusCell, formatAddress(row, col));
    }

    /**
    Sets the first visible line and column positions. This attribute is set by a formatted 
    string "%d:%d" (C syntax), where each "%d" represent the line and column integer
    indexes respectively.
    */
    void setOriginCell(int row, int col)
    {
        setAttribute(IupAttributes.Origin, formatAddress(row, col));
    }

    /**
    */
    IupMatrixCell getCell(int row, int col)
    {
        return new IupMatrixCell(this, row, col);
    }

    /**
    Background color of column C.
    */
    Color getColumnBackgroundColor(int col) {
        string c = getAttribute(IupAttributes.BgColor ~ std.format.format("*:%d", col)); 
        return Color.parse(c); 
    }

    /// ditto
    void setColumnBackgroundColor(int col, Color value) { 
        setAttribute(IupAttributes.BgColor ~ std.format.format("*:%d", col), value.toRgb()); 
    }

    /// ditto
    void setColumnBackgroundColor(int col, string value) { 
        setAttribute(IupAttributes.BgColor ~ std.format.format("*:%d", col), value); 
    }

    /**
    Text font of the cells in column C.
    */
    Font getColumnfont(int col) {
        string f = getAttribute(IupAttributes.Font ~ std.format.format("*:%d", col));
        return Font.parse(f); 
    }

    /// ditto
    void setColumnFont(int col, Font value) { 
        setAttribute(IupAttributes.Font ~ std.format.format("*:%d", col), value.toString());
    }

    /// ditto
    void setColumnFont(int col, string value) { 
        setAttribute(IupAttributes.Font ~ std.format.format("*:%d", col), value);
    }

    /**
    Text color of column C.
    */
    Color getColumnForegroundColor(int col) {
        string c = getAttribute(IupAttributes.FgColor ~ std.format.format("*:%d", col)); 
        return Color.parse(c); 
    }

    /// ditto
    void setColumnForegroundColor(int col, Color value) { 
        setAttribute(IupAttributes.FgColor ~ std.format.format("*:%d", col), value.toRgb()); 
    }

    /// ditto
    void setColumnForegroundColor(int col, string value) { 
        setAttribute(IupAttributes.FgColor ~ std.format.format("*:%d", col), value); 
    }

    /**
    same as FRAMEVERTCOLORL:C but for all the cells of the column C.
    */
    Color getColumnRightFrameColor(int col) {
        string c = getAttribute(IupAttributes.FrameVertColor ~ std.format.format("*:%d", col)); 
        return Color.parse(c); 
    }

    /// ditto
    void setColumnRightFrameColor(int col, Color value) { 
        setAttribute(IupAttributes.FrameVertColor ~ std.format.format("*:%d", col), value.toRgb()); 
    }

    /// ditto
    void setColumnRightFrameColor(int col, string value) { 
        setAttribute(IupAttributes.FrameVertColor ~ std.format.format("*:%d", col), value); 
    }

    /**
    Sets the color to be used in the frame lines.
    */
    Color getFrameLineColor(int row) {
        string c = getAttribute(IupAttributes.FrameColor); 
        return Color.parse(c); 
    }

    /// ditto
    void setFrameLineColor(int row, Color value) { 
        setAttribute(IupAttributes.FrameColor, value.toRgb()); 
    }

    /// ditto
    void setFrameLineColor(int row, string value) { 
        setAttribute(IupAttributes.FrameColor, value); 
    }

    /**
    Background color of line L.
    */
    Color getRowBackgroundColor(int row) {
        string c = getAttribute(IupAttributes.BgColor ~ std.format.format("%d:*", row)); 
        return Color.parse(c); 
    }

    /// ditto
    void setRowBackgroundColor(int row, Color value) { 
        setAttribute(IupAttributes.BgColor ~ std.format.format("%d:*", row), value.toRgb()); 
    }

    /// ditto
    void setRowBackgroundColor(int row, string value) { 
        setAttribute(IupAttributes.BgColor ~ std.format.format("%d:*", row), value); 
    }

    /**
    same as FRAMEHORIZCOLORL:C but for all the cells of the line L.
    */
    Color getRowBottomFrameColor(int row) {
        string c = getAttribute(IupAttributes.FrameHorizColor ~ std.format.format("%d:*", row)); 
        return Color.parse(c); 
    }

    /// ditto
    void setRowBottomFrameColor(int row, Color value) { 
        setAttribute(IupAttributes.FrameHorizColor ~ std.format.format("%d:*", row), value.toRgb()); 
    }

    /// ditto
    void setRowBottomFrameColor(int row, string value) { 
        setAttribute(IupAttributes.FrameHorizColor ~ std.format.format("%d:*", row), value); 
    }

    /**
    Text font of the cells in line L.
    */
    Font getRowFont(int row) {
        string f = getAttribute(IupAttributes.Font ~ std.format.format("%d:*", row));
        return Font.parse(f); 
    }

    /// ditto
    void setRowFont(int row, Font value) { 
        setAttribute(IupAttributes.Font ~ std.format.format("%d:*", row), value.toString());
    }

    /// ditto
    void setRowFont(int row, string value) { 
        setAttribute(IupAttributes.Font ~ std.format.format("%d:*", row), value);
    }

    /**
    Text color of line L.
    */
    Color getRowForegroundColor(int row) {
        string c = getAttribute(IupAttributes.FgColor ~ std.format.format("%d:*", row)); 
        return Color.parse(c); 
    }

    /// ditto
    void setRowForegroundColor(int row, Color value) { 
        setAttribute(IupAttributes.FgColor ~ std.format.format("%d:*", row), value.toRgb()); 
    }

    /// ditto
    void setRowForegroundColor(int row, string value) { 
        setAttribute(IupAttributes.FgColor ~ std.format.format("%d:*", row), value); 
    }

    /**
    Title of column C.
    */
    string getColumnTitle(int col) {
        return getAttribute(formatAddress(0, col)); 
    }

    /// ditto
    void setColumnTitle(int col, string value) { 
        setAttribute(formatAddress(0, col), value); 
    }

    /**
    Title of line L.
    */
    string getRowTitle(int row) {
        return getAttribute(formatAddress(row, 0)); 
    }

    /// ditto
    void setRowTitle(int row, string value) { 
        setAttribute(formatAddress(row, 0), value); 
    }

    /**
    Type of column C.  
    */
    string getColumnType(int col) {
        return getAttribute(IupAttributes.Type ~ std.format.format("*:%d", col)); 
    }

    /// ditto
    void setColumnType(int col, string value) { 
        setAttribute(IupAttributes.Type ~ std.format.format("*:%d", col), value); 
    }

    /**
    Type of line L. 
    */
    string getRowType(int row) {
        return getAttribute(IupAttributes.Type ~ std.format.format("%d:*", row)); 
    }

    /// ditto
    void setRowType(int row, string value) { 
        setAttribute(IupAttributes.Type ~ std.format.format("%d:*", row), value); 
    }

    /**
    */
    static string formatAddress(int row, int col)
    { 
        return std.format.format("%d:%d", row, col); 
    }
}


/**
*/
class IupMatrixCell : IupAuxiliaryObject
{
    class IupAttributes : super.IupAttributes
    {
        enum IupMatrixCell = "IupMatrixCell";
 
        enum Align = "ALIGN";
        enum Type = "TYPE";
        enum FrameColor = "FRAMECOLOR";
        enum FrameVertColor = "FRAMEVERTCOLOR";
        enum FrameHorizColor = "FRAMEHORIZCOLOR";
        enum FrameTitleHighlight = "TOGGLEIMAGEOFF";
        enum ResizeMatrixColor = "RESIZEMATRIXCOLOR";

        enum Cell = "CELL";
        enum ToggleValue = "TOGGLEVALUE";
        enum CellBgColor = "CELLBGCOLOR";
        enum CellFgColor = "CELLFGCOLOR";
        enum CellOffset = "CELLOFFSET";
        enum CellSize = "CELLSIZE";

        enum Alignment = "ALIGNMENT";
        enum AlignmentLin = "ALIGNMENTLIN";
        enum LineAlignment = "LINEALIGNMENT";
        enum SortSign = "SORTSIGN";
        enum SortImageDown = "SORTIMAGEDOWN";
        enum SortImageUp = "SORTIMAGEUP";

        enum LimitExpand = "LIMITEXPAND";
        enum ResizeMatrix = "RESIZEMATRIX";
        enum UseTitleSize = "USETITLESIZE";
        enum RasterWidth = "RASTERWIDTH";
        enum Width = "WIDTH";
        enum WidthDef = "WIDTHDEF";
        enum Height = "HEIGHT";
        enum HeightDef = "HEIGHTDEF";
        enum RasterHeight = "RASTERHEIGHT";

        enum AddCol = "ADDCOL";
        enum AddLin = "ADDLIN";
        enum DelCol = "DELCOL";
        enum DelLin = "DELLIN";
        enum NumCol = "NUMCOL";
        enum NumColVisible = "NUMCOL_VISIBLE";
        enum NumColVisibleLast = "NUMCOL_VISIBLE_LAST";
        enum NumColNoScroll = "NUMCOL_NOSCROLL";
        enum NumLin = "NUMLIN";
        enum NumLinVisible = "NUMLIN_VISIBLE";
        enum NumLinVisibleLast = "NUMLIN_VISIBLE_LAST";
        enum NumLinNoScroll = "NUMLIN_NOSCROLL";

        enum MarkArea = "MARKAREA";
        enum MarkAtTitle = "MARKATTITLE";
        enum MarkMode = "MARKMODE";
        enum Mmark = "MARK";
        enum Mmarked = "MARKED";
        enum MmarkMultiple = "MARKMULTIPLE";

        enum EditMode = "EDITMODE";
        enum EditAlign = "EDITALIGN";
        enum EditCell = "EDITCELL";
        enum EditFitValue = "EDITFITVALUE";
        enum EditHideOnFocus = "EDITHIDEONFOCUS";
        enum Editing = "EDITING";
        enum EditNext = "EDITNEXT";
        enum EditText = "EDITTEXT";
        enum EditValue = "EDITVALUE";

        enum Caret = "CARET";
        enum Insert = "INSERT";
        enum Mask = "MASK";
        enum Multiline = "MULTILINE";
        enum Selection = "SELECTION";
    }

    private string m_address;

    this(IupMatrix control, int row, int col)
    {
        super(control);
        columnIndex = row;
        columnIndex = col;
    }

    /**
    Alignment of the cell value in line L and column C. Values are in the format: 
    "linalign:colalign", where linalign can be "ATOP", "ACENTER" or "ABOTTOM", and
    colalign can be "ALEFT", "ACENTER" or "ARIGHT". Default will use ALIGNMENT* and 
    LINEALIGMENT*. 
    */
    @property 
    {
        string alignment() { return getAttribute(IupAttributes.Alignment ~ m_address); }
        void alignment(string value) { setAttribute(IupAttributes.Alignment ~ m_address, value); }
    }

    /**
    Background color of the cell in line L and column C.
    */
    @property 
    {
        Color backgroundColor() { 
            string c = getAttribute(IupElement.IupAttributes.BgColor ~ m_address);
            return Color.parse(c); 
        }

        void backgroundColor(Color value)  { 
            setAttribute(IupElement.IupAttributes.BgColor ~ m_address, value.toRgb()); 
        }

        void backgroundColor(string value)  { 
            setAttribute(IupElement.IupAttributes.BgColor ~ m_address, value); 
        }
    }

    /**
    Color of the horizontal bottom frame line of the cell. When not defined the FRAMECOLOR
    is used. For a title line cell (lin=0) defines bottom and top frames. If value is
    "BGCOLOR" the frame line is not drawn.
    */
    @property 
    {
        Color bottomFrameLineColor() { 
            string c = getAttribute(IupAttributes.FrameHorizColor ~ m_address);
            return Color.parse(c); 
        }

        void bottomFrameLineColor(Color value)  { 
            setAttribute(IupAttributes.FrameHorizColor ~ m_address, value.toRgb()); 
        }

        void bottomFrameLineColor(string value)  { 
            setAttribute(IupAttributes.FrameHorizColor ~ m_address, value); 
        }
    }

    /**
    Summary:
    Gets the index of the cell's parent row.

    Returns:
    The index of the column that contains the cell; -1 if the cell is not contained
    within a column.
    */
    @property 
    {
        int columnIndex() { return m_columnIndex; }

        void columnIndex(int value) { 
            m_columnIndex = value; 
            m_address = IupMatrix.formatAddress(m_rowIndex, m_columnIndex);
        }
        private int m_columnIndex;
    }

    /**
    Returns the displayed cell value. Returns NULL if the cell does not exists, or it is
    not visible, or the element is not mapped. 
    */
    @property 
    {
        string displayValue() { return getAttribute(IupAttributes.Cell ~ m_address); }
    }

    /**
    Text font of the cell in line L and column C.
    */
    @property 
	{
        Font font() {
            string f = getAttribute(IupControl.IupAttributes.Font ~ m_address);
            return Font.parse(f); 
        }

        void font(Font value) { 
            setAttribute(IupControl.IupAttributes.Font ~ m_address, value.toString());
        }

        void font(string value) { 
            setAttribute(IupControl.IupAttributes.Font ~ m_address, value);
        }
	}

    /**
    Text color of the cell in line L and column C.
    */
    @property 
    {
        Color foregroundColor() { 
            string c = getAttribute(IupElement.IupAttributes.FgColor ~ m_address);
            return Color.parse(c); 
        }

        void foregroundColor(Color value)  { 
            setAttribute(IupElement.IupAttributes.FgColor ~ m_address, value.toRgb()); 
        }

        void foregroundColor(string value)  { 
            setAttribute(IupElement.IupAttributes.FgColor ~ m_address, value); 
        }
    }

    /**
    Color of the vertical right frame line of the cell. When not defined the FRAMECOLOR 
    is used. For a title column cell (col=0) defines right and left frames. If value is 
    "BGCOLOR" the frame line is not drawn.
    */
    @property 
    {
        Color rightFrameLineColor() { 
            string c = getAttribute(IupAttributes.FrameVertColor ~ m_address);
            return Color.parse(c); 
        }

        void rightFrameLineColor(Color value)  { 
            setAttribute(IupAttributes.FrameVertColor ~ m_address, value.toRgb()); 
        }

        void rightFrameLineColor(string value)  { 
            setAttribute(IupAttributes.FrameVertColor ~ m_address, value); 
        }
    }

    /**
    Summary:
    Gets the column index for this cell.

    Returns:
    The index of the row that contains the cell; -1 if there is no owning row.
    */    
    @property 
    {
        int rowIndex() { return m_rowIndex; }

        void rowIndex(int value) { 
            m_rowIndex = value; 
            m_address = IupMatrix.formatAddress(m_rowIndex, m_columnIndex);
        }
        private int m_rowIndex;
    }

    /**
    Text of the cell located in line L and column C, where L and C are integer numbers. 
    */
    @property 
    {
        string text() { return getAttribute(m_address); }
        void text(string value) { setAttribute(m_address, value); }
    }

    /**
    Type of the cell value in line L and column C.  
    */
    @property 
    {
        string type() { return getAttribute(IupAttributes.Type ~ m_address); }
        void type(string value) { setAttribute(IupAttributes.Type ~ m_address, value); }
    }

    /**
    value of the toggle inside the cell. The toggle is shown only if the DROPCHECK_CB 
    returns IUP_CONTINUE for the cell. When the toggle is interactively change the 
    TOGGLEVALUE_CB callback is called.
    */
    @property 
    {
        string toggleValue() { return getAttribute(IupAttributes.ToggleValue ~ m_address); }
        void toggleValue(string value) { setAttribute(IupAttributes.ToggleValue ~ m_address, value); }
    }

    /**
    Allows setting or verifying the value of the current cell. Is the same as obtaining 
    the current cell line and column from FOCUSCELL attribute, and then using them to
    access the "L:C" attribute. But when updated or retrieved during cell editing, the
    edit control will be updated or consulted instead of the matrix cell. When retrieved
    inside the EDITION_CB callback when mode is 0, then the return value is the new value
    that will be updated in the cell.
    */
    @property 
    {
        string value() { return getAttribute(IupControl.IupAttributes.Value ~ m_address); }
        void value(string value) { setAttribute(IupControl.IupAttributes.Value ~ m_address, value); }
    }


}