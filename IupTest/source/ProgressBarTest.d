module ProgressBarTest;


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


public class ProgressBarTestDialog : IupDialog
{
    private IupTimer timer;
    private IupProgressBar progressbar1, progressbar2;
    private IupButton btn_restart, btn_pause, btn_accelerate;
    private IupButton btn_decelerate, btn_show1, btn_show2;
    private float increment = 0.1f;
    private IupImage8 img_play, img_pause;

    this() 
    {
        super();
    }

    ~this()
    {
        writeln("~this");
    }

    protected override void initializeComponent() 
    {
        IupImage8 img_restart = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, pixmap_restart);
        Color background = img_restart.background;
        img_restart.setColor(0, Color.fromRgb(0, 0, 0));
        img_restart.setColor(1, background);

        img_play = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, pixmap_play);
        background = img_play.background;
        img_play.setColor(0, Color.fromRgb(0, 0, 0));
        img_play.setColor(1, background);

        IupImage8 img_forward = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, pixmap_forward);
        background = img_forward.background;
        img_forward.setColor(0, Color.fromRgb(0, 0, 0));
        img_forward.setColor(1, background);

        IupImage8 img_rewind = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, pixmap_rewind);
        background = img_rewind.background;
        img_rewind.setColor(0, Color.fromRgb(0, 0, 0));
        img_rewind.setColor(1, background);

        img_pause = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, pixmap_pause);
        background = img_pause.background;
        img_pause.setColor(0, Color.fromRgb(0, 0, 0));
        img_pause.setColor(1, background);
         
        timer = new IupTimer();
        timer.interval = 100;
        timer.tick += &timer_tick;

        progressbar1 = new IupProgressBar();
        progressbar1.canExpand = true;
        progressbar1.isMarqueeStyle = true;


        progressbar2 = new IupProgressBar();
        progressbar2.orientation = Orientation.Vertical;
        progressbar2.backgroundColor = Color.fromRgb(255, 0, 128);
        progressbar2.foregroundColor = Color.fromRgb(0, 128, 0);
        progressbar2.rasterSize = Size(30, 100);
        progressbar2.maximum = 50;
        progressbar2.value = 25;
        // progressbar2.isDashed = false;


        btn_restart = new IupButton();
        btn_restart.click += &btn_restart_click;
        btn_restart.image = img_restart;
        btn_restart.tooltip.text  = "Restart";

        btn_pause = new IupButton();
        btn_pause.click += &btn_pause_click;
        btn_pause.image = img_play;
        btn_pause.tooltip.text  = "Play/Pause";

        btn_accelerate = new IupButton();
        btn_accelerate.click += &btn_accelerate_click;
        btn_accelerate.image = img_forward;
        btn_accelerate.tooltip.text  = "Accelerate";

        btn_decelerate = new IupButton();
        btn_decelerate.click += &btn_decelerate_click;
        btn_decelerate.image = img_rewind;
        btn_decelerate.tooltip.text  = "Decelerate";

        btn_show1 = new IupButton("Dashed");
        btn_show1.click += &btn_show1_click;
        btn_show1.tooltip.text  = "Dashed or Continuous";

        btn_show2 = new IupButton("Marquee");
        btn_show2.click += &btn_show2_click;
        btn_show2.tooltip.text  = "Marquee or Defined";

        IupHbox hbox1 = new IupHbox(new IupFill(), 
                                    btn_pause,
                                    btn_restart,
                                    btn_decelerate,
                                    btn_accelerate,
                                    btn_show1,
                                    btn_show2,
                                    new IupFill());

        IupVbox vbox1 = new IupVbox(progressbar1, hbox1);

        IupHbox hbox = new IupHbox(vbox1, progressbar2);
        hbox.margin = Size(10, 10);
        hbox.gap = 5;

        this.child = hbox;
        this.title = "ProgressBar Test";
        this.unmapped += &dialog_unmapped;
        this.destroying += &dialog_destroying;
        this.closing += &dialog_closing;
    }


    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        timer.enabled = false;
        writeln("dialog_closing");
    }

    private void dialog_destroying(Object sender, CallbackEventArgs e)
    {
        timer.destroy();
        writeln("dialog_destroying");
    }

    private void dialog_unmapped(Object sender, CallbackEventArgs e)
    {
        writeln("dialog_unmapped");
    }

    private void btn_restart_click(Object sender, CallbackEventArgs e)
    {
        progressbar2.value = 0;
    }


    private void btn_pause_click(Object sender, CallbackEventArgs e)
    {
        bool ee = timer.enabled;
        if(timer.enabled)
        {
            progressbar1.isMarqueeStyle = false;
            timer.enabled = false;
            btn_pause.image = img_play;
        }
        else
        {
            progressbar1.isMarqueeStyle = true;
            timer.enabled = true;
            btn_pause.image = img_pause;
        }
    }


    private void btn_accelerate_click(Object sender, CallbackEventArgs e)
    {
        increment *= 2;
    }


    private void btn_decelerate_click(Object sender, CallbackEventArgs e)
    {
        increment /= 2;
    }


    private void btn_show1_click(Object sender, CallbackEventArgs e)
    {
        progressbar2.isDashed = !progressbar2.isDashed;
    }


    private void btn_show2_click(Object sender, CallbackEventArgs e)
    {
        progressbar2.isMarqueeStyle =  !progressbar2.isMarqueeStyle;
    }

    void timer_tick(Object sender, CallbackEventArgs args)
    {
        int value = progressbar2.value;
        value += cast(int)(increment*50);
        if (value > 50) value = 0; /* start over */
        progressbar2.value = value;

        writefln("value=%d", value);
    }


    enum TEST_IMAGE_SIZE = 22;

    private const(ubyte)[] pixmap_play = [
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 
    ];

    private const(ubyte)[] pixmap_restart = [
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,2,2,2,2,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,1,1,1,1,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,1,1,1,1,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,2,2,2,2,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,1,1,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 
    ];

    private const(ubyte)[] pixmap_rewind = [
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,2,2,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,2,1,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,1,1,1,1,2,1,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,2,2,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    ];

    private const(ubyte)[] pixmap_forward = [
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,2,1,1,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,2,2,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,1,2,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,1,2,1,1,1,1,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,1,2,2,1,1,1,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,2,1,1,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    ];

    private const(ubyte)[] pixmap_pause = [
        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,1,1,2,2,1,1,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    ];
}
