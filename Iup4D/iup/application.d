module iup.application;

import iup.c;
import iup.dialog;
import iup.core;
import iup.menu;
import iup.system;

import toolkit.event;
import toolkit.path;

import std.path;
import std.string;


/**
The Application class manage the whole program, it can be used for load embedded resources,
close the program, get the current path and so on.

Internally in initialize manifest (if available), DLLs, and it handle exceptions showing
a window with exception information.
*/
public final class Application
{
	/// Static constructor (it enable the manifest, if available)
	static this()
	{
        m_executablePath = getModuleFullPath!string();
        m_basePath = dirName(m_executablePath) ~ dirSeparator;

		//version(Unicode)
		iup.c.IupSetGlobal(GlobalAttributes.Utf8Mode, FlagIdentifiers.Yes);
        version(Windows)
        {
            iup.c.IupSetGlobal(GlobalAttributes.Utf8ModeFile, FlagIdentifiers.Yes);  // 
        }

        open();
        iup.system.IupClipboard.open();


        registerIdleCallback(GlobalCallbacks.Idle);
	}

	static ~this()
	{
        exit();
        //iup.c.IupClose();
	}


    /* ************* Properties *************** */

    @property static string executablePath() {	return m_executablePath;  }
	private static string m_executablePath;

    /**
    c:\\temp\\
    */
	@property static string basePath() { return m_basePath;	}
	private static string m_basePath;



    /**
    The parent dialog of a dialog.
    This dialog will be always in front of the parent dialog. If the parent is minimized, 
    this dialog is automatically minimized. The parent dialog must be mapped before
    mapping the child dialog.

    If PARENTDIALOG is not defined then the NATIVEPARENT attribute is consulted. This one
    must be a native handle of an existing dialog.
    */
    @property 
    { 
        static iup.dialog.IupDialog parentDialog() 
        {
            return cast(iup.dialog.IupDialog)iup.c.IupGetGlobal(GlobalAttributes.ParentDialog);
        }

        static void parentDialog(iup.dialog.IupDialog dialog) 
        {
            iup.c.IupSetGlobal(GlobalAttributes.ParentDialog, cast(char*)dialog);
        }
    }


    /* ************* Events *************** */

    /**
    Predefined IUP action, generated when there are no events or messages to be processed.
    Often used to perform background operations.

    The Idle callback will be called whenever there are no messages left to be processed. 
    But this occurs more frequent than expected, for example if you move the mouse over 
    the application the idle callback will be called many times because the mouse move 
    message is processed so fast that the Idle will be called before another mouse move 
    message is schedule to processing.

    So this callback changes the message loop to a more CPU consuming one. It is important 
    that you set it to NULL when not using it. Or the application will be consuming CPU 
    even if the callback is doing nothing.
    */
    //static CallbackHandler!CallbackEventArgs idle;
    mixin FunctionCallback!("idle");


    /* ************* Public methods *************** */

	/**
	Close the program.
	Params:
	exitCode = Exit code of the program (usually is 0)
	*/
	public static void exit(int exitCode = 0)
	{
        if(isOpened)
        {
		    iup.c.IupClose();
            isOpened = false;
        }
	}
    private static bool isOpened = false;


    /**
    Terminates the current message loop. It has the same effect of a callback returning IUP_CLOSE. 
    */
    public static void exitLoop()
    {
        iup.c.IupExitLoop();
    }

    /**
    */
	public static open()
	{
        isOpened = true;
		iup.c.IupOpen(null, null);
	}

    /**
    Processes all pending messages in the message queue.
    When you change an attribute of a certain element, the change may not take place immediately. 
    For this update to occur faster than usual, call IupFlush after the attribute is changed.
    Important: A call to this function may cause other callbacks to be processed before it returns.
    */
    public static void flush()
    {
		return iup.c.IupFlush();
    }

    /**
    Runs one iteration of the message loop.
    This function is useful for allowing a second message loop to be managed by the 
    application itself. This means that messages can be intercepted and callbacks 
    can be processed inside an application loop.
    */
	public static int loopStep()
	{
		return iup.c.IupLoopStep();
	}

    /**
    Executes the user interaction until a callback returns IUP_CLOSE, IupExitLoop is 
    called, or hiding the last visible dialog.

    When this function is called, it will interrupt the program execution until a 
    callback returns IUP_CLOSE, IupExitLoop is called, or there are no visible dialogs. 
    */
	public static int mainLoop()
	{
		return iup.c.IupMainLoop();
	}

    /**
    Several additional controls are included in this library. These controls are drawn by IUP 
    using CD on a IupCanvas control, and are not native controls.

    The IupControlsOpen function must be called after IupOpen. 
    */
	public static useIupControls()
	{
		iup.c.IupControlsOpen();
	}

