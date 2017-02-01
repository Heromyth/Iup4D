module ColorTest;

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

public class ColorBarTestDialog : IupDialog
{
    private IupCdCanvas cdcanvas;
    private IupColorBar cb;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        /* Creates a canvas associated with the redraw action */
        IupCanvas canvas = new IupCanvas();
        canvas.rasterSize = Size(200, 300);
        canvas.paint += &canvas_paint;

        cb = new IupColorBar();
        cb.rasterSize = Size(70, 0);
        cb.expandOrientation = ExpandOrientation.Vertical;
        cb.groupNumber = 2;
        cb.canShowSecondary = true;
        cb.previewSize = 60;
        //cb.backgroundColor = "128 0 255";

        cb.colorSelected += &cb_colorSelected;
        cb.cellDoubleClicked += &cb_cellDoubleClicked;
        cb.selectionSwitched += &cb_selectionSwitched;
        cb.extendedRightClick += &cb_extendedRightClick;


        IupHbox hbox = new IupHbox(canvas, cb);

        this.child = hbox;
        this.margin = Size(5, 5);
        this.title = "IupColorbar Test";

        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;
        this.mapped += &dialog_mapped;

        /* Maps the dlg. This must be done before the creation of the CD canvas.
        Could also use MAP_CB callback. */
        this.map();
        cdcanvas = new IupCdCanvas(canvas);
    }


    private void dialog_mapped(Object sender, CallbackEventArgs args)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("MAP_CB(%s)", dialog.title);
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("loaded(%s)", dialog.title);
        //cdcanvas.activate();
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        cdcanvas.dispose();
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        redrawCanvas();
    }

    private void redrawCanvas()
    {
        //writefln("ACTION(posx=%.2f, posy=%.2f)", posx, posy);
        /* Activates canvas cdcanvas */
        cdcanvas.activate();
        cdcanvas.clear();

        /* Draws a rectangle on the canvas */
        cdcanvas.begin(CdPolygonMode.Fill);
        cdcanvas.vertex(50, 50);
        cdcanvas.vertex(150, 50);
        cdcanvas.vertex(100, 150);
        cdcanvas.end();

        /* Function executed sucessfully */
    }

    void cb_colorSelected(Object sender, CallbackEventArgs args, int cell, int type)
    {
        Color color = cb.getCellColor(cell);
        printf("select_cb(%d, %d): %d, %d, %d\n", cell, type, color.R, color.G, color.B);

        cdcanvas.activate();
        if(type == -1)
            cdcanvas.foreground = color;
        else
            cdcanvas.background = color;
        redrawCanvas();
    }

    void cb_cellDoubleClicked(Object sender, ColorBarCallbackEventArgs args, int cell)
    {
        Color color = cb.getCellColor(cell);
        printf("cell_cb(%d): %d, %d, %d\n", cell, color.R, color.G, color.B);

        args.result = CallbackResult.Ignore;
        args.color = Colors.Red;
    }

    void cb_selectionSwitched(Object sender, CallbackEventArgs args, int primcell, int seccell)
    {
        writef("switch_cb(%d, %d)\n", primcell, seccell);
        cdcanvas.activate();

        Color foreColor = cdcanvas.foreground;
        Color backColor = cdcanvas.background;
        cdcanvas.background = foreColor;
        cdcanvas.foreground = backColor;

        redrawCanvas();
    }

    void cb_extendedRightClick(Object sender, CallbackEventArgs args, int cell)
    {
        writef("extended_cb(%d)\n", cell);
    }
}


public class ColorBrowserTestDialog : IupDialog
{
    private IupLabel label_red;
    private IupLabel label_green;
    private IupLabel label_blue;

    private IupLabel label_color;
    private IupColorBrowser clrbrwsr;
    private IupButton startBtn;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        label_red = new IupLabel();
        label_red.size = Size(100, 10);
        label_red.font = "Courier, 12";

        label_green = new IupLabel();
        label_green.size = Size(100, 10);
        label_green.font = "Courier, 12";

        label_blue = new IupLabel();
        label_blue.size = Size(100, 10);
        label_blue.font = "Courier, 12";

        label_color = new IupLabel();
        label_color.rasterSize = Size(50, 50);

        clrbrwsr = new IupColorBrowser();
        clrbrwsr.canExpand = true;
        clrbrwsr.rgb = "128 0 128";
        clrbrwsr.mouseUp += &clrbrwsr_mouseUp;
        clrbrwsr.mouseMove += &clrbrwsr_mouseMove;

        updateText(clrbrwsr.rgb, clrbrwsr.hsi);

        IupVbox vbox = new IupVbox(label_red, label_green, label_blue, label_color);
        IupHbox hbox = new IupHbox(clrbrwsr, vbox);
        hbox.margin = Size(10, 10);

        this.child = hbox;
        this.title = "IupColorBrowser Test";
    }

    private void clrbrwsr_mouseUp(Object sender, CallbackEventArgs e, ubyte r, ubyte g, ubyte b)
    {
        writef("CHANGE_CB(%d, %d, %d)\n", r, g, b);
        updateText(clrbrwsr.rgb, clrbrwsr.hsi);
    }

    private void clrbrwsr_mouseMove(Object sender, CallbackEventArgs e, ubyte r, ubyte g, ubyte b)
    {
        writef("DRAG_CB(%d, %d, %d)\n", r, g, b);
        updateText(clrbrwsr.rgb, clrbrwsr.hsi);
    }

    private void updateText(Color rgb, HsiColor hsi)
    {
        label_red.title = std.format.format("R:%3d  H:%3.0f", rgb.R, hsi.H);
        label_green.title = std.format.format("G:%3d  S:%1.2f", rgb.G, hsi.S);
        label_blue.title = std.format.format("B:%3d  I:%1.2f", rgb.B, hsi.I);
        label_color.backgroundColor = rgb;

    }

}

