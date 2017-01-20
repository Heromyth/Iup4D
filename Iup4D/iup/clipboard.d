module iup.clipboard;

import iup.c.core;
import iup.c.api;
import iup.c.image;
import im.c.image;
import im.image;

import std.string;



public final static class IupClipboard 
{
    private static Ihandle* handle;

	protected struct IupAttributes
	{
        enum AddFormat = "ADDFORMAT";
        enum Format = "FORMAT";
        enum FormatAvailable = "FORMATAVAILABLE";
        enum FormatData = "FORMATDATA";
        enum FormatDataSize = "FORMATDATASIZE";
        enum ImageAvailable = "IMAGEAVAILABLE";
        enum NativeImage = "NATIVEIMAGE";
        enum Image = "IMAGE";
        enum Text = "TEXT";
        enum TextAvailable = "TEXTAVAILABLE";

        version(Windows)
        {
            enum EmfAvailable = "EMFAVAILABLE";
            enum SaveEmf = "SAVEEMF";
            enum SaveWmf = "SAVEWMF";
            enum WmfAvailable = "WMFAVAILABLE";
        }

	}

    //static this()
    //{
    //    iup.c.api.IupOpen(null, null);
    //    handle = iup.c.api.IupClipboard();
    //}

    //static ~this()
    //{
    //    iup.c.IupDestroy(handle);  // BUG?
    //}

    static void open()
    {
        // IupOpen must be run firstly.
        if(handle is null)
            handle = iup.c.api.IupClipboard();
    }

    static void dispose()
    {
        if(handle is null)
            return;

        iup.c.IupDestroy(handle);
        handle = null;
    }

    /* ************* Properties *************** */


    /**
    */
    @property 
	{ 
		public static bool isTextAvailable() { return cast(bool)getIntAttribute(IupAttributes.TextAvailable); }
		public static bool isFormatAvailable() { return cast(bool)getIntAttribute(IupAttributes.FormatAvailable); }
		public static bool isImageAvailable() { return cast(bool)getIntAttribute(IupAttributes.ImageAvailable); }
	}


    /* ************* Public methods *************** */

    /**
    register a custom format for clipboard data given its name. The registration remains 
    valid even after the element is destroyed. A new format must be added before used. (since 3.7)
    */
    public static void addFormat(string name)
    {
        setAttribute(IupAttributes.AddFormat, name);
    }    
    
    /**
    set the current format to be used by the FORMATAVAILABLE and FORMATDATA attributes. (since 3.7)
    */
    public static void setFormat(string name)
    {
        setAttribute(IupAttributes.Format, name);
    }

    /**
    sets or retrieves the data from the clipboard in the format defined by the FORMAT 
    attribute. If FORMAT is not set returns NULL. If set to NULL clears the clipboard 
    data. When set the FORMATDATASIZE attribute must be set before with the data size. 
    When retrieved FORMATDATASIZE will be set and available after data is retrieved. (since 3.7)
    */
    @property 
	{ 
        public static void* formatData()
        {
            return gePointertAttribute(IupAttributes.FormatData);
        }

        public static void formatData(void* data)
        {
            setPointerAttribute(IupAttributes.FormatData, data);
        }
    }

    /**
    size of the data on the clipboard. Used by the FORMATDATA attribute processing. (since 3.7)
    */
    @property 
	{ 
        public static int formatDataSize()
        {
            return getIntAttribute(IupAttributes.FormatDataSize); 
        }

        public static void formatDataSize(int size)
        {
            setIntAttribute(IupAttributes.FormatDataSize, size);
        }
    }

    /**
    copy or paste text to or from the clipboard. If set to NULL clears the clipboard data.
    */
    @property 
	{
        public static string text()
        {
            return getAttribute(IupAttributes.Text);
        }

        public static void text(string text)
        {
            if(text.empty)
                setPointerAttribute(IupAttributes.Text, null);
            else
                setAttribute(IupAttributes.Text, text);
        }
    }


    /**
    native handle of an image to copy or paste, to or from the clipboard. In Win32 is a HANDLE of a DIB. In GTK is a GdkPixbuf*. 
    In Motif is a Pixmap. If set to NULL clears the clipboard data. The returned handle in a paste must be released after 
    used (GlobalFree(handle), g_object_unref(pixbuf) or XFreePixmap(display, pixmap)). After copy, do NOT release the given 
    handle. See IUP-IM Functions for utility functions on image native handles. (GTK 2.6)
    */
    public static ImImage getNativeImage()
    {
        im.c.image.imImage* imageHandle = IupGetNativeHandleImage(gePointertAttribute(IupAttributes.NativeImage));
        return  new ImImage(imageHandle);
    }

    /// ditto
    public static void setNativeImage(ImImage image)
    {
        setPointerAttribute(IupAttributes.NativeImage, IupGetImageNativeHandle(image.image));
    }


    version(Windows)
    {
        /// informs if there is a Windows Enhanced Metafile available at the clipboard. (Since 3.2)
		public static bool isEmfAvailable() { return cast(bool)getIntAttribute(IupAttributes.EmfAvailable); }

        /// informs if there is a Windows Metafile available at the clipboard. (Since 3.2)
		public static bool isWmfAvailable() { return cast(bool)getIntAttribute(IupAttributes.WmfAvailable); }

    }


    private static string getAttribute(string name) 
    {
        auto v = iup.c.api.IupGetAttribute(handle, std.string.toStringz(name));
        return std.string.fromStringz(v).idup;
        //return cast(string)std.string.fromStringz(v);
    }

    private static void* gePointertAttribute(string name) 
    {
        return cast(void*)iup.c.api.IupGetAttribute(handle, std.string.toStringz(name));
    }


    /**
    this function automatically creates a non conflict name and associates the name with the attribute.
    */
    private static setPointerAttribute(string name, void* value)
    {
        iup.c.api.IupSetAttribute(handle, std.string.toStringz(name), cast(char*)value);
    }

    /**
    this function automatically creates a non conflict name and associates the name with the attribute.
    */
    private static setAttribute(string name, string value)
    {
        iup.c.api.IupSetStrAttribute (handle, std.string.toStringz(name), std.string.toStringz(value));
    }

    /**
    */
    private static void setIntAttribute(string name, int v)
    {
        iup.c.api.IupSetInt(handle, std.string.toStringz(name), v);
    }

    private static int getIntAttribute(string name)
    {
        return iup.c.api.IupGetInt(handle, std.string.toStringz(name));
    }
}







// Summary:
//     Specifies the formats used with text-related methods of the System.Windows.Forms.Clipboard
//     and System.Windows.Forms.DataObject classes.
public enum TextFormat
{
    // Summary:
    //     Specifies the standard ANSI text format.
    Text = 0,
        //
        // Summary:
        //     Specifies the standard Windows Unicode text format.
        UnicodeText = 1,
        //
        // Summary:
        //     Specifies text consisting of rich text format (RTF) data.
        Rtf = 2,
        //
        // Summary:
        //     Specifies text consisting of HTML data.
        Html = 3,
        //
        // Summary:
        //     Specifies a comma-separated value (CSV) format, which is a common interchange
        //     format used by spreadsheets.
        CommaSeparatedValue = 4,
}