    /**
    */
	public static useImageLib()
	{
		iup.c.IupImageLibOpen();
	}

    /**
    */
	public static useOpenGL()
	{
		iup.c.IupGLCanvasOpen();
	}

	/**
	Start the program and adds onClose() event at the MainForm
	Params:
	mainForm = The Application's main form
	*/
    public static void run(iup.dialog.IupDialog dialog)
	{
        parentDialog = dialog;
        int r = dialog.show();
        //dialog.resetUserSize();
        mainLoop();

        dialog.dispose();
        iup.system.IupClipboard.dispose(); 
        exit();
	}

}




public class IupConfig : IupDisposableObject
{
    protected class IupAttributes
	{
        enum FileName = "APP_FILENAME";
        enum AppConfig = "APP_CONFIG";
        enum AppName = "APP_NAME";
        enum AppPath = "APP_PATH";
    }


    //this()
    //{
    //    super();
    //}

    //~this()
    //{
    //    //dispose();  // BUG? Access violations
    //}

	protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupConfig();
	}


    protected override void onCreated()
	{
        registerAttribute!IupObject(this);
	}


    /**
    The filename (with path) can be set using a regular attribute called APP_FILENAME. 
    */
    @property 
	{
		public string fileName()  {  return getAttribute(IupAttributes.FileName); }
        //public void fileName(string value) { setAttribute(IupAttributes.FileName, value);}
	}


    /**
    */
    @property 
	{
		public bool isHomeDirectoryUsed()  {  return m_isHomeDirectoryUsed; }
        private void isHomeDirectoryUsed(bool value) {  m_isHomeDirectoryUsed = value;  }
        private bool m_isHomeDirectoryUsed;
	}

    /**
    */
    @property 
	{
		public bool isAppDirectoryUsed()  {  return m_isAppDirectoryUsed; }
        private void isAppDirectoryUsed(bool value) 
        { 
            m_isAppDirectoryUsed = value;
            setAttribute(IupAttributes.AppConfig, 
                         value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
        private bool m_isAppDirectoryUsed;
	}

    @property 
	{
		public bool isCustomFileUsed()  {  return m_isCustomFileUsed; }
        private void isCustomFileUsed(bool value) {  m_isCustomFileUsed = value;  }
        private bool m_isCustomFileUsed;
	}
    /* ************* Public methods *************** */

    /**
    */
    void load()
    {
        iup.c.api.IupConfigLoad(handle);
    }

    /**
    */
    void save()
    {
        iup.c.api.IupConfigSave(handle);
    }

    /**
    But the most interesting is to let the filename to be dynamically constructed using the APP_NAME attribute.
    In this case APP_FILENAME must not be defined. The file name creation will depend on the system and on its usage.

    There are two defined usages. First, for a User Configuration File, it will be stored on the user Home Orientation. 
    Second, as an Application Configuration File, it will be stored in the same Orientation of the executable.

    The User Configuration File is the most common usage. In UNIX, the filename will be "<HOME>/.<APP_NAME>", 
    where "<HOME>" is replaced by the "HOME" environment variable contents, and <APP_NAME> replaced by the APP_NAME attribute value. 
    In Windows, the filename will be "<HOMEDRIVE><HOMEPATH>\<APP_NAME>.cfg", where HOMEDRIVE and HOMEPATH are 
    also obtained from environment variables.

    After the functions are called the attribute FILENAME is set reflecting the constructed filename.
    */
    void useHomeDirectory(string baseName)
    {
        isHomeDirectoryUsed = true;
        isAppDirectoryUsed = false;
        isCustomFileUsed = false;
        clearAttribute(IupAttributes.FileName);
        setAttribute(IupAttributes.AppName, baseName);
    }


    /**
    The Application Configuration File is defined by setting the attribute APP_CONFIG to Yes (default is No). 
    In this case the attribute APP_PATH must also be set. In UNIX, the filename will be "<APP_PATH>.<APP_NAME>",  
    and in Windows will be "<APP_PATH><APP_NAME>.cfg". Notice that the attribute APP_PATH must contains a Orientation 
    separator "/" at the end.
    */
    void useAppDirectory(string appDir, string baseName)
    {
        isHomeDirectoryUsed = false;
        isAppDirectoryUsed = true;
        isCustomFileUsed = false;
        clearAttribute(IupAttributes.FileName);
        setAttribute(IupAttributes.AppPath, appDir);
        setAttribute(IupAttributes.AppName, baseName);
    }

    void useCustomDirectory(string fullPath)
    {
        isHomeDirectoryUsed = false;
        isAppDirectoryUsed = false;
        isCustomFileUsed = true;
        setAttribute(IupAttributes.FileName, fullPath);
    }



    /**
    */
    void setVariable(string group, string key, string value)
    {
        iup.c.api.IupConfigSetVariableStr(handle, toStringz(group), toStringz(key), toStringz(value));
    }

    /**
    */
    void setVariable(string group, string key, int id, string value)
    {
        iup.c.api.IupConfigSetVariableStrId(handle, toStringz(group), toStringz(key), id, toStringz(value));
    }

    /**
    */
    void setVariable(string group, string key, int value)
    {
        iup.c.api.IupConfigSetVariableInt(handle, toStringz(group), toStringz(key), value);
    }

    /**
    */
    void setVariable(string group, string key, int id, int value)
    {
        iup.c.api.IupConfigSetVariableIntId(handle, toStringz(group), toStringz(key), id, value);
    }

    /**
    */
    void setVariable(string group, string key, double value)
    {
        iup.c.api.IupConfigSetVariableDouble(handle, toStringz(group), toStringz(key), value);
    }

    /**
    */
    void setVariable(string group, string key, int id, double value)
    {
        iup.c.api.IupConfigSetVariableDoubleId(handle, toStringz(group), toStringz(key), id, value);
    }


    /**
    */
    string getVariableAsString(string group, string key)
    {
        auto r = iup.c.api.IupConfigGetVariableStr(handle, toStringz(group), toStringz(key));
        return cast(string)std.string.fromStringz(r);
    }


    /**
    */
    string getVariableAsString(string group, string key, int id)
    {
        auto r = iup.c.api.IupConfigGetVariableStrId(handle, toStringz(group), toStringz(key), id);
        return cast(string)std.string.fromStringz(r);
    }

    /**
    */
    string getVariableAsStringWithDefault(string group, string key, string def)
    {
        auto r = iup.c.api.IupConfigGetVariableStrDef(handle, toStringz(group), toStringz(key),  toStringz(def));
        return cast(string)std.string.fromStringz(r);
    }

    /**
    */
    int getVariableAsInt(string group, string key)
    {
        auto r = iup.c.api.IupConfigGetVariableInt(handle, toStringz(group), toStringz(key));
        return r;
    }

    /**
    */
    int getVariableAsInt(string group, string key, int id)
    {
        auto r = iup.c.api.IupConfigGetVariableIntId(handle, toStringz(group), toStringz(key), id);
        return r;
    }


    /**
    */
    double getVariableAsDouble(string group, string key)
    {
        auto r = iup.c.api.IupConfigGetVariableDouble(handle, toStringz(group), toStringz(key));
        return r;
    }

    /**
    */
    double getVariableAsDouble(string group, string key, int id)
    {
        auto r = iup.c.api.IupConfigGetVariableDoubleId(handle, toStringz(group), toStringz(key), id);
        return r;
    }


    /**
    Initialize the "Recent Files" menu 
    */
    void initRecentMenu(iup.menu.IupMenu menu, 
                        FileHandlerDelegate handler, int maxRecent)
    {
        recentFileHandler = handler;
        iup.c.api.IupConfigRecentInit(handle, menu.handle,
                                      &recentMenuCallbackAdapter, maxRecent);
    }
    alias FileHandlerDelegate = void delegate(string fileName);

    private
    {
        FileHandlerDelegate recentFileHandler;
        int onRecentMenuCallback(string fileName) nothrow
        {
            try
            {
                if(recentFileHandler !is null)
                    recentFileHandler(fileName);
            }
            catch(Exception ex) { }

            return IUP_DEFAULT;
        }

        extern(C) static nothrow int recentMenuCallbackAdapter(Ihandle *ih) 
        {
            const(char)* filename = iup.c.api.IupGetAttribute(ih, "TITLE");
            string file = cast(string)std.string.fromStringz(filename);

            char* p = iup.c.api.IupGetAttribute(ih, "IupObject");
            IupConfig d = cast(IupConfig)(p);
            return cast(int)d.onRecentMenuCallback(file);
        }
    }

    /**
    Every time a file is open or saved call IupConfigRecentUpdate so that the menu list is updated. 
    The last file will be always on the top of the list. 
    */
    void updateMenuRecent(string filename)
    {
        iup.c.api.IupConfigRecentUpdate(handle, toStringz(filename));
    }


    /**
    */
    void onDialogShow(iup.dialog.IupDialog dialog, string name)
    {
        iup.c.api.IupConfigDialogShow(handle, dialog.handle, toStringz(name));
    }

    /**
    */
    void onDialogClosed(iup.dialog.IupDialog dialog, string name)
    {
        iup.c.api.IupConfigDialogClosed(handle, dialog.handle, toStringz(name));
    }
}