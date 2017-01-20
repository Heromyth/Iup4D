module SplitTest;

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


public class SplitTestDialog : IupDialog
{
    private IupButton bt;
    private IupSplitContainer split;

    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {
        bt = new IupButton("Button");
        bt.click += &bt_click;
        bt.canExpand = true;
        //bt.minSize = Size(30, 0);
        //bt.rasterSize = Size(30, 0);

        IupMultiLine ml = new IupMultiLine();
        ml.canExpand = true;
        ml.visibleLines = 5;
        ml.visibleColumns = 10;
        ml.text = "Multiline";
        //ml.minSize = Size(30, 0);

        split = new IupSplitContainer(bt, ml);
        split.orientation = Orientation.Vertical;
        split.color = Color.parse("0 255 0");
        //split.canUpdateLayout = false;
        split.canAutoHide = true;
        //split.canShowGrip = false;
        split.cropRange = "100:800";

        split.splitterMoved += &split_splitterMoved;


        IupVbox vbox = new IupVbox(split);
        vbox.margin = Size(10, 10);
        vbox.gap = 10;

        this.child = vbox;
        this.title = "IupSplit Example";
    }

    private void bt_click(Object sender, CallbackEventArgs e)
    {
        split.proportion = 0;
    }

    private void split_splitterMoved(Object sender, CallbackEventArgs e)
    {
        writefln("splitter: %d", split.proportion);
    }


}
