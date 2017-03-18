module TrayTest;

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


public class TrayTestDialog : IupDialog
{
    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {

        IupImage8 image = new IupImage8(16, 16, pixmap_8);
        image.useBackground(0);
        image.setColor(1, Color.fromRgb(255, 255, 0));
        image.setColor(2, Color.parse("255 0 0"));
        image.setColor(3, Color.parse("255 255 0"));

        IupTray m_tray = this.tray;
        m_tray.enabled = true;
        version(Windows)
        {
            m_tray.hasTipBalloon = true;
            m_tray.tipBalloonTitle = "Test Title";
            m_tray.tipBalloonIco = BalloonIco.Info;
        }
        m_tray.tipText = "Tip at Tray";
        m_tray.image = image;

        this.size = Size(100, 100);
        this.title = "Tray Test";

        this.closing += &dialog_closing;
        this.trayClick += &dialog_trayClick;

        /* start only the task bar icon */
        //this.canHideTaskBar = true; // works after show() is called
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        this.canHideTaskBar = true;
        e.result = IupElementAction.Ignore;
    }

    private void dialog_trayClick(Object sender, CallbackEventArgs e, int button, bool pressed, bool dclick)
    {
        writefln("trayclick_cb(button=%d, pressed=%s, dclick=%s)", button, pressed, dclick);
        if (button == 1 && pressed)
            this.canHideTaskBar = false;
        else if (button == 3 && pressed)
            showMenu();
    }

    private void showMenu()
    {
        IupMenuItem showMenuItem = new IupMenuItem("Show");
        showMenuItem.click += &showMenuItem_click;

        IupMenuItem hideMenuItem =  new IupMenuItem("Hide");
		hideMenuItem.click += &hideMenuItem_click;

        IupMenuItem exitMenuItem =  new IupMenuItem("Exit");
		exitMenuItem.click += &exitMenuItem_click;

        IupMenu menu = new IupMenu(showMenuItem, hideMenuItem);
        menu.items.append(exitMenuItem);

        menu.popup(ScreenPostionH.MousePos, ScreenPostionV.MousePos);

        menu.dispose();
    }


    private void showMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.canHideTaskBar = false;
    }

    private void hideMenuItem_click(Object sender, CallbackEventArgs e)
    {
        this.canHideTaskBar = true;
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