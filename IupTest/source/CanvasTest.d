module CanvasTest;

import std.algorithm;
import std.ascii;
import std.container.array;
import std.conv;
import std.format;
import std.file;
import std.math;
import std.path;
import std.stdio;
import std.string;
import std.traits;

import core.stdc.stdlib; 

import iup;
import im;
import cd;

import toolkit.event;
import toolkit.input;
import toolkit.drawing;

version(Windows)
{
    import core.sys.windows.windef;
    import core.sys.windows.winuser;
    import core.sys.windows.wingdi;
	import std.windows.charset;
}

import derelict.opengl3.gl;


public class CanvasTestDialog : IupDialog
{
    private IupCanvas canvas;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupImage8 image = new IupImage8(16, 16, matrx_img_cur_excel_8);
        image.useBackground(0);
        image.setColor(1, Color.fromRgb(255, 0, 0));
        image.setColor(2, Color.parse("128 0 0"));
        image.hotspot = Point!int(21,10);

        image = new IupImage8(32, 32, pixmap_cursor_8);
        image.useBackground(0);
        image.setColor(1, Color.fromRgb(0, 0, 0));
        image.setColor(2, Color.parse("255 255 255"));
        image.hotspot = Point!int(7,7);


        canvas = new IupCanvas();
        canvas.rasterSize = Size(300, 200);
        //canvas.canExpand = false;
        canvas.tipText = "Canvas Tip";
        canvas.backgroundColor = Color.parse("0 255 0");

        IupScrollBar scrollBars = canvas.scrollBars;
        scrollBars.visibility = ScrollBarsVisibility.Horizontal;
        scrollBars.xMax = 600;
        scrollBars.dx = 300; /* use a 1x1 scale, this value is updated in RESIZE_CB,
        so when the canvas is larger than 600 
        it will hide the scrollbar */

        canvas.isDropTarget = true;
        canvas.dropContent = DragDropContent.Text;
        canvas.dropped += &canvas_dropped;

        //canvas.hasBorder = false;
        //canvas.cursor = image;
        canvas.cursor = IupCursors.Cross;
        canvas.mapped += &canvas_mapped;
        canvas.keyPress += &canvas_keyPress;
        canvas.helpRequested += &canvas_helpRequested;
        canvas.gotFocus += &canvas_gotFocus;
        canvas.lostFocus += &canvas_lostFocus;
        canvas.focusChanged += &canvas_focusChanged;
        canvas.mouseEnter += &canvas_mouseEnter;
        canvas.mouseLeave += &canvas_mouseLeave;
        canvas.mouseClick += &canvas_mouseClick;
        //canvas.mouseMove += &canvas_mouseMove;
        canvas.wheel += &canvas_wheel;
        canvas.scroll += &canvas_scroll;
        canvas.sizeChanged += &canvas_sizeChanged;
        canvas.paint += &canvas_paint;
        canvas.fileDropped += &canvas_fileDropped;

        IupVbox vbox = new IupVbox(canvas);
        vbox.margin = Size(5, 5);
        //vbox.cmargin = Size(30, 30);

        this.child = vbox;
        this.title = "IupCanvas Test";
        this.loaded += &dialog_loaded;

        writefln("IupMap");
        this.map();
        writefln("IupShow");
        // IupShow(dlg);
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        // Notice: It runs after redraw().

