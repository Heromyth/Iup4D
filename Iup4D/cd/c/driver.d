module cd.c.driver;


import cd.c.core: cdContext, CD_ABORT, CD_CONTINUE;


// even without version=CD, libiupcd.so (depending on libcd.so) is used anyway as libiupcontrols.so depends on it
version(DigitalMars) version(Windows) { pragma(lib, "iupcd.lib"); } 

extern(C) @nogc nothrow
{
    /* NOTICE: implementation done in IUP at the IUPCD library. 
    Only this file is at the CD files. */

    // IUP driver
    // even with version=CD defined, cdContext* may not be dereferenced, 
    // as it is known only via (non-published) cd_private.d
    cdContext* cdContextIup(); 
    cdContext* cdContextIupDBuffer();
    cdContext* cdContextIupDBufferRGB();
    alias CD_IUP           = cdContextIup;
    alias CD_IUPDBUFFER    = cdContextIupDBuffer;
    alias CD_IUPDBUFFERRGB = cdContextIupDBufferRGB;

    // NativeWindow driver
    cdContext* cdContextNativeWindow();
    alias CD_NATIVEWINDOW = cdContextNativeWindow;
    void cdGetScreenSize(int* width, int* height, double* width_mm, double* height_mm);
    int cdGetScreenColorPlanes();

    // pragma(lib, "cdgl.lib");
    // OpenGL driver  
    cdContext* cdContextGL();
    alias CD_GL = cdContextGL;

    // Clipboard driver
    cdContext* cdContextClipboard();
    alias CD_CLIPBOARD = cdContextClipboard;

    // Printer driver
    cdContext* cdContextPrinter();
    alias CD_PRINTER = cdContextPrinter;

    // Picture driver
    cdContext* cdContextPicture();
    alias CD_PICTURE = cdContextPicture;

    // Server Image driver
    cdContext* cdContextImage();
    alias CD_IMAGE = cdContextImage;

    // IMAGERGB driver
    cdContext* cdContextImageRGB();
    cdContext* cdContextDBufferRGB();
    alias CD_IMAGERGB = cdContextImageRGB;
    alias CD_DBUFFERRGB = cdContextDBufferRGB;

    // Double Buffer driver
    cdContext* cdContextDBuffer();
    alias CD_DBUFFER = cdContextDBuffer;

    // pragma(lib, "cdpdf.lib"); 
    // PDF driver
    cdContext* cdContextPDF();
    alias CD_PDF = cdContextPDF;

    // PS driver
    cdContext* cdContextPS();
    alias CD_PS = cdContextPS;

    // SVG driver
    cdContext* cdContextSVG();
    alias CD_SVG = cdContextSVG;

    // Metafile driver
    cdContext* cdContextMetafile();
    alias CD_METAFILE = cdContextMetafile;

    // Debug driver
    cdContext* cdContextDebug();
    alias CD_DEBUG = cdContextDebug;

    // CGM driver
    cdContext* cdContextCGM();
    alias CD_CGM = cdContextCGM;

    enum CD_CGMCOUNTERCB = 1;
    enum CD_CGMSCLMDECB = 2;
    enum CD_CGMVDCEXTCB = 3;
    enum CD_CGMBEGPICTCB = 4;
    enum CD_CGMBEGPICTBCB = 5;
    enum CD_CGMBEGMTFCB = 6;

    /* OLD definitions, defined for backward compatibility */
    enum CDPLAY_ABORT = CD_ABORT;
    enum CDPLAY_GO    = CD_CONTINUE;

    // DGN driver
    cdContext* cdContextDGN();
    alias CD_DGN = cdContextDGN;

    // DXF driver
    cdContext* cdContextDXF();
    alias CD_DXF = cdContextDXF;

    // EMF driver
    cdContext* cdContextEMF();
    alias CD_EMF = cdContextEMF;

    // WMF driver
    cdContext* cdContextWMF();
    alias CD_WMF = cdContextWMF;


}
