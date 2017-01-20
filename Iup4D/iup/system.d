module iup.system;

import iup.c;
import iup.core;

import std.string;



final class Environment
{
    final class IUP
    {
        /**
        Returns a string with the IUP version number.
        Returns: the version number including the bug fix. The defines only includes the major 
        and minor numbers. For example: "2.7.1".
        */
        @property static string ver() 
        { 
            char* v = iup.c.IupVersion();
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns the IUP's copyright.
        Ex: "Copyright (C) 1994-2014 Tecgraf/PUC-Rio".
        */
        @property static string copyright()
        {  
            char* v = iup.c.IupGetGlobal("COPYRIGHT");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Informs the current driver being used.
        Two drivers are available now, one for each platform: "GTK", "Motif" and "Win32".
        */
        @property static string driver() 
        { 
            char* v = iup.c.IupGetGlobal("DRIVER");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        */
        @property static string isUtf8Mode() 
        { 
            char* v = iup.c.IupGetGlobal(GlobalAttributes.Utf8Mode);
            return cast(string)std.string.fromStringz(v);
        }

        /**
        The language used by some pre-defined dialogs.
        Can have the values ENGLISH and PORTUGUESE. Default: ENGLISH. 
        Can also be set by IupSetLanguage.
        */
        @property
        {
            static string language() 
            { 
                char* v = iup.c.IupGetGlobal("LANGUAGE");
                return cast(string)std.string.fromStringz(v);
            }

            static void language(string lang)
            {
                iup.c.IupSetLanguage(std.string.toStringz(lang));
            }
        }
    }

    final class OS
    {

        /**
        Informs the current operating system. On UNIX, it is equivalent to the command 
        "uname -s" (sysname). On Windows, it identifies if you are on Windows 2000, 
        Windows XP or Windows Vista. Some known names: 

        "MacOS" 
        "FreeBSD" 
        "Linux" 
        "SunOS" 
        "Solaris" 
        "IRIX" 
        "AIX" 
        "HP-UX" 
        "Win2K" 
        "WinXP" 
        "Vista" 
        "Win7" 
        "Win8" 

        Notice that "Windows 8.1" will normally be detected as "Windows 8", unless a special
        Manifest is used. See MSDN for more information.
        */
        @property static string name() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEM");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Informs the current operating system version number.

        On UNIX, it is equivalent to the command  "uname -r" (release). On Windows, it identifies
        the system version number and service pack version. On MacOSX is system version.
        */
        @property static string ver() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEMVERSION");
            return cast(string)std.string.fromStringz(v);
        }


        /**
        Returns a text with a description of the system language.
        */
        @property static string language() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEMLANGUAGE");
            return cast(string)std.string.fromStringz(v);
        }


        /**
        Returns a text with a description of the system locale.
        */
        @property static string locale() 
        { 
            char* v = iup.c.IupGetGlobal("SYSTEMLOCALE");
            return cast(string)std.string.fromStringz(v);
        }
    }


    /// Screen Information
    final class Screen
    {
        /**
        Returns the screen depth in bits per pixel.
        */
        @property static double depth() { return iup.c.IupGetDouble(null,GlobalAttributes.ScreenDepth);}

        /**
        Returns the screen size in pixels available for dialogs, i.e. not including menu bars, 
        task bars, etc. In Motif has the same value as the FULLSIZE attribute. The main screen 
        size does not include additional monitors.

        String in the "widthxheight" format.
        */
        @property static string size()
        { 
            char* v = iup.c.IupGetGlobal(GlobalAttributes.ScreenSize);
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns the full screen size in pixels.
        String in the "widthxheight" format.
        */
        @property static string fullSize() 
        { 
            char* v = iup.c.IupGetGlobal(GlobalAttributes.FullSize);
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns a real value with the screen resolution in pixels per inch (same as 
        dots per inch - DPI).
        */
        @property static double dpi() { return iup.c.IupGetDouble(null, GlobalAttributes.ScreenDpi);}


        /**
        Returns the virtual screen position and size in pixels. It is the virtual 
        space defined by all monitors in the system.

        String in the "x y width height" format.
        */
        @property static string virtualScreen() 
        { 
            char* v = iup.c.IupGetGlobal("VIRTUALSCREEN");
            return cast(string)std.string.fromStringz(v);
        }

        /**
        Returns the position and size in pixels of all monitors. Each monitor information is
        terminated by a "\n" character.

        String in the "x y width height\nx y width height\n..." format.
        */
        @property static string monitorsInfo() 
        { 
            char* v = iup.c.IupGetGlobal("MONITORSINFO");
            return cast(string)std.string.fromStringz(v);
        }
    }

    /**
    Returns the hostname.
    */
    @property static string computerName() 
    { 
        char* v = iup.c.IupGetGlobal("COMPUTERNAME");
        return cast(string)std.string.fromStringz(v);
	}


    /**
    Returns the user logged in.
    */
    @property static string userName() 
    { 
        char* v = iup.c.IupGetGlobal("USERNAME");
        return cast(string)std.string.fromStringz(v);
	}


    /**
    */
    @property static string defaultFont() 
    { 
        char* v = iup.c.IupGetGlobal("DEFAULTFONT");
        return cast(string)std.string.fromStringz(v);
	}


}