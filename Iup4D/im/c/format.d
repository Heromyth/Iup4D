/** \file
 * \brief All the Internal File Formats.
 * They are all automatically registered by the library.
 * The signatures are in C, but the functions are C++.
 * Header for internal use only.
 *
 * See Copyright Notice in im_lib.h
 */
module im.c.format;

//version(IM) :

version(DigitalMars) version(Windows) { pragma(lib, "im.lib"); }

extern(C) @nogc nothrow :

/** \defgroup tiff TIFF - Tagged Image File Format
 * \section Description
 *
 * \par
 * Copyright (c) 1986-1988, 1992 by Adobe Systems Incorporated. \n
 * Originally created by a group of companies,
 * the Aldus Corporation keeped the copyright until Aldus was aquired by Adobe. \n
 * TIFF Revision 6.0 Final  June 3, 1992 \n
 * http://www.adobe.com/Support/TechNotes.html
 * \par
 * Access to the TIFF file format uses libTIFF version 4.0.3 \n
 * http://www.remotesensing.org/libtiff/                     \n
 * Copyright (c) 1988-1997 Sam Leffler                      \n
 * Copyright (c) 1991-1997 Silicon Graphics, Inc.           \n
 *
 * \section Features
 *
\verbatim
    Data Types: <all>
    Color Spaces: Gray, RGB, CMYK, YCbCr, Lab, XYZ, Map and Binary.
    Compressions:
      NONE - no compression  [default for IEEE Floating Point Data]
      CCITTRLE - CCITT modified Huffman RLE (binary only) [default for Binary]
      CCITTFAX3 - CCITT Group 3 fax         (binary only)
      CCITTFAX4 - CCITT Group 4 fax         (binary only)
      LZW - Lempel-Ziv & Welch  [default]
      JPEG - ISO JPEG    [default for YCBCR]
      NEXT - NeXT 2-bit RLE (2 bpp only)
      CCITTRLEW - CCITT modified Huffman RLE with word alignment (binary only)
      RLE - Packbits (Macintosh RLE) [default for MAP]
      THUNDERSCAN - ThunderScan 4-bit RLE (only for 2 or 4 bpp)
      PIXARLOG - Pixar companded 11-bit ZIP (only byte, ushort and float)
      DEFLATE - LZ77 variation (ZIP)
      ADOBE_DEFLATE - Adobe LZ77 variation
      SGILOG - SGI Log Luminance RLE for L and Luv (only byte, ushort and float) [default for XYZ]
      SGILOG24 - SGI Log 24-bit packed for Luv (only byte, ushort and float)
    Can have more than one image.
    Can have an alpha channel.
    Components can be packed or not.
    Lines arranged from top down to bottom or bottom up to top.
    Handle(1) returns a TIFF* libTIFF structure.

    Attributes:
      Photometric IM_USHORT (1) (when writing this will complement the color_mode information, for Mask, MinIsWhite, ITULab and ICCLab)
      ExtraSampleInfo IM_USHORT (1) (description of alpha channel: 0- uknown, 1- pre-multiplied, 2-normal)
      JPEGQuality IM_INT (1) [0-100, default 75] (write only)
      ZIPQuality IM_INT (1) [1-9, default 6] (write only)
      ResolutionUnit (string) ["DPC", "DPI"]
      XResolution, YResolution IM_FLOAT (1)
      Description, Author, Copyright, DateTime, DocumentName,
      PageName, TargetPrinter, Make, Model, Software, HostComputer (string)
      InkNames (strings separated by '0's)
      InkSet IM_USHORT (1)
      NumberOfInks IM_USHORT (1)
      DotRange IM_USHORT (2)
      TransferFunction0, TransferFunction1, TransferFunction3 IM_USHORT [gray=0, rgb=012]
      ReferenceBlackWhite IMFLOAT (6)
      WhitePoint IMFLOAT (2)
      PrimaryChromaticities  IMFLOAT (6)
      YCbCrCoefficients IM_FLOAT (3)
      YCbCrSubSampling IM_USHORT (2)
      YCbCrPositioning IM_USHORT (1)
      PageNumber IM_USHORT (2)
      StoNits IM_DOUBLE (1)
      XPosition, YPosition IM_FLOAT (1)
      SMinSampleValue, SMaxSampleValue IM_FLOAT (1)
      HalftoneHints IM_USHORT (2)
      SubfileType IM_INT (1)
      ICCProfile IM_BYTE (N)
      MultiBandCount IM_USHORT (1)    [Number of bands in a multiband gray image.]
      MultiBandSelect IM_USHORT (1)   [Band number to read one band of a multiband gray image. Must be set before reading image info.]
      and other TIFF tags as they are described in the TIFF documentation.
      GeoTIFF tags:
        GeoTiePoints, GeoTransformationMatrix, "Intergraph TransformationMatrix", GeoPixelScale, GeoDoubleParams IM_DOUBLE (N)
        GeoASCIIParams (string)
      Read-only support for EXIF tags as they are described in the EXIF 2.2 documentation. See http://www.exif.org/
      DNG tags as they are described in the DNG documentation. See http://www.adobe.com/br/products/dng/
        Tags BlackLevel, DefaultCropOrigin and DefaultCropSize are incorrectly interpreted by libTIFF so they are ignored.
        Raw image is loaded in place of the thumbnail image in the main IFD.
        SubIFDCount IM_USHORT (1)    [Number of subifds of the current image.]
        SubIFDSelect IM_USHORT (1)   [Subifd number to be read. Must be set before reading image info.]
      (other attributes can be obtained by using libTIFF directly using the Handle(1) function)

    Comments:
      LogLuv is in fact Y'+CIE(u,v), so we choose to always convert it to XYZ.
      SubIFD is handled only for DNG.
      Since LZW patent expired, LZW compression is enabled. LZW Copyright Unisys.
      libGeoTIFF can be used without XTIFF initialization. Use Handle(1) to obtain a TIFF*.

    Changes:
      "tiff_jpeg.c" - commented "downsampled_output = TRUE" and downsampled_input = TRUE.
      "tiff_fax3.c" - replaced "inline" by "INLINE"
      "tif_strip.c" - fixed scanline_size
      New files "tif_config.h" and "tifconf.h" to match our needs.
      New file "tiff_binfile.c" that implement I/O rotines using imBinFile.
      Search for "IMLIB" to see the changes.
\endverbatim
 * \ingroup format */
