module IdleTest;

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


public class IdleTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    ~this()
    {
    }

    protected override void initializeComponent() 
    {
        IupToggleButton toggleBtn = new IupToggleButton();
        toggleBtn.checked += &toggle_checked;

        this.child = toggleBtn;
        this.rasterSize = Size(500, 500);
        this.title = "Idle Test";
    }


    private void toggle_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;

        if(state == ToggleState.On)
            Application.idle += &application_idle;
        else
        {
            Application.idle -= &application_idle;
        }
    }

    private static void application_idle(CallbackEventArgs args)
    {
        writefln("IDLE_ACTION(count = %d)", idle_count++);
    }


    static int idle_count = 0;

}
