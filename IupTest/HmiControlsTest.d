module HmiControlsTest;

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


// TODO: load widgets from *.led
public class DialTestDialog : IupDialog
{
    private IupDial dial_h;
    private IupDial dial_v;
    private IupDial dial_c;

    private IupLabel lbl_h;
    private IupLabel lbl_v;
    private IupLabel lbl_c;

    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {
        dial_v = new IupDial(DialLayoutOrientation.Vertical);
        dial_v.unit = IupAngleUnit.Degrees;
        dial_v.mouseDown += &dial_mouseDown;
        dial_v.mouseUp += &dial_mouseUp;
        dial_v.mouseMove += &dial_mouseMove;

        dial_h = new IupDial(DialLayoutOrientation.Horizontal);
        dial_h.mouseDown += &dial_mouseDown;
        dial_h.mouseUp += &dial_mouseUp;
        dial_h.mouseMove += &dial_mouseMove;

        dial_c = new IupDial(DialLayoutOrientation.Circular);
        dial_c.unit = IupAngleUnit.Degrees;
        dial_c.mouseDown += &dial_mouseDown;
        dial_c.mouseUp += &dial_mouseUp;
        dial_c.mouseMove += &dial_mouseMove;

        lbl_v = new IupLabel("0");
        lbl_v.size = Size(50, 0);

        lbl_h = new IupLabel("0");
        lbl_h.size = Size(50, 0);

        lbl_c = new IupLabel("0");
        lbl_c.size = Size(50, 0);

        IupHbox hbox1 = new IupHbox(dial_v, lbl_v);
        hbox1.alignment = VerticalAlignment.Center;

        IupHbox hbox2 = new IupHbox(dial_h, lbl_h);
        hbox2.alignment = VerticalAlignment.Center;

        IupHbox hbox3 = new IupHbox(dial_c, lbl_c);
        hbox3.alignment = VerticalAlignment.Center;

        IupVbox vbox = new IupVbox(hbox1, hbox2, hbox3);
        vbox.margin = Size(10, 10);
        vbox.gap = 10;

        this.child = vbox;
        this.title = "IupDial Test";
    }


    private void dial_mouseDown(Object sender, CallbackEventArgs e, double a)
    {
        printdial(cast(IupDial)sender, a, "0 255 0");
    }


    private void dial_mouseUp(Object sender, CallbackEventArgs e, double a)
    {
        printdial(cast(IupDial)sender, a, "255 0 0");
    }


    private void dial_mouseMove(Object sender, CallbackEventArgs e, double a)
    {
        printdial(cast(IupDial)sender, a, "");
    }

    private void printdial(IupDial dial, double a, string color)
    {
        DialLayoutOrientation orientation = dial.orientation;
        if( orientation == DialLayoutOrientation.Vertical)
        {
            lbl_v.title = std.format.format("%.3g %s", a, "deg");
            lbl_v.backgroundColor = color;

        }
        else if(orientation == DialLayoutOrientation.Horizontal)
        {
            lbl_h.title = std.format.format("%.3g %s", a, "rad");
            lbl_h.backgroundColor = color;
        }
        else if(orientation == DialLayoutOrientation.Circular)
        {
            lbl_c.title = std.format.format("%.3g %s", a, "deg");
            lbl_c.backgroundColor = color;
        }

    }
}