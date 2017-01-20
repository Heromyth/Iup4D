module im.c.core;


version(DigitalMars) version(Windows) { pragma(lib, "im.lib"); }

import core.stdc.config : c_long;
import im.c.file : _imFile;

extern(C) nothrow {

      
/** \defgroup lib Library Management
 * \ingroup util 
 * \par
 * Usefull definitions for about dialogs and 
 * for comparing the compiled version with the linked version of the library.
 * \par
 * \verbatim im._AUTHOR [in Lua 5] \endverbatim
 * \verbatim im._COPYRIGHT [in Lua 5] \endverbatim
 * \verbatim im._VERSION [in Lua 5] \endverbatim
 * \verbatim im._VERSION_DATE [in Lua 5] \endverbatim
 * \verbatim im._VERSION_NUMBER [in Lua 5] \endverbatim
 * \verbatim im._DESCRIPTION [in Lua 5] \endverbatim
 * \verbatim im._NAME [in Lua 5] \endverbatim
 * \par
 * See \ref im_lib.h
 * @{
 */
enum IM_NAME = "IM - An Imaging Toolkit";
enum IM_DESCRIPTION =  "Toolkit for Image Representation, Storage, Capture and Processing";
enum IM_COPYRIGHT = "Copyright (C) 1994-2016 Tecgraf/PUC-Rio";
enum IM_AUTHOR = "Antonio Scuri";
enum IM_VERSION = "3.11";      /* bug fixes are reported only by imVersion functions */
enum IM_VERSION_NUMBER = 311000;
enum IM_VERSION_DATE = "2016/06/20";  /* does not include bug fix releases */
/** @} */


/** Returns the library current version. Returns the definition IM_VERSION plus the bug fix number.
 *
 * \verbatim im.Version() -> version: string [in Lua 5] \endverbatim
 * \ingroup lib */
const(char)* imVersion();

/** Returns the library current version release date. Returns the definition IM_VERSION_DATE.
 *
 * \verbatim im.VersionDate() -> date: string [in Lua 5] \endverbatim
 * \ingroup lib */
const(char)* imVersionDate();

/** Returns the library current version number. Returns the definition IM_VERSION_NUMBER plus the bug fix number. \n
 * Can be compared in run time with IM_VERSION_NUMBER to compare compiled and linked versions of the library.
 *
 * \verbatim im.VersionNumber() -> version: number [in Lua 5] \endverbatim
 * \ingroup lib */
int imVersionNumber();

template FreeEnumMembers(T) if (is(T == enum))
{
	mixin(()
          {
              string s;
              foreach (member; __traits(allMembers, T))
              {
                  s ~= "enum T " ~ member ~ " = T." ~ member ~ ";\x0a";
              }
              return s;
          }
          ());
}

/** Image data type descriptors. \n
* See also \ref datatypeutl.
* \ingroup imagerep */
enum imDataType
{
    IM_BYTE,   /**< "unsigned char". 1 byte from 0 to 255.                  */
    IM_SHORT,  /**< "short". 2 bytes from -32,768 to 32,767.                */
    IM_USHORT, /**< "unsigned short". 2 bytes from 0 to 65,535.             */
    IM_INT,    /**< "int". 4 bytes from -2,147,483,648 to 2,147,483,647.    */
    IM_FLOAT,  /**< "float". 4 bytes single precision IEEE floating point.  */
    IM_DOUBLE, /**< "double". 8 bytes double precision IEEE floating point. */
    IM_CFLOAT, /**< complex "float". 2 float values in sequence, real and imaginary parts.   */
    IM_CDOUBLE /**< complex "double". 2 double values in sequence, real and imaginary parts.   */
}
mixin FreeEnumMembers!imDataType;

/** Image color mode color space descriptors (first byte). \n
* See also \ref colormodeutl.
* \ingroup imagerep */
enum imColorSpace
{
    IM_RGB,    /**< Red, Green and Blue (nonlinear).              */
    IM_MAP,    /**< Indexed by RGB color map (data_type=IM_BYTE). */
    IM_GRAY,   /**< Shades of gray, luma (nonlinear Luminance), or an intensity value that is not related to color. */
    IM_BINARY, /**< Indexed by 2 colors: black (0) and white (1) (data_type=IM_BYTE).     */
    IM_CMYK,   /**< Cian, Magenta, Yellow and Black (nonlinear).                          */
    IM_YCBCR,  /**< ITU-R 601 Y'CbCr. Y' is luma (nonlinear Luminance).                   */
    IM_LAB,    /**< CIE L*a*b*. L* is Lightness (nonlinear Luminance, nearly perceptually uniform). */
    IM_LUV,    /**< CIE L*u*v*. L* is Lightness (nonlinear Luminance, nearly perceptually uniform). */
    IM_XYZ     /**< CIE XYZ. Linear Light Tristimulus, Y is linear Luminance.             */
}
mixin FreeEnumMembers!imColorSpace;

/** Image color mode configuration/extra descriptors (1 bit each in the second byte). \n
* See also \ref colormodeutl.
* \ingroup imagerep */
enum imColorModeConfig
{
    IM_ALPHA    = 0x100,  /**< adds an Alpha channel */
    IM_PACKED   = 0x200,  /**< packed components (rgbrgbrgb...) */
    IM_TOPDOWN  = 0x400   /**< orientation from top down to bottom */
}
mixin FreeEnumMembers!imColorModeConfig;


/** File Access Error Codes
* \par
* In Lua use im.ErrorStr(err) to convert the error number into a string.
* \ingroup file */
enum imErrorCodes
{
    IM_ERR_NONE,     /**< No error. */
    IM_ERR_OPEN,     /**< Error while opening the file (read or write). */
    IM_ERR_ACCESS,   /**< Error while accessing the file (read or write). */
    IM_ERR_FORMAT,   /**< Invalid or unrecognized file format. */
    IM_ERR_DATA,     /**< Invalid or unsupported data. */
    IM_ERR_COMPRESS, /**< Invalid or unsupported compression. */
    IM_ERR_MEM,      /**< Insufficient memory */
    IM_ERR_COUNTER   /**< Interrupted by the counter */
}
mixin FreeEnumMembers!imErrorCodes;

@nogc nothrow :

/** \brief Image File Structure (Private).
* \ingroup file */
//struct _imFile;
alias imFile = _imFile; // ATTENTION usage: im/im_format.h:21:class imFileFormatBase: public _imFile

/** Opens the file for reading. It must exists. Also reads file header.
* It will try to identify the file format.
* See also \ref imErrorCodes. \n
* In Lua the IM file metatable name is "imFile".
* When converted to a string will return "imFile(%p)" where %p is replaced by the userdata address.
* If the file is already closed by im.FileClose, then it will return also the suffix "-closed".
*
* \verbatim im.FileOpen(file_name: string) -> ifile: imFile, error: number [in Lua 5] \endverbatim
* \ingroup file */
imFile* imFileOpen(const(char)* file_name, int* error);

/** Opens the file for reading using a specific format. It must exists. Also reads file header.
* See also \ref imErrorCodes and \ref format.
*
* \verbatim im.FileOpenAs(file_name, format: string) -> ifile: imFile, error: number [in Lua 5] \endverbatim
* \ingroup file */
imFile* imFileOpenAs(const(char)* file_name, const(char)* format, int* error);

/** Creates a new file for writing using a specific format. If the file exists will be replaced. \n
* It will only initialize the format driver and create the file, no data is actually written.
* See also \ref imErrorCodes and \ref format.
*
* \verbatim im.FileNew(file_name: string, format: string) -> ifile: imFile, error: number [in Lua 5] \endverbatim
* \ingroup file */
imFile* imFileNew(const(char)* file_name, const(char)* format, int* error);

/** Closes the file. \n
* In Lua if this function is not called, the file is closed by the garbage collector.
*
* \verbatim im.FileClose(ifile: imFile) [in Lua 5] \endverbatim
* \verbatim ifile:Close() [in Lua 5] \endverbatim
* \ingroup file */
void imFileClose(imFile* ifile);

/** Returns an internal handle.
* index=0 returns always an imBinFile* handle,
* but for some formats returns NULL because they do not use imBinFile (like AVI and WMV).
* index=1 return an internal structure used by the format, usually is a handle
* to a third party library structure. This is file format dependent.
*
* \verbatim ifile:Handle() -> handle: userdata [in Lua 5] \endverbatim
* \ingroup file */
void* imFileHandle(imFile* ifile, int index);

/** Returns file information.
* image_count is the number of images in a stack or
* the number of frames in a video/animation or the depth of a volume data. \n
* compression and image_count can be NULL. \n
* These information are also available as attributes:
* \verbatim FileFormat (string) \endverbatim
* \verbatim FileCompression (string) \endverbatim
* \verbatim FileImageCount IM_INT (1) \endverbatim
* See also \ref format.
*
* \verbatim ifile:GetInfo() -> format: string, compression: string, image_count: number [in Lua 5] \endverbatim
* \ingroup file */
void imFileGetInfo(imFile* ifile, char* format, char* compression, int* image_count);

/** Changes the write compression method. \n
* If the compression is not supported will return an error code when writing. \n
* Use NULL to set the default compression. You can use the imFileGetInfo to retrieve the actual compression
* but only after \ref imFileWriteImageInfo. Only a few formats allow you to change the compression between frames.
*
* \verbatim ifile:SetInfo(compression: string) [in Lua 5] \endverbatim
* \ingroup file */
void imFileSetInfo(imFile* ifile, const(char)* compression);

/** Changes an extended attribute. \n
* The data will be internally duplicated. \n
* If data is NULL the attribute is removed.
* If data_type is BYTE then count can be -1 to indicate a NULL terminated string.
* See also \ref imDataType.
*
* \verbatim ifile:SetAttribute(attrib: string, data_type: number, data: table of numbers or string) [in Lua 5] \endverbatim
* If data_type is IM_BYTE, as_string can be used as data.
* \ingroup file */
void imFileSetAttribute(imFile* ifile, const(char)* attrib, int data_type, int count, const(void)* data);

/** Changes an extended attribute as an integer.
* \ingroup file */
void imFileSetAttribInteger(const(imFile)* ifile, const(char)* attrib, int data_type, int value);

/** Changes an extended attribute as a real.
* \ingroup file */
void imFileSetAttribReal(const(imFile)* ifile, const(char)* attrib, int data_type, double value);

/** Changes an extended attribute as a string.
* \ingroup file */
void imFileSetAttribString(const(imFile)* ifile, const(char)* attrib, const(char)* value);

/** Returns an extended attribute. \n
* Returns NULL if not found. data_type and count can be NULL.
* See also \ref imDataType.
*
* \verbatim ifile:GetAttribute(attrib: string, [as_string: boolean]) -> data: table of numbers or string, data_type: number [in Lua 5] \endverbatim
* If data_type is IM_BYTE, as_string can be used to return a string instead of a table.
* \verbatim ifile:GetAttributeRaw(attrib: string) -> data: userdata, data_type, count: number [in Lua 5] \endverbatim
* \ingroup file */
const(void)* imFileGetAttribute(imFile* ifile, const(char)* attrib, int* data_type, int* count);

/** Returns an extended attribute as an integer.
* \ingroup file */
int imFileGetAttribInteger(const(imFile)* ifile, const(char)* attrib, int index);

/** Returns an extended attribute as a real.
* \ingroup file */
double imFileGetAttribReal(const(imFile)* ifile, const(char)* attrib, int index);

/** Returns an extended attribute as a string.
* \ingroup file */
const(char)* imFileGetAttribString(const(imFile)* ifile, const(char)* attrib);

/** Returns a list of the attribute names. \n
* "attrib" must contain room enough for "attrib_count" names. Use "attrib=NULL" to return only the count.
*
* \verbatim ifile:GetAttributeList() -> data: table of strings [in Lua 5] \endverbatim
* \ingroup file */
void imFileGetAttributeList(imFile* ifile, char** attrib, int* attrib_count);

/** Returns the palette if any. \n
* "palette" must be a 256 colors allocated array. \n
* Returns zero in "palette_count" if there is no palette. "palette_count" is >0 and <=256.
*
* \verbatim ifile:GetPalette() -> palette: imPalette [in Lua 5] \endverbatim
* \ingroup file */
void imFileGetPalette(imFile* ifile, c_long* palette, int* palette_count);

/** Changes the pallete. \n
*  "palette_count" is >0 and <=256.
*
* \verbatim ifile:SetPalette(palette: imPalette) [in Lua 5] \endverbatim
* \ingroup file */
void imFileSetPalette(imFile* ifile, c_long* palette, int palette_count);

/** Reads the image header if any and returns image information. \n
* Reads also the extended image attributes, so other image attributes will be available only after calling this function. \n
* Returns an error code.
* index specifies the image number between 0 and image_count-1. \n
* Some drivers reads only in sequence, so "index" can be ignored by the format driver. \n
* Any parameters can be NULL. This function must be called at least once, check each format documentation.
* See also \ref imErrorCodes, \ref imDataType, \ref imColorSpace and \ref imColorModeConfig.
*
* \verbatim ifile:ReadImageInfo([index: number]) -> error: number, width: number, height: number, file_color_mode: number, file_data_type: number [in Lua 5] \endverbatim
* Default index is 0.
* \ingroup file */
int imFileReadImageInfo(imFile* ifile, int index, int* width, int* height, int* file_color_mode, int* file_data_type);

/** Writes the image header. Writes the file header at the first time it is called.
* Writes also the extended image attributes. \n
* Must call imFileSetPalette and set other attributes before calling this function. \n
* In some formats the color space will be converted to match file format specification. \n
* Returns an error code. This function must be called at least once, check each format documentation.
* See also \ref imErrorCodes, \ref imDataType, \ref imColorSpace and \ref imColorModeConfig.
*
* \verbatim ifile:WriteImageInfo(width: number, height: number, user_color_mode: number, user_data_type: number) -> error: number [in Lua 5] \endverbatim
* \ingroup file */
int imFileWriteImageInfo(imFile* ifile, int width, int height, int user_color_mode, int user_data_type);

/** Reads the image data with or without conversion. \n
* The data can be converted to bitmap when reading.
* Data type conversion to byte will always scan for min-max then scale to 0-255, 
* except integer values that min-max are already between 0-255. Complex to real conversions will use the magnitude. \n
* Color mode flags contains packed, alpha and top-bottom information.
* If flag is 0 means unpacked, no alpha and bottom up. If flag is -1 the file original flags are used. \n
* Returns an error code.
* See also \ref imErrorCodes, \ref imDataType, \ref imColorSpace and \ref imColorModeConfig.
*
* \verbatim ifile:ReadImageData(data: userdata, convert2bitmap: boolean, color_mode_flags: number) -> error: number [in Lua 5] \endverbatim
* \ingroup file */
int imFileReadImageData(imFile* ifile, void* data, int convert2bitmap, int color_mode_flags);

/** Writes the image data. \n
* Returns an error code.
*
* \verbatim ifile:WriteImageData(data: userdata) -> error: number [in Lua 5] \endverbatim
* \ingroup file */
int imFileWriteImageData(imFile* ifile, void* data);




/** Registers all the internal formats. \n
* It is automatically called internally when a format is accessed,
* but can be called to force the internal formats to be registered before other formats.
* Notice that additional formats when registered will be registered before the internal formats
* if imFormatRegisterInternal is not called yet. \n
* To control the register order is useful when two format drivers handle the same format.
* The first registered format will always be used first.
* \ingroup format */
void imFormatRegisterInternal();

/** Remove all registered formats. Call this if you are checking memory leaks.
* \ingroup format */
void imFormatRemoveAll();

/** Returns a list of the registered formats. \n
* format_list is an array of format identifiers.
* Each format identifier is 10 chars max, maximum of 50 formats.
* You can use "char* format_list[50]".
*
* \verbatim im.FormatList() -> format_list: table of strings [in Lua 5] \endverbatim
* \ingroup format */
void imFormatList(char** format_list, int* format_count);

/** Returns the format description. \n
* Format description is 50 chars max. \n
* Extensions are separated like "*.tif;*.tiff;", 50 chars max. \n
* Returns an error code. The parameters can be NULL, except format.
* See also \ref format.
*
* \verbatim im.FormatInfo(format: string) -> error: number, desc: string, ext: string, can_sequence: boolean [in Lua 5] \endverbatim
* \ingroup format */
int imFormatInfo(const(char)* format, char* desc, char* ext, int* can_sequence);

/** Returns the format information of the third party library used to support the format. \n
* Format extra is 50 chars max. \n
* Returns an error code.
* See also \ref format.
*
* \verbatim im.FormatInfoExtra(format: string) -> error: number, extra: string [in Lua 5] \endverbatim
* \ingroup format */
int imFormatInfoExtra(const(char)* format, char* extra);

/** Returns the format compressions. \n
* Compressions are 20 chars max each, maximum of 50 compressions. You can use "char* comp[50]". \n
* color_mode and data_type are optional, use -1 to ignore them. \n
* If you use them they will select only the allowed compressions checked like in \ref imFormatCanWriteImage. \n
* Returns an error code.
* See also \ref format, \ref imErrorCodes, \ref imDataType, \ref imColorSpace and \ref imColorModeConfig.
*
* \verbatim im.FormatCompressions(format: string, [color_mode: number], [data_type: number]) -> error: number, comp: table of strings [in Lua 5] \endverbatim
* \ingroup format */
int imFormatCompressions(const(char)* format, char** comp, int* comp_count, int color_mode, int data_type);

/** Checks if the format support the given image class at the given compression. \n
* Returns an error code.
* See also \ref format, \ref imErrorCodes, \ref imDataType, \ref imColorSpace and \ref imColorModeConfig.
*
* \verbatim im.FormatCanWriteImage(format: string, compression: string, color_mode: number, data_type: number) -> can_write: boolean [in Lua 5] \endverbatim
* \ingroup format */
int imFormatCanWriteImage(const(char)* format, const(char)* compression, int color_mode, int data_type);

} // extern(C) @nogc nothrow


