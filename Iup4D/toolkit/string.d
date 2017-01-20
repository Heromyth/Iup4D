module toolkit.string;


import std.ascii;

string capitalize(string s) nothrow pure
{
    char letter = s[0];
    if(std.ascii.isUpper(letter))
        return s;

    char[] buffer = s.dup;
    buffer[0] = std.ascii.toUpper(letter);

    return cast(string) buffer;
}