void imFormatRegisterTIFF();


/** \defgroup jpeg JPEG - JPEG File Interchange Format
 * \section Description
 *
 * \par
 * ISO/IEC 10918 (1994, 1995, 1997, 1999)\n
 * http://www.jpeg.org/
 * \par
 * Access to the JPEG file format uses libjpeg version 8c. \n
 * http://www.ijg.org                                      \n
 * Copyright (C) 1994-2011, Thomas G. Lane, Guido Vollbeding  \n
 *   from the Independent JPEG Group.
 * \par
 * Access to the EXIF attributes uses libEXIF version 0.6.20. \n
 * http://sourceforge.net/projects/libexif                    \n
 * Copyright (C) 2001-2010, Lutz Müller
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: Gray, RGB, CMYK and YCbCr (Binary Saved as Gray)
    Compressions:
      JPEG - ISO JPEG  [default]
    Only one image.
    No alpha channel.
    Internally the components are always packed.
    Internally the lines are arranged from top down to bottom.
    Handle(1) returns jpeg_decompress_struct* when reading, and
                      jpeg_compress_struct* when writing (libJPEG structures).

    Attributes:
      AutoYCbCr IM_INT (1) (controls YCbCr auto conversion) default 1
      JPEGQuality IM_INT (1) [0-100, default 75] (write only)
      ResolutionUnit (string) ["DPC", "DPI"]
      XResolution, YResolution IM_FLOAT (1)
      Interlaced (same as Progressive) IM_INT (1 | 0) default 0
      Description (string)
      (lots of Exif tags)

    Changes to libJPEG:
      jdatadst.c - fflush and ferror replaced by macros JFFLUSH and JFERROR.
      jinclude.h - standard JFFLUSH and JFERROR definitions, and new macro HAVE_JFIO.
      new file created: jconfig.h from jconfig.txt

    Changes to libEXIF:
      new files config.h and _stdint.h
      small fixes in exif-entry.c, exif-loader.c, exif-tag.c, mnote-fuji-tag.h and mnote-olympus-tag.h

    Comments:
      Other APPx markers are ignored.
      No thumbnail support.
      RGB images are automatically converted to YCbCr when saved.
      Also YcbCr are automatically converted to RGB when loaded. Use AutoYCbCr=0 to disable this behavior.
\endverbatim
 * \ingroup format */
void imFormatRegisterJPEG();


