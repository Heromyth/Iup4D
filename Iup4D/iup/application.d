module iup.application;

import iup.c;
import iup.dialog;
import iup.core;
import iup.clipboard;

import toolkit.event;
import toolkit.path;

import std.path;
import std.string;


/**
The Application class manage the whole program, it can be used for load embedded resources,
close the program, get the current path and so on.
Internally in initialize manifest (if available), DLLs, and it handle exceptions showing a window with exception information.
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
        iup.clipboard.IupClipboard.open();


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
        iup.clipboard.IupClipboard.dispose(); 
        exit();
	}

}

