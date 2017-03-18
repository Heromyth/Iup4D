module iup.canvas;

import iup.control;
import iup.core;

import iup.c.core;
import iup.c.api;
import iup.c.opengl;

import std.string;

import toolkit.event;
import toolkit.drawing;

version(Windows)
{
    import core.sys.windows.windef;
	import std.windows.charset;
}


//public class IupCanvasControl : IupStandardControl
//{
//
//    this() { super(); }
//
//    this(string title)
//    {
//        super(title);
//    }
//
//
//    /* ************* Protected methods *************** */
//
//    protected override void onCreated()
//    {    
//        super.onCreated();
//
//        m_scrollBar = new IupScrollBar(this);
//    }  
//
//
//    /**
//    Associates a horizontal and/or vertical scrollbar to the canvas. Default: "NO". The 
//    secondary attributes are all non inheritable.
//    */
//    @property 
//    {
//        IupScrollBar scrollBars() { return m_scrollBar; }
//        protected void scrollBars(IupScrollBar value) { m_scrollBar = value; }
//        private IupScrollBar m_scrollBar; 
//    }
//}

/**
Creates an interface element that is a canvas - a working area for your application.
*/
public class IupCanvasBase : IupStandardControl
{
	class IupAttributes : super.IupAttributes
	{
        enum Border = "BORDER";
        enum DrawColor = "DRAWCOLOR";
        enum DrawStyle = "DRAWSTYLE";
        enum DrawSize = "DRAWSIZE";
        enum DragCursor = "DRAGCURSOR";
        enum DragSource = "DRAGSOURCE";
        enum DragTypes = "DRAGTYPES";
        enum DragSourceMove = "DRAGSOURCEMOVE";
        enum DropTarget = "DROPTARGET";
        enum DropTypes = "DROPTYPES";
        enum HDC_WmPaint = "HDC_WMPAINT";
        enum HWND = "HWND";
        enum MdiClient = "MDICLIENT";
        enum MdiMenu = "MDIMENU";
	}

	this() { super(); }

    this(string title)
    {
        super(title);
    }


    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();

