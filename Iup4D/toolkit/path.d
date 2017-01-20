module toolkit.path;

import std.string;
import std.conv;
import core.sys.windows.windows;


/**
* Get the full path for a specific module
*/
T getModuleFullPath(T)(HINSTANCE hInstance = null) @trusted
if(is(T == wstring) || is(T == string))
{
    wchar[MAX_PATH] buffer;

    DWORD len = GetModuleFileNameW(hInstance, buffer.ptr, buffer.length);
    if( len <= 0 )
        throw new Exception("can't get current module path");

    if(len == buffer.length && 
       GetLastError() == ERROR_INSUFFICIENT_BUFFER)
        throw new Exception("The buffer is full.");

    static if(is(T == wstring))
        return buffer[0..len].idup;
    else if(is(T == string))
        return to!string(buffer[0..len]);
    else 
        assert(0, "invalid return type");
}
