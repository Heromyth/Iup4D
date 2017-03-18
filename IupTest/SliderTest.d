module SliderTest;

import std.container.array;
import std.stdio;
import std.algorithm;
import std.ascii;
//import std.exception;
import std.string;
import std.traits;
import std.conv;
import std.file;
import std.path;
import std.format;
import std.math;

import core.stdc.stdlib; 

import iup;
import im;
import cd;

import toolkit.event;
import toolkit.input;
import toolkit.drawing;

public class SliderTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        lbl_v = new IupLabel("VALUE=");
        lbl_v.size = Size(70, 0);

        IupSlider val_v = new IupSlider();
        val_v.orientation = Orientation.Vertical;
        val_v.maximum = 10.0;
        val_v.step = 0.02;
        val_v.pageStep = 0.2;
        val_v.ticksCount = 5;
        //val_v.tickPosition = TickPosition.Reverse;
        val_v.tooltip.text  = "Val Tip";
        val_v.isInverted = true;
        val_v.valueChanged += &slider1_valueChanged; 
        //val_v.buttonPress += &slider_buttonPress;
        //val_v.buttonRelease += &slider_buttonRelease;
        //val_v.mouseMove += &slider_mouseMove;

        IupHbox hbox1 = new IupHbox(val_v, lbl_v);
        hbox1.alignment = VerticalAlignment.Center;


        lbl_h = new IupLabel("VALUE=");
        lbl_h.size = Size(70, 0);

        IupSlider val_h = new IupSlider();
        val_h.orientation = Orientation.Horizontal;
        val_h.maximum = 100.0;
        //val_h.rasterSize = Size(0, 20);
        val_h.canFocus = false;
        val_h.valueChanged += &slider2_valueChanged; 
        //val_h.buttonPress += &slider_buttonPress;
        //val_h.buttonRelease += &slider_buttonRelease;
        //val_h.mouseMove += &slider_mouseMove;

        IupVbox vbox1 = new IupVbox(val_h, lbl_h);
        vbox1.alignment = HorizontalAlignment.Center;


        IupHbox hbox = new IupHbox(hbox1, vbox1);
        this.child = hbox;
        this.margin = Size(10, 10);
        this.gap = 10;
        this.title = "IupSlider(IupVal) Test";
    }
    private IupLabel lbl_v;
    private IupLabel lbl_h;

    private void slider1_valueChanged(Object sender, CallbackEventArgs e)
    {
        IupSlider iupSlider = cast(IupSlider)sender;
        writefln("valueChanged %.2f", iupSlider.value);
        lbl_v.title = std.format.format("VALUE=%.2f", iupSlider.value);
    }    
    
    private void slider2_valueChanged(Object sender, CallbackEventArgs e)
    {
        IupSlider iupSlider = cast(IupSlider)sender;
        writefln("valueChanged %.2f", iupSlider.value);
        lbl_h.title = std.format.format("VALUE=%.2f", iupSlider.value);
    }


    private void slider_buttonPress(Object sender, CallbackEventArgs e, double a)
    {
        writefln("buttonPress %.2f", a);
    }

    private void slider_buttonRelease(Object sender, CallbackEventArgs e, double a)
    {
        writefln("buttonRelease %.2f", a);
    }

    private void slider_mouseMove(Object sender, CallbackEventArgs e, double a)
    {
        writefln("mouseMove %.2f", a);
    }
}