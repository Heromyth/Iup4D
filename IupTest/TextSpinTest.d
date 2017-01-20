module TextSpinTest;

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


public class TextSpinTestDialog : IupDialog
{
    private IupIntegerUpDown integerUpDown;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        integerUpDown = new IupIntegerUpDown();
        integerUpDown.minimum = 5;
        integerUpDown.maximum = 50;
        integerUpDown.increment = 10;
        integerUpDown.value = 13;
        integerUpDown.name = "spin";
        integerUpDown.size = Size(60,0); 
        //integerUpDown.mask = NumberMaskStyle.Int;
        //integerUpDown.canWrap = true;
        //integerUpDown.spinAlignment = SpinAlignment.Left;
        //integerUpDown.canAutomaticUpdate = false;
        integerUpDown.spinned += &integerUpDown_spinned;
        integerUpDown.valueChanged += &integerUpDown_valueChanged;
        integerUpDown.valueChanging += &integerUpDown_valueChanging;

        IupLabel intLabel = new IupLabel("IntegerUpDown");

        IupHbox hbox1 = new IupHbox(intLabel, integerUpDown);
        hbox1.gap = 10;
        
        // TODO: more tests
        IupFloatUpDown floatUpDown = new IupFloatUpDown();
        floatUpDown.minimum = 1;
        floatUpDown.maximum = 10;
        floatUpDown.increment = 1.5f;
        floatUpDown.value = 3.5f;
        floatUpDown.name = "spin2";
        floatUpDown.size = Size(60,0); 
        //floatUpDown.spinned += &floatUpDown_spinned;
        //floatUpDown.valueChanged += &floatUpDown_valueChanged;
        //floatUpDown.valueChanging += &floatUpDown_valueChanging;

        IupLabel floatLabel = new IupLabel("IupFloatUpDown");

        IupHbox hbox2 = new IupHbox(floatLabel, floatUpDown);
        hbox2.gap = 10;

        IupButton btn = new IupButton("Spin Value");
        btn.click += &btn_click;


        IupVbox vbox = new IupVbox(new IupFill(), hbox1, hbox2, btn);

        this.child = vbox;
        this.gap = 20;
        this.margin = Size(20, 20);
        this.title = "Text Spin Test";
    }

    private void integerUpDown_spinned(Object sender, CallbackEventArgs e, int pos)
    {
        writefln("spinned(%d)", pos);
        if(!integerUpDown.canAutomaticUpdate)
        {
            integerUpDown.text = std.format.format("Test(%d)", pos);
        }

        if(pos == 10)
            e.result = CallbackResult.Ignore;
    }


    private void integerUpDown_valueChanged(Object sender, CallbackEventArgs e)
    {
        writefln("valueChanged(%d)", integerUpDown.value);
    }

    private void integerUpDown_valueChanging(Object sender, CallbackEventArgs e, int c, string newValue)
    {
        writefln("valueChanging(%d, %s)", c, newValue);
    }

    private void btn_click(Object sender, CallbackEventArgs e)
    {
        integerUpDown.value = 25;

        if(!integerUpDown.canAutomaticUpdate)
            integerUpDown.text = std.format.format("Test(%d)", 25);
    }
}