/** \defgroup png PNG - Portable Network Graphic Format
 * \section Description
 *
 * \par
 * Access to the PNG file format uses libpng version 1.6.23. \n
 * http://www.libpng.org                                    \n
 * Copyright (c) 2000-2002, 2004, 2006-2015 Glenn Randers-Pehrson
 *
 * \section Features
 *
\verbatim
    Data Types: Byte and UShort
    Color Spaces: Gray, RGB, MAP and Binary
    Compressions:
      DEFLATE - LZ77 variation (ZIP) [default]
    Only one image.
    Can have an alpha channel.
    Internally the components are always packed.
    Internally the lines are arranged from top down to bottom.
    Handle(1) returns png_structp libPNG structure.

    Attributes:
      ZIPQuality IM_INT (1) [1-9, default 6] (write only)
      ResolutionUnit (string) ["DPC", "DPI"]
      XResolution, YResolution IM_FLOAT (1)
      Interlaced (same as Progressive) IM_INT (1 | 0) default 0
      Gamma IM_FLOAT (1)
      WhitePoint IMFLOAT (2)
      PrimaryChromaticities  IMFLOAT (6)
      XPosition, YPosition IM_FLOAT (1)
      sRGBIntent IM_INT (1) [0: Perceptual, 1: Relative colorimetric, 2: Saturation, 3: Absolute colorimetric]
      TransparencyMap IM_BYTE (N) (for MAP images is the alpha value of the corresponding palette index)
      TransparencyIndex IM_BYTE (1) (for MAP images is the first index that has minimum alpha in TransparencyMap, for GRAY images is the index that it is fully transparent)
      TransparencyColor IM_BYTE (3) (for RGB images is the color that is full transparent)
      CalibrationName, CalibrationUnits (string)
      CalibrationLimits IM_INT (2)
      CalibrationEquation IM_BYTE (1) [0-Linear,1-Exponential,2-Arbitrary,3-HyperbolicSine)]
      CalibrationParam (string) [params separated by '\\n']
      Title, Author, Description, Copyright, DateTime (string)
      Software, Disclaimer, Warning, Source, Comment, ...       (string)
      DateTimeModified (string) [when writing uses the current system time]
      ICCProfile IM_BYTE (N)
      ScaleUnit (string) ["meters", "radians"]
      XScale, YScale IM_FLOAT (1)

    Comments:
      When saving PNG image with TransparencyIndex or TransparencyMap, TransparencyMap has precedence, 
        so set it to NULL if you changed TransparencyIndex.
      Attributes set after the image are ignored.
\endverbatim
 * \ingroup format */
void imFormatRegisterPNG();


/** \defgroup gif GIF - Graphics Interchange Format
 * \section Description
 *
 * \par
 * Copyright (c) 1987,1988,1989,1990 CompuServe Incorporated. \n
 * GIF is a Service Mark property of CompuServe Incorporated. \n
 * Graphics Interchange Format Programming Reference, 1990. \n
 * LZW Copyright Unisys.
 * \par
 * Patial Internal Implementation. \n
 * Decoding and encoding code were extracted from GIFLib 1.0. \n
 * Copyright (c) 1989 Gershon Elber.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: MAP only, (Gray and Binary saved as MAP)
    Compressions:
      LZW - Lempel-Ziv & Welch      [default]
    Can have more than one image.
    No alpha channel.
    Internally the lines are arranged from top down to bottom.

    Attributes:
      ScreenHeight, ScreenWidth IM_USHORT (1) screen size [default to the first image size]
      Interlaced IM_INT (1 | 0) default 0
      Description (string)
      TransparencyIndex IM_BYTE (1)
      XScreen, YScreen IM_USHORT (1) screen position
      UserInput IM_BYTE (1) [1, 0]
      Disposal (string) [UNDEF, LEAVE, RBACK, RPREV]
      Delay IM_USHORT (1) [time to wait betweed frames in 1/100 of a second]
      Iterations IM_USHORT (1) (NETSCAPE2.0 Application Extension) [The number of times to repeat the animation. 0 means to repeat forever. ]

    Comments:
      Attributes after the last image are ignored.
      Reads GIF87 and GIF89, but writes GIF89 always.
      Ignored attributes: Background Color Index, Pixel Aspect Ratio,
                          Plain Text Extensions, Application Extensions...
\endverbatim
 * \ingroup format */
void imFormatRegisterGIF();


