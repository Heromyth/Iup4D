module iup.core;


import iup.c.core;
import iup.c.api;

import std.conv;
import iup.core;
import std.string;
import std.format;

import toolkit.string;
import toolkit.event;
import toolkit.drawing;


/**
Defines a method to release allocated resources.
*/
interface IDisposable
{
    /**
    Performs application-defined tasks associated with freeing, releasing, or
    resetting unmanaged resources.
    */
    void dispose();
}


/**
*/
interface IIupObject
{
    @property Ihandle*  handle();

    /**
    */
    @property bool isValid();

    /**
    Name of the control inside the dialog. Not releated to IupSetHandle.
    */
    @property 
	{
		string name();
		void name(string value);
	}
}


/**
*/
class IupObject : IIupObject
{
    class IupAttributes 
    {
        enum IupObject = "IupObject";
		enum Name =          "NAME";
        enum Wid = "WID";
    }

    //~this()
    //{
    //    dispose();  // BUG? Access violation
    //}


    /* ************* Properties *************** */

    /**
    */
	@property 
	{
		Ihandle *  handle(){ return m_handle; }
		protected void handle(Ihandle * value) { m_handle = value;}
        private Ihandle * m_handle;
	}

    /**
    */
    @property bool isValid() { return m_handle !is null;}


    /**
    Name of the control inside the dialog. Not releated to IupSetHandle.
    */
    @property 
	{
		string name() { return getAttribute(IupAttributes.Name); }
		void name(string value) { setAttribute(IupAttributes.Name, value); }
	}

    /**
    Returns a name of an interface element, if the element has an associated name using 
    IupSetHandle or using LED (which calls IupSetHandle when parsed).

    Notice that a handle can have many names. IupGetName will return the last name set.
    */
    @property 
	{
		string lastName() 
        {
            char* s = IupGetName(this.handle);
            return std.string.fromStringz(s).idup;
        }
	}


    /* ************* Protected methods *************** */

    /**
    */
    protected void registerAttribute(T)(T p)
    {
        iup.c.api.IupSetAttribute(p.handle, T.stringof, cast(char*)p);
    }

    /**
    */
    void setPointerAttribute(string name, void* value)
    {
        iup.c.api.IupSetAttribute(handle, std.string.toStringz(name), cast(char*)value);
    }

    /**
    It can store only constant strings (like "Title", "30", etc) or application pointers. 
    The given value is not duplicated as a string, only a reference is stored. 
    Therefore, you can store application custom attributes, such as a context structure 
    to be used in a callback.
    */
    void setAttribute(string name, string value)
    {
        iup.c.api.IupSetStrAttribute(handle, std.string.toStringz(name), std.string.toStringz(value));
    }

    /**
    restore attribute to default.
    */
    void clearAttribute(string name)
    {
        iup.c.api.IupSetAttribute(handle, std.string.toStringz(name), null);
    }

    /**
    this function automatically creates a non conflict name and associates the name with 
    the attribute.
    */
    protected void setHandleAttribute(string name, IIupObject value)
    {
        iup.c.api.IupSetAttributeHandle (handle, std.string.toStringz(name), 
                                         value is null ? null : value.handle);
    }

    /**
    It can only store strings. The given string value will be duplicated internally. 
    */
    protected void setStrAttribute(string name, string value)
    {
        if(value.empty)
            iup.c.api.IupSetAttribute(handle, std.string.toStringz(name), null);
        else
            iup.c.api.IupSetStrAttribute(handle, std.string.toStringz(name), std.string.toStringz(value));
    }

    /**
    */
    protected void setIntAttribute(string name, int v) 
    {
        iup.c.api.IupSetInt(handle, std.string.toStringz(name), v);
    }

    /**
    */
    protected void setIdAttribute(string name, size_t id, string value)
    {
        iup.c.api.IupSetAttributeId(this.handle, std.string.toStringz(name),
                                    cast(int)id, std.string.toStringz(value));
    }

    /**
    */
    protected void setFloatAttribute(string name, float v) 
    {
        iup.c.api.IupSetFloat(handle, std.string.toStringz(name), v);
    }

    /**
    */
    protected void setDoubleAttribute(string name, double v) 
    {
        iup.c.api.IupSetDouble(handle, std.string.toStringz(name), v);
    }

    /**
    */
    protected void setAttribute(string name, int i1, int i2) 
    {
        iup.c.api.IupSetIntId(handle, std.string.toStringz(name), i1, i2);
    }

    /**
    C string returned by IupGetAttribute is a dynamically allocated pointer.
    */
    public string getAttribute(string name) // AsString
    {
        auto v = iup.c.api.IupGetAttribute(handle, std.string.toStringz(name));
        return std.string.fromStringz(v).idup;
    }


    /**
    */
    protected string getIdAttributeAsString(string name, int id)
    {
        char* v = iup.c.api.IupGetAttributeId(this.handle, std.string.toStringz(name), id);
        return cast(string)std.string.fromStringz(v).idup;
    }

    /**
    */
    protected int getIdAttributeAsInt(string name, int id)
    {
        return iup.c.api.IupGetIntId(this.handle, std.string.toStringz(name), id);
    }

    /**
    C string returned by IupGetAttribute is a dynamically allocated pointer.
    */
    protected int getIntAttribute(string name) // 
    {
        return iup.c.api.IupGetInt(handle, std.string.toStringz(name));
    }

    protected float getFloatAttribute(string name) // 
    {
        return iup.c.api.IupGetFloat(handle, std.string.toStringz(name));
    }

    protected double getDoubleAttribute(string name) // 
    {
        return iup.c.api.IupGetDouble(handle, std.string.toStringz(name));
    }

    protected int getIntIntAttribute(string name, out int i1, out int i2) // 
    {
        return iup.c.api.IupGetIntInt(handle, std.string.toStringz(name), &i1, &i2);
    }