        // canvas.clearAttribute("RASTERSIZE"); /* release the minimum limitation */
    }

    private void canvas_dropped(Object sender, CallbackEventArgs e,
                                DragDropContent type, void* data, int len, int x, int y)
    {
        if(type == DragDropContent.Text)
        {
            string s = cast(string)data[0..len];
            //printf("FILE_CB(%s - %s)\n", status.ptr,   toMBSz(fileName)); 
            string v = std.format.format("\n  DROPDATA_CB(type=%s, data=%s, size=%d, x=%d, y=%d)\n", type, s, len, x, y);
            printf("%s", toMBSz(v)); 
        }
        else
            writefln("\n  DROPDATA_CB(type=%s, data=(void*), size=%d, x=%d, y=%d)\n", type, len, x, y);
    }

    private void canvas_mapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MAP_CB(%s)", element.title);
    }

    private void canvas_keyPress(Object sender, CallbackEventArgs args, int key)
    {
        IupElement element = cast(IupElement)sender;

        if(isPrintable(key))
        {
            writefln("K_ANY(%s, %d = %s \'%c\')", element.name, key,  Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("K_ANY(%s, %d = %s)", element.name, key, Keys.toName(key));
        }

        writefln("  MODKEYSTATE(%s)", Keys.getModifierKeyState()); 

        writefln("  isShiftXkey(%s)", Keys.isShiftXkey(key));
        writefln("  isCtrlXkey(%s)", Keys.isCtrlXkey(key));
        writefln("  isAltXkey(%s)", Keys.isAltXkey(key));
    }

    private void canvas_helpRequested(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HELP_CB(%s)", element.title);
    }

    private void canvas_gotFocus(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("GETFOCUS_CB(%s)", element.title);
    }

    private void canvas_lostFocus(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("KILLFOCUS_CB(%s)", element.title);
    }

    private void canvas_focusChanged(Object sender, CallbackEventArgs args, bool isFocused)
    {
        IupElement element = cast(IupElement)sender;
        writefln("FOCUS_CB(%s)", isFocused);
    }

    private void canvas_mouseEnter(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("ENTERWINDOW_CB(%s)", element.title);
    }

    private void canvas_mouseLeave(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("LEAVEWINDOW_CB(%s)", element.title);
    }

    private void canvas_mouseClick(Object sender, CallbackEventArgs args, 
                                  MouseButtons button, MouseState mouseState, 
                                  int x, int y, string status)
    {
        writefln("BUTTON_CB(but=%s (%s), x=%d, y=%d [%s])", button, mouseState, x, y, status);
        if(button == MouseButtons.Left && mouseState == MouseState.Pressed)
        {
            canvas.cursor = IupCursors.Cross;
        }
        else if(button == MouseButtons.Left && mouseState == MouseState.Released)
        {
            //canvas.clearAttribute("CURSOR");
            canvas.cursor = "";
        }
    }

    private void canvas_mouseMove(Object sender, CallbackEventArgs args, int x, int y, string status)
    {
        writefln("MOTION_CB(x=%d, y=%d [%s])",x,y, status);
    }

    private void canvas_wheel(Object sender, CallbackEventArgs args, float delta, int x, int y, string status)
    {
        writefln("WHEEL_CB(delta=%.2f, x=%d, y=%d [%s])",delta,x,y, status);
    }

    private void canvas_scroll(Object sender, CallbackEventArgs args, int op, float posx, float posy)
    {
        string[] op2str = ["SBUP", "SBDN", "SBPGUP", "SBPGDN", "SBPOSV", "SBDRAGV",
        "SBLEFT", "SBRIGHT", "SBPGLEFT", "SBPGRIGHT", "SBPOSH", "SBDRAGH"];
        writefln("SCROLL_CB(%s, posx=%.2f, posy=%.2f)", op2str[op], posx, posy);
        drawTest(0);
    }

    private void canvas_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        Size rasterSize = canvas.rasterSize;
        Size drawSize = canvas.drawSize;
        writefln("RESIZE_CB(%d, %d) RASTERSIZE=%s DRAWSIZE=%s", width, height, 
                 rasterSize.toString(), drawSize.toString());

        /* update page size */
        canvas.scrollBars.dx = width;
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        writefln("ACTION(posx=%.2f, posy=%.2f)", posx, posy);
        drawTest(cast(int)posx);
    }

    private void canvas_fileDropped(Object sender, CallbackEventArgs e,
                                    string fileName, int number, int x, int y)
    {
        string v = std.format.format("DROPFILES_CB(%s, %d, x=%d, y=%d)", fileName, number, x, y);
        printf("%s", toMBSz(v)); 
    }

    private void drawTest(int posx)
    {
        //testWin32Draw(0);
        testIupDraw(0);
    }

    private void testIupDraw(int posx)
    {
        IupDraw iupDraw = new IupDraw(canvas);
        iupDraw.begin();
        //iupDraw.useParentBackground();
        Size s = iupDraw.getSize();

        /* white background */
        canvas.drawColor = Color.parse("255 255 255");
        canvas.drawStyle = IupDrawStyle.Fill;

        iupDraw.drawRectangle(0,0,s.width, s.height);

        s.width = 600; /* virtual size */
        canvas.drawColor = Color.parse("255 0 0");
        iupDraw.drawLine(-posx, 0, s.width - posx, s.height);
        iupDraw.drawLine(-posx, s.height, s.width - posx, 0);

        iupDraw.end();
    }

    private void testWin32Draw(int posx)
    {
        RECT rect;
        HWND hWnd = canvas.hwnd;
        HPEN oldPen;
        HDC hDC = GetDC(hWnd);

         Size size = canvas.drawSize;
         int w = size.width;
         int h = size.height;

        SetRect(&rect, 0, 0, w, h);
        FillRect(hDC, &rect, GetStockObject(WHITE_BRUSH));

        oldPen = SelectObject(hDC, GetStockObject(DC_PEN));
        SetDCPenColor(hDC, RGB(255, 0, 0));

        w = 600; /* virtual size */
        MoveToEx(hDC, -posx, 0, NULL);
        LineTo(hDC, w-posx, h);
        MoveToEx(hDC, -posx, h, NULL);
        LineTo(hDC, w-posx, 0);

        SelectObject(hDC, oldPen);
        ReleaseDC(hWnd, hDC);
    }


    // 16x16 8-bit
    private const(ubyte)[] matrx_img_cur_excel_8 = [
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,1,2,3,3,3,3,3,3,3,2,1,0,0,0, 
        0,0,2,1,2,3,3,3,3,3,2,1,2,0,0,0, 
        0,0,3,2,1,2,3,3,3,2,1,2,3,0,0,0,
        0,0,3,3,2,1,2,3,2,1,2,3,3,0,0,0, 
        0,0,3,3,3,2,1,2,1,2,3,3,3,0,0,0, 
        0,0,3,3,3,3,2,1,2,3,3,3,3,0,0,0, 
        0,0,3,3,3,2,1,2,1,2,3,3,3,0,0,0, 
        0,0,3,3,2,1,2,3,2,1,2,3,3,0,0,0, 
        0,0,3,2,1,2,3,3,3,2,1,2,3,0,0,0, 
        0,0,2,1,2,3,3,3,3,3,2,1,2,0,0,0, 
        0,0,1,2,3,3,3,3,3,3,3,2,1,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ];

    // 32x32 8-bit
    private const(ubyte)[] pixmap_cursor_8 = [
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,2,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ];

}