/** \defgroup bmp BMP - Windows Device Independent Bitmap
 * \section Description
 *
 * \par
 * Windows Copyright Microsoft Corporation.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: RGB, MAP and Binary (Gray saved as MAP)
    Compressions:
      NONE - no compression [default]
      RLE  - Run Lenght Encoding (only for MAP and Gray)
    Only one image.
    Can have an alpha channel (only for RGB)
    Internally the components are always packed.
    Lines arranged from top down to bottom or bottom up to top. But are saved always as bottom up.

    Attributes:
      ResolutionUnit (string) ["DPC", "DPI"]
      XResolution, YResolution IM_FLOAT (1)

    Comments:
      Reads OS2 1.x and Windows 3, but writes Windows 3 always.
      Version 4 and 5 BMPs are not supported.
\endverbatim
 * \ingroup format */
void imFormatRegisterBMP();


/** \defgroup ras RAS - Sun Raster File
 * \section Description
 *
 * \par
 * Copyright Sun Corporation.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: Gray, RGB, MAP and Binary
    Compressions:
      NONE - no compression   [default]
      RLE  - Run Lenght Encoding
    Only one image.
    Can have an alpha channel (only for IM_RGB)
    Internally the components are always packed.
    Internally the lines are arranged from top down to bottom.

    Attributes:
      none
\endverbatim
 * \ingroup format */
void imFormatRegisterRAS();


/** \defgroup led LED - IUP image in LED
 * \section Description
 *
 * \par
 * Copyright Tecgraf/PUC-Rio and PETROBRAS/CENPES.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: MAP only (Gray and Binary saved as MAP)
    Compressions:
      NONE - no compression  [default]
    Only one image.
    No alpha channel.
    Internally the lines are arranged from top down to bottom.

    Attributes:
      none

    Comments:
      LED file must start with "LEDImage = IMAGE[".
\endverbatim
 * \ingroup format */
void imFormatRegisterLED();


/** \defgroup sgi SGI - Silicon Graphics Image File Format
 * \section Description
 *
 * \par
 * SGI is a trademark of Silicon Graphics, Inc.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte and UShort
    Color Spaces: Gray and RGB (Binary saved as Gray, MAP with fixed palette when reading only)
    Compressions:
      NONE - no compression  [default]
      RLE  - Run Lenght Encoding
    Only one image.
    Can have an alpha channel (only for IM_RGB)
    Internally the components are always packed.
    Internally the lines are arranged from bottom up to top.

    Attributes:
      Description (string)
\endverbatim
 * \ingroup format */
void imFormatRegisterSGI();


/** \defgroup pcx PCX - ZSoft Picture
 * \section Description
 *
 * \par
 * Copyright ZSoft Corporation. \n
 * ZSoft (1988) PCX Technical Reference Manual.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: RGB, MAP and Binary (Gray saved as MAP)
    Compressions:
      NONE - no compression
      RLE  - Run Lenght Encoding [default - since uncompressed PCX is not well supported]
    Only one image.
    No alpha channel.
    Internally the components are always packed.
    Internally the lines are arranged from top down to bottom.

    Attributes:
      ResolutionUnit (string) ["DPC", "DPI"]
      XResolution, YResolution IM_FLOAT (1)
      XScreen, YScreen IM_USHORT (1) screen position

    Comments:
      Reads Versions 0-5, but writes Version 5 always.
\endverbatim
 * \ingroup format */
void imFormatRegisterPCX();


/** \defgroup tga TGA - Truevision Graphics Adapter File
 * \section Description
 *
 * \par
 * Truevision TGA File Format Specification Version 2.0 \n
 * Technical Manual Version 2.2 January, 1991           \n
 * Copyright 1989, 1990, 1991 Truevision, Inc.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: Gray, RGB and MAP (Binary saved as Gray)
    Compressions:
      NONE - no compression [default]
      RLE  - Run Lenght Encoding
    Only one image.
    Can have an alpha channel (only for RGB)
    Internally the components are always packed.
    Internally the lines are arranged from bottom up to top or from top down to bottom.

    Attributes:
      XScreen, YScreen IM_USHORT (1) screen position
      Title, Author, Description, JobName, Software (string)
      SoftwareVersion (read only) (string)
      DateTimeModified (string) [when writing uses the current system time]
      Gamma IM_FLOAT (1)
\endverbatim
 * \ingroup format */
void imFormatRegisterTGA();


/** \defgroup pnm PNM - Netpbm Portable Image Map
 * \section Description
 *
 * \par
 * PNM formats Copyright Jef Poskanzer
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte and UShort
    Color Spaces: Gray, RGB and Binary
    Compressions:
      NONE - no compression [default]
      ASCII (textual data)
    Can have more than one image, but sequencial access only.
    No alpha channel.
    Internally the components are always packed.
    Internally the lines are arranged from top down to bottom.

    Attributes:
      Description (string)

    Comments:
      In fact ASCII is an expansion, not a compression, because the file will be larger than binary data.
\endverbatim
 * \ingroup format */
