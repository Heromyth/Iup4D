module toolkit.exception;

import std.string;

public class ArgumentException : Exception
{
    string paramName;

    this( string msg, string paramName, string file = __FILE__, size_t line = __LINE__, Throwable next = null )
    {
        super( msg, file, line, next );
        this.paramName = paramName;
    }
}



public class ArgumentNullException : Exception
{
    string paramName;

    this(string paramName, string file = __FILE__, size_t line = __LINE__, Throwable next = null )
    {
        super( paramName ~ "is null.", file, line, next );
        this.paramName = paramName;
    }
}



public class FileNotFoundException : Exception
{
    this(string msg = null, Throwable next = null, string file = __FILE__, size_t line = __LINE__)
    {
        super( msg, file, line, next );
    }
}



/*
 *     The exception that is thrown when a method call is invalid for the object's
 *     current state.
 */
public class InvalidOperationException : Exception
{
    this(string msg = null, Throwable next = null, string file = __FILE__, size_t line = __LINE__)
    {
        super( msg, file, line, next );
    }
}



public class NotImplementedException : Exception
{
    this(string msg = null, string file = __FILE__, size_t line = __LINE__, Throwable next = null )
    {
        super( msg, file, line, next );
    }
}



public class NotSupportedException : Exception
{
    this(string msg = null, string file = __FILE__, size_t line = __LINE__, Throwable next = null )
    {
        super( msg, file, line, next );
    }
}



public class TimeoutException : Exception
{
    this(string msg = null, Throwable next = null, string file = __FILE__, size_t line = __LINE__)
    {
        super( msg, file, line, next );
    }
}