public class CanvasCDSimpleTestDialog : IupDialog
{
    private IupCanvas canvas;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        canvas = new IupCanvas();
        canvas.rasterSize = Size(300, 200);  /* initial size */
        canvas.tipText = "Canvas Tip";
        //canvas.background = Color.parse("0 255 0");
        canvas.sizeChanged += &canvas_sizeChanged;
        canvas.mapped += &canvas_mapped;
        canvas.unmapped += &canvas_unmapped;
        canvas.paint += &canvas_paint;

        this.child = canvas;
        this.title = "CD Simple Buffer Test";

        writefln("IupMap");
        this.map();

    }

    private void canvas_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        Size rasterSize = canvas.rasterSize;
        Size drawSize = canvas.drawSize;
        writefln("RESIZE_CB(%d, %d) RASTERSIZE=%s DRAWSIZE=%s", width, height, 
                 rasterSize.toString(), drawSize.toString());

        /* update page size */
        //canvas.scrollBars.dx = width;

        /* update canvas size */
        cdCanvas.activate();
    }

    private void canvas_mapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MAP_CB(%s)", element.title);

        cdCanvas = new IupCdCanvas(canvas);
    }
    private CdCanvas cdCanvas;

    private void canvas_unmapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("UNMAP_CB(%s)", element.title);
        cdCanvas.dispose();
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        writefln("ACTION(posx=%.2f, posy=%.2f)", posx, posy);
        drawTest();
    }

    private void drawTest()
    {        
        /* draw the background */
        //cdCanvas.activate();
        cdCanvas.background = Colors.White;
        cdCanvas.clear();

        cdCanvas.foreground = Colors.Red;
        int width, height;
        double width_mm, height_mm;
        cdCanvas.getSize(width, height, width_mm, height_mm);
        cdCanvas.drawLine(0, 0, width-1, height-1);
        cdCanvas.drawLine(0, height-1, width-1, 0);

    }

}