        m_scrollBar = new IupScrollBar(this);
    }  


    /* ************* Properties *************** */

    /**
    The primitives color is controlled by the attribute DRAWCOLOR. Default: "0 0 0".
    */
    @property 
    {
        Color drawColor() { 
            string c = getAttribute(IupAttributes.DrawColor);
            return Color.parse(c); 
        }

        void drawColor(Color value)  { setAttribute(IupAttributes.DrawColor, value.toRgb()); }
    }

    /**
    The size of the drawing area in pixels. This size is also used in the RESIZE_CB callback.
    Notice that the drawing area size is not the same as RASTERSIZE. The SCROLLBAR and BORDER attributes 
    affect the size of the drawing area.
    */
    @property 
	{
		Size drawSize() 
        {
            Size m_drawSize;
            getIntIntAttribute(IupAttributes.DrawSize, m_drawSize.width, m_drawSize.height);
            return m_drawSize; 
        }

		void drawSize(Size value) 
		{
			setAttribute(IupAttributes.DrawSize, value.width, value.height);
		}
	}

    /**
    Can have values: FILL, STROKE, STROKE_DASH or STROKE_DOT. Default: STROKE. The FILL 
    value when set before DrawLine has the same effect as STROKE.
    */
    @property 
    {
        IupDrawStyle drawStyle() { 
            string c = getAttribute(IupAttributes.DrawStyle);
            return IupDrawStyleIdentifiers.convert(c); 
        }

        void drawStyle(IupDrawStyle value)  {
            setAttribute(IupAttributes.DrawStyle, IupDrawStyleIdentifiers.convert(value)); 
        }
    }

    /**
    Shows a border around the canvas. Default: "YES".
    */
    @property 
	{
		bool hasBorder() { return getAttribute(IupAttributes.Border) == FlagIdentifiers.Yes; }

		void hasBorder(bool value) {
            setAttribute(IupAttributes.Border, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
    }

    /**
    */
    @property 
	{
		bool isDropTarget() { return getAttribute(IupAttributes.DropTarget) == FlagIdentifiers.Yes; }

		void isDropTarget(bool value) {
            setAttribute(IupAttributes.DropTarget, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
    }

    /**
    */
    @property 
	{
		DragDropContent dropContent() { 
            string s = getAttribute(IupAttributes.DropTarget);
            return DragDropContentIdentifiers.convert(s); 
        }

		void dropContent(DragDropContent value) {
            string c = DragDropContentIdentifiers.convert(value);
            setAttribute(IupAttributes.DropTarget, c);
		}
    }

    /**
    Associates a horizontal and/or vertical scrollbar to the canvas. Default: "NO". The 
    secondary attributes are all non inheritable.
    */
    @property 
	{
		IupScrollBar scrollBars() { return m_scrollBar; }
		protected void scrollBars(IupScrollBar value) { m_scrollBar = value; }
        private IupScrollBar m_scrollBar; 
	}

    version(Windows)
    {

        /**
        Contains the HDC created with the BeginPaint inside the WM_PAINT message. 
        Valid only during the ACTION callback.
        */
        @property 
        {
            HDC hdcWmPaint() { return cast(HDC)getPointerAttribute(IupAttributes.HDC_WmPaint); }
        }

        /**
        Returns the Windows Window handle. Available in the Windows driver or in the 
        GTK driver in Windows.
        */
        @property 
        {
            HWND hwnd() { return cast(HWND)getPointerAttribute(IupAttributes.HWND); }
        }

        /**
        Configure the canvas as a MDI client. Can be YES or NO. No callbacks will be called. This 
        canvas will be used internally only by the MDI Frame and its MDI Children. The MDI frame
        must have one and only one MDI client. Default: NO.
        */
        @property 
        {
            bool isMdiClient() { return getAttribute(IupAttributes.MdiClient) == FlagIdentifiers.Yes; }

            void isMdiClient(bool value) 
            {
                setAttribute(IupAttributes.MdiClient, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }

        /**
        Name of a IupMenu to be used as the Window list of a MDI frame. The system will automatically
        add the list of MDI child windows there.
        */
        @property 
        {
            iup.menu.IupMenu mdiMenu() { return m_menu; }

            void mdiMenu(iup.menu.IupMenu value) 
            {
                m_menu = value;
                setHandleAttribute(IupAttributes.MdiMenu, value);
            }
            private iup.menu.IupMenu m_menu; 
        }
    }


    /* ************* Public methods *************** */

}


/**
Creates an interface element that is a canvas - a working area for your application.
*/
public class IupCanvas : IupCanvasBase
{
    class IupCallbacks : super.IupCallbacks
    {
		enum Button = "BUTTON_CB";
		enum DragBegin = "DRAGBEGIN_CB";
		enum DragDataSize = "DRAGDATASIZE_CB";
		enum DragData = "DRAGDATA_CB";
		enum DragEnd = "DRAGEND_CB";
		enum DropData = "DROPDATA_CB";
		enum DropMotion = "DROPMOTION_CB";
        enum DropFiles = "DROPFILES_CB";
		enum Focus = "FOCUS_CB";
		enum Motion = "MOTION_CB";
		enum Resize = "RESIZE_CB";
		enum Scroll = "SCROLL_CB";
		enum Wheel = "WHEEL_CB";
    }

	protected class IupAttributes : super.IupAttributes
	{
        enum IupCanvas = "IupCanvas";
	}

	this() { super(); }

    this(string title)
    {
        super(title);
    }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupCanvas(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerDroppedCallback(IupCallbacks.DropData);
        registerFocusChangedCallback(IupCallbacks.Focus);
        registerFileDroppedCallback(IupCallbacks.DropFiles);
        registerMouseClickCallback(IupCallbacks.Button);
        registerMouseMoveCallback(IupCallbacks.Motion);
        //registerPaintCallback(IupCallbacks.Action);
        registerSizeChangedCallback(IupCallbacks.Resize);
        registerScrollCallback(IupCallbacks.Scroll);
        registerWheelCallback(IupCallbacks.Wheel);
        setPaintEvent(true);
    }  


    /* ************* Events *************** */

    mixin EventCallback!(IupCanvas, "focusChanged", bool);


    /**
    source has sent target the requested data. It is called when the data is dropped. If both 
    drag and drop would be in the same application it would be called after the DRAGDATA_CB callback.

    type: type of the data. It is one of the registered types in DROPTYPES.
    data: content data received in the drop operation.  In Lua is a light userdata.
    len: data size in bytes.
    x, y: cursor position relative to the top-left corner of the element.
    */
    EventHandler!(CallbackEventArgs, DragDropContent, void*, int, int, int)  dropped;
    mixin EventCallbackAdapter!(IupCanvas, "dropped", const(char)*, void*, int, int, int, );
    private IupElementAction onDropped(const(char)* type, void* data, int len, int x, int y) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(type);
            DragDropContent contentType = DragDropContentIdentifiers.convert(s);

            dropped(this, callbackArgs, contentType, data, len, x, y);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /**
    Action generated when one or more files are dropped in the element.
    */
    EventHandler!(CallbackEventArgs, string, int, int, int)  fileDropped;
    mixin EventCallbackAdapter!(IupCanvas, "fileDropped", const (char)*, int, int, int);

    private IupElementAction onFileDropped(const (char)* fileName, int num, int x, int y) nothrow
    {
        IupElementAction r = IupElementAction.Default;
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

    button: identifies the activated mouse button.
    pressed: indicates the state of the button.
    x, y: position in the canvas where the event has occurred, in pixels.
    status: status of the mouse buttons and some keyboard keys at the moment the event is generated.
    */
    EventHandler!(CallbackEventArgs, MouseButtons, MouseState, int, int, string)  mouseClick;
    mixin EventCallbackAdapter!(IupCanvas, "mouseClick", int, int, int, int, const(char)*);
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
    */
    EventHandler!(CallbackEventArgs, int, int, string)  mouseMove;
    mixin EventCallbackAdapter!(IupCanvas, "mouseMove", int, int, const(char)*);
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
    Action generated when the canvas needs to be redrawn.

    posx: thumb position in the horizontal scrollbar. The POSX attribute value.
    posy: thumb position in the vertical scrollbar. The POSY attribute value.
    */
    mixin EventCallback!(IupCanvas, "paint", float, float);

    /**
    width: the width of the internal element size in pixels not considering the decorations (client size)
    height: the height of the internal element size in pixels not considering the decorations (client size)
    */
    mixin EventCallback!(IupCanvas, "sizeChanged", int, int);

    /**
    Called when some manipulation is made to the scrollbar. The canvas is automatically 
    redrawn only if this callback is NOT defined.
    */
    mixin EventCallback!(IupCanvas, "scroll", int, float, float);

    /**
    Action generated when the mouse wheel is rotated. If this callback is not defined the 
    wheel will automatically scroll the canvas in the vertical direction by some lines, the
    SCROLL_CB callback if defined will be called with the IUP_SBDRAGV operation.

    delta: the amount the wheel was rotated in notches.
    x, y: position in the canvas where the event has occurred, in pixels.
    status: status of mouse buttons and certain keyboard keys at the moment the event was generated. 
    The same macros used for BUTTON_CB can be used for this status.
    */
    EventHandler!(CallbackEventArgs, float, int, int, string)  wheel;
    mixin EventCallbackAdapter!(IupCanvas, "wheel", float, int, int, char*);
    private IupElementAction onWheel(float delta, int x, int y, char *status) nothrow
    {       
        IupElementAction r = IupElementAction.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            string s = cast(string)std.string.fromStringz(status);
            wheel(this, callbackArgs, delta, x, y, s);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }
        return r;
    }

    /**
    */
    void setPaintEvent(bool isEnabled = true)
    {
        if(isEnabled)
        {
            if(!isPaintEventEnabled)
            {
                registerPaintCallback(IupCallbacks.Action);
                isPaintEventEnabled = true;
            }
        }
        else if(isPaintEventEnabled)
        {
            clearAttribute(IupCallbacks.Action);
            isPaintEventEnabled = false;
        }
    }
    private bool isPaintEventEnabled = false;
}


/**
Creates an OpenGL canvas (drawing area for OpenGL). It inherits from IupCanvas.
The IupGLCanvasOpen function must be called after a IupOpen, so that the control can be used. The "iupgl.h" 
file must also be included in the source code. 
The program must be linked to the controls library (iupgl), and with the OpenGL library.

To make the control available in Lua use require"iupluagl" or manually call the initialization function in C, 
iupgllua_open, after calling iuplua_open. When manually calling the function the iupluagl.h 
file must also be included in the source code and the program must be linked to the lua control library (iupluagl).

To link with the OpenGL libraries in Windows add: opengl32.lib. In UNIX add before the X-Windows libraries: -LGL.
*/
public class IupGLCanvas : IupCanvas
{

	protected class IupAttributes : super.IupAttributes
	{
        enum IupGLCanvas = "IupGLCanvas";
        enum AlphaSize = "ALPHA_SIZE";
        enum ArbContext = "ARBCONTEXT";
        enum Buffer = "BUFFER";
        enum BufferSize = "BUFFER_SIZE";
        //enum Color = "COLOR";
        enum ColorMap = "COLORMAP";
        enum Context = "CONTEXT";
        enum ContextFlags = "CONTEXTFLAGS";
        enum ContextProfile = "CONTEXTPROFILE";
        enum ContextVersion = "CONTEXTVERSION";
        enum DepthSize = "DEPTH_SIZE";
        enum Error = "ERROR";
        enum LastError = "LASTERROR";
        enum RedSize = "RED_SIZE";
        enum GreenSize = "GREEN_SIZE";
        enum BlueSize = "BLUE_SIZE";
        enum RefreshContext = "REFRESHCONTEXT";
        enum StencilSize = "STENCIL_SIZE";
        enum SharedContext = "SHAREDCONTEXT";
        enum Stereo = "STEREO";
        enum Visual = "VISUAL";
	}


	this()
	{
        m_bufferMode = GlBufferMode.Single;
		super();
	}

	protected override Ihandle* createIupObject()
	{
		return iup.c.opengl.IupGLCanvas(null);
	}


    /* ************* Properties *************** */


    /**
    Indicates if the buffer will be single "SINGLE" or double "DOUBLE". Default is "SINGLE".
    */
    @property 
	{
		GlBufferMode bufferMode() { return m_bufferMode; }

		void bufferMode(GlBufferMode value) 
		{
			m_bufferMode = value;
            setAttribute(IupAttributes.Buffer, toIupIdentifier(value));
		}
        private GlBufferMode m_bufferMode; 
	}

    /**
    Context version number in the format "major.minor". Used only when ARBCONTEXT=Yes. (since 3.6)
    */
    @property 
	{
		string contextVersion()  {  return getAttribute(IupAttributes.ContextVersion); }
        void contextVersion(string value) { setAttribute(IupAttributes.ContextVersion, value);}
	}

    /**
    If an error is found during IupMap and IupGLMakeCurrent, returns a string containing a 
    description of the error in English. 

    Possible ERROR strings during IupMap:

    "X server has no OpenGL GLX extension." - OpenGL not supported (UNIX Only)
    "No appropriate visual." - Failed to choose a Visual (UNIX Only) 
    "No appropriate pixel format." - Failed to choose a Pixel Format (Windows Only)
    "Could not create a rendering context." - Failed to create the OpenGL context. (Windows
    and UNIX)
    */
    @property 
	{
		string errorMessage()  {  return getAttribute(IupAttributes.Error); }
	}

    /**
    If an error is found, returns a string with the system error description. (Since 3.6)
    */
    version(Windows) @property 
	{
		string lastError()  {  return getAttribute(IupAttributes.LastError); }
	}

    /**
    enable the usage of ARB extension contexts. If during map the ARB extensions could not be 
    loaded the attribute will be set to NO and the standard context creation will be used. 
    Default: NO. (since 3.6)
    */
    @property 
	{
		bool enableArbContext() { return getAttribute(IupAttributes.ArbContext) == FlagIdentifiers.Yes; }

		void enableArbContext(bool value) 
		{
            setAttribute(IupAttributes.ArbContext, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}


    /**
    Creates a stereo GL canvas (special glasses are required to visualize it correctly). Possible 
    values: "YES" or "NO". Default: "NO". When this flag is set to Yes but the OpenGL driver 
    does not support it, the map will be successful and STEREO will be set to NO and ERROR 
    will not be set (since 3.9).
    */
    @property 
	{
		bool isStereo() { return getAttribute(IupAttributes.Stereo) == FlagIdentifiers.Yes; }

		void isStereo(bool value) 
		{
            setAttribute(IupAttributes.Stereo, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}


    /* ************* Public methods *************** */

    /**
    Activates the given canvas as the current OpenGL context. All subsequent OpenGL commands are 
    directed to such canvas. The first call will set the global attributes GL_VERSION, GL_VENDOR
    and GL_RENDERER (since 3.16).
    */
    void makeCurrent()
    {
        IupGLMakeCurrent(handle);
    }

    /**
    Makes the BACK buffer visible. This function is necessary when a double buffer is used.
    */
    void swapBuffers()
    {
        IupGLSwapBuffers(handle);
    }
}


enum GlBufferMode
{
    Single,
    Double
}

string toIupIdentifier(GlBufferMode b)
{
    switch(b)
    {
        case GlBufferMode.Single:
            return "SINGLE";

        case GlBufferMode.Double:
            return "DOUBLE";

        default:
            assert(0, "Not supported");
    }
}