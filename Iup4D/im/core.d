module im.core;


/** File Access Error Codes
* \par
* In Lua use im.ErrorStr(err) to convert the error number into a string.
* \ingroup file */
enum ImErrorCodes
{
    None,     /**< No error. */
    Open,     /**< Error while opening the file (read or write). */
    Access,   /**< Error while accessing the file (read or write). */
    Format,   /**< Invalid or unrecognized file format. */
    Data,     /**< Invalid or unsupported data. */
    Compress, /**< Invalid or unsupported compression. */
    Mem,      /**< Insufficient memory */
    Counter   /**< Interrupted by the counter */
}


/** Image color mode color space descriptors (first byte). \n
* See also \ref colormodeutl.
* \ingroup imagerep */
enum ImColorSpace
{
    RGB,    /**< Red, Green and Blue (nonlinear).              */
    MAP,    /**< Indexed by RGB color map (data_type=IM_BYTE). */
    GRAY,   /**< Shades of gray, luma (nonlinear Luminance), or an intensity value that is not related to color. */
    BINARY, /**< Indexed by 2 colors: black (0) and white (1) (data_type=IM_BYTE).     */
    CMYK,   /**< Cian, Magenta, Yellow and Black (nonlinear).                          */
    YCBCR,  /**< ITU-R 601 Y'CbCr. Y' is luma (nonlinear Luminance).                   */
    LAB,    /**< CIE L*a*b*. L* is Lightness (nonlinear Luminance, nearly perceptually uniform). */
    LUV,    /**< CIE L*u*v*. L* is Lightness (nonlinear Luminance, nearly perceptually uniform). */
    XYZ     /**< CIE XYZ. Linear Light Tristimulus, Y is linear Luminance.             */
}

enum ImDataType
{
    Byte,   /**< "unsigned char". 1 byte from 0 to 255.                  */
    Short,  /**< "short". 2 bytes from -32,768 to 32,767.                */
    UShort, /**< "unsigned short". 2 bytes from 0 to 65,535.             */
    Int,    /**< "int". 4 bytes from -2,147,483,648 to 2,147,483,647.    */
    Float,  /**< "float". 4 bytes single precision IEEE floating point.  */
    Double, /**< "double". 8 bytes double precision IEEE floating point. */
    CFloat, /**< complex "float". 2 float values in sequence, real and imaginary parts.   */
    CDouble /**< complex "double". 2 double values in sequence, real and imaginary parts.   */
}