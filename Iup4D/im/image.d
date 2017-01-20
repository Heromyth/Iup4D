module im.image;

import std.string;

import im.core;

import im.c.image;
import im.c.core;
import im.c.converter;

class ImImage
{
    protected class ImAttributes
	{
        enum GlData  = "GLDATA";
	}

    /**
    */
	@property 
	{
		public imImage*  image(){ return m_image; }
		protected void image(imImage* value) { m_image = value;}
        private imImage* m_image;
	}

    this()
    {
        this(100,100);
    }


    this(int width, int height, ImColorSpace colorSpace = ImColorSpace.RGB, ImDataType dataType = ImDataType.Byte)
    {
        this.image  = imImageCreate(width, height, cast(imColorSpace)colorSpace, cast(imDataType)dataType);
    }

    this(imImage* image)
    {
        this.image = image;
    }

    this(string fileName)
    {
        int error;  
        image  = imFileImageLoadBitmap(std.string.toStringz(fileName),0, &error);
    }

    this(ImImage im, ImColorSpace c)
    {
        this.image = imImageCreateBased(im.image, -1, -1, cast(imColorSpace)c, -1);
    }

    ~this()
    {
        dispose();
    }


    /* ************* Properties *************** */

    /**
    Color space descriptor.
    */
    @property 
	{
		public ImColorSpace colorSpace() { return cast(ImColorSpace)image.color_space; }
		public void colorSpace(ImColorSpace value) { image.color_space = cast(imColorSpace)value; }
	}


    @property 
	{    
        bool isValid() { return m_image !is null;}

        /**
        Number of columns.
        */
		public int width() { return image.width; }

        /**
        Number of lines. 
        */
		public int height() { return image.height; }

        /**
        Number of pixels per plane (width * height) 
        */
		public int planePixelsCount() { return image.count; }

        /**
        Number of planes (ColorSpaceDepth. That means the alpha channel is not included.)
        */
		public int planeNumber() { return image.depth; }

        /**
        Number of bytes per line in one plane (width * DataTypeSize) 
        */
		public int lineSize() { return image.line_size; }

        /**
        Number of bytes per plane. (line_size * height) 
        */
		public int planeSize() { return image.plane_size; }

        /**
        Number of bytes occupied by the image (plane_size * depth) 
        */
		public int size() { return image.size; }


        /**
        Indicates that there is an extra channel with alpha.
        It will not affect the secondary parameters, i.e. the number of planes will be in fact depth+1. 
        It is always 0 unless imImageAddAlpha is called. Alpha is automatically added in image loading functions. 
        */
        bool hasAlpha() { return image.has_alpha != 0; }

        /**
        The data of alpha channel may be attathced at the last plane.
        */
        ubyte[][] matrixData()
        {
            int planeNumber= image.depth;
            if(hasAlpha)
                planeNumber++;
            int planeSize = image.plane_size;
            ubyte[][] buffer = new ubyte[][planeNumber];
            for(int i=0; i<planeNumber; i++)
                buffer[i] = cast(ubyte[])image.data[i][0..planeSize];

            return buffer;
        }

        /**
        */
        ubyte[] linearData()
        {
            int length = image.size;
            return cast(ubyte[])image.data[0][0..length];
        }


        /**
        The palette is always 256 colors allocated, but can have less colors used. 
        */
        //public int size() { return image.size; }

        const(int)[] palette()
        {
            int length = image.palette_count;
            return cast(const(int)[])image.palette[0..length];
        }

	}



    /* ************* Public methods *************** */

    /**
    Loads an image from file, but forces the image to be a bitmap. Open, loads and closes the file. 
    index specifies the image number between 0 and image_count-1. 
    Returns NULL if failed. Attributes from the file will be stored at the image.
    */
    ImErrorCodes load(string fileName)
    {
       int error;  
       image  = imFileImageLoadBitmap(std.string.toStringz(fileName),0, &error);
       return cast(ImErrorCodes)error;
    }


    void removeAlpha()
    {
        imImageRemoveAlpha(image);
    }

    void convertColorSpace(ImImage im)
    {
        int r = imConvertColorSpace(im.image, this.image);
    }


    /* create OpenGL compatible data */
    void convertToOpenGLData()
    {
        imImageGetOpenGLData(this.image, null);
    }

    const(void)* getGlData()
    {
        return cast(const(void)*)imImageGetAttribute(this.image, ImAttributes.GlData, null, null);
    }


    void dispose()
    {
        if(!isDisposed)
        {
            imImageDestroy(image);
            isDisposed = true;
        }
    }
    private bool isDisposed = false;

}