public class CanvasCDDBufferTestDialog : IupDialog
{
    private IupCanvas canvas;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        canvas = new IupCanvas();
        canvas.rasterSize = Size(300, 200);  /* initial size */
        canvas.tipText = "Canvas Tip";
        //canvas.background = Color.parse("0 255 0");
        canvas.sizeChanged += &canvas_sizeChanged;
        canvas.mapped += &canvas_mapped;
        canvas.unmapped += &canvas_unmapped;
        canvas.paint += &canvas_paint;

        this.child = canvas;
        this.title = "CD Double Buffer Test";

        writefln("IupMap");
        this.map();

    }

    private void canvas_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        Size rasterSize = canvas.rasterSize;
        Size drawSize = canvas.drawSize;
        writefln("RESIZE_CB(%d, %d) RASTERSIZE=%s DRAWSIZE=%s", width, height, 
                 rasterSize.toString(), drawSize.toString());

        /* update page size */
        //canvas.scrollBars.dx = width;

        /* update canvas size */
        cdCanvas.activate();

        /* update render */
        updateRender();
    }

    private void canvas_mapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MAP_CB(%s)", element.title);

        // Notice: It must run after calling redraw().
        cdCanvas = new IupDBufferCdCanvas(canvas);
    }
    private CdCanvas cdCanvas;

    private void canvas_unmapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("UNMAP_CB(%s)", element.title);
        cdCanvas.dispose();
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        writefln("ACTION(posx=%.2f, posy=%.2f)", posx, posy);
        //drawTest();

        /* update display */
        cdCanvas.flush();
    }

    private void updateRender()
    {        
        /* draw the background */
        //cdCanvas.activate();
        cdCanvas.background = Colors.White;
        cdCanvas.clear();

        cdCanvas.foreground = Colors.Red;
        int width, height;
        double width_mm, height_mm;
        cdCanvas.getSize(width, height, width_mm, height_mm);
        cdCanvas.drawLine(0, 0, width-1, height-1);
        cdCanvas.drawLine(0, height-1, width-1, 0);

    }
}


public class CanvasScrollbarTestDialog : IupDialog
{
    enum WORLD_W = 600;
    enum WORLD_H = 400;
    private IupCanvas canvas;
    private CdCanvas cdCanvas;
    private WdCanvas wdCanvas;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        canvas = new IupCanvas();
        canvas.rasterSize = Size(300, 200);  /* initial size */
        canvas.tipText = "Canvas Tip";
        canvas.scrollBars.visibility = ScrollBarsVisibility.Both;
        canvas.hasBorder = false;
        canvas.backgroundColor = Color.parse("0 255 0");
        canvas.sizeChanged += &canvas_sizeChanged;
        canvas.mapped += &canvas_mapped;
        canvas.unmapped += &canvas_unmapped;
        canvas.wheel += &canvas_wheel;
        canvas.scroll += &canvas_scroll;
        canvas.paint += &canvas_paint;

        IupVbox vbox = new IupVbox(canvas);

