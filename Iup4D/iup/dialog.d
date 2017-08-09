module iup.dialog;

import iup.button;
import iup.control;
import iup.core;
import iup.container;
import iup.menu;
import iup.c;

import toolkit.event;
import toolkit.drawing;
import toolkit.container;

import std.conv;
import std.string;
import std.format;

version (Windows)
{
    import core.sys.windows.windef;
    import std.windows.charset;
}

/**
Creates a dialog element. It manages user interaction with the interface elements. For any 
interface element to be shown, it must be encapsulated in a dialog.
*/
public class IupDialog : IupContentControl
{

    alias DialogCollection = ItemCollection!(IupDialog, false);

    class IupCallbacks : super.IupCallbacks
    {
        enum Close = "CLOSE_CB";
        enum CustomFrame = "CUSTOMFRAME_CB";
        enum DropFiles = "DROPFILES_CB";
        enum MdiActivate = "MDIACTIVATE_CB";
        enum Move = "MOVE_CB";
        enum Resize = "RESIZE_CB";
        enum Show = "SHOW_CB";
        enum TrayClick = "TRAYCLICK_CB";
    }

    class IupAttributes : super.IupAttributes
    {
        enum Border = "BORDER";
        enum HideTaskBar = "HIDETASKBAR";
        enum Cursor = "CURSOR";
        enum CustomFrame = "CUSTOMFRAME";
        enum CustomFrameEx = "CUSTOMFRAMEEX";
        enum CustomFrameCaption = "CUSTOMFRAMECAPTION";
        enum CustomFrameCaptionLimits = "CUSTOMFRAMECAPTIONLIMITS";
        enum DialogFrame = "DIALOGFRAME";
        enum DefaultEnter = "DEFAULTENTER";
        enum DefaultEsc = "DEFAULTESC";
        enum FullScreen = "FULLSCREEN";
        enum HDC_WmPaint = "HDC_WMPAINT";
        enum HelpButton = "HELPBUTTON";
        enum HWND = "HWND";
        enum Icon = "ICON";
        enum MaxBox = "MAXBOX";
        enum MdiActive = "MDIACTIVE";
        enum MdiActivate = "MDIACTIVATE";
        enum MdiArrange = "MDIARRANGE";
        enum MdiCloseAll = "MDICLOSEALL";
        enum MdiChild = "MDICHILD";
        enum MdiFrame = "MDIFRAME";
        enum MdiNext = "MDINEXT";
        enum MenuBox = "MENUBOX";
        enum MinBox = "MINBOX";
        //enum MinSize = "MINSIZE";
        enum Modal = "MODAL";
        enum ParentDialog = "PARENTDIALOG";
        enum Placement = "PLACEMENT";
        enum Opacity = "OPACITY";
        enum OpacityImage = "OPACITYIMAGE";
        enum Resize = "RESIZE";
        enum SaveUnder = "SAVEUNDER";
        enum Shrink = "SHRINK";
        enum Status = "STATUS";
        enum StartFocus = "STARTFOCUS";
        enum Toolbox = "TOOLBOX";
        enum TopMost = "TOPMOST";
    }

    this()
    {
        super();
    }

    this(bool canSaveUnder, bool canResize)
    {
        super();
        this.canSaveUnder = canSaveUnder;
        this.canResize = canResize;
    }

    this(IupControl child)
    {
        super(child);
    }