/*! \mainpage IM
 * <CENTER>
 * <H3> Image Representation, Storage, Capture and Processing </H3>
 * Tecgraf: Computer Graphics Technology Group, PUC-Rio, Brazil \n
 * http://www.tecgraf.puc-rio.br/im \n
 * mailto:im@tecgraf.puc-rio.br
 * </CENTER>
 *
 * \section over Overview
 * \par
 * IM is a toolkit for Digital Imaging. 
 * \par
 * It provides support for image capture, several image file formats and many image processing operations. 
 * \par
 * Image representation includes scientific data types (like IEEE floating point data) 
 * and attributes (or metadata like GeoTIFF and Exif tags).
 * Animation, video and volumes are supported as image sequences, 
 * but there is no digital audio support.
 * \par
 * The main goal of the library is to provide a simple API and abstraction
 * of images for scientific applications.
 * \par
 * The toolkit API is written in C. 
 * The core library source code is implemented in C++ and it is very portable, 
 * it can be compiled in Windows and UNIX with no modifications. 
 * New image processing operations can be implemented in C or in C++.
 * \par
 * IM is free software, can be used for public and commercial applications.
 * \par
 * This work was developed at Tecgraf/PUC-Rio 
 * by means of the partnership with PETROBRAS/CENPES.
 *
 * \section author Author
 * \par
 * Antonio Scuri scuri@tecgraf.puc-rio.br
 *
 * \section copyright Copyright Notice
\verbatim

****************************************************************************
Copyright (C) 1994-2016 Tecgraf/PUC-Rio.                                
                                                                         
Permission is hereby granted, free of charge, to any person obtaining    
a copy of this software and associated documentation files (the          
"Software"), to deal in the Software without restriction, including      
without limitation the rights to use, copy, modify, merge, publish,      
distribute, sublicense, and/or sell copies of the Software, and to       
permit persons to whom the Software is furnished to do so, subject to    
the following conditions:                                                
                                                                         
The above copyright notice and this permission notice shall be           
included in all copies or substantial portions of the Software.          
                                                                         
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,          
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF       
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,     
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                   
****************************************************************************
\endverbatim
 */