        this.child = vbox;
        this.title = "Scrollbar Test";
        this.margin = Size(10, 10);
        this.map();

    }

    private void update_scrollbar(int canvas_w, int canvas_h)
    {
        /* update page size, it is always the client size of the canvas,
        but must convert it to world coordinates.
        If you change canvas size or scale must call this function. */
        double ww, wh;
        if (scale > 0)
        {
            ww = cast(double)canvas_w/scale;
            wh = cast(double)canvas_h/scale;
        }
        else
        {
            ww = canvas_w*std.math.abs(scale);
            wh = canvas_h*std.math.abs(scale);
        }
        canvas.scrollBars.dx = ww;
        canvas.scrollBars.dy = wh;
    }
    private int scale = 1;

    private void update_viewport(float posx, float posy)
    {  
        int view_x, view_y, view_w, view_h;

        /* The CD viewport is the same area represented by the virtual space of the scrollbar,
        but not using the same coordinates. */

        /* posy is top-bottom, CD is bottom-top.
        invert posy reference (YMAX-DY - POSY) */
        posy = canvas.scrollBars.yMax - canvas.scrollBars.dy - posy;
        if (posy < 0) posy = 0;

        if (scale > 0)
        {
            view_w = WORLD_W*scale;
            view_h = WORLD_H*scale;
            view_x = cast(int)(posx*scale);
            view_y = cast(int)(posy*scale);
        }
        else
        {
            view_w = WORLD_W/std.math.abs(scale);
            view_h = WORLD_H/std.math.abs(scale);
            view_x = cast(int)(posx/std.math.abs(scale));
            view_y = cast(int)(posy/std.math.abs(scale));
        }

        wdCanvas.viewport = RectangleInt(-view_x, -view_y, view_w-1 - view_x, view_h-1 - view_y);
    }

    private void canvas_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        Size rasterSize = canvas.rasterSize;
        Size drawSize = canvas.drawSize;
        writefln("RESIZE_CB(%d, %d) RASTERSIZE=%s DRAWSIZE=%s", width, height, 
                 rasterSize.toString(), drawSize.toString());
        
        /* When *AUTOHIDE=Yes, this can hide a scrollbar and so change the canvas drawsize */
        //update_scrollbar(width, height);

        //drawSize = canvas.drawSize;
        //writefln("             DRAWSIZE=%s",drawSize.toString());

        /* update the canvas size */
        drawSize = canvas.drawSize;
        update_scrollbar(drawSize.width, drawSize.height);
        writefln("             DRAWSIZE=%s",drawSize.toString());


        /* update canvas size */
        cdCanvas.activate();
        update_viewport(canvas.scrollBars.posX, canvas.scrollBars.posY);
    }

    private void canvas_mapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MAP_CB(%s)", element.title);

        cdCanvas = new IupCdCanvas(canvas);
        wdCanvas = new WdCanvas(cdCanvas);

        /* World size is fixed */
        wdCanvas.window = Rectangle!double( 0, 0, WORLD_W, WORLD_H);

        /* handle scrollbar in world coordinates, so we only have to update DX/DY */
        IupScrollBar scrollBars = canvas.scrollBars;
        scrollBars.xMin = 0;
        scrollBars.yMin = 0;
        scrollBars.xMax = WORLD_W;
        scrollBars.yMax = WORLD_H;
    }

    private void canvas_unmapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("UNMAP_CB(%s)", element.title);
        cdCanvas.dispose();
    }

    private void canvas_scroll(Object sender, CallbackEventArgs args, int op, float posx, float posy)
    {
        string[] op2str = ["SBUP", "SBDN", "SBPGUP", "SBPGDN", "SBPOSV", "SBDRAGV",
        "SBLEFT", "SBRIGHT", "SBPGLEFT", "SBPGRIGHT", "SBPOSH", "SBDRAGH"];
        writefln("SCROLL_CB(%s, posx=%.2f, posy=%.2f)", op2str[op], posx, posy);

        cdCanvas.activate();
        update_viewport(posx, posy);
        canvas.redraw(false);
    }

    private void canvas_wheel(Object sender, CallbackEventArgs args, float delta, int x, int y, string status)
    {
        writefln("WHEEL_CB(delta=%.2f, x=%d, y=%d [%s])",delta,x,y, status);

        int canvas_w, canvas_h;
        if (scale+delta==0) /* skip 0 */
        {
            if (scale > 0) 
                scale = -1;
            else 
                scale = 1;
        }
        else
            scale += cast(int)delta;

        cdCanvas.activate();
        double width_mm, height_mm;
        cdCanvas.getSize(canvas_w, canvas_h, width_mm, height_mm);
        update_scrollbar(canvas_w, canvas_h);
        update_viewport(canvas.scrollBars.posX, canvas.scrollBars.posY);
        canvas.redraw(false);
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        writefln("ACTION(posx=%.2f, posy=%.2f)", posx, posy);
        drawTest();
    }

    private void drawTest()
    {        
        /* draw the background */
        wdCanvas.activate();
        wdCanvas.clear();
        wdCanvas.foreground = Colors.Red;

        wdCanvas.drawLine(0, 0, WORLD_W, WORLD_H);
        wdCanvas.drawLine(0, WORLD_H, WORLD_W, 0);
        wdCanvas.drawArc(WORLD_W/2, WORLD_H/2+WORLD_H/10, WORLD_W/10, WORLD_H/10, 0, 360);

        wdCanvas.drawLine(0, 0, WORLD_W, 0);
        wdCanvas.drawLine(0, WORLD_H, WORLD_W, WORLD_H);
        wdCanvas.drawLine(0, 0, 0, WORLD_H);
        wdCanvas.drawLine(WORLD_W, 0, WORLD_W, WORLD_H);

    }

}



