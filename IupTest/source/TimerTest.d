module TimerTest;

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


public class TimerTestDialog : IupDialog
{
    private IupTimer timer1, timer2, timer3;
    private IupButton startBtn;

    this() 
    {
        super();
    }

    ~this()
    {
        timer1.destroy();
        timer2.destroy();
        timer3.destroy();
    }

    protected override void initializeComponent() 
    {
        startBtn = new IupButton("Start timer");
        startBtn.click += &startBtn_click;

        timer1 = new IupTimer();
        timer1.interval = 200;
        timer1.tick += &timer1_tick;

        timer2 = new IupTimer();
        timer2.interval = 400;
        timer2.tick += &timer2_tick;

        timer3 = new IupTimer();
        timer3.interval = 5000;
        timer3.tick += &timer3_tick;

        IupVbox vbox = new IupVbox(startBtn);

        this.child = vbox;
        this.gap = 10;
        this.margin = Size(200, 100);
        this.title = "IupTimer Test";
    }

    private void startBtn_click(Object sender, CallbackEventArgs e)
    {
        startBtn.enabled = false;

        timer1.start();
        timer2.start();
        timer3.start();
    }

    void timer1_tick(Object sender, CallbackEventArgs args)
    {
        writefln("timer 1 called");
    }

    void timer2_tick(Object sender, CallbackEventArgs args)
    {
        writefln("timer 2 called and stopped");
        timer2.stop();
    }

    void timer3_tick(Object sender, CallbackEventArgs args)
    {
        writefln("timer 3 called and all timers are stopped.");

        timer1.stop();
        timer3.stop();

        startBtn.enabled = true;
    }
}

