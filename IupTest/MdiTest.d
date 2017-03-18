module MdiTest;

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


public class MdiTestDialog : IupDialog
{
    private IupMenu winMenu;
    private IupMenu mainMenu;
    //private IupMenu winmenu;

    IupDraw iupDraw;

    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {
        createMenu();

        IupCanvas cnv = new IupCanvas();
        cnv.isMdiClient = true;
        cnv.mdiMenu = winMenu;
        cnv.backgroundColor = Color.parse("128 255 0");
        cnv.paint += &canvas_paint;
        iupDraw = new IupDraw(cnv);

        IupButton bt = new IupButton("Test");
        bt.click += &button_click;

        IupHbox hbox = new IupHbox(bt);
        hbox.margin = Size(5, 5);

        IupVbox vbox = new IupVbox(hbox, cnv);

        this.child = vbox;
        this.title = "MDI Frame Test";
        this.isMdiContainer = true;
        this.rasterSize = Size(800, 600);
        this.menu = mainMenu;

        this.closing += &dialog_closing;

    }

    private void createMenu()
    {
        IupMenuItem newMenuItem = new IupMenuItem("New");
        newMenuItem.click += &newMenuItem_click;

        IupMenu mdiMenu = new IupMenu(newMenuItem);

        //
        IupMenuItem tilehorizMenuItem = new IupMenuItem("Tile Horizontal");
        tilehorizMenuItem.click += &tilehorizMenuItem_click;

        IupMenuItem tilevertMenuItem = new IupMenuItem("Tile Vertical");
        tilevertMenuItem.click += &tilevertMenuItem_click;

        IupMenuItem cascadeMenuItem = new IupMenuItem("Cascade");
        cascadeMenuItem.click += &cascadeMenuItem_click;

        IupMenuItem iconMenuItem = new IupMenuItem("Icon Arrange");
        iconMenuItem.click += &iconMenuItem_click;

        IupMenuItem closeallMenuItem = new IupMenuItem("Close All");
        closeallMenuItem.click += &closeallMenuItem_click;

        IupMenuSeparator menuSeparator = new IupMenuSeparator();

        IupMenuItem nextMenuItem = new IupMenuItem("Next");
        nextMenuItem.click += &nextMenuItem_click;

        IupMenuItem previousMenuItem = new IupMenuItem("Previous");
        previousMenuItem.click += &previousMenuItem_click;

        winMenu = new IupMenu(tilehorizMenuItem, tilevertMenuItem, cascadeMenuItem, 
                              iconMenuItem, closeallMenuItem,
                              menuSeparator, nextMenuItem, previousMenuItem);

        mainMenu = new IupMenu(new IupSubmenu("MDI", mdiMenu), 
                               new IupSubmenu("Window", winMenu));

    }


    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
    }


    private void button_click(Object sender, CallbackEventArgs e)
    {
        writefln("button_cb()");
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        writefln("canvas_paint()");
        IupCanvas canvas = cast(IupCanvas) sender;

        //IupDraw iupDraw = new IupDraw(canvas);
        iupDraw.begin();
        //iupDraw.useParentBackground();
        Size s = iupDraw.getSize();

        /* white background */
        canvas.drawColor = Color.parse("255 255 255");
        canvas.drawStyle = IupDrawStyle.Fill;

        iupDraw.drawRectangle(0,0,s.width, s.height);

        canvas.drawColor = Color.parse("255 0 255");
        //canvas.drawStyle = IupDrawStyle.Stroke;

        Point!int[] points = [Point!int(50,100), Point!int(200,100), Point!int(200,200), 
        Point!int(300,30), Point!int(50,100)];

        iupDraw.drawPolygon(points);
        iupDraw.end();
    }

    private void newMenuItem_click(Object sender, CallbackEventArgs e)
    {
        IupTextBox txt = new IupTextBox();

        IupButton bt = new IupButton("Test");
        bt.click += &button_click;

        IupVbox box = new IupVbox(new IupHbox(bt), txt);
        box.margin = Size(5, 5);

        IupDialog dlg = new IupDialog();
        dlg.title = std.format.format("MDI Child (%d)", id++);
        dlg.isMdiChild = true;
        dlg.child = box;
        dlg.rasterSize = Size(300, 300);
        dlg.mdiChildActivated += &dlg_mdiChildActivated;
        this.addMdiChild(dlg);
        dlg.show();
    }
    private int id = 0;


    private void dlg_mdiChildActivated(Object sender, CallbackEventArgs e)
    {
        if(this.activeMdiChild is null)
            return;

        IupElement dlg = cast(IupElement)sender;
        writefln("mdi_activate(name=%s, title=%s)", dlg.lastName, this.activeMdiChild.title); 
    }

    private void tilehorizMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.layoutMdi(MdiLayout.TileHorizontal);
    }

    private void tilevertMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.layoutMdi(MdiLayout.TileVertical);
    }

    private void cascadeMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.layoutMdi(MdiLayout.Cascade);

    }

    private void iconMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.layoutMdi(MdiLayout.ArrangeIcons);
    }

    private void closeallMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.closeAllMdi();
    }

    private void nextMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.activateNextMdi();
    }

    private void previousMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.activatePreviousMdi();
    }

 
    private void exitMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.close();
        //this.dispose();
        //e.result = IupElementActionClose;
    }


    // 16x16 8-bit
    private const(ubyte)[] pixmap_8 = [
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

}