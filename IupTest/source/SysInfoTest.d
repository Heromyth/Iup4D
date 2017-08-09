module SysInfoTest;

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


public class SysInfoTestDialog : IupDialog
{
    private IupButton startBtn;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        startBtn = new IupButton("Detect");
        startBtn.click += &startBtn_click;

        IupHbox hbox = new IupHbox(new IupFill(), startBtn, new IupFill());

        IupVbox vbox = new IupVbox(new IupFill(), hbox, new IupFill());
        vbox.canExpand = true;
        vbox.alignment = HorizontalAlignment.Center;

        this.child = vbox;
        this.size = Size(200, 100);
        this.title = "System Info Test";
    }

    private void startBtn_click(Object sender, CallbackEventArgs e)
    {
        writefln("IUP System Info:");
        writefln("  Version: %s", Environment.IUP.ver);
        writefln("  Copyright: %s", Environment.IUP.copyright);
        writefln("  Driver: %s", Environment.IUP.driver);
        writefln("  System: %s", Environment.OS.name);
        writefln("  System Version: %s", Environment.OS.ver);
        writefln("  System Language: %s (IUP Language: %s)", Environment.OS.language, Environment.IUP.language);
        writefln("  System Locale: %s (IUP UTF-8: %s)\n", Environment.OS.locale, Environment.IUP.isUtf8Mode);

        writefln("  Screen Depth: %s", Environment.Screen.depth);
        writefln("  Screen Size: %s", Environment.Screen.size);
        writefln("  Screen DPI: %s", Environment.Screen.dpi);
        writefln("  Full Screen Size: %s", Environment.Screen.fullSize);

        writefln("  Virtual Screen: %s", Environment.Screen.virtualScreen);
        writefln("  Monitors Info: %s", Environment.Screen.monitorsInfo);

        writefln("  Computer Name: %s", Environment.computerName);
        writefln("  User Name: %s", Environment.userName);
        writefln("  Default Font: %s", Environment.defaultFont);

    }
}