public class GLCanvasTestDialog : IupDialog
{
    private IupGLCanvas canvas;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        canvas = new IupGLCanvas();
        canvas.bufferMode = GlBufferMode.Double;
        canvas.hasBorder = false;
        canvas.rasterSize = Size(300, 200);  /* initial size */
        //canvas.background = Color.parse("0 255 0");
        canvas.sizeChanged += &canvas_sizeChanged;
        canvas.mouseClick += &canvas_mouseClick;
        canvas.mapped += &canvas_mapped;
        canvas.unmapped += &canvas_unmapped;
        canvas.paint += &canvas_paint;

        //canvas.enableArbContext = true;
        //canvas.contextVersion = "3.3";

        IupVbox vbox = new IupVbox(canvas);
        vbox.margin = Size(5,5);

        this.child = vbox;
        this.title = "IupGLCanvas Test";

        writefln("IupMap");
        this.map();

        string error = canvas.errorMessage;
        if(!error.empty())
            writefln("ERROR=%s", error);

        //canvas.makeCurrent();

        writefln("Vendor: %s", std.string.fromStringz(glGetString(GL_VENDOR)));
        writefln("Renderer: %s", std.string.fromStringz(glGetString(GL_RENDERER)));
        writefln("Version: %s", std.string.fromStringz(glGetString(GL_VERSION)));
        
        error = canvas.errorMessage;
        if(!error.empty())
            writefln("ERROR=%s", error);
    }

    private void canvas_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        Size rasterSize = canvas.rasterSize;
        Size drawSize = canvas.drawSize;
        writefln("RESIZE_CB(%d, %d) RASTERSIZE=%s DRAWSIZE=%s", width, height, 
                 rasterSize.toString(), drawSize.toString());
    }
    
    private void canvas_mouseClick(Object sender, CallbackEventArgs args, 
                                    MouseButtons button, MouseState mouseState, 
                                    int x, int y, string status)
    {
        writefln("BUTTON_CB(but=%s (%s), x=%d, y=%d [%s])", button, mouseState, x, y, status);
    }

    private void canvas_mapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MAP_CB(%s)", element.title);
    }

    private void canvas_unmapped(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("UNMAP_CB(%s)", element.title);
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        writefln("ACTION(posx=%.2f, posy=%.2f)", posx, posy);

        canvas.makeCurrent();

        glClearColor(1.0, 0.0, 1.0, 1.0f);  /* pink */
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glColor3f(1.0,0.0,0.0);  /* red */
        glBegin(GL_QUADS); 
        glVertex2f(0.9f,0.9f); 
        glVertex2f(0.9f,-0.9f); 
        glVertex2f(-0.9f,-0.9f); 
        glVertex2f(-0.9f,0.9f); 
        glEnd();

        canvas.swapBuffers();

    }

}