    protected void* getPointerAttribute(string name) // As a void pointer
    {
        return cast(void*)iup.c.api.IupGetAttribute(handle, std.string.toStringz(name));
    }

    protected Ihandle* getHandleAttribute(string name)
    {
        return iup.c.api.IupGetAttributeHandle(handle, std.string.toStringz(name));
    }
}


/**
*/
class IupDisposableObject : IupObject, IDisposable
{

    this()
    {
        onCreating();
        onCreated();
    }

    this(Ihandle* handle)
    {
        assert(handle !is null);
        m_handle = handle;
        onCreated();
    }

    /* ************* Protected methods *************** */

	/*
	*/
	protected void onCreating()
	{
		m_handle = createIupObject();
	}

	protected abstract Ihandle* createIupObject();

	/*
	*/
	protected void onCreated()
	{
        registerAttribute!IupObject(this);
	}

	/*
    Removes a callback from an event.
	*/
    protected void unregisterCallback(string actionName)
    {
        iup.c.api.IupSetCallback(this.handle, std.string.toStringz(actionName), null);
    }

    /* ************* Properties *************** */

    @property bool isDisposed() { return m_handle is null;}

    /* ************* Public methods *************** */

    /**
    Destroys an interface element and all its children. Only dialogs, timers, popup menus and 
    images should be normally destroyed, but detached controls can also be destroyed.

    It will automatically unmap and detach the element if necessary, and then destroy the element.
    This function also deletes the main names associated to the interface element being destroyed, 
    but if it has more than one name then some names may be left behind. 
    Menu bars associated with dialogs are automatically destroyed when the dialog is destroyed. 
    Images associated with controls are NOT automatically destroyed, because images can be reused 
    in several controls the application must destroy them when they are not used anymore.
    All dialogs and all elements that have names are automatically destroyed in IupClose.
    */
    void dispose()
    {
        if(isDisposed)
            return;

        iup.c.IupDestroy(handle);
        handle = null;
    }

    void destroy()
    {
        dispose();
    }
}


/**
*/
class IupAuxiliaryObject : IupObject
{

    this(IupObject obj)
    {
        attatchedObject = obj;
    }

    /**
    */
    @property 
    {
        IupObject attatchedObject() { return m_attatchedObject; }

        protected void attatchedObject(IupObject value) 
        {
            m_attatchedObject = value;
            this.handle = value.handle;
        }
        private IupObject m_attatchedObject; 
    }
}


/**
*/
class IupElement : IupDisposableObject
{
	protected class IupCallbacks 
	{
        enum Map = "MAP_CB";
		enum Unmap = "UNMAP_CB";
		enum Destroy = "DESTROY_CB";
		enum Key = "K_ANY";
		enum Help = "HELP_CB";
	}

	class IupAttributes : super.IupAttributes
	{
		enum Title =          "TITLE";
		enum Active =          "ACTIVE";
		enum BgColor =        "BGCOLOR";
		enum FgColor =        "FGCOLOR";
	}


    this()
    {
        super();
    }

	this(string title)
    {
        super();
        this.title = title;
    }


    /* ************* Protected methods *************** */

    protected override void onCreated()
    {    
        super.onCreated();

        registerDestroyingCallback(IupCallbacks.Destroy);
        registerMappedCallback(IupCallbacks.Map);
        registerUnmappedCallback(IupCallbacks.Unmap);
        registerHelpRequestedCallback(IupCallbacks.Help);
    }   


    /* ************* Properties *************** */


    /**
    Element’s background color.

    The RGB components. Values should be between 0 and 255, separated by a blank space. For example "255 0 128", 
    red=255 blue=0 green=128.

    Default: It is the value of the DLGBGCOLOR global attribute. On some controls if not defined will inherit the 
    background of the native parent.

    Hexadecimal notation in the format "#RRGGBB" is also accepted in all color attributes. For example, 
    "255 0 128" can also be written as "#FF0080".
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
    Element’s foreground color. Usually it is the color of the associated text.

    The RGB components. Values should be between 0 and 255, separated by a blank space. For example "255 0 128", 
    red=255 blue=0 green=128.

    Default: It is the value of the DLGBGCOLOR global attribute. On some controls if not defined will inherit the 
    background of the native parent.

    Hexadecimal notation in the format "#RRGGBB" is also accepted in all color attributes. For example, 
    "255 0 128" can also be written as "#FF0080".
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
    Returns the name of the class of an interface element.
    */
    @property string className() { 
        auto v = iup.c.api.IupGetClassName(handle);
        return std.string.fromStringz(v).idup;
    }



    /**
    Element’s title. It is often used to modify some static text of the element (which cannot
    be changed by the user).
    */
	@property 
	{
        string title() { return getAttribute(IupAttributes.Title); }
        void title(string value) { setStrAttribute(IupAttributes.Title, value); }
	}