void imFormatRegisterPNM();


/** \defgroup pfm PFM - Portable FloatMap Image Format
* \section Description
*
* \par
* Internal Implementation.
*
* \section Features
*
\verbatim
Data Types: Float
Color Spaces: Gray and RGB
Compressions:
  NONE - no compression [default]

No alpha channel.
Internally the components are always packed.
Internally the lines are arranged from bottom to top.

\endverbatim
* \ingroup format */
void imFormatRegisterPFM();


/** \defgroup ico ICO - Windows Icon
 * \section Description
 *
 * \par
 * Windows Copyright Microsoft Corporation.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Byte
    Color Spaces: RGB, MAP and Binary (Gray saved as MAP)
    Compressions:
      NONE - no compression [default]
    Can have more than one image. But reading and writing is limited to 10 images max,
      and all images must have different sizes and bpp.
    Can have an alpha channel (only for RGB)
    Internally the components are always packed.
    Internally the lines are arranged from bottom up to top.

    Attributes:
      TransparencyIndex IM_BYTE (1)

    Comments:
      If the user specifies an alpha channel, the AND mask is loaded as alpha if
        the file color mode does not contain the IM_ALPHA flag.
      For MAP imagens, if the user does not specifies an alpha channel
        the TransparencyIndex is used to initialize the AND mask when writing,
        and if the user does specifies an alpha channel
        the most repeated index with transparency will be the transparent index.
      Although any size and common bpp can be used is recomended to use the typical configurations:
        16x16, 32x32, 48x48, 64x64 or 96x96
        2 colors, 16 colors, 256 colors, 24bpp or 32bpp
\endverbatim
 * \ingroup format */
void imFormatRegisterICO();


/** \defgroup krn KRN - IM Kernel File Format
 * \section Description
 *
 * \par
 * Textual format to provied a simple way to create kernel convolution images.
 * \par
 * Internal Implementation.
 *
 * \section Features
 *
\verbatim
    Data Types: Int, Float
    Color Spaces: Gray
    Compressions:
      NONE - no compression [default]
    Only one image.
    No alpha channel.
    Internally the lines are arranged from top down to bottom.

    Attributes:
      Description (string)

    Comments:
      The format is very simple, inspired by PNM.
      It was developed because PNM does not have support for INT and FLOAT.
      Remeber that usually convolution operations use kernel size an odd number.

    Format Model:
      IMKERNEL
      Description up to 512 characters
      width height
      type (0 - IM_INT, 1 - IM_FLOAT)
      data...

    Example:
      IMKERNEL
      Gradian
      3 3
      0
      0 -1 0
      0  1 0
      0  0 0
\endverbatim
 * \ingroup format */
void imFormatRegisterKRN();


/** \defgroup avi AVI - Windows Audio-Video Interleaved RIFF
* \section Description
* 
* \par
* Windows Copyright Microsoft Corporation.
* \par
* Access to the AVI format uses Windows AVIFile library. Available in Windows Only. \n
* When writing a new file you must use an ".avi" extension, or the Windows API will fail. \n
* You must link the application with "im_avi.lib" 
* and you must call the function \ref imFormatRegisterAVI once 
* to register the format into the IM core library. 
* In Lua call require"imlua_avi". \n
* Depends also on the VFW library (vfw32.lib).
* When using the "im_avi.dll" this extra library is not necessary. \n
* If using Cygwin or MingW must link with "-lvfw32". 
* Old versions of Cygwin and MingW use the "-lvfw_ms32" and "-lvfw_avi32".
* \par
* See \ref im_format_avi.h
*
* \section Features
*
\verbatim
Data Types: Byte
Color Spaces: RGB, MAP and Binary (Gray saved as MAP)
Compressions (installed in Windows XP by default):
NONE     - no compression [default]
RLE      - Microsoft RLE (8bpp only)
CINEPACK - Cinepak Codec by Radius
MSVC     - Microsoft Video 1 (old)  (8bpp and 16bpp only)
M261     - Microsoft H.261 Video Codec
M263     - Microsoft H.263 Video Codec
I420     - Intel 4:2:0 Video Codec (same as M263)
IV32     - Intel Indeo Video Codec 3.2 (old)
IV41     - Intel Indeo Video Codec 4.5 (old)
IV50     - Intel Indeo Video 5.1
IYUV     - Intel IYUV Codec
MPG4     - Microsoft MPEG-4 Video Codec V1 (not MPEG-4 compliant) (old)
MP42     - Microsoft MPEG-4 Video Codec V2 (not MPEG-4 compliant)
CUSTOM   - (show compression dialog)
DIVX     - DivX 5.0.4 Codec (DivX must be installed)
(others, must be the 4 charaters of the fourfcc code)
Can have more than one image. 
Can have an alpha channel (only for RGB)
Internally the components are always packed.
Lines arranged from top down to bottom or bottom up to top. But are saved always as bottom up.
Handle(0) returns NULL. imBinFile is not supported.
Handle(1) returns PAVIFILE.
Handle(2) returns PAVISTREAM.

Attributes:
FPS IM_FLOAT (1) (should set when writing, default 15)
AVIQuality IM_INT (1) [1-10000, default -1] (write only) [unsed if compression=CUSTOM]
KeyFrameRate IM_INT (1) (write only) [key frame frequency, if 0 not using key frames, default 15, unsed if compression=CUSTOM]
DataRate IM_INT (1) (write only) [kilobits/second, default 2400, unsed if compression=CUSTOM]

Comments:
Reads only the first video stream. Other streams are ignored.
All the images have the same size, you must call imFileReadImageInfo/imFileWriteImageInfo 
at least once.
For codecs comparsion and download go to:
http://graphics.lcs.mit.edu/~tbuehler/video/codecs/
http://www.fourcc.org
\endverbatim
* \ingroup format */

