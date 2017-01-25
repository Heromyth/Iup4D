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