    /**
    Activates or inhibits user interaction.
    */
    @property 
	{
		bool enabled() { return getAttribute(IupAttributes.Active) == FlagIdentifiers.Yes; }

		void enabled(bool value) {
            setAttribute(IupAttributes.Active,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
    }

    /**
    */
    @property 
    {
		bool isAcitve() { return enabled; }
		void isAcitve(bool value)  { enabled = value; }
	}


    /* ************* Events *************** */

    /**
    Called right before an element is destroyed.
    If the dialog is visible then it is hidden before it is destroyed. The callback will be called right after it is hidden.
    The callback will be called before all other destroy procedures.
    For instance, if the element has children then it is called before the children are destroyed. 
    For language binding implementations use the callback name "LDESTROY_CB" to release memory allocated 
    by the binding for the element. Also the callback will be called before the language callback.
    */
    mixin EventCallback!(IupElement, "destroying");

    /**
    Called right after an element is mapped and its attributes updated in IupMap.
    When the element is a dialog, it is called after the layout is updated. For all other elements 
    is called before the layout is updated, so the element current size will still be 0x0 during MAP_CB (since 3.14).
    */
    mixin EventCallback!(IupElement, "mapped");

    /**
    Called right before an element is unmapped.
    */
    mixin EventCallback!(IupElement, "unmapped");

    /**
    Action generated when the user press F1 at a control. 
    In Motif is also activated by the Help button in some workstations keyboard.
    */
    mixin EventCallback!(IupElement, "helpRequested");


    /* ************* Public methods *************** */

    /**
    Updates the size and layout of all controls in the same dialog. 
    To be used after changing size attributes, or attributes that affect the size of the control. 
    Can be used for any element inside a dialog, but the layout of the dialog and all controls 
    will be updated. It can change the layout of all the controls inside the dialog because of 
    the dynamic layout positioning. 
    */
    void refresh()
    {
        iup.c.api.IupRefresh(this.handle);
    }

    /**
    Updates the size and layout of controls after changing size attributes, or attributes that 
    affect the size of the control. Can be used for any element inside a dialog, only its 
    children will be updated. It can change the layout of all the controls inside the given
    element because of the dynamic layout positioning. 
    */
    void refreshChildren()
    {
        iup.c.api.IupRefreshChildren(this.handle);
    }

    /**
    Creates (maps) the native interface objects corresponding to the given IUP interface elements. 
    It will also called recursively to create the native element of all the children in the 
    element's tree. The element must be already attached to a mapped container, except the dialog.
    A child can only be mapped if its parent is already mapped. This function is automatically 
    called before the dialog is shown in IupShow, IupShowXY or IupPopup.  
    */
    void map()
    {
        iup.c.api.IupMap(this.handle);
    }
}


/**
Creates a user element in IUP, which is not associated to any interface element. It is used to
map an external element to a IUP element. Its use is usually for additional elements, but 
you can use it to create an Ihandle* to store private attributes.
*/
class IupExternalElement : IupObject
{
    //alias Dictionary!(string, string) AttributeDict;
    //private AttributeDict attributeDict;

    this()
    {
        //attributeDict = new AttributeDict();

		m_handle = IupUser();
    }

    //void append(string name, string value)
    //{
    //    //attributeDict.add(name, value);
    //    setStrAttribute(name, value);
    //}


    /**
    it will clear all attributes stored internally and remove all references.
    */
    void clearAll()
    {
        clearAttribute("CLEARATTRIBUTES");
    }

}

/**
The callbacks implemented in C by the application must return one of the following values
*/
enum IupElementAction
{
    /**
    Proceeds normally with user interaction. 
    In case other return values do not apply, the callback should return this value. 
    */
    Default = IUP_DEFAULT,

    /**
    Call IupExitLoop after return. Depending on the state of the application it will close
    all windows and exit the application. Applies only to some actions. 
    */
    Close = IUP_CLOSE,

    /**
    Makes the native system ignore that callback action. Applies only to some actions. 
    */
    Ignore = IUP_IGNORE,

    /**
    Makes the element to ignore the callback and pass the treatment of the execution to the 
    parent element. Applies only to some actions. 
    */
    Continue = IUP_CONTINUE
}


/**
*/
class CallbackEventArgs : EventArgs
{
    bool isHandled;
    IupElementAction result;

    this()
    {
        isHandled = false;
        result = IupElementAction.Default;
    }

    this(IupElementAction result)
    {
        isHandled = false;
        this.result = result;
    }
}


/**
*/
interface ICallbackResult(T)
{
    @property
    {
        T value() nothrow;
        void value(T r) nothrow;
    }
}


/**
*/
class CallbackResult(T) : ICallbackResult!T
{
    @property
    {
        T value() nothrow { return m_value; }
        void value(T r) nothrow { m_value = r; }
        private T m_value;
    }

    this()
    {
    }

    this(T v)
    {
        m_value = v;
    }
}


alias ActionCallbackResult = CallbackResult!(IupElementAction); 
alias IntCallbackResult = CallbackResult!(int); 

alias DefaultActionCallbackResult = CallbackResult!(IupElementAction, IupElementAction.Default);

/**
*/
class CallbackResult(T, T defaultValue) : CallbackResult!T
{

    this()
    {
        super(defaultValue);
    }

    this(T v)
    {
        super(defaultValue);
    }
}



/**
Callback Adapter
*/
mixin template EventCallbackAdapter(T, string eventName, TEventArgs...)
{
    import std.format:format;
    import toolkit.string : capitalize;
    import toolkit.event;
    import iup.c.api;

    enum capitalizedName = capitalize(eventName);

    mixin(q{
        private void register%2$sCallback(string actionName)
        {
            iup.c.api.IupSetCallback(this.handle, std.string.toStringz(actionName), 
                                     cast(Icallback)&%1$sCallbackAdapter);
        }
    }.format(eventName, capitalizedName));

    mixin(q{
        extern(C) static private nothrow int %1$sCallbackAdapter(Ihandle *ih, TEventArgs args) 
        {
            char* p = iup.c.api.IupGetAttribute(ih, "IupObject");
            T d = cast(T)(p);
            return cast(int)d.on%2$s(args);
        }
    }.format(eventName, capitalizedName));
}

/**
Callback Adapter and Default EventHandler
*/
deprecated("using IupEventHandler instead")
mixin template EventCallback(T, string eventName, TEventArgs...)
{
    import toolkit.string : capitalize;
    import toolkit.event;

    enum capitalizedName = capitalize(eventName);

    mixin("EventHandler!(CallbackEventArgs, TEventArgs) "  ~ eventName ~ ";");

    mixin(q{
        private int on%2$s(TEventArgs args) nothrow
        {
            IupElementAction r = IupElementAction.Default;
            try {
                auto callbackArgs = new CallbackEventArgs();
                %1$s(this, callbackArgs, args); 
                r = callbackArgs.result;
            }
            catch(Exception ex) { /* do nothing. */ }
            return cast(int)r;
        }
    }.format(eventName, capitalizedName));

    mixin EventCallbackAdapter!(T, eventName, TEventArgs);
}


/**
*/
mixin template IupEventHandler(T, string eventName, TResponseResults, TEventArgs...)
//if(is(T == IEventResult))
//if(IEventResult in BaseTypeTuple!TEventResults)
{
    import toolkit.string : capitalize;
    import toolkit.event;

    enum capitalizedName = capitalize(eventName);
    alias ResultType = typeof(TResponseResults.value);

    mixin("EventHandler!(CallbackResult!ResultType, TEventArgs) "  ~ eventName ~ ";");
    //mixin("EventHandler!(EventArgs, TEventArgs) "  ~ eventName ~ ";");

    mixin(q{
        private ResultType on%2$s(TEventArgs args) nothrow
        {
            ResultType r = ResultType.init;
            try {
                auto response = new TResponseResults();
                %1$s(this, response, args); 
                r = response.value;
            }
            catch(Exception ex) { /* do nothing. */ }
            return r;
        }
    }.format(eventName, capitalizedName));

    mixin EventCallbackAdapter!(T, eventName, TEventArgs);
}


/**
*/
mixin template FunctionCallbackAdapter(string eventName, TEventArgs...)
{
    import std.format:format;
    import toolkit.string : capitalize;
    import toolkit.event;
    import iup.c.api;

    enum capitalizedName = capitalize(eventName);

    mixin(q{
        private static void register%2$sCallback(const(char)* actionName)
        {
            iup.c.IupSetFunction(actionName, cast(Icallback)&%1$sCallbackAdapter);
        }
    }.format(eventName, capitalizedName));

    mixin(q{
        extern(C) static private nothrow int %1$sCallbackAdapter(TEventArgs args) 
        {
            return cast(int)on%2$s(args);
        }
    }.format(eventName, capitalizedName));
}


/**
*/
mixin template FunctionCallback(string eventName, TEventArgs...)
{
    import toolkit.string : capitalize;
    import toolkit.event;

    enum capitalizedName = capitalize(eventName);

    mixin("static CallbackHandler!(CallbackEventArgs, TEventArgs) "  ~ eventName ~ ";");

    mixin(q{
        private static IupElementAction on%2$s(TEventArgs args) nothrow
        {
            IupElementAction r = IupElementAction.Default;
            try {
                auto callbackArgs = new CallbackEventArgs();
                %1$s(callbackArgs, args); 
                r = callbackArgs.result;
            }
            catch(Exception ex) { /* do nothing. */ }
            return r;
        }
    }.format(eventName, capitalizedName));

    mixin FunctionCallbackAdapter!(eventName, TEventArgs);
}


/**
*/
struct GlobalAttributes
{
	// General 
	enum Language =      "LANGUAGE";
	enum Version =       "VERSION";

	// System Control
	enum Utf8Mode =         "UTF8MODE";
	enum Utf8ModeFile =     "UTF8MODE_FILE";


	enum ParentDialog =    "PARENTDIALOG";

	// System Mouse and Keyboard

    /// Returns the state of the Shift keys (left and right). Possible values: "ON" or "OFF".
    enum ShiftKey =         "SHIFTKEY";  

    /// Returns the state of the Control keys (left and right). Possible values: "ON" or "OFF".
    enum ControlKey =         "CONTROLKEY";  

    /**
    Returns the state of the keyboard modifier keys: Shift, Ctrl, Alt and sYs(Win/Apple). 
    In the format of 4 characters: "SCAY". When not pressed the respective letter is replaced by a space " ". 
    */
    enum ModifierKeyState =    "MODKEYSTATE";  

    /// Returns the width of the vertical scrollbar (the same as the height of the horizontal scrollbar).
	enum ScrollBarSize =      "SCROLLBARSIZE";  


    // Screen Information

    /// Returns a real value with the screen resolution in pixels per inch (same as dots per inch - DPI).
	enum ScreenDepth =      "SCREENDEPTH"; 

    /// Returns a real value with the screen resolution in pixels per inch (same as dots per inch - DPI).
	enum ScreenSize =      "SCREENSIZE"; 

    /// Returns a real value with the screen resolution in pixels per inch (same as dots per inch - DPI).
	enum FullSize =      "FULLSIZE"; 

    /// Returns a real value with the screen resolution in pixels per inch (same as dots per inch - DPI).
	enum ScreenDpi =      "SCREENDPI"; 

}

final class GlobalCallbacks
{
	// General 
	enum Idle =      "IDLE_ACTION";
}


int getGlobalAttributeInt(string name) 
{
    return iup.c.api.IupGetInt(null, std.string.toStringz(name));
}


void unregisterCallback(string name)
{
    iup.c.IupSetFunction(std.string.toStringz(name), null);
}

enum LeftRightAlignment
{
    Left = 0,
    Right = 1
}


string toIupIdentifier(LeftRightAlignment alignment)
{
    switch(alignment)
    {
        case LeftRightAlignment.Left:
            return AlignmentIdentifiers.Left;

        case LeftRightAlignment.Right:
            return AlignmentIdentifiers.Right;

        default:
            assert(false, "Not supported");
    }
}


/**
*/
enum Orientation
{
    Horizontal,
    Vertical
}

/// ditto
struct OrientationIdentifiers
{
	enum Horizontal  =	"HORIZONTAL";
	enum Vertical  =	"VERTICAL";

    static Orientation convert(string id)
    {
        switch(id)
        {
            case Horizontal:
                return Orientation.Horizontal;

            case Vertical:
                return Orientation.Vertical;

            default:
                assert(0,"Identifier is Not supported: " ~ id);
        }
    }

    static string convert(Orientation d)
    {
        final switch(d)
        {
            case Orientation.Horizontal:
                return Horizontal;

            case Orientation.Vertical:
                return Vertical;
        }
    }
}



/**
horizontal position of the top left corner of the window, relative to the origin of the main screen.
*/
enum ScreenPostionH
{
	Center        = 0xFFFF,  /* 65535 */
    Left          = 0xFFFE,  /* 65534 */
    Right         = 0xFFFD,  /* 65533 */
    MousePos      = 0xFFFC,  /* 65532 */
    Current       = 0xFFFB,  /* 65531 */
    CenterParent  = 0xFFFA,  /* 65530 */
}

/**
vertical position of the top left corner of the window, relative to the origin of the main screen.
*/
enum ScreenPostionV
{
	Center        = 0xFFFF,  /* 65535 */
    Top           = 0xFFFE,  /* 65534 */
    Bottom        = 0xFFFD,  /* 65533 */
    MousePos      = 0xFFFC,  /* 65532 */
    Current       = 0xFFFB,  /* 65531 */
    CenterParent  = 0xFFFA,  /* 65530 */
}


enum Position
{
    Left,
    Right,
    Top,
    Bottom
}

struct PositionIdentifiers
{
	enum Left =	"LEFT";
	enum Right  =	"RIGHT";
	enum Top  =	"TOP";
	enum Bottom  =	"BOTTOM";


    static string convert(Position d)
    {
        final switch(d)
        {
            case Position.Left:
                return Left;

            case Position.Right:
                return Right;

            case Position.Top:
                return Top;

            case Position.Bottom:
                return Bottom;
        }
    }

    static Position convert(string s)
    {
        if(s == Right)
            return Position.Right;
        else  if(s == Top)
            return Position.Top;
        else  if(s == Bottom)
            return Position.Bottom;

        return Position.Left;
    }
}


//
// Summary:
//     Specifies alignment of content on the drawing surface.
public enum ContentAlignment
{
    //
    // Summary:
    //     Content is vertically aligned at the top, and horizontally aligned on the left.
    TopLeft = 1,
        //
        // Summary:
        //     Content is vertically aligned at the top, and horizontally aligned at the center.
        TopCenter = 2,
        //
        // Summary:
        //     Content is vertically aligned at the top, and horizontally aligned on the right.
        TopRight = 4,
        //
        // Summary:
        //     Content is vertically aligned in the middle, and horizontally aligned on the
        //     left.
        MiddleLeft = 16,
        //
        // Summary:
        //     Content is vertically aligned in the middle, and horizontally aligned at the
        //     center.
        MiddleCenter = 32,
        //
        // Summary:
        //     Content is vertically aligned in the middle, and horizontally aligned on the
        //     right.
        MiddleRight = 64,
        //
        // Summary:
        //     Content is vertically aligned at the bottom, and horizontally aligned on the
        //     left.
        BottomLeft = 256,
        //
        // Summary:
        //     Content is vertically aligned at the bottom, and horizontally aligned at the
        //     center.
        BottomCenter = 512,
        //
        // Summary:
        //     Content is vertically aligned at the bottom, and horizontally aligned on the
        //     right.
        BottomRight = 1024
}


//
// Summary:
//     Indicates where an element should be displayed on the horizontal axis relative
//     to the allocated layout slot of the parent element.
public enum HorizontalAlignment
{

    //     An element aligned to the left of the layout slot for the parent element.
    Left = 0,

        //     An element aligned to the center of the layout slot for the parent element.
        Center = 1,

        //     An element aligned to the right of the layout slot for the parent element.
        Right = 2
}


//
// Summary:
//     Describes how a child element is vertically positioned or stretched within a
//     parent's layout slot.
public enum VerticalAlignment
{

    //     The child element is aligned to the top of the parent's layout slot.
    Top = 0,

        //     The child element is aligned to the center of the parent's layout slot.
        Center = 1,

        //     The child element is aligned to the bottom of the parent's layout slot.
        Bottom = 2
}


/**
*/
struct AlignmentIdentifiers
{
	enum Left =	"ALEFT";
	enum Center  =	"ACENTER";
	enum Right  =	"ARIGHT";
	enum Top  =	"ATOP";
	enum Bottom  =	"ABOTTOM";

    //static string convert(Position p)
    //{
    //    final switch(p)
    //    {
    //        case Position.Left:
    //            return Left;
    //
    //        case Position.Right:
    //            return Right;
    //
    //        case Position.Top:
    //            return Top;
    //
    //        case Position.Bottom:
    //            return Bottom;
    //    }
    //}

    static string convert(ContentAlignment a)
    {
        enum Sepeator = ":";
        switch(a)
        {
            case ContentAlignment.TopLeft:
                return Left ~ Sepeator ~ Top ;

            case ContentAlignment.TopCenter:
                return Center ~ Sepeator ~ Top;

            case ContentAlignment.TopRight:
                return Right ~ Sepeator ~ Top ;

            case ContentAlignment.MiddleLeft:
                return Left ~ Sepeator ~ Center;

            case ContentAlignment.MiddleRight:
                return Right ~ Sepeator ~ Center;

            case ContentAlignment.BottomLeft:
                return Left ~ Sepeator ~ Bottom;

            case ContentAlignment.BottomCenter:
                return Center ~ Sepeator ~ Bottom;

            case ContentAlignment.BottomRight:
                return Right ~ Sepeator ~ Bottom;

            default:
                return Center ~ Sepeator ~ Center;
        }
    }


    static string convert(HorizontalAlignment alignment)
    {
        switch(alignment)
        {
            case HorizontalAlignment.Left:
                return Left;

            case HorizontalAlignment.Right:
                return Right;

            default:
                return Center;
        }
    }

    static HorizontalAlignment convertHorizontalAlignment(string a)
    {
        switch(a)
        {
            case Left:
                return HorizontalAlignment.Left;

            case Right:
                return HorizontalAlignment.Right;

            default:
                return HorizontalAlignment.Center;
        }
    }

    static string convert(VerticalAlignment alignment)
    {
        switch(alignment)
        {
            case VerticalAlignment.Top:
                return Top;

            case VerticalAlignment.Bottom:
                return Bottom;

            default:
                return Center;
        }
    }


    static VerticalAlignment convertVerticalAlignment(string a)
    {
        switch(a)
        {
            case Top:
                return VerticalAlignment.Top;

            case Bottom:
                return VerticalAlignment.Bottom;

            default:
                return VerticalAlignment.Center;
        }
    }

}


struct DirectionIdentifiers
{
	enum North =	"NORTH";
	enum South =	"SOUTH";
	enum East  =	"EAST";
	enum West  =	"WEST";


    static Position convert(string a)
    {
        switch(a)
        {
            case North:
                return Position.Top;

            case South:
                return Position.Bottom;

            case West:
                return Position.Left;

            case East:
                return Position.Right;

            default:
                assert(false, a ~ " is not supported");
        }
    }

    static string convert(Position a)
    {
        final switch(a)
        {
            case Position.Top:
                return North;

            case Position.Bottom:
                return South;

            case Position.Left:
                return West;

            case Position.Right:
                return East;
        }
    }
}


struct FlagIdentifiers
{
	enum Yes =	"YES";
	enum No  =	"NO";
}


enum ToggleState
{
    Indeterminate = -1,
    Off = 0,
    On = 1,
}


struct ToggleStateIdentifiers
{
	enum On =	"ON";
	enum Off  =	"OFF";
	enum Notdef  =	"NOTDEF";

    static string convert(ToggleState t)
    {
        switch(t)
        {
            case ToggleState.On:
                return On;

            case ToggleState.Off:
                return Off;

            case ToggleState.Indeterminate:
                return Notdef;

            default:
                assert(0, "Not supported");
        }
    }

    static ToggleState convert(string v)
    {
        if(v == On)
            return ToggleState.On;
        else if(v == Off)
            return ToggleState.Off;
        else
            return ToggleState.Indeterminate;
    }
}



public enum SimpleExpandOrientation
{
    None,
        Horizontal,
        Vertical,
        Both
}


struct SimpleExpandIdentifiers
{
	enum Yes =	"YES";
	enum No  =	"NO";
	enum Horizontal  =	"HORIZONTAL";
	enum Vertical  =	"VERTICAL";

    static SimpleExpandOrientation convert(string s)
    {
        switch(s)
        {
            case No:
                return SimpleExpandOrientation.None;

            case Horizontal:
                return SimpleExpandOrientation.Horizontal;

            case Vertical:
                return SimpleExpandOrientation.Vertical;

            case Yes:
                return SimpleExpandOrientation.Both;

            default:
                assert(0, "Not Supported: " ~ s);
        }
    }


    static string convert(SimpleExpandOrientation e)
    {
        final switch(e)
        {
            case SimpleExpandOrientation.None:
                return No;

            case SimpleExpandOrientation.Horizontal:
                return Horizontal;

            case SimpleExpandOrientation.Vertical:
                return Vertical;

            case SimpleExpandOrientation.Both:
                return Yes;
        }
    }
}


/**
*/
public enum ExpandOrientation
{
    None,
        Horizontal,
        Vertical,
        HorizontalFree,
        VerticalFree,
        Both
}


struct ExpandOrientationIdentifiers
{
	enum Yes =	"YES";
	enum No  =	"NO";
	enum Horizontal  =	"HORIZONTAL";
	enum Vertical  =	"VERTICAL";
	enum HorizontalFree  =	"HORIZONTALFREE";
	enum VerticalFree  =	"VERTICALFREE";



    static ExpandOrientation convert(string s)
    {
        switch(s)
        {
            case No:
                return ExpandOrientation.None;

            case Horizontal:
                return ExpandOrientation.Horizontal;

            case Vertical:
                return ExpandOrientation.Vertical;

            case HorizontalFree:
                return ExpandOrientation.HorizontalFree;

            case VerticalFree:
                return ExpandOrientation.VerticalFree;

            case Yes:
                return ExpandOrientation.Both;

            default:
                assert(0, "Not Supported: " ~ s);
        }
    }


    static string convert(ExpandOrientation e)
    {
        final switch(e)
        {
            case ExpandOrientation.None:
                return No;

            case ExpandOrientation.Horizontal:
                return Horizontal;

            case ExpandOrientation.Vertical:
                return Vertical;

            case ExpandOrientation.HorizontalFree:
                return HorizontalFree;

            case ExpandOrientation.VerticalFree:
                return VerticalFree;

            case ExpandOrientation.Both:
                return Yes;
        }
    }
}



//
// Summary:
//     Specifies which scroll bars will be visible on a control.
public enum ScrollBarsVisibility
{
    //
    // Summary:
    //     No scroll bars are shown.
    None = 0,
        //
        // Summary:
        //     Only horizontal scroll bars are shown.
        Horizontal = 1,
        //
        // Summary:
        //     Only vertical scroll bars are shown.
        Vertical = 2,
        //
        // Summary:
        //     Both horizontal and vertical scroll bars are shown.
        Both = 3
}


struct ScrollbarVisibilityIdentifiers
{
    enum No =	"NO";
    enum Yes =	"YES";
    enum Horizontal  =	"HORIZONTAL";
    enum Vertical  =	"VERTICAL";


    static string convert(ScrollBarsVisibility s)
    {
        final switch(s)
        {
            case ScrollBarsVisibility.None:
                return No;

            case ScrollBarsVisibility.Both:
                return Yes;

            case ScrollBarsVisibility.Horizontal:
                return Horizontal;

            case ScrollBarsVisibility.Vertical:
                return Vertical;
        }
    }


    static ScrollBarsVisibility convert(string s)
    {
        switch(s)
        {
            case No:
                return ScrollBarsVisibility.None;

            case Yes:
                return ScrollBarsVisibility.Both;

            case Horizontal:
                return ScrollBarsVisibility.Horizontal;

            case Vertical:
                return ScrollBarsVisibility.Vertical;

            default:
                assert(0, "Not supported");
        }
    }
}


/**
A library of pre-defined stock images for buttons and labels.
To generate an application that uses this function, 
the program must be linked to the functions library (iupimglib.lib on Windows and libiupimglib.a on Unix). 
*/
struct IupImages
{
    enum ActionCancel = "IUP_ActionCancel";
    enum ActionOk = "IUP_ActionOk";
    enum ArrowDown = "IUP_ArrowDown";
    enum ArrowLeft = "IUP_ArrowLeft";
    enum ArrowRight = "IUP_ArrowRight";
    enum ArrowUp = "IUP_ArrowUp";
    enum EditCopy = "IUP_EditCopy";
    enum EditCut = "IUP_EditCut";
    enum EditErase = "IUP_EditErase";
    enum EditFind = "IUP_EditFind";
    enum EditPaste = "IUP_EditPaste";
    enum EditRedo = "IUP_EditRedo";
    enum EditUndo = "IUP_EditUndo";
    enum FileClose = "IUP_FileClose";
    enum FileNew = "IUP_FileNew";
    enum FileOpen = "IUP_FileOpen";
    enum FileProperties = "IUP_FileProperties";
    enum FileSave = "IUP_FileSave";
    enum MediaForward = "IUP_MediaForward";
    enum MediaGoToBegin = "IUP_MediaGoToBegin";
    enum MediaGoToEnd = "IUP_MediaGoToEnd";
    enum MediaPause = "IUP_MediaPause";
    enum MediaPlay = "IUP_MediaPlay";
    enum MediaRecord = "IUP_MediaRecord";
    enum MediaReverse = "IUP_MediaReverse";
    enum MediaRewind = "IUP_MediaRewind";
    enum MediaStop = "IUP_MediaStop";
    enum MessageError = "IUP_MessageError";
    enum MessageHelp = "IUP_MessageHelp";
    enum MessageInfo = "IUP_MessageInfo";
    enum NavigateHome = "IUP_NavigateHome";
    enum NavigateRefresh = "IUP_NavigateRefresh";
    enum Print = "IUP_Print";
    enum PrintPreview = "IUP_PrintPreview";
    enum ToolsColor = "IUP_ToolsColor";
    enum ToolsSettings = "IUP_ToolsSettings";
    enum ToolsSortAscend = "IUP_ToolsSortAscend";
    enum ToolsSortDescend = "IUP_ToolsSortDescend";
    enum ViewFullScreen = "IUP_ViewFullScreen";
    enum ZoomActualSize = "IUP_ZoomActualSize";
    enum ZoomIn = "IUP_ZoomIn";
    enum ZoomOut = "IUP_ZoomOut";
    enum ZoomSelection = "IUP_ZoomSelection"; 

    enum Tecgraf = "IUP_Tecgraf";
    enum PucRio = "IUP_PUC-Rio";
    enum BR = "IUP_BR";
    enum Lua = "IUP_Lua"; 
    enum TecgrafPucRio = "IUP_TecgrafPUC-Rio";
    enum Petrobras = "IUP_Petrobras"; 

    enum CircleProgressAnimation = "IUP_CircleProgressAnimation"; 


    /* // NOT included in the pre-compiled library, since 3.3
    enum IconMessageSecurity = "IUP_IconMessageSecurity"; 
    enum IconMessageWarning = "IUP_IconMessageWarning"; 
    enum IconMessageInfo = "IUP_IconMessageInfo"; 
    enum IconMessageError = "IUP_IconMessageError"; 
    enum IconMessageHelp = "IUP_IconMessageHelp"; 
    enum DeviceCamera = "IUP_DeviceCamera";
    enum DeviceCD = "IUP_DeviceCD";
    enum DeviceCellPhone = "IUP_DeviceCellPhone";
    enum DeviceComputer = "IUP_DeviceComputer";
    enum DeviceFax = "IUP_DeviceFax";
    enum DeviceHardDrive = "IUP_DeviceHardDrive";
    enum DeviceMP3 = "IUP_DeviceMP3";
    enum DeviceNetwork = "IUP_DeviceNetwork";
    enum DevicePDA = "IUP_DevicePDA";
    enum DevicePrinter = "IUP_DevicePrinter";
    enum DeviceScanner = "IUP_DeviceScanner";
    enum DeviceSound = "IUP_DeviceSound";
    enum DeviceVideo = "IUP_DeviceVideo"; 
    */

}


struct IupCursors
{
    enum None = "NONE";
    enum Null = "NULL";
    enum Arrow = "ARROW";
    enum Busy = "BUSY";
    enum Cross = "CROSS";
    enum Hand = "HAND";
    enum Help = "HELP";
    enum Move = "MOVE";
    enum Pen = "PEN";
    enum Resize_n = "RESIZE_N";
    enum Resize_s = "RESIZE_S";
    enum Resize_ns = "RESIZE_NS";
    enum Resize_w = "RESIZE_W";
    enum Resize_e = "RESIZE_E";
    enum Resize_we = "RESIZE_WE";
    enum Resize_ne = "RESIZE_NE";
    enum Resize_sw = "RESIZE_SW";
    enum Resize_nw = "RESIZE_NW";
    enum Resize_se = "RESIZE_SE";
    enum Text = "TEXT";
    enum AppStarting = "APPSTARTING";
    enum No = "NO";
    enum Uparrow = "UPARROW";
}


struct IupSize
{
	static Size parse(const(char)[] s )
	{

		Size r = Size(0,0);
		auto index = std.string.indexOf(s, 'x');
		if(index == -1)
			return r;

		r.width = to!int(s[0..index]);

		auto length = s.length;
		if(s[$-1] == '\0')
			length--;

		if(index + 1 < length)
			r.height = to!int(s[index+1..length]);

		return r;
	}

	/**
	"widthxheight", where width and height are integer values corresponding to the horizontal and vertical size, respectively, 
    in characters fraction unit (see Notes below). 
	You can also set only one of the parameters by removing the other one and maintaining the separator "x", 
    but this is equivalent of setting the other value to 0. For example: "x40" (height only = "0x40") or "40x" (width only = "40x0").
	*/
	static string format(Size size)
	{
		string w = "";
		string h = "";
		if(size.width>0)
			w = to!string(size.width);
		if(size.height>0)
			h = to!string(size.height);

		string r = w ~ "x" ~ h ~ "\0";
		return r;
	}
}


/**
*/
struct IupOffsetXY
{
	static OffsetXY parse(const(char)[] s )
	{
		OffsetXY r = OffsetXY(0,0);
		int index = cast(int) std.string.indexOf(s, 'x');
		if(index == -1)
			return r;

		r.dx = to!int(s[0..index]);

		int length = cast(int) s.length;
		if(s[$-1] == '\0')
			length--;

		if(index + 1 < length)
			r.dy = to!int(s[index+1..length]);

		return r;
	}

	/**
	"widthxheight", where width and height are integer values corresponding to the horizontal and vertical size, respectively, 
    in characters fraction unit (see Notes below). 
	You can also set only one of the parameters by removing the other one and maintaining the separator "x", 
    but this is equivalent of setting the other value to 0. For example: "x40" (height only = "0x40") or "40x" (width only = "40x0").
	*/
	static string format(OffsetXY offset)
	{
		string w = "";
		string h = "";
        w = to!string(offset.dx);
        h = to!string(offset.dy);

		string r = w ~ "x" ~ h ~ "\0";
		return r;
	}
}


/**
*/
struct IupRectangleConverter
{
    static string convert(Rectangle!int rect)
    {
        return std.format.format("%d %d %d %d", rect.x1, rect.y1, rect.x2, rect.y2);
    }

    static Rectangle!int convert(string s)
    {
        Rectangle!int r;
        std.format.formattedRead(s, "%d %d %d %d", &r.x1, &r.y1, &r.x2, &r.y2);
        return r;
    }

}

unittest
{
	//Size s = Size(100, 80);
	//printf("%s\n", Size.iupFormat(s));
	//printf("%s\n", Size.iupFormat(Size(0, 80)));
	//printf("%s\n", Size.iupFormat(Size(100, 0)));
	//printf("%s", Size.iupFormat(Size(0, 0)));
	//
	//
	//s = Size.iupParse("100x\0");
}


const(char) * iupToStringz(int d)
{
    return  std.string.toStringz(to!(string)(d));
}


struct NumberMaskStyle
{
    /// integer number
    enum Int = "[+/-]?/d+";

    /// unsigned integer number
    enum UInt = "/d+";

    /// floating point number
    enum Float = "[+/-]?(/d+/.?/d*|/./d+)";

    /// unsigned floating point number
    enum UFloat = "(/d+/.?/d*|/./d+)";

    /// floating point number with exponential notation
    enum EFloat = "[+/-]?(/d+/.?/d*|/./d+)([eE][+/-]?/d+)?";

    /// floating point number
    enum FloatComma  = "[+/-]?(/d+/,?/d*|/,/d+)";

    /// unsigned floating point number
    enum UFloatComma = "(/d+/,?/d*|/,/d+)";

}


enum DragDropContent
{
    Text,
    BitMap
}


struct DragDropContentIdentifiers
{
    enum Text = "TEXT";
    enum BitMap = "BITMAP";

    static string convert(DragDropContent d)
    {
        final switch(d)
        {
            case DragDropContent.BitMap:
                return DragDropContentIdentifiers.BitMap;

            case DragDropContent.Text:
                return DragDropContentIdentifiers.Text;
        }
    }

    static DragDropContent convert(string s)
    {
        if(s == DragDropContentIdentifiers.BitMap)
            return DragDropContent.BitMap;

        return DragDropContent.Text;
    }
}




enum IupDrawStyle
{
    Fill, 
    Stroke,
    StrokeDash,
    StrokeDot
}


struct IupDrawStyleIdentifiers
{
    enum Fill = "FILL";
    enum Stroke = "STROKE";
    enum StrokeDash = "STROKE_DASH";
    enum StrokeDot = "STROKE_DOT";

    static string convert(IupDrawStyle t)
    {
        final switch(t)
        {
            case IupDrawStyle.Fill:
                return Fill;

            case IupDrawStyle.Stroke:
                return Stroke;

            case IupDrawStyle.StrokeDash:
                return StrokeDash;

            case IupDrawStyle.StrokeDot:
                return StrokeDot;
        }
    }

    static IupDrawStyle convert(string s)
    {
        switch(s)
        {
            case Fill:
                return IupDrawStyle.Fill;

            case StrokeDash:
                return IupDrawStyle.StrokeDash;

            case StrokeDot:
                return IupDrawStyle.StrokeDot;

            default:
                return IupDrawStyle.Stroke;
        }
    }
}