/** Register the AVI Format. \n
* In Lua, when using require"imlua_avi" this function will be automatically called.
* \ingroup avi */
void imFormatRegisterAVI();

/** \defgroup ecw ECW - ECW JPEG 2000
* \section Description
* 
* \par
* ECW JPEG 2000 Copyright 1998 Earth Resource Mapping Ltd.
* Two formats are supported with this module. The ECW (Enhanced Compression Wavelet) format and the ISO JPEG 2000 format.
* \par
* Access to the ECW format uses the ECW JPEG 2000 SDK version 3.3. 
* Available in Windows, Linux and Solaris Only. But source code is also available. \n
* You must link the application with "im_ecw.lib" 
* and you must call the function \ref imFormatRegisterECW once 
* to register the format into the IM core library. \n
* Depends also on the ECW JPEG 2000 SDK libraries (NCSEcw.lib).
* \par
* When using other JPEG 2000 libraries the first registered library will be used to guess the file format. 
* Use the extension *.ecw to shortcut to this implementation of the JPEG 2000 format.
* \par
* See \ref im_format_ecw.h
* \par
* \par
* http://www.ermapper.com/ecw/ \n
* The three types of licenses available for the ECW JPEG 2000 SDK are as follows:
\verbatim
- ECW JPEG 2000 SDK Free Use License Agreement - This license governs the free use of
the ECW JPEG 2000 SDK with Unlimited Decompression and Limited Compression (Less
than 500MB).
- ECW JPEG 2000 SDK Public Use License Agreement - This license governs the use of the
ECW SDK with Unlimited Decompression and Unlimited Compression for applications
licensed under a GNU General Public style license.
- ECW JPEG 2000 SDK Commercial Use License Agreement - This license governs the use
of the ECW JPEG 2000 SDK with Unlimited Decompression and Unlimited Compression
for commercial applications.
\endverbatim
* 
* \section Features
*
\verbatim
Data Types: Byte, Short, UShort, Float
Color Spaces: BINARY, GRAY, RGB, YCBCR
Compressions:
ECW - Enhanced Compression Wavelet
JPEG-2000 - ISO JPEG 2000  
Only one image.
Can have an alpha channel
Internally the components are always packed.
Lines arranged from top down to bottom.
Handle() returns NCSFileView* when reading, NCSEcwCompressClient* when writing.

Attributes:
CompressionRatio   IM_FLOAT (1) [example: Ratio=7 just like 7:1]
OriginX, OriginY   IM_FLOAT (1)
Rotation           IM_FLOAT (1)
CellIncrementX, CellIncrementY    IM_FLOAT (1)
CellUnits (string)
Datum (string)
Projection (string)
ViewWidth, ViewHeight                    IM_INT (1)    [view zoom]
ViewXmin, ViewYmin, ViewXmax, ViewYmax   IM_INT (1)    [view limits]
MultiBandCount IM_USHORT (1)    [Number of bands in a multiband gray image.]
MultiBandSelect IM_USHORT (1)   [Band number to read one band of a multiband gray image. Must be set before reading image info.]

Comments:
Only read support is implemented.
To read a region of the image you must set the View* attributes before reading the image data.
After reading a partial image the width and height returned in ReadImageInfo is the view size.
The view limits define the region to be read. 
The view size is the actual size of the image, so the result can be zoomed.
\endverbatim
* \ingroup format */