    /* ************* Protected methods *************** */

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupDialog(null);
    }

    override protected void onCreated()
    {
        super.onCreated();

        m_mdiChildren = new DialogCollection();
        m_tray = new IupTray(this);

        registerClosingCallback(IupCallbacks.Close);
        registerFileDroppedCallback(IupCallbacks.DropFiles);
        registerMoveCallback(IupCallbacks.Move);
        registerSizeChangedCallback(IupCallbacks.Resize);
        registerStateChangedCallback(IupCallbacks.Show);
        registerTrayClickCallback(IupCallbacks.TrayClick);

        version (Windows)
        {
            //registerCustomFramePaintedCallback(IupCallbacks.CustomFrame); // bug
            registerMdiChildActivatedCallback(IupCallbacks.MdiActivate);

        }

        dialogResult = DialogResult.None;
        sizeMode = WindowSizeMode.Custom;

        initializeComponent(); // 
    }

    protected void initializeComponent()
    {
        // do nothing
    }

    /* ************* Events *************** */

    /**
    */
    EventHandler!CallbackEventArgs loaded;

    /**
    Called just before a dialog is closed when the user clicks the close button of 
    the title bar or an equivalent action.
    */
    mixin EventCallback!(IupDialog, "closing");

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
    public EventHandler!(CallbackEventArgs, string, int, int, int) fileDropped;
    mixin EventCallbackAdapter!(IupDialog, "fileDropped", const(char)*, int, int, int);

    private IupElementAction onFileDropped(const(char)* fileName, int num, int x, int y) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            fileDropped(this, callbackArgs,
                    cast(string) std.string.fromStringz(fileName), num, x, y);
            r = callbackArgs.result;
        }
        catch (Exception ex)
        { /* do nothing. */ }
        return r;
    }

    /**
    Called after the dialog was moved on screen. The coordinates are the same as the 
    SCREENPOSITION attribute. (since 3.0)
    */
    mixin EventCallback!(IupDialog, "move", int, int);

    /**
    width: the width of the internal element size in pixels not considering the decorations (client size)
    height: the height of the internal element size in pixels not considering the decorations (client size)
    */
    mixin EventCallback!(IupDialog, "sizeChanged", int, int);

    /**
    Called right after the dialog is showed, hidden, maximized, minimized or 
    restored from minimized/maximized. 
    This callback is called when those actions were performed by the user or 
    programmatically by the application.
    */
    public EventHandler!(CallbackEventArgs, DialogState) stateChanged;
    mixin EventCallbackAdapter!(IupDialog, "stateChanged", int);

    private IupElementAction onStateChanged(int state) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            if (state == IUP_SHOW)
            {
                loaded(this, callbackArgs);
            }
            else
            {
                stateChanged(this, callbackArgs, cast(DialogState) state);
                r = callbackArgs.result;
            }
        }
        catch (Exception ex)
        { /* do nothing. */ }

        return r;
    }

    /**
    Called right after the mouse button is pressed or released over the tray icon. (GTK 2.10)
    */
    mixin EventCallback!(IupDialog, "trayClick", int, bool, bool);

    version (Windows)
    {

        /**
        Called when the dialog must be redraw. Although it is designed for drawing the 
        frame elements, all the dialog must be painted. Works only when CUSTOMFRAME or 
        CUSTOMFRAMEEX is defined. The dialog can be used just like an IupCanvas to draw
        its elements, the HDC_WMPAINT and CLIPRECT attributes are defined during the 
        callback. For mouse callbacks use the same callbacks as IupCanvas, such as BUTTON_CB
        and MOTION_CB. (since 3.18)
        */
        mixin EventCallback!(IupDialog, "customFramePainted");

        /**
        Called when a MDI child window is activated. Only the MDI child receive this message. 
        It is not called when the child is shown for the first time.
        */
        mixin EventCallback!(IupDialog, "mdiChildActivated");
    }

    /* ************* Properties *************** */

    /**
    Action attribute that when set to "YES", hides the dialog, but does not decrement the visible
    dialog count, does not call SHOW_CB and does not mark the dialog as hidden inside IUP. It is
    usually used to hide the dialog and keep the tray icon working without closing the main loop. 
    It has the same effect as setting LOCKLOOP=Yes and normally hiding the dialog. IMPORTANT: when 
    you hide using HIDETASKBAR, you must show using HIDETASKBAR also. Possible values: YES, NO. 
    */
    @property
    {
        public bool canHideTaskBar()
        {
            return getAttribute(IupAttributes.HideTaskBar) == FlagIdentifiers.Yes;
        }

        public void canHideTaskBar(bool value)
        {
            setAttribute(IupAttributes.HideTaskBar, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Allows changing the elements’ distribution when the dialog is smaller than the minimum size.
    Default: NO.
    */
    @property
    {
        public bool canShrink()
        {
            return getAttribute(IupAttributes.Shrink) == FlagIdentifiers.Yes;
        }

        public void canShrink(bool value)
        {
            setAttribute(IupAttributes.Shrink, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Defines the element's cursor.

    The Windows SDK recommends that cursors and icons should be implemented as resources 
    rather than created at run time.

    If it is not a pre-defined name, then will check for other system cursors. In Windows
    the value will be used to load a cursor form the application resources. In Motif the 
    value will be used as a X-Windows cursor number, see definitions in the X11 header
    "cursorfont.h". In GTK the value will be used as a cursor name, see the GDK 
    documentation on Cursors. 

    If no system cursors were found then the value will be used to try to find an IUP 
    image with the same name. Use IupSetHandle to define a name for an IupImage. But the 
    image will need an extra attribute and some specific characteristics, see notes below.
    */
    @property
    {
        public string cursor()
        {
            return getAttribute(IupAttributes.Cursor);
        }

        public void cursor(string value)
        {
            setAttribute(IupAttributes.Cursor, value);
        }

        public void cursor(iup.image.IupImage value)
        {
            setHandleAttribute(IupAttributes.Cursor, value);
        }
    }

    /**
    Allows interactively changing the dialog’s size. Default: YES. If RESIZE=NO then MAXBOX will
    be set to NO. In Motif the decorations are controlled by the Window Manager and may not be
    possible to be changed from IUP.
    */
    @property
    {
        public bool canResize()
        {
            return getAttribute(IupAttributes.Resize) == FlagIdentifiers.Yes;
        }

        public void canResize(bool value)
        {
            setAttribute(IupAttributes.Resize, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    When this attribute is true (YES), the dialog stores the original image of the desktop region it 
    occupies (if the system has enough memory to store the image). In this case, when the dialog is 
    closed or moved, a redrawing event is not generated for the windows that were shadowed by it. 
    Its default value is YES. To save memory disable it for your main dialog. Not available in GTK.
    */
    @property
    {
        public bool canSaveUnder()
        {
            return getAttribute(IupAttributes.SaveUnder) == FlagIdentifiers.Yes;
        }

        public void canSaveUnder(bool value)
        {
            setAttribute(IupAttributes.SaveUnder, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Shows a resize border around the dialog. Default: "YES". BORDER=NO is useful only when RESIZE=NO, 
    MAXBOX=NO, MINBOX=NO, MENUBOX=NO and TITLE=NULL, if any of these are defined there will be 
    always some border. (creation only)
    */
    @property
    {
        public bool hasBorder()
        {
            return getAttribute(IupAttributes.Border) == FlagIdentifiers.Yes;
        }

        public void hasBorder(bool value)
        {
            setAttribute(IupAttributes.Border, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Requires a maximize button from the window manager. If RESIZE=NO then MAXBOX will be set to NO. 
    Default: YES. In Motif the decorations are controlled by the Window Manager and may not be 
    possible to be changed from IUP. In Windows MAXBOX is hidden only if MINBOX is hidden as well,
    or else it will be just disabled.
    */
    @property
    {
        public bool hasMaxBox()
        {
            return getAttribute(IupAttributes.MaxBox) == FlagIdentifiers.Yes;
        }

        public void hasMaxBox(bool value)
        {
            setAttribute(IupAttributes.MaxBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Requires a system menu box from the window manager. If hidden will also remove the Close button.
    Default: YES. In Motif the decorations are controlled by the Window Manager and may not be possible
    to be changed from IUP. In Windows if hidden will hide also MAXBOX and MINBOX.
    */
    @property
    {
        public bool hasMenuBox()
        {
            return getAttribute(IupAttributes.MenuBox) == FlagIdentifiers.Yes;
        }

        public void hasMenuBox(bool value)
        {
            setAttribute(IupAttributes.MenuBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Requires a minimize button from the window manager. Default: YES. In Motif the decorations are
    controlled by the Window Manager and may not be possible to be changed from IUP. In Windows MINBOX
    is hidden only if MAXBOX is hidden as well, or else it will be just disabled.
    */
    @property
    {
        public bool hasMinBox()
        {
            return getAttribute(IupAttributes.MinBox) == FlagIdentifiers.Yes;
        }

        public void hasMinBox(bool value)
        {
            setAttribute(IupAttributes.MinBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Dialog's icon. This icon will be used when the dialog is minimized among other places
    by the native system. Icon sizes are usually less than or equal to 32x32. 

    The Windows SDK recommends that cursors and icons should be implemented as resources 
    rather than created at run time. We suggest using an icon with at least 3 images: 16x16
    32bpp, 32x32 32 bpp and 48x48 32 bpp.
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
    Makes the dialog occupy the whole screen over any system bars in the main monitor. All dialog details, such as title bar, borders, maximize button, etc, are removed. Possible values: YES, NO. In Motif you may have to click in the dialog to set its focus.
    In Motif if set to YES when the dialog is hidden, then it can not be changed after it is visible.
    */
    @property
    {
        public bool isFullScreen()
        {
            return getAttribute(IupAttributes.FullScreen) == FlagIdentifiers.Yes;
        }

        public void isFullScreen(bool value)
        {
            setAttribute(IupAttributes.FullScreen, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Requires a maximize button from the window manager. If RESIZE=NO then MAXBOX will be set to NO. 
    Default: YES. In Motif the decorations are controlled by the Window Manager and may not be 
    possible to be changed from IUP. In Windows MAXBOX is hidden only if MINBOX is hidden as well, 
    or else it will be just disabled.
    */
    @property
    {
        public bool maximizeBox()
        {
            return getAttribute(IupAttributes.MaxBox) == FlagIdentifiers.Yes;
        }

        public void maximizeBox(bool value)
        {
            setAttribute(IupAttributes.MaxBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    ///**
    //Associates a menu to the dialog as a menu bar. The previous menu, if any, is unmapped. Use 
    //IupSetHandle or IupSetAttributeHandle to associate a menu to a name. See also IupMenu.
    //*/
    //@property 
    //{
    //    public iup.menu.IupMenu menuBar() { return m_menuBar; }
    //
    //    private void menuBar(iup.menu.IupMenu value) 
    //    {
    //        m_menuBar = value;
    //        iup.c.IupSetAttributeHandle(handle, IupAttributes.Menu, value is null ? null : value.handle);
    //    }
    //    private iup.menu.IupMenu m_menuBar; 
    //}

    /**
    Maximum size for the dialog in raster units (pixels). The windowing system will not be able
    to change the size beyond this limit. Default: 65535x65535. (since 3.0)
    */
    //@property 
    //{
    //    public Size maxSize() 
    //    { 
    //        string s = getAttribute(IupAttributes.MaxSize);
    //        return IupSize.parse(s); 
    //    }
    //
    //    public void maxSize(Size value) 
    //    {
    //        setAttribute(IupAttributes.MaxSize, IupSize.format(value));
    //    }
    //}

    /**
    Requires a minimize button from the window manager. Default: YES. In Motif the decorations are
    controlled by the Window Manager and may not be possible to be changed from IUP. In Windows 
    MINBOX is hidden only if MAXBOX is hidden as well, or else it will be just disabled.
    */
    @property
    {
        public bool minimizeBox()
        {
            return getAttribute(IupAttributes.MinBox) == FlagIdentifiers.Yes;
        }

        public void minimizeBox(bool value)
        {
            setAttribute(IupAttributes.MinBox, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Minimum size for the dialog in raster units (pixels). The windowing system will not be able to
    change the size beyond this limit. Default: 1x1. Some systems define a very minimum size greater
    than this, for instance in Windows the horizontal minimum size includes the window decoration
    buttons. (since 3.0)
    */
    //@property 
    //{
    //    public Size minSize() 
    //    { 
    //        string s = getAttribute(IupAttributes.MinSize);
    //        return IupSize.parse(s); 
    //    }
    //
    //    public void minSize(Size value) 
    //    {
    //        setAttribute(IupAttributes.MinSize, IupSize.format(value));
    //    }
    //}

    /**
    */
    @property
    {
        public WindowSizeMode sizeMode()
        {
            return m_sizeMode;
        }

        public void sizeMode(WindowSizeMode value)
        {
            m_sizeMode = value;
            string str;

            if (value == WindowSizeMode.Custom)
                str = IupSize.format(size);
            else
                str = iupToString(value);

            setAttribute(IupAttributes.Size, str);
        }

        private WindowSizeMode m_sizeMode;
    }

    /**
    sets the dialog transparency alpha value. Valid values range from 0 (completely transparent) to 255 (opaque). 
    In Windows must be set before map so the native window would be properly initialized when mapped (since 3.16). (GTK 2.12)
    */
    @property
    {
        public int opacity()
        {
            return getIntAttribute(IupAttributes.Opacity);
        }

        public void opacity(int value)
        {
            setIntAttribute(IupAttributes.Opacity, value);
        }
    }

    /**
    sets a transparent image as the dialog shape so it is possible to create a non rectangle window. 
    In Windows must be set before map so the native window would be properly initialized when mapped 
    (since 3.16). In GTK the shape works only as a bitmap mask, to view a color image must also use 
    a label. (GTK 2.12) (since 3.12)
    */
    @property
    {
        //public string opacityImage() { return getAttribute(IupAttributes.OpacityImage); }

        public void opacityImage(iup.image.IupImage value)
        {
            setHandleAttribute(IupAttributes.OpacityImage, value);
        }
    }

    /**
    Set the common decorations for modal dialogs. This means RESIZE=NO, MINBOX=NO and MAXBOX=NO. 
    In Windows, if the PARENTDIALOG is defined then the MENUBOX is also removed, but the Close button remains.
    */
    @property
    {
        public bool isDialogFrame()
        {
            return m_isDialogFrame;
        }

        public void isDialogFrame(bool value)
        {
            m_isDialogFrame = value;
            setAttribute(IupAttributes.DialogFrame, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }

        private bool m_isDialogFrame;
    }

    /**
    Returns the popup state. It is "YES" if the dialog was shown using IupPopup. It is "NO" if 
    IupShow was used or it is not visible. At the first time the dialog is shown, MODAL is 
    not set yet when SHOW_CB is called. (since 3.0)
    */
    @property public bool isModal()
    {
        return getAttribute(IupAttributes.Modal) == FlagIdentifiers.Yes;
    }

    /**
   puts the dialog always in front of all other dialogs in all applications. Default: NO.
   */
    @property
    {
        public bool isTopMost()
        {
            return getAttribute(IupAttributes.TopMost) == FlagIdentifiers.Yes;
        }

        public void isTopMost(bool value)
        {
            setAttribute(IupAttributes.TopMost, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    version (Windows)
    {

        protected DialogCollection m_mdiChildren;

        /**
    limits of the caption area at left and at right. The caption area is always expanded inside
    the limits when the dialog is resized. Format is "left:right" or in C "%d:%d". Default: "0:0".
    This will allow the dialog to be moved by the system when the user click and drag the caption
    area. (since 3.18)
    */
        @property
        {
            public string customFrameCaptionLimits()
            {
                return getAttribute(IupAttributes.CustomFrameCaptionLimits);
            }

            public void customFrameCaptionLimits(string value)
            {
                setAttribute(IupAttributes.CustomFrameCaptionLimits, value);
            }
        }

        /**
    Inserts a help button in the same place of the maximize button. It can only be used for 
    dialogs without the minimize and maximize buttons, and with the menu box. For the next 
    interaction of the user with a control in the dialog, the callback  HELP_CB will be called
    instead of the control defined ACTION callback. Possible values: YES, NO. Default: NO.
    (creation only)
    */
        @property
        {
            public bool hasHelpButton()
            {
                return getAttribute(IupAttributes.HelpButton) == FlagIdentifiers.Yes;
            }

            public void hasHelpButton(bool value)
            {
                setAttribute(IupAttributes.HelpButton, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
    Contains the HDC created with the BeginPaint inside the WM_PAINT message. Valid only during the ACTION callback.
    */
        @property
        {
            public HDC hdcWmPaint()
            {
                return cast(HDC) getPointerAttribute(IupAttributes.HDC_WmPaint);
            }
        }

        /**
    Returns the Windows Window handle. Available in the Windows driver or in the GTK driver in Windows.
    */
        @property
        {
            public HWND hwnd()
            {
                return cast(HWND) getPointerAttribute(IupAttributes.HWND);
            }
        }

        /**
    allows the application to customize the frame elements by drawing them with the CUSTOMFRAME_CB
    callback. Can be Yes or No. The Window client area is expanded to include the whole window. 
    Notice that the dialog attributes like BORDER, RESIZE, MAXBOX, MINBOX and TITLE must still
    be defined. But maximize, minimize and close buttons must be manually implemented. One drawback
    is that menu bars will not work. (since 3.18)
    */
        @property
        {
            public bool isCustomFrame()
            {
                return getAttribute(IupAttributes.CustomFrame) == FlagIdentifiers.Yes;
            }

            public void isCustomFrame(bool value)
            {
                setAttribute(IupAttributes.CustomFrame, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
                if (value)
                {
                    //  register only once
                    if (!isCustomFramePaintedCallbackRegistered)
                    {
                        registerCustomFramePaintedCallback(IupCallbacks.CustomFrame);
                        isCustomFramePaintedCallbackRegistered = true;
                    }
                }
                else if (isCustomFramePaintedCallbackRegistered)
                {
                    unregisterCallback(IupCallbacks.CustomFrame);
                    isCustomFramePaintedCallbackRegistered = false;
                }
            }

            private bool isCustomFramePaintedCallbackRegistered;
        }

        /**
    Same as CUSTOMFRAME but used when the application use controls for frame elements like caption,
    minimize button, maximize button, and close buttons. The application is responsible for leaving 
    space for the borders. The CUSTOMFRAME_CB callback will also work. (since 3.18)
    */
        @property
        {
            public bool isCustomFrameEx()
            {
                return getAttribute(IupAttributes.CustomFrameEx) == FlagIdentifiers.Yes;
            }

            public void isCustomFrameEx(bool value)
            {
                setAttribute(IupAttributes.CustomFrameEx, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
    Configure this dialog to be a MDI child. Can be YES or NO. The PARENTDIALOG attribute must 
    also be defined. Each MDI child is automatically named if it does not have one. Default: NO.
    */
        @property
        {
            public bool isMdiChild()
            {
                return getAttribute(IupAttributes.MdiChild) == FlagIdentifiers.Yes;
            }

            public void isMdiChild(bool value)
            {
                setAttribute(IupAttributes.MdiChild, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
    Configure this dialog as a MDI frame. Can be YES or NO. Default: NO.
    */
        @property
        {
            public bool isMdiContainer()
            {
                return getAttribute(IupAttributes.MdiFrame) == FlagIdentifiers.Yes;
            }

            public void isMdiContainer(bool value)
            {
                setAttribute(IupAttributes.MdiFrame, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
    makes the dialog look like a toolbox with a smaller title bar. It is only valid if the PARENTDIALOG or 
    NATIVEPARENT attribute is also defined. Default: NO.
    */
        @property
        {
            public bool isToolbox()
            {
                return m_isToolbox;
            }

            public void isToolbox(bool value)
            {
                m_isToolbox = value;
                setAttribute(IupAttributes.Toolbox, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }

            private bool m_isToolbox;
        }
    }

    /**
    */
    @property
    {
        public IIupButton defaultEnter()
        {
            return m_defaultEnter;
        }

        public void defaultEnter(IIupButton value)
        {
            m_defaultEnter = value;
            setHandleAttribute(IupAttributes.DefaultEnter, value);
        }

        private IIupButton m_defaultEnter;
    }

    /**
    */
    @property
    {
        public iup.button.IupButton defaultEsc()
        {
            return m_defaultEsc;
        }

        public void defaultEsc(iup.button.IupButton value)
        {
            m_defaultEsc = value;
            setHandleAttribute(IupAttributes.DefaultEsc, value);
        }

        private iup.button.IupButton m_defaultEsc;
    }

    /**
    */
    @property
    {
        public iup.dialog.IupDialog parent()
        {
            return m_parent;
        }

        public void parent(iup.dialog.IupDialog value)
        {
            m_parent = value;
            setHandleAttribute(IupAttributes.ParentDialog, value);
        }

        private iup.dialog.IupDialog m_parent;
    }

    /**
    */
    @property
    {
        public iup.core.IupElement startFocus()
        {
            return m_startFocus;
        }

        public void startFocus(iup.core.IupElement value)
        {
            m_startFocus = value;
            setHandleAttribute(IupAttributes.StartFocus, value);
        }

        private iup.core.IupElement m_startFocus;
    }

    /**
    */
    @property
    {
        public DialogResult dialogResult()
        {
            return m_dialogResult;
        }

        protected void dialogResult(DialogResult value)
        {
            m_dialogResult = value;
        }

        private DialogResult m_dialogResult;
    }

    /**
    Text to be shown when the mouse lies over the element.
    */
    @property
    {
        public IupTray tray()
        {
            return m_tray;
        }

        protected void tray(IupTray value)
        {
            m_tray = value;
        }

        private IupTray m_tray;
    }

    /**
    Changes how the dialog will be shown. Values: "FULL", "MAXIMIZED", "MINIMIZED" and "NORMAL". 
    Default: NORMAL. After IupShow/IupPopup the attribute is set back to "NORMAL". FULL is similar 
    to FULLSCREEN but only the dialog client area covers the screen area, menu and decorations 
    will be there but out of the screen. In UNIX there is a chance that the placement won't work 
    correctly, that depends on the Window Manager. In Windows, the SHOWNOACTIVE attribute can be
    set to Yes to avoid to make the window active (since 3.15). In Windows, the SHOWMINIMIZENEXT
    attribute can be set to Yes to activate the next top-level window in the Z order when 
    minimizing (since 3.15).
    */
    @property
    {
        public WindowState windowState()
        {
            string v = getAttribute(IupAttributes.Placement);
            return WindowStateIdentifiers.convert(v);
        }

        public void windowState(WindowState value)
        {
            setAttribute(IupAttributes.Placement, WindowStateIdentifiers.convert(value));
        }
    }

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
    int popup(int x, int y)
    {
        checkValid();
        return iup.c.IupPopup(handle, x, y);
    }

    /**
    Displays a dialog in a given position on the screen.
    */
    int showXY(int x, int y)
    {
        checkValid();
        return iup.c.IupShowXY(handle, x, y);
    }

    /// ditto
    //int show() {  return showXY(horizontalPostion, verticalPostion); }

    /**
    For dialogs it is equivalent to call IupShowXY using IUP_CURRENT. See IupShowXY for more details. 

    For other controls, to call IupShow is the same as setting VISIBLE=YES.
    */
    int show()
    {
        checkValid();
        return iup.c.IupShow(handle);
    }

    private void checkValid()
    {
        if (!isValid)
            throw new Exception("This dialog has been destroyed!");
    }

    /**
    Shows a dialog or menu and restricts user interaction only to the specified element. 
    It is equivalent of creating a Modal dialog is some toolkits.
    */
    DialogResult showDialog()
    {
        iup.c.IupPopup(handle, ScreenPostionH.CenterParent, ScreenPostionV.CenterParent);
        return dialogResult;
    }

    DialogResult showDialog(iup.dialog.IupDialog parent)
    {
        this.parent = parent;
        return showDialog();
    }

    /// ditto
    DialogResult showDialog(int x, int y)
    {
        iup.c.IupPopup(handle, x, y);
        return dialogResult;
    }

    /// ditto
    DialogResult showDialog(ScreenPostionH x, ScreenPostionV y)
    {
        iup.c.IupPopup(handle, x, y);
        return dialogResult;
    }

    /**
    Hides an interface element. This function has the same effect as attributing value "NO" to 
    the interface element’s VISIBLE attribute.
    Once a dialog is hidden, either by means of IupHide or by changing the VISIBLE attribute or 
    by means of a click in the window close button, the elements inside this dialog are not destroyed, 
    so that you can show the dialog again. To destroy dialogs, the IupDestroy function must be called.
    */
    int hide()
    {
        return iup.c.IupHide(handle);
    }

    /**
    */
    void close(DialogResult r = DialogResult.None)
    {
        dialogResult = r;
        if (r == DialogResult.OK)
            hide();
        else
            dispose();
    }

    version (Windows)
    {
        /**
        Name of a MDI child window to be activated. If value is "NEXT" will activate the next window 
        after the current active window. If value is "PREVIOUS" will activate the previous one. 
        */
        void activateNextMdi()
        {
            setAttribute(IupAttributes.MdiActivate, "NEXT");
        }

        /// ditto
        void activatePreviousMdi()
        {
            setAttribute(IupAttributes.MdiActivate, "PREVIOUS");
        }

        void addMdiChild(IupDialog mdi)
        {
            mdi.parent = this;
            //mdi.mdiChildActivated += &mdi_childActivated;
            //mdi.closed +=  // todo: remove the child
            m_mdiChildren.append(mdi);
        }

        //private void mdi_childActivated(Object sender, CallbackEventArgs e)
        //{
        //    m_activeMdiChild = cast(IupDialog)sender;
        //}

        void removeMdiChild(IupDialog mdi)
        {
            m_mdiChildren.remove(mdi);
            //if(mdi == m_activeMdiChild)
            //    m_activeMdiChild = null;
        }

        /**
        */
        @property
        {
            IupDialog[] mdiChildren()
            {
                size_t len = m_mdiChildren.count;
                if (len == 0)
                    return new IupDialog[0];
                else
                {
                    auto items = new IupDialog[len];
                    for (size_t i = 0; i < len; i++)
                        items[i] = m_mdiChildren[i];
                    return items;
                }
            }
        }

        /**
        Returns the name of the current active MDI child. Use IupGetAttributeHandle to directly retrieve the child handle.
        */
        @property
        {
            public IupDialog activeMdiChild()
            {
                //Ihandle* m_handle = cast(Ihandle*) getPointerAttribute(IupAttributes.MdiActive);
                Ihandle* m_handle = getHandleAttribute(IupAttributes.MdiActive);
                for (int i = 0; i < m_mdiChildren.count; i++)
                {
                    if (m_mdiChildren[i].handle == m_handle)
                        return m_mdiChildren[i];
                }
                return null;
            }
            //public IupDialog activeMdiChild() { return m_activeMdiChild; }
            //protected void activeMdiChild(IupDialog value) { m_activeMdiChild = value; }
            //private IupDialog m_activeMdiChild; 
        }

        /**
        Action to close and destroy all MDI child windows. The CLOSE_CB callback will be called for each child. 
        */
        void closeAllMdi()
        {
            clearAttribute(IupAttributes.MdiCloseAll);
            m_mdiChildren.clear();
            //m_activeMdiChild = null;
        }

        /**
        Action to arrange MDI child windows. Possible values: TILEHORIZONTAL, TILEVERTICAL, 
        CASCADE and ICON (arrange the minimized icons).
        */
        void layoutMdi(MdiLayout value)
        {
            final switch (value)
            {
            case MdiLayout.ArrangeIcons:
                setAttribute(IupAttributes.MdiArrange, "ICON");
                break;

            case MdiLayout.Cascade:
                setAttribute(IupAttributes.MdiArrange, "CASCADE");
                break;

            case MdiLayout.TileHorizontal:
                setAttribute(IupAttributes.MdiArrange, "TILEHORIZONTAL");
                break;

            case MdiLayout.TileVertical:
                setAttribute(IupAttributes.MdiArrange, "TILEVERTICAL");
                break;
            }
        }
    }

    /* ************* Static methods *************** */
    static string iupToString(WindowSizeMode m)
    {
        string sizeUid;
        switch (m)
        {
        case WindowSizeMode.Full:
            sizeUid = DialogSizeIdentifiers.Full;
            break;

        case WindowSizeMode.Half:
            sizeUid = DialogSizeIdentifiers.Half;
            break;

        case WindowSizeMode.Third:
            sizeUid = DialogSizeIdentifiers.Third;
            break;

        case WindowSizeMode.Quarter:
            sizeUid = DialogSizeIdentifiers.Quarter;
            break;

        case WindowSizeMode.Eighth:
            sizeUid = DialogSizeIdentifiers.Eighth;
            break;

        default:
            assert(0, "Not supported: ");
        }

        string r = sizeUid ~ "x" ~ sizeUid ~ "\0";
        return r;
    }
}

//
// Summary:
//     Specifies the layout of multiple document interface (MDI) child windows in an
//     MDI parent window.
public enum MdiLayout
{
    //
    // Summary:
    //     All MDI child windows are cascaded within the client region of the MDI parent
    //     form.
    Cascade = 0,
    //
    // Summary:
    //     All MDI child windows are tiled horizontally within the client region of the
    //     MDI parent form.
    TileHorizontal = 1,
    //
    // Summary:
    //     All MDI child windows are tiled vertically within the client region of the MDI
    //     parent form.
    TileVertical = 2,
    //
    // Summary:
    //     All MDI child icons are arranged within the client region of the MDI parent form.
    ArrangeIcons = 3
}

/**
*/
public class IupTray : IupAuxiliaryObject
{
    protected class IupAttributes : super.IupAttributes
    {
        enum Tray = "TRAY";
        enum TipBalloon = "TRAYTIPBALLOON";
        enum TipBalloonDelay = "TRAYTIPBALLOONDELAY";
        enum TipBalloonTitle = "TRAYTIPBALLOONTITLE";
        enum TipBalloonTitleIcon = "TRAYTIPBALLOONTITLEICON";
        enum Image = "TRAYIMAGE";
        enum TipText = "TRAYTIP";
        enum Markup = "TRAYTIPMARKUP";
    }

    this(IupDialog dialog)
    {
        super(dialog);
    }

    /* ************* Properties *************** */

    /**
    When set to "YES", displays an icon on the system tray. (GTK 2.10)
    */
    @property
    {
        public bool enabled()
        {
            return getAttribute(IupAttributes.Tray) == FlagIdentifiers.Yes;
        }

        public void enabled(bool value)
        {
            setAttribute(IupAttributes.Tray, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Name of a IUP image to be used as the tray icon. The Windows SDK recommends that cursors 
    and icons should be implemented as resources rather than created at run time. (GTK 2.10)
    */
    @property
    {
        public string image()
        {
            return getAttribute(IupAttributes.Image);
        }

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
    Text to be shown when the mouse lies over the element.
    */
    @property
    {
        public string tipText()
        {
            return m_tipText;
        }

        public void tipText(string value)
        {
            m_tipText = value;
            setAttribute(IupAttributes.TipText, value);
        }

        private string m_tipText;
    }

    version (Windows)
    {
        /**
        Time the tip will remain visible. Default: "5000". In Windows the maximum value 
        is 32767 milliseconds.
        */
        @property
        {
            public int tipBalloonDelay()
            {
                return getIntAttribute(IupAttributes.TipBalloonDelay);
            }

            public void tipBalloonDelay(int value)
            {
                setIntAttribute(IupAttributes.TipBalloonDelay, value);
            }
        }

        /**
        The tip window will have the appearance of a cartoon "balloon" with rounded corners and 
        a stem pointing to the item. Default: NO. Must be set before setting the TRAYTIP attribute. (since 3.6)
        */
        @property
        {
            public bool hasTipBalloon()
            {
                return getAttribute(IupAttributes.TipBalloon) == FlagIdentifiers.Yes;
            }

            public void hasTipBalloon(bool value)
            {
                setAttribute(IupAttributes.TipBalloon, value
                        ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
        When using the balloon format, the tip can also has a pre-defined icon in the title area. 
        Must be set before setting the TRAYTIP attribute. (since 3.6) 
        */
        @property
        {
            public BalloonIco tipBalloonIco()
            {
                int code = getIntAttribute(IupAttributes.TipBalloonTitleIcon);
                return cast(BalloonIco) code;
            }

            public void tipBalloonIco(BalloonIco value)
            {
                setIntAttribute(IupAttributes.TipBalloonTitleIcon, cast(int) value);
            }
        }

        /**
        Text to be shown when the mouse lies over the element.
        */
        @property
        {
            public string tipBalloonTitle()
            {
                return m_balloonTitle;
            }

            public void tipBalloonTitle(string value)
            {
                m_balloonTitle = value;
                setAttribute(IupAttributes.TipBalloonTitle, value);
            }

            private string m_balloonTitle;
        }
    }
    else
    {
        @property
        {
            public bool allowMarkup()
            {
                return getAttribute(IupAttributes.Markup) == FlagIdentifiers.Yes;
            }

            public void allowMarkup(bool value)
            {
                setAttribute(IupAttributes.Markup, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

}

/**
*/
public class IupDialogBase : IupControl
{
    protected class IupAttributes : super.IupAttributes
    {
        enum ParentDialog = "PARENTDIALOG";
        enum Value = "VALUE";
    }

    //
    ScreenPostionH horizontalPostion;
    ScreenPostionV verticalPostion;

    this()
    {
        super();
    }

    this(string title)
    {
        super(title);
    }

    ~this()
    {
        dispose(); // safely
    }

    override protected void onCreated()
    {
        super.onCreated();

        horizontalPostion = ScreenPostionH.CenterParent;
        verticalPostion = ScreenPostionV.CenterParent;
    }

    //protected int statusCode;
    protected int popup(int x, int y)
    {
        return iup.c.IupPopup(handle, x, y);
    }

    protected abstract DialogResult checkStatus(int status);

    /* ************* Properties *************** */

    /**
    */
    @property
    {
        public iup.dialog.IupDialog parent()
        {
            return m_parent;
        }

        public void parent(iup.dialog.IupDialog value)
        {
            m_parent = value;
            setHandleAttribute(IupAttributes.ParentDialog, value);
        }

        private iup.dialog.IupDialog m_parent;
    }

    /* ************* Public methods *************** */

    DialogResult showDialog()
    {
        popup(horizontalPostion, verticalPostion);
        int statusCode = getIntAttribute(statusAttribute);

        return checkStatus(statusCode);
    }

    protected string statusAttribute;

    DialogResult showDialog(iup.dialog.IupDialog parent)
    {
        this.parent = parent;
        //Application.parent = parent;
        //int statusCode = getIntAttribute(statusAttribute);

        return showDialog();
    }

    void close()
    {
        dispose();
    }
}

/**
Creates the Color Dialog element. It is a predefined dialog for selecting a color. 
The dialog can be shown with the IupPopup function only.
The dialog is mapped only inside IupPopup, IupMap does nothing.
In Windows, the dialog will be modal relative only to its parent or to the active dialog.
*/
public class IupColorDialog : IupDialogBase
{

    protected class IupCallbacks
    {
        enum ColorUpdate = "COLORUPDATE_CB";
    }

    protected class IupAttributes : super.IupAttributes
    {
        enum Alpha = "ALPHA";
        enum Color = "COLOR";
        enum ColorTable = "COLORTABLE";
        enum ShowAlpha = "SHOWALPHA";
        enum ShowColorTable = "SHOWCOLORTABLE";
        enum ShowHex = "SHOWHEX";
        enum ShowHelp = "SHOWHELP";
        enum ValueHsi = "VALUEHSI";
        enum ValueHex = "VALUEHEX";
        enum PreviewText = "PREVIEWTEXT";
        enum Status = "STATUS";
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

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupColorDlg();
    }

    override protected void onCreated()
    {
        super.onCreated();
        statusAttribute = IupAttributes.Status;
        registerColorUpdatedCallback(IupCallbacks.ColorUpdate);
    }

    protected override DialogResult checkStatus(int status)
    {
        if (status == 1)
            return DialogResult.OK;
        else
            return DialogResult.Cancel;
    }

    /* ************* Events *************** */

    /**
    Action generated when the color is updated in the dialog. It is also called when the color is 
    updated programmatically. (since 3.11)
    */
    mixin EventCallback!(IupColorDialog, "colorUpdated");

    /* ************* Properties *************** */

    /**
    if defined it will enable an alpha selection additional controls with its initial value.
    If the user pressed the Ok button contains the returned value. Default: no defined, 
    or 255 if SHOWALPHA=YES.
    */
    @property
    {
        public int alpha()
        {
            return getIntAttribute(IupAttributes.Alpha);
        }

        public void alpha(int value)
        {
            setIntAttribute(IupAttributes.Alpha, value);
        }
    }

    /**
    if enabled will display the alpha selection controls, regardless if ALPHA is defined for 
    the initial value or not. 
    */
    @property
    {
        public bool canShowAlpha()
        {
            return getAttribute(IupAttributes.ShowAlpha) == FlagIdentifiers.Yes;
        }

        public void canShowAlpha(bool value)
        {
            setAttribute(IupAttributes.ShowAlpha, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    if enabled will display the color table, regardless if COLORTABLE is defined or not. 
    The default colors in the color table are different in GTK and in the ColorBrowser 
    based dialog. In Windows the default colors are all black.
    */
    @property
    {
        public bool canShowColorTable()
        {
            return getAttribute(IupAttributes.ShowColorTable) == FlagIdentifiers.Yes;
        }

        public void canShowColorTable(bool value)
        {
            setAttribute(IupAttributes.ShowColorTable, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    if enabled will display the Hexadecimal notation of the color.
    */
    @property
    {
        public bool canShowHex()
        {
            return getAttribute(IupAttributes.ShowHex) == FlagIdentifiers.Yes;
        }

        public void canShowHex(bool value)
        {
            setAttribute(IupAttributes.ShowHex, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    if enabled will display the Help button. In GTK and Windows, the Help button is shown only 
    if the HELP_CB callback is defined.
    */
    @property
    {
        public bool canShowHelp()
        {
            return getAttribute(IupAttributes.ShowHelp) == FlagIdentifiers.Yes;
        }

        public void canShowHelp(bool value)
        {
            setAttribute(IupAttributes.ShowHelp, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    The color value in RGB coordinates and optionally alpha. It is used as the initial value 
    and contains the selected value if the user pressed the Ok button. Format: "R G B" or 
    "R G B A". Each component range from 0 to 255.
    */
    @property
    {
        public Color color()
        {
            string c = getAttribute(IupAttributes.Value);
            return Color.parse(c);
        }

        public void color(Color value)
        {
            string c = std.format.format("%d %d %d %d", value.R, value.G, value.B, value.A);
            setAttribute(IupAttributes.Value, c);
        }
    }

    /**
    list of colors separated by ";". In GTK and in the ColorBrowser based accepts 20 values and 
    if not present the palette will not be visible. In Windows accepts 16 values and will be 
    always visible, even if the colors are not defined (in this case are initialized with black). 
    If a color is not specified then the default color is used. You can skip colors using ";;".
    */
    @property
    {
        public string colorTable()
        {
            return getAttribute(IupAttributes.ColorTable);
        }

        public void colorTable(string value)
        {
            setAttribute(IupAttributes.ColorTable, value);
        }
    }

    /**
    The color value in HSI coordinates. It is used as the initial value and contains the selected
    value if the user pressed the Ok button. Format: "H S I". Each component range from 0-359, 
    0-100 and 0-100 respectively.
    */
    @property
    {
        public string hsiValue()
        {
            return getAttribute(IupAttributes.ValueHsi);
        }

        public void hsiValue(string value)
        {
            setAttribute(IupAttributes.ValueHsi, value);
        }
    }

    /**
    The color value in RGB Hexadecimal notation. It is used as the initial value and contains the
    selected value if the user pressed the Ok button. Format: "#RRGGBB". Each component range 
    from 0-255, but in hexadecimal notation.
    */
    @property
    {
        public string hexValue()
        {
            return getAttribute(IupAttributes.ValueHex);
        }

        public void hexValue(string value)
        {
            setAttribute(IupAttributes.ValueHex, value);
        }
    }

    /**
    The color value in RGB coordinates and optionally alpha. It is used as the initial value and 
    contains the selected value if the user pressed the Ok button. Format: "R G B" or "R G B A". 
    Each component range from 0 to 255.
    */
    @property
    {
        public string rgbValue()
        {
            return getAttribute(IupAttributes.Value);
        }

        public void rgbValue(string value)
        {
            setAttribute(IupAttributes.Value, value);
        }
    }

    /**
    Shows a modal dialog which allows the user to select a color. Based on IupColorDlg.

    x, y: x, y values of the IupPopup function.
    */
    static DialogResult getColor(ScreenPostionH x, ScreenPostionV y, ref Color color)
    {
        ubyte r = color.R, g = color.G, b = color.B;
        int result = IupGetColor(x, y, &r, &g, &b);

        if (result == 0)
            return DialogResult.Cancel;

        color = Color.fromRgb(r, g, b);

        return DialogResult.OK;
    }

    /// ditto
    static DialogResult getColor(ref Color color)
    {
        return getColor(ScreenPostionH.CenterParent, ScreenPostionV.CenterParent, color);
    }
}

alias IupColorDlg = IupColorDialog;

/**
Creates an Element Properties Dialog. It is a predefined dialog to edit the properties of an 
element in run time. It is a standard IupDialog constructed with other IUP elements. The dialog 
can be shown with any of the show functions IupShow, IupShowXY or IupPopup.

Any existent element can be edited. It does not need to be mapped on the native system nor 
visible. It could have been created in C, LED or Lua.

This is a dialog intended for developers, so they can see and inspect their elements in other ways.

It contains 3 Tab sections: one for the registered attributes of the element, one for custom 
attributes set at the hash table, and one for the callbacks. The callbacks are just for inspection,
and custom attribute should be handled carefully because they may be not strings. Registered 
attributes values are shown in red when they were changed by the application. 
*/
public class IupElementPropertiesDialog : IupDialog
{
    private IupObject element;

    this(IupObject element)
    {
        this.element = element;
        super();
    }

    /* ************* Protected methods *************** */

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupElementPropertiesDialog(element.handle);
    }
}

/**
Creates the File Dialog element. It is a predefined dialog for selecting files or a directory. 
The dialog can be shown with the IupPopup function only.

set Utf8ModeFile to false;
*/
public class IupFileDialog : IupDialogBase
{

    protected class IupCallbacks : super.IupCallbacks
    {
        enum File = "FILE_CB";
    }

    protected class IupAttributes : super.IupAttributes
    {
        enum AllowNew = "ALLOWNEW";
        enum DialogType = "DIALOGTYPE";
        enum Directory = "DIRECTORY";
        enum ExtFilter = "EXTFILTER";
        enum ExtDefault = "EXTDEFAULT";
        enum File = "FILE";
        enum FileExist = "FILEEXIST";
        enum Filter = "FILTER";
        enum FilterInfo = "FILTERINFO";
        enum FilteRused = "FILTERUSED";
        enum MultipleFiles = "MULTIPLEFILES";
        enum MultiValueCount = "MULTIVALUECOUNT";
        enum MultiValue = "MULTIVALUE";
        enum MultiValuePath = "MULTIVALUEPATH";
        enum NoChangeDir = "NOCHANGEDIR";
        enum NoOverwritePrompt = "NOOVERWRITEPROMPT";
        enum PreviewAtRight = "PREVIEWATRIGHT";
        enum PreviewGlCanvas = "PREVIEWGLCANVAS";
        enum PreviewDc = "PREVIEWDC";
        enum PreviewWidth = "PREVIEWWIDTH";
        enum PreviewHeight = "PREVIEWHEIGHT";
        enum HWND = "HWND";
        enum XWindow = "XWINDOW";
        enum ShowHidden = "SHOWHIDDEN";
        enum ShowPreview = "SHOWPREVIEW";
        enum Status = "STATUS";
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

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupFileDlg();
    }

    override protected void onCreated()
    {
        super.onCreated();
        statusAttribute = IupAttributes.Status;

        registerFileSelectedCallback(IupCallbacks.File);
    }

    /**
    Indicates the status of the selection made:
    "1": New file.
    "0": Normal, existing file or directory.
    "-1": Operation cancelled.
    */
    protected override DialogResult checkStatus(int status)
    {
        if (status == -1)
            return DialogResult.Cancel;
        else
            return DialogResult.OK;
    }

    /* ************* Events *************** */

    /**
    Action generated when a file is selected. Not called when DIALOGTYPE=DIR. When MULTIPLEFILES=YES 
    it is called only for one file. Can be used with SHOWPREVIEW=NO also. (Windows only in 2.x)

    file_name: name of the file selected.
    status: describes the action. Can be:

    "INIT" - when the dialog has started. file_name is NULL. 
    "FINISH" - when the dialog is closed. file_name is NULL. 
    "SELECT" - a file has been selected. 
    "OTHER" - an invalid file or a directory is selected. file_name is the one selected. (Since 3.0) 

    "OK" - the user pressed the OK button. If returns IUP_IGNORE, the action is refused and the dialog 
    is not closed, if returns IUP_CONTINUE does the same, but if the FILE attribute is defined the 
    current filename is updated (since 3.8). 

    "PAINT" - the preview area must be redrawn.
    Used only when SHOWPREVIEW=YES. If an invalid file or a directory is selected, file_name is NULL. 
    "FILTER" - when a filter is changed. (Windows Only) (since 3.6)
    FILTERUSED attribute will be updated to reflect the change. If returns IUP_CONTINUE, the FILE 
    attribute if defined will update the current filename. 
    */
    public EventHandler!(CallbackEventArgs, string, string) fileSelected;
    mixin EventCallbackAdapter!(IupFileDialog, "fileSelected", const(char)*, const(char)*);
    private IupElementAction onFileSelected(const(char)* filename, const(char)* status) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string f = cast(string) std.string.fromStringz(filename);
            string s = cast(string) std.string.fromStringz(status);
            fileSelected(this, callbackArgs, f, s);
            r = callbackArgs.result;
        }
        catch (Exception ex)
        { /* do nothing. */ }
        return r;
    }

    /* ************* Properties *************** */

    /**
    Indicates if non-existent file names are accepted. If equals "NO" and the user specifies a
    non-existing file, an alert dialog is shown. Default: if the dialog is of type "OPEN", 
    default is "NO"; if the dialog is of type "SAVE", default is "YES". Not used when DIALOGTYPE=DIR.
    */
    @property
    {
        public bool allowNew()
        {
            return getAttribute(IupAttributes.AllowNew) == FlagIdentifiers.Yes;
        }

        public void allowNew(bool value)
        {
            setAttribute(IupAttributes.AllowNew, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Allows the user to select multiple files when DIALOGTYPE=OPEN. Can be "Yes" or "No". Default "No".
    */
    @property
    {
        public bool canMultiSelect()
        {
            return getAttribute(IupAttributes.MultipleFiles) == FlagIdentifiers.Yes;
        }

        public void canMultiSelect(bool value)
        {
            setAttribute(IupAttributes.MultipleFiles, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Show hidden files. Default: NO. (since 3.0) (GTK 2.6)
    */
    @property
    {
        public bool canShowHidden()
        {
            return getAttribute(IupAttributes.ShowHidden) == FlagIdentifiers.Yes;
        }

        public void canShowHidden(bool value)
        {
            setAttribute(IupAttributes.ShowHidden, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    A preview area is shown inside the file dialog. Can have values "YES" or "NO". Default: "NO". 
    In Windows, you must link with the "iup.rc" resource file so the preview area can be enabled
    (not necessary if using "iup.dll"). Valid only if the FILE_CB callback is defined, use it to 
    retrieve the file name and the necessary attributes to paint the preview area. (in Motif 
    since 3.0)
    */
    @property
    {
        public bool canShowPreview()
        {
            return getAttribute(IupAttributes.ShowPreview) == FlagIdentifiers.Yes;
        }

        public void canShowPreview(bool value)
        {
            setAttribute(IupAttributes.ShowPreview, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Type of dialog (Open, Save or Directory). Can have values "OPEN", "SAVE" or "DIR". Default: "OPEN". 
    */
    @property
    {
        public FileDialogType dialogType()
        {
            return m_dialogType;
        }

        public void dialogType(FileDialogType value)
        {
            m_dialogType = value;
            setAttribute(IupAttributes.DialogType, toIupIdentifier(value));
        }

        private FileDialogType m_dialogType;
    }

    /**
    default extension to be used if selected file does not have an extension. The inspected 
    extension will consider to have the same number of characters of the default extension. 
    It must NOT include the period ".". (since 3.18)
    */
    @property
    {
        public string defaultExt()
        {
            return getAttribute(IupAttributes.ExtDefault);
        }

        public void defaultExt(string value)
        {
            setAttribute(IupAttributes.ExtDefault, value);
        }
    }

    /**
    Defines several file filters. It has priority over FILTERINFO and FILTER. Must be a text with the 
    format "FilterInfo1|Filter1|FilterInfo2|Filter2|...". The list ends with character '|'. 
    Example: "Text files|*.txt;*.doc|Image files|*.gif;*.jpg;*.bmp|". 
    In GTK there is no way how to overwrite the filters, so it is recommended to always add a less restrictive 
    filter to the filter list, for example "All Files|*.*".
    */
    @property
    {
        public string extFilter()
        {
            return getAttribute(IupAttributes.ExtFilter);
        }

        public void extFilter(string value)
        {
            setAttribute(IupAttributes.ExtFilter, value);
        }
    }

    /**
    Initial directory. When consulted after the dialog is closed and the user pressed the OK button, 
    it will contain the directory of the selected file. When set the last separator does not need to be specified, 
    but when get the returned value will always contains the last separator.

    In Motif or GTK, if not defined, the dialog opens in the current directory. 

    In Windows, if not defined and the application has used the dialog in the past, the path most recently used is selected 
    as the initial directory. However, if an application is not run for a long time, its saved selected path is discarded. 
    Also if not defined and the current directory contains any files of the specified filter types, the initial directory is 
    the current directory. Otherwise, the initial directory is the "My Documents" directory of the current user. Otherwise, 
    the initial directory is the Desktop folder.
    */
    @property
    {
        public string initialDirectory()
        {
            return getAttribute(IupAttributes.Directory);
        }

        public void initialDirectory(string value)
        {
            setAttribute(IupAttributes.Directory, value);
        }
    }

    /**
    Name of the file initially shown in the "File Name" field in the dialog. If contains a full 
    path, then it is used as the initial directory and DIRECTORY is ignored.
    */
    @property
    {
        public string initialFile()
        {
            return getAttribute(IupAttributes.File);
        }

        public void initialFile(string value)
        {
            setAttribute(IupAttributes.File, value);
        }
    }

    /**
    Indicates if the file defined by the FILE attribute exists or not. It is only valid if the user 
    has pressed OK in the dialog. Not set when DIALOGTYPE=DIR or MULTIPLEFILES=YES.
    */
    @property
    {
        public bool isFileExisted()
        {
            return getAttribute(IupAttributes.FileExist) == FlagIdentifiers.Yes;
        }
    }

    @property
    {
        public bool isPreviewAtRight()
        {
            return getAttribute(IupAttributes.PreviewAtRight) == FlagIdentifiers.Yes;
        }

        public void isPreviewAtRight(bool value)
        {
            setAttribute(IupAttributes.PreviewAtRight, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Name of the selected file(s), or NULL if no file was selected. If FILE is not defined this
    is used as the initial value. When MULTIPLEFILES=Yes it contains the path (but NOT the same
    value returned in DIRECTORY, it does not contains the last separator) and several file 
    names separated by the '|' character. The file list ends with character '|'. BUT when the 
    user selects just one file, the directory and the file are not separated by '|'. For example:

    "/tecgraf/iup/test|a.txt|b.txt|c.txt|" (MULTIPLEFILES=Yes and more than one file is selected)
    "/tecgraf/iup/test/a.txt" (only one file is selected)
    */
    @property
    {
        public string fileName()
        {
            return getAttribute(IupAttributes.Value);
        }

        public void fileName(string value)
        {
            setAttribute(IupAttributes.Value, value);
        }
    }

    /**
    String containing a list of file filters separated by ';' without spaces. Example: "*.C;*.LED;test.*".
    In Motif only the first filter is used. 
    */
    @property
    {
        public string filter()
        {
            return getAttribute(IupAttributes.Filter);
        }

        public void filter(string value)
        {
            setAttribute(IupAttributes.Filter, value);
        }
    }

    /**
    Filter's description. If not defined the filter itself will be used as its description.
    */
    @property
    {
        public string filterInfo()
        {
            return getAttribute(IupAttributes.FilterInfo);
        }

        public void filterInfo(string value)
        {
            setAttribute(IupAttributes.FilterInfo, value);
        }
    }

    /**
    If the attribute PREVIEWGLCANVAS is defined then it is used as the name of an existent 
    IupGLCanvas control to be mapped internally to the preview canvas. Notice that this is 
    not a fully implemented IupGLCanvas that inherits from IupCanvas. This does the minimum 
    necessary so you can use IupGLCanvas auxiliary functions for the preview canvas and call
    OpenGL functions. No IupCanvas attributes or callbacks are available. (since 3.0)
    */
    @property
    {
        public iup.IupGLCanvas gLCanvas()
        {
            return m_gLCanvas;
        }

        public void gLCanvas(iup.IupGLCanvas value)
        {
            m_gLCanvas = value;
            setHandleAttribute(IupAttributes.PreviewGlCanvas, value);
        }

        private iup.IupGLCanvas m_gLCanvas;
    }

    /**
    Indicates if the current working directory must be restored after the user navigation. 
    Default: "NO".
    */
    @property
    {
        public bool restoreDirectory()
        {
            return getAttribute(IupAttributes.NoChangeDir) == FlagIdentifiers.No;
        }

        public void restoreDirectory(bool value)
        {
            setAttribute(IupAttributes.NoChangeDir, value
                    ? FlagIdentifiers.No : FlagIdentifiers.Yes);
        }
    }

    /**
     prompt to overwrite an existent file when in "SAVE" dialog. Default is "Yes", i.e. prompt before overwrite.  
    */
    @property
    {
        public bool overwritePrompt()
        {
            return getAttribute(IupAttributes.NoOverwritePrompt) == FlagIdentifiers.No;
        }

        public void overwritePrompt(bool value)
        {
            setAttribute(IupAttributes.NoOverwritePrompt, value
                    ? FlagIdentifiers.No : FlagIdentifiers.Yes);
        }
    }

    /**
    */
    @property
    {
        public int previewHeight()
        {
            return getIntAttribute(IupAttributes.PreviewHeight);
        }

        public void previewHeight(int value)
        {
            setIntAttribute(IupAttributes.PreviewHeight, value);
        }
    }

    /**
    */
    @property
    {
        public int previewWidth()
        {
            return getIntAttribute(IupAttributes.PreviewWidth);
        }

        public void previewWidth(int value)
        {
            setIntAttribute(IupAttributes.PreviewWidth, value);
        }
    }

    @property
    {
        public HDC deviceContext()
        {
            return cast(HDC) getPointerAttribute(IupAttributes.PreviewDc);
        }
    }

    /**
    number of returned values when MULTIPLEFILES=Yes. It always includes the path, so if 
    only 1 file is selected its value is 2. (Since 3.14)
    */
    @property
    {
        public int selectionCount()
        {
            return getIntAttribute(IupAttributes.MultiValueCount);
        }

    }

    /* ************* Public methods *************** */

    /**
    almost the same sequence returned in VALUE when MULTIPLEFILES=Yes but split in several
    attributes. VALUE0 contains the path (same value returned in DIRECTORY), and VALUE1,
    VALUE2,... contains each file name without the path. (Since 3.14)
    */
    public string getSelection(int index)
    {
        return getIdAttributeAsString(IupAttributes.MultiValue, index);
    }

}

alias IupFileDlg = IupFileDialog;

/**
Creates the Font Dialog element. It is a predefined dialog for selecting a font.
The dialog can be shown with the IupPopup function only.
The dialog is mapped only inside IupPopup, IupMap does nothing.
In Windows, the dialog will be modal relative only to its parent or to the active dialog.
*/
public class IupFontDialog : IupDialogBase
{
    protected class IupAttributes : super.IupAttributes
    {
        enum PreviewText = "PREVIEWTEXT";
        enum Color = "COLOR";
        enum Status = "STATUS";
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

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupFontDlg();
    }

    override protected void onCreated()
    {
        super.onCreated();
        statusAttribute = IupAttributes.Status;
    }

    protected override DialogResult checkStatus(int status)
    {
        if (status == 1)
            return DialogResult.OK;
        else
            return DialogResult.Cancel;
    }

    /* ************* Properties *************** */

    version (Windows)
    {
        /**
        The initial color value and the returned selected value if the user pressed the Ok button. In Windows the Choose Font dialog allows the user to select a color from a pre-defined list of colors. Since IUP 3.15 must set SHOWCOLOR=Yes to enable this option.
        */
        @property
        {
            public Color color()
            {
                string c = getAttribute(IupAttributes.Color);
                return Color.parse(c);
            }

            public void color(Color value)
            {
                string c = std.format.format("%d %d %d %d", value.R, value.G, value.B, value.A);
                setAttribute(IupAttributes.Color, c);
            }
        }
    }
    else
    {
        /**
        the text shown in the preview area. If not defined, the system will provide a default text.
        */
        @property
        {
            public string previewText()
            {
                return getAttribute(IupAttributes.PreviewText);
            }

            public void previewText(string value)
            {
                setAttribute(IupAttributes.PreviewText, value);
            }
        }
    }

    /**
    The initial font value and the selected value returned if the user pressed the Ok button. Has the same 
    format as the FONT attribute.
    */
    @property
    {
        public Font selectedFont()
        {
            string f = getAttribute(IupAttributes.Value);
            return Font.parse(f);
        }

        public void selectedFont(Font value)
        {
            setAttribute(IupAttributes.Value, value.toString());
        }
    }

}

alias IupFontDlg = IupFontDialog;

/**
Creates a Layout Dialog. It is a predefined dialog to visually edit the layout of another dialog 
in run time. It is a standard IupDialog constructed with other IUP elements. The dialog can be 
shown with any of the show functions IupShow, IupShowXY or IupPopup.

Any existent dialog can be selected. It does not need to be mapped on the native system nor visible. 
It could have been created in C, LED or Lua.

The layout dialog is composed by two areas: one showing the given dialog children hierarchy tree, 
and one displaying its layout.

This is a dialog intended for developers, so they can see and inspect their dialogs in other ways.
*/
public class IupLayoutDialog : IupDialog
{
    protected class IupAttributes : super.IupAttributes
    {
        enum DestroyWhenClosed = "DESTROYWHENCLOSED";
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
        return iup.c.IupLayoutDialog(null);
    }

    /* ************* Properties *************** */

    /**
    The dialog will be automatically destroyed when closed. Default: Yes.
    */
    @property
    {
        public bool canDestroy()
        {
            return getAttribute(IupAttributes.DestroyWhenClosed) == FlagIdentifiers.Yes;
        }

        public void canDestroy(bool value)
        {
            setAttribute(IupAttributes.DestroyWhenClosed, value
                    ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }
}

/**
Creates the Message Dialog element. It is a predefined dialog for displaying a message. 
The dialog can be shown with the IupPopup function only.

The IupMessageDlg is a native pre-defined dialog not altered by IupSetLanguage.
To show the dialog, use function IupPopup. In Lua, use the popup function.
The dialog is mapped only inside IupPopup, IupMap does nothing.
In Windows the position (x,y) used in IupPopup is ignored and the dialog is always centered on screen.
The IupMessage function simply creates and popup a IupMessageDlg.
In Windows each different dialog type is always associated with a different beep sound.
In Windows, if PARENTDIALOG is specified then it will be modal relative only to its parent.
*/
public class IupMessageDialog : IupDialogBase
{
    protected class IupAttributes : super.IupAttributes
    {
        enum ButtonDefault = "BUTTONDEFAULT";
        enum ButtonResponse = "BUTTONRESPONSE";
        enum Buttons = "BUTTONS";
        enum DialogType = "DIALOGTYPE";
    }

    this()
    {
        m_dialogType = MessageDialogType.Message;
        m_buttons = MessageBoxButtons.OK;
        super();
    }

    this(string title, string message, MessageBoxButtons buttons = MessageBoxButtons.OK,
            MessageDialogType dialogType = MessageDialogType.Message)
    {
        assert(buttons != MessageBoxButtons.AbortRetryIgnore, "Not supported");

        this();
        this.title = title;
        this.message = message;
        this.buttons = buttons;
        this.dialogType = dialogType;
    }

    /* ************* Protected methods *************** */

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupMessageDlg();
    }

    override protected void onCreated()
    {
        super.onCreated();
        statusAttribute = IupAttributes.ButtonResponse;
    }

    /**
    Number of the pressed button. Can be "1", "2" or "3". Default: "1".
    */
    protected override DialogResult checkStatus(int status)
    {
        DialogResult r = DialogResult.OK;

        switch (buttons)
        {
        case MessageBoxButtons.OkCancel:
            if (status == 2)
                r = DialogResult.Cancel;
            break;

        case MessageBoxButtons.RetryCancel:
            if (status == 1)
                r = DialogResult.Retry;
            else
                r = DialogResult.Cancel;
            break;

        case MessageBoxButtons.YesNo:
            if (status == 1)
                r = DialogResult.Yes;
            else
                r = DialogResult.No;
            break;

        case MessageBoxButtons.YesNoCancel:
            if (status == 1)
                r = DialogResult.Yes;
            else if (status == 2)
                r = DialogResult.No;
            else
                r = DialogResult.Cancel;
            break;

        default:
            break;
        }

        return r;
    }

    /* ************* Properties *************** */

    /**
    Buttons configuration. Can have values: "OK", "OKCANCEL", "RETRYCANCEL", "YESNO", or "YESNOCANCEL". Default: "OK". 
    Additionally the "Help" button is displayed if the HELP_CB callback is defined. (RETRYCANCEL and YESNOCANCEL since 3.16)
    */
    @property
    {
        public MessageBoxButtons buttons()
        {
            return m_buttons;
        }

        public void buttons(MessageBoxButtons value)
        {
            m_buttons = value;
            setAttribute(IupAttributes.Buttons, toIupIdentifier(value));
        }

        private MessageBoxButtons m_buttons;
    }

    /**
    Type of dialog defines which icon will be displayed besides the message text. 
    Can have values: "MESSAGE" (No Icon), "ERROR" (Stop-sign), "WARNING" (Exclamation-point),
    "QUESTION" (Question-mark) or "INFORMATION" (Letter "i"). Default: "MESSAGE".
    */
    @property
    {
        public MessageDialogType dialogType()
        {
            return m_dialogType;
        }

        public void dialogType(MessageDialogType value)
        {
            m_dialogType = value;
            setAttribute(IupAttributes.DialogType, toIupIdentifier(value));
        }

        private MessageDialogType m_dialogType;
    }

    /**
    Message text.
    */
    @property
    {
        public string message()
        {
            return m_message;
        }

        public void message(string value)
        {
            m_message = value;
            setAttribute(IupAttributes.Value, value);
        }

        private string m_message;
    }

    /**
    */
    @property
    {
        public DialogResult defaultResult()
        {
            return m_defaultResult;
        }

        public void defaultResult(DialogResult value)
        {
            m_defaultResult = value;

            // Number of the default button. Can be "1", "2" or "3". "2" is valid only for "RETRYCANCEL",
            // "OKCANCEL" and "YESNO" button configurations. "3" is valid only for "YESNOCANCEL". Default: "1".
            int defaultButtonNumber = 1;
            switch (value)
            {
            case DialogResult.Cancel:
                if (buttons == MessageBoxButtons.YesNoCancel)
                    defaultButtonNumber = 3;
                else
                    defaultButtonNumber = 2;
                break;

            case DialogResult.No:
                defaultButtonNumber = 2;
                break;

            default:
                break;
            }

            setIntAttribute(IupAttributes.ButtonDefault, defaultButtonNumber);
        }

        private DialogResult m_defaultResult;
    }

}

alias IupMessageDlg = IupMessageDialog;

//IupMessageDialog dialog = new IupMessageDialog("IupMessageDlg Test",
//                                               "Message Text\nSecond Line");
//
//dialog.parent = this;
//dialog.buttons = MessageBoxButtons.YesNoCancel;
//dialog.dialogType = MessageDialogType.Error;
//auto r = dialog.showDialog();

/**
Shows a modal dialog to edit a multiline text.
The function does not allocate memory space to store the text entered by the user. Therefore,
the text parameter must be large enough to contain the user input. The returned string is 
limited to maxsize characters. 

The dialog uses a global attribute called "PARENTDIALOG" as the parent dialog if it is defined. 
It also uses a global attribute called "ICON" as the dialog icon if it is defined.
*/
public class IupTextInputDialog
{
    private string m_title;
    private char[] textBuffer;

    @property
    {
        void text(string value)
        {
            size_t count = value.length;
            textBuffer[0 .. count] = value[0 .. $];
            textBuffer[count] = '\0';
        }

        string text()
        {
            return to!string(textBuffer.ptr);
        }
    }

    this(string title, size_t maxSize = 1024)
    {
        assert(maxSize > 0 && maxSize < 10240, "out of range");
        this.m_title = title;
        textBuffer = new char[maxSize];
    }

    /* ************* Protected methods *************** */

    DialogResult showDialog()
    {
        int r = iup.c.IupGetText(std.string.toStringz(m_title), textBuffer.ptr, cast(int)textBuffer.length);

        return checkStatus(r);
    }

    DialogResult showDialog(string defaultText)
    {
        assert(textBuffer.length > defaultText.length, "out of range");

        text = defaultText;
        return showDialog();
    }

    protected DialogResult checkStatus(int status)
    {
        if (status != 0)
            return DialogResult.OK;
        else
            return DialogResult.Cancel;
    }

}

/**
Shows a modal dialog for capturing parameter values using several types of controls. 
The dialog uses the IupParam and IupParamBox controls internally.
*/
public class IupInputDialog : IupDialogBase
{
    this()
    {
        super();
    }

    /* ************* Protected methods *************** */

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupMessageDlg();
    }

    //override protected void onCreated()
    //{
    //    super.onCreated();
    //    statusAttribute = IupAttributes.ButtonResponse;
    //}

}

alias IupGetParam = IupInputDialog;

/**
Creates a progress dialog element. It is a predefined dialog for displaying the progress of 
an operation. The dialog is meant to be shown with the show functions IupShow or IupShowXY.

The dialog is not automatically closed, the application must do that manually inside the 
CANCEL_CB callback or inside your processing loop by checking the STATE attribute. 
*/
public class IupProgressDialog : IupDialogBase
{
    protected class IupCallbacks : super.IupCallbacks
    {
        enum Cancel = "CANCEL_CB";
        enum Show = "SHOW_CB";
    }

    protected class IupAttributes : super.IupAttributes
    {
        enum IupProgressDialog = "IupProgressDialog";
        enum Count = "COUNT";
        enum Icon = "ICON";
        enum Inc = "INC";
        enum Percent = "PERCENT";
        enum TotalCount = "TOTALCOUNT";
        enum State = "STATE";
        enum Description = "DESCRIPTION";
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

    override protected Ihandle* createIupObject()
    {
        return iup.c.IupProgressDlg();
    }

    override protected void onCreated()
    {
        super.onCreated();
        registerCancelCallback(IupCallbacks.Cancel);
        registerStateChangedCallback(IupCallbacks.Show);
    }

    protected override DialogResult checkStatus(int status)
    {
        if (status != 0)
            return DialogResult.OK;
        else
            return DialogResult.Cancel;
    }

    /* ************* Events *************** */

    /**
    */
    mixin EventCallback!(IupProgressDialog, "cancel");

    /**
    */
    EventHandler!CallbackEventArgs loaded;

    /**
    Called right after the dialog is showed, hidden, maximized, minimized or 
    restored from minimized/maximized. 
    This callback is called when those actions were performed by the user or 
    programmatically by the application.
    */
    public EventHandler!(CallbackEventArgs, DialogState) stateChanged;
    mixin EventCallbackAdapter!(IupProgressDialog, "stateChanged", int);

    private IupElementAction onStateChanged(int state) nothrow
    {
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            if (state == IUP_SHOW)
            {
                loaded(this, callbackArgs);
            }
            else
            {
                stateChanged(this, callbackArgs, cast(DialogState) state);
                r = callbackArgs.result;
            }
        }
        catch (Exception ex)
        { /* do nothing. */ }

        return r;
    }

    /* ************* Properties *************** */

    /**
    current count of iterations.
    */
    @property
    {
        public int count()
        {
            return getIntAttribute(IupAttributes.Count);
        }

        public void count(int value)
        {
            setIntAttribute(IupAttributes.Count, value);
        }
    }

    /**
    text description to be shown at the dialog.
    */
    @property
    {
        string description()
        {
            return getAttribute(IupAttributes.Description);
        }

        void description(string value)
        {
            setStrAttribute(IupAttributes.Description, value);
        }
    }

    /**
    Dialog’s icon
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
    current percent of iterations.
    */
    @property
    {
        public int percent()
        {
            return getIntAttribute(IupAttributes.Percent);
        }

        public void percent(int value)
        {
            setIntAttribute(IupAttributes.Percent, value);
        }
    }

    /**
    describe the state of the iteration. Can be: IDLE, PROCESSING, UNDEFINED or ABORTED. 
    Default is IDLE. When INC, COUNT or PERCENT are set the state is changed to PROCESSING. 
    If the user pressed the Cancel button the state is changed to ABORTED, but check the 
    CANCEL_CB callback for other options. If the state is set to UNDEFINED by the application 
    the progress bar will display an undefined state animation (same as setting MARQUEE=Yes 
    in IupProgressBar), to resume processing set the state attribute to PROCESSING.
    */
    @property
    {
        public ProgressDialogState state()
        {
            string s = getAttribute(IupAttributes.State);
            return ProgressDialogStateIdentifiers.convert(s);
        }

        public void state(ProgressDialogState value)
        {
            string c = ProgressDialogStateIdentifiers.convert(value);
            setAttribute(IupAttributes.State, c);
        }
    }

    /**
    total number of iterations. 
    */
    @property
    {
        public int totalCount()
        {
            return getIntAttribute(IupAttributes.TotalCount);
        }

        public void totalCount(int value)
        {
            setIntAttribute(IupAttributes.TotalCount, value);
        }
    }

    /* ************* Public methods *************** */

    /**
    Hides an interface element. This function has the same effect as attributing value "NO" to 
    the interface element’s VISIBLE attribute.
    Once a dialog is hidden, either by means of IupHide or by changing the VISIBLE attribute or 
    by means of a click in the window close button, the elements inside this dialog are not destroyed, 
    so that you can show the dialog again. To destroy dialogs, the IupDestroy function must be called.
    */
    int hide()
    {
        return iup.c.IupHide(handle);
    }

    /**
    increment the current count by the given amount. If set to NULL will increment +1.
    */
    public void increment(int value = 1)
    {
        setIntAttribute(IupAttributes.Inc, value);
    }
}

/**
*/
enum ProgressDialogState
{
    Idle,
    Processing,
    Undefined,
    Aborted
}

struct ProgressDialogStateIdentifiers
{
    enum Idle = "IDLE";
    enum Processing = "PROCESSING";
    enum Undefined = "UNDEFINED";
    enum Aborted = "ABORTED";

    static ProgressDialogState convert(string id)
    {
        switch (id)
        {
        case Idle:
            return ProgressDialogState.Idle;

        case Processing:
            return ProgressDialogState.Processing;

        case Undefined:
            return ProgressDialogState.Undefined;

        case Aborted:
            return ProgressDialogState.Aborted;

        default:
            assert(0, "Not supported");
        }
    }

    static string convert(ProgressDialogState d)
    {
        final switch (d)
        {
        case ProgressDialogState.Idle:
            return Idle;

        case ProgressDialogState.Processing:
            return Processing;

        case ProgressDialogState.Undefined:
            return Undefined;

        case ProgressDialogState.Aborted:
            return Aborted;
        }
    }
}

/**
*/
enum WindowSizeMode
{
    Custom,
    Full,
    Half,
    Third,
    Quarter,
    Eighth,
}

enum FileDialogType
{
    Open,
    Save,
    Dir
}

public string toIupIdentifier(FileDialogType t)
{
    switch (t)
    {
    case FileDialogType.Open:
        return "OPEN";

    case FileDialogType.Save:
        return "SAVE";

    case FileDialogType.Dir:
        return "DIR";

    default:
        assert(0, "Not supported");
    }
}

public enum MessageDialogType
{
    Message,
    Error,
    Warning,
    Question,
    Information
}

public string toIupIdentifier(MessageDialogType t)
{
    switch (t)
    {
    case MessageDialogType.Message:
        return "MESSAGE";

    case MessageDialogType.Error:
        return "ERROR";

    case MessageDialogType.Warning:
        return "WARNING";

    case MessageDialogType.Question:
        return "QUESTION";

    case MessageDialogType.Information:
        return "INFORMATION";

    default:
        assert(0, "Not supported");
    }
}

/**
*/
struct DialogSizeIdentifiers
{
    enum Full = "FULL";
    enum Half = "HALF";
    enum Third = "THIRD";
    enum Quarter = "QUARTER";
    enum Eighth = "EIGHTH";
}

//
// Summary:
//     Specifies identifiers to indicate the return value of a dialog box.
enum DialogResult
{
    //
    // Summary:
    //     Nothing is returned from the dialog box. This means that the modal dialog continues
    //     running.
    None = 0,
    //
    // Summary:
    //     The dialog box return value is OK (usually sent from a button labeled OK).
    OK = 1,
    //
    // Summary:
    //     The dialog box return value is Cancel (usually sent from a button labeled Cancel).
    Cancel = 2,
    //
    // Summary:
    //     The dialog box return value is Abort (usually sent from a button labeled Abort).
    Abort = 3,
    //
    // Summary:
    //     The dialog box return value is Retry (usually sent from a button labeled Retry).
    Retry = 4,
    //
    // Summary:
    //     The dialog box return value is Ignore (usually sent from a button labeled Ignore).
    Ignore = 5,
    //
    // Summary:
    //     The dialog box return value is Yes (usually sent from a button labeled Yes).
    Yes = 6,
    //
    // Summary:
    //     The dialog box return value is No (usually sent from a button labeled No).
    No = 7
}

enum DialogState
{
    Show = IUP_SHOW,
    Restore = IUP_RESTORE,
    Minimize = IUP_MINIMIZE,
    Maximize = IUP_MAXIMIZE,
    Hide = IUP_HIDE
};

enum WindowState
{
    Full,
    Maximize,
    Minimize,
    Normal
};

struct WindowStateIdentifiers
{
    enum Full = "FULL";
    enum Maximize = "MAXIMIZED";
    enum Minimize = "MINIMIZED";
    enum Normal = "NORMAL";

    static WindowState convert(string id)
    {
        switch (id)
        {
        case WindowStateIdentifiers.Full:
            return WindowState.Full;

        case WindowStateIdentifiers.Maximize:
            return WindowState.Maximize;

        case WindowStateIdentifiers.Minimize:
            return WindowState.Minimize;

        case WindowStateIdentifiers.Normal:
            return WindowState.Normal;

        default:
            assert(0, "Not supported");
        }
    }

    static string convert(WindowState d)
    {
        switch (d)
        {
        case WindowState.Full:
            return WindowStateIdentifiers.Full;

        case WindowState.Maximize:
            return WindowStateIdentifiers.Maximize;

        case WindowState.Minimize:
            return WindowStateIdentifiers.Minimize;

        case WindowState.Normal:
            return WindowStateIdentifiers.Normal;

        default:
            assert(0, "Not supported");
        }
    }
}

/**
*/
public class IupMessageBox
{

    //
    // Summary:
    //     Displays a message box with specified text.
    //
    public static DialogResult show(string title, string message)
    {
        const(char)* _title;
        const(char)* _message;

        //version(Windows)
        //{
        //    _title = toMBSz(title, 0);
        //    _message = toMBSz(message, 0);
        //}
        //else
        {
            _title = std.string.toStringz(title);
            _message = std.string.toStringz(message);
        }

        iup.c.IupMessage(_title, _message);

        return DialogResult.OK;
    }

    /**
    t: Dialog’s title
    m: Message
    b1: Text of the first button
    b2: Text of the second button (optional)
    b3: Text of the third button (optional)

    Returns: the number of the button selected by the user (1, 2 or 3) , or 0 if failed. It fails only if b1 is not defined.

    The dialog uses a global attribute called "PARENTDIALOG" as the parent dialog if it is defined. 
    It also uses a global attribute called "ICON" as the dialog icon if it is defined.
    */
    static int show(string title, string message, string button1,
            string button2 = null, string button3 = null)
    {
        assert(button1 !is null);

        const(char)* _title = std.string.toStringz(title);
        const(char)* _message = std.string.toStringz(message);
        const(char)* _button1 = std.string.toStringz(button1);
        const(char)* _button2 = button2.empty ? null : std.string.toStringz(button2);
        const(char)* _button3 = button3.empty ? null : std.string.toStringz(button3);

        return iup.c.IupAlarm(_title, _message, _button1, _button2, _button3);
    }

    //
    // Summary:
    //     Displays a message box in front of the specified object and with the specified
    //     text, caption, and buttons.
    //
    //   text:
    //     The text to display in the message box.
    //
    //   caption:
    //     The text to display in the title bar of the message box.
    //
    //   buttons:
    //     One of the System.Windows.Forms.MessageBoxButtons values that specifies which
    //     buttons to display in the message box.
    //
    // Returns:
    //     One of the System.Windows.Forms.DialogResult values.
    static DialogResult show(string title, string message, MessageBoxButtons button)
    {
        const(char)* _title = std.string.toStringz(title);
        const(char)* _message = std.string.toStringz(message);
        int selection = 0;
        DialogResult r = DialogResult.OK;

        switch (button)
        {
        case MessageBoxButtons.OkCancel:
            selection = iup.c.IupAlarm(_title,
                    _message, "Ok", "Cancel", null);

            if (selection == 1)
                r = DialogResult.OK;
            else
                r = DialogResult.Cancel;

            break;

        case MessageBoxButtons.AbortRetryIgnore:
            selection = iup.c.IupAlarm(_title,
                    _message, "Abort", "Retry", "Ignore");
            if (selection == 1)
                r = DialogResult.Abort;
            else if (selection == 2)
                r = DialogResult.Retry;
            else
                r = DialogResult.Ignore;
            break;

        case MessageBoxButtons.YesNoCancel:
            selection = iup.c.IupAlarm(_title,
                    _message, "Yes", "No", "Cancel");

            if (selection == 1)
                r = DialogResult.Yes;
            else if (selection == 2)
                r = DialogResult.No;
            else
                r = DialogResult.Cancel;
            break;

        case MessageBoxButtons.YesNo:
            selection = iup.c.IupAlarm(_title,
                    _message, "Yes", "No", null);

            if (selection == 1)
                r = DialogResult.Yes;
            else
                r = DialogResult.No;
            break;

        case MessageBoxButtons.RetryCancel:
            selection = iup.c.IupAlarm(_title,
                    _message, "Retry", "Cancel", null);

            if (selection == 1)
                r = DialogResult.Retry;
            else
                r = DialogResult.Cancel;
            break;

        default:
            selection = iup.c.IupAlarm(_title, _message, "Ok", null, null);
        }

        return r;
    }
}

//
// Summary:
//     Specifies constants defining which buttons to display on a System.Windows.Forms.MessageBox.
public enum MessageBoxButtons
{
    //
    // Summary:
    //     The message box contains an OK button.
    OK = 0,
    //
    // Summary:
    //     The message box contains OK and Cancel buttons.
    OkCancel = 1,
    //
    // Summary:
    //     The message box contains Abort, Retry, and Ignore buttons.
    AbortRetryIgnore = 2,
    //
    // Summary:
    //     The message box contains Yes, No, and Cancel buttons.
    YesNoCancel = 3,
    //
    // Summary:
    //     The message box contains Yes and No buttons.
    YesNo = 4,
    //
    // Summary:
    //     The message box contains Retry and Cancel buttons.
    RetryCancel = 5
}

public string toIupIdentifier(MessageBoxButtons b)
{
    switch (b)
    {
    case MessageBoxButtons.OK:
        return "OK";

    case MessageBoxButtons.OkCancel:
        return "OKCANCEL";

    case MessageBoxButtons.RetryCancel:
        return "RETRYCANCEL";

    case MessageBoxButtons.YesNo:
        return "YESNO";

    case MessageBoxButtons.YesNoCancel:
        return "YESNOCANCEL";

    default:
        assert(0, "Not supported");
    }
}
