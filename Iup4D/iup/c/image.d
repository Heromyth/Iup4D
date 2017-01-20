module iup.c.image;

import iup.c.core : Ihandle;
import im.c.image : imImage;

// libiupim.so depends on libim.so, (maybe image type specific .so like libpng12.so), libiup.so,...
version(DigitalMars) version(Windows) { pragma(lib, "iupim.lib"); } 

extern(C) @nogc nothrow 
{
    Ihandle* IupLoadImage(const(char)* file_name);
    int IupSaveImage(Ihandle* ih, const(char)* file_name, const(char)* format);
    Ihandle* IupLoadAnimation(const(char)* file_name);
    Ihandle* IupLoadAnimationFrames(const(char)** file_name_list, int file_count);

    imImage* IupGetNativeHandleImage(void* handle);       // in libiupim.so
    void* IupGetImageNativeHandle(const(imImage)* image); // in libiupim.so
    Ihandle* IupImageFromImImage(const(imImage)* image);  // in libiupim.so
}