/** Register the ECW Format 
* \ingroup ecw */
void imFormatRegisterECW();

/** \defgroup jp2 JP2 - JPEG-2000 JP2 File Format
* \section Description
* 
* \par
* ISO/IEC 15444 (2000, 2003)\n
* http://www.jpeg.org/
* \par
* You must link the application with "im_jp2.lib" 
* and you must call the function \ref imFormatRegisterJP2 once 
* to register the format into the IM core library. 
* In Lua call require"imlua_jp2". \n
* \par
* Access to the JPEG2000 file format uses libJasper version 1.900.1 \n
* http://www.ece.uvic.ca/~mdadams/jasper                             \n
* Copyright (c) 2001-2006 Michael David Adams.                       \n
* and GeoJasPer 1.4.0                                                \n
* Copyright (c) 2003-2007 Dmitry V. Fedorov.                         \n
* http://www.dimin.net/software/geojasper/                           \n
* 
* \par
* See \ref im_format_jp2.h
*
* \section Features
*
\verbatim
Data Types: Byte and UShort
Color Spaces: Binary, Gray, RGB, YCbCr, Lab and XYZ
Compressions: 
JPEG-2000 - ISO JPEG 2000  [default]
Only one image.
Can have an alpha channel.
Internally the components are always unpacked.
Internally the lines are arranged from top down to bottom.
Handle(1) returns jas_image_t*
Handle(2) returns jas_stream_t*

Attributes:
CompressionRatio IM_FLOAT (1) [write only, example: Ratio=7 just like 7:1]
GeoTIFFBox IM_BYTE (n)
XMLPacket IM_BYTE (n)

Comments:
We read code stream syntax and JP2, but we write always as JP2.
Used definitions EXCLUDE_JPG_SUPPORT,EXCLUDE_MIF_SUPPORT,
EXCLUDE_PNM_SUPPORT,EXCLUDE_RAS_SUPPORT,
EXCLUDE_BMP_SUPPORT,EXCLUDE_PGX_SUPPORT
Changed jas_config.h to match our needs.
New file jas_binfile.c
Changed base/jas_stream.c to export jas_stream_create and jas_stream_initbuf.
Changed jp2/jp2_dec.c and jpc/jpc_cs.c to remove "uint" and "ulong" usage.
The counter is restarted many times, because it has many phases.
\endverbatim
* \ingroup format */

/** Register the JP2 Format. \n
* In Lua, when using require"imlua_jp2" this function will be automatically called.
* \ingroup jp2 */
void imFormatRegisterJP2();


struct imFormat; // ATTENTION  im/im_format.h:48:class imFormat

/** \defgroup raw RAW - RAW File
* 
* \par
* The file must be open/created with the functions \ref imFileOpenRaw and \ref imFileNewRaw.
* 
* \section Description
* 
* \par
* Internal Implementation.
* \par
* Supports RAW binary images. This is an unstructured and uncompressed binary data. 
* It is NOT a Camera RAW file generated in many professional digital cameras. \n
* You must know image parameters a priori and must set the IM_INT attributes "Width", "Height", "ColorMode", "DataType" 
* before the imFileReadImageInfo/imFileWriteImageInfo functions.
* \par
* The data must be in binary form, but can start in an arbitrary offset from the begining of the file, use attribute "StartOffset".
* The default is at 0 offset. 
* \par
* Integer sign and double precision can be converted using attribute "SwitchType". \n
* The conversions will be BYTE<->CHAR, USHORT<->SHORT, INT<->UINT, FLOAT<->DOUBLE.
* \par
* Byte Order can be Little Endian (Intel=1) or Big Endian (Motorola=0), use the attribute "ByteOrder", the default is the current CPU.
* \par
* The lines can be aligned to a BYTE (1), WORD (2) or DWORD (4) boundaries, ue attribute "Padding" with the respective value.
* \par
* If the compression is ASCII the data is stored in textual format, instead of binary. 
* In this case SwitchType and ByteOrder are ignored, and Padding should be 0.
* \par
* When reading, if data type is BYTE, color space is RGB and data is packed, then the attribute "RGB16" is consulted. 
* It can has values "555" or "565" indicating a packed 16 bits RGB pixel is stored with the given bit distribution for R, G and B.
* \par
* See \ref im_raw.h
* 
* \section Features
*
\verbatim
Data Types: <all>
Color Spaces: all, except MAP.
Compressions: 
NONE - no compression [default] 
ASCII (textual data)
Can have more than one image, depends on "StartOffset" attribute.
Can have an alpha channel.
Components can be packed or not.
Lines arranged from top down to bottom or bottom up to top.

Attributes:
Width, Height, ColorMode, DataType IM_INT (1)
ImageCount[1], StartOffset[0], SwitchType[FALSE], ByteOrder[IM_LITTLEENDIAN], Padding[0]  IM_INT (1)

Comments:
In fact ASCII is an expansion, not a compression, because the file will be larger than binary data.
\endverbatim
* \ingroup format */
imFormat* imFormatInitRAW();

