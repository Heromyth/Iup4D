module iup.misc;

import std.string;
import iup.c.api;


/**
Opens the given URL. In UNIX executes Netscape, Safari (MacOS) or Firefox (in Linux) passing the desired URL as a parameter. 
In Windows executes the shell "open" operation on the given URL.
*/
int IupHelp(string url)
{
    return iup.c.api.IupHelp(std.string.toStringz(url));
}