/** \defgroup imagerep Image Representation
 * \par
 * See \ref im.h
 */


/** \defgroup file Image Storage
 * \par
 * See \ref im.h
 */


/** \defgroup format File Formats
 * \par
 * See \ref im.h
 *
 * Internal Predefined File Formats:
 * \li "BMP" - Windows Device Independent Bitmap
 * \li "GIF" - Graphics Interchange Format
 * \li "ICO" - Windows Icon 
 * \li "JPEG" - JPEG File Interchange Format
 * \li "LED" - IUP image in LED
 * \li "PCX" - ZSoft Picture
 * \li "PFM" - Portable FloatMap Image Format
 * \li "PNG" - Portable Network Graphic Format 
 * \li "PNM" - Netpbm Portable Image Map 
 * \li "RAS" - Sun Raster File
 * \li "RAW" - RAW File
 * \li "SGI" - Silicon Graphics Image File Format
 * \li "TGA" - Truevision Targa
 * \li "TIFF" - Tagged Image File Format
 *
 * Other Supported File Formats:
 * \li "JP2" - JPEG-2000 JP2 File Format 
 * \li "AVI" - Windows Audio-Video Interleaved RIFF
 * \li "WMV" -  Windows Media Video Format
 *          
 * Some Known Compressions:
 * \li "NONE" - No Compression.
 * \li "RLE"  - Run Lenght Encoding.
 * \li "LZW"  - Lempel, Ziff and Welsh.
 * \li "JPEG" - Join Photographics Experts Group.
 * \li "DEFLATE" - LZ77 variation (ZIP)
 *          
 * \ingroup file */

 
/* Library Names Convention
 *
 *   Global Functions and Types - "im[Object][Action]"  using first capitals (imFileOpen)
 *   Local Functions and Types  -  "i[Object][Action]"  using first capitals (iTIFFGetCompIndex)
 *   Local Static Variables - same as local functions and types (iFormatCount)
 *   Local Static Tables - same as local functions and types with "Table" suffix (iTIFFCompTable)
 *   Variables and Members - no prefix, all lower case (width)
 *   Defines and Enumerations - all capitals (IM_ERR_NONE)
 *
 */