void imFormatFinishRAW();

/** \defgroup wmv WMV - Windows Media Video Format
* \section Description
* 
* \par
* Advanced Systems Format (ASF) \n
* Windows Copyright Microsoft Corporation.
* \par
* Access to the WMV format uses Windows Media SDK. Available in Windows Only. \n
* You must link the application with "im_wmv.lib" 
* and you must call the function \ref imFormatRegisterWMV once 
* to register the format into the IM core library. 
* In Lua call require"imlua_wmv". \n
* Depends also on the WMF SDK (wmvcore.lib).
* When using the "im_wmv.dll" this extra library is not necessary.
* \par
* The application users should have the WMV codec 9 installed:
* http://www.microsoft.com/windows/windowsmedia/format/codecdownload.aspx
* \par
* You must agree with the WMF SDK EULA to use the SDK. \n
* http://wmlicense.smdisp.net/v9sdk/
* \par
* For more information: \n
* http://www.microsoft.com/windows/windowsmedia/9series/sdk.aspx \n
* http://msdn.microsoft.com/library/en-us/wmform/htm/introducingwindowsmediaformat.asp 
* \par
* See \ref im_format_wmv.h
* 
* \section Features
*
\verbatim
Data Types: Byte
Color Spaces: RGB and MAP (Gray and Binary saved as MAP)
Compressions (installed in Windows XP by default):
NONE       - no compression
MPEG-4v3   - Windows Media MPEG-4 Video V3
MPEG-4v1   - ISO MPEG-4 Video V1
WMV7       - Windows Media Video  V7
WMV7Screen - Windows Media Screen V7
WMV8       - Windows Media Video  V8
WMV9Screen - Windows Media Video 9 Screen
WMV9       - Windows Media Video 9 [default]
Unknown    - Others
Can have more than one image. 
Can have an alpha channel (only for RGB) ?
Internally the components are always packed.
Lines arranged from top down to bottom or bottom up to top.
Handle(0) return NULL. imBinFile is not supported.
Handle(1) returns IWMSyncReader* when reading, IWMWriter* when writing.

Attributes:
FPS IM_FLOAT (1) (should set when writing, default 15)
WMFQuality IM_INT (1) [0-100, default 50] (write only)
MaxKeyFrameTime IM_INT (1) (write only) [maximum key frame interval in miliseconds, default 5 seconds]
DataRate IM_INT (1) (write only) [kilobits/second, default 2400]
VBR IM_INT (1) [0, 1] (write only) [0 - Constant Bit Rate (default), 1 - Variable Bit Rate (Quality-Based)]
(and several others from the file-level attributes) For ex:
Title, Author, Copyright, Description (string)
Duration IM_INT [100-nanosecond units]
Seekable, HasAudio, HasVideo, Is_Protected, Is_Trusted, IsVBR IM_INT (1) [0, 1]
NumberOfFrames IM_INT (1)

Comments:
IMPORTANT - The "image_count" and the "FPS" attribute may not be available from the file,
we try to estimate from the duration and from the average time between frames, or using the default value.
We do not handle DRM protected files (Digital Rights Management).
Reads only the first video stream. Other streams are ignored.
All the images have the same size, you must call imFileReadImageInfo/imFileWriteImageInfo 
at least once.
For optimal random reading, the file should be indexed previously.
If not indexed by frame, random positioning may not be precise.
Sequencial reading will always be precise.
When writing we use a custom profile and time indexing only.
We do not support multipass encoding.  
Since the driver uses COM, CoInitialize(NULL) and CoUninitialize() are called every Open/Close.
\endverbatim
* \ingroup format */

/** Register the WMF Format. \n
* In Lua, when using require"imlua_wmv" this function will be automatically called.
* \ingroup wmv */
void imFormatRegisterWMV();
