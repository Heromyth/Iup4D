module CalendarTest;

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

public class CalendarTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {

        IupButton button = new IupButton("Set Value");
        //button.title = "Set Value";
        button.click += &button_click;

        calendar = new IupCalendar();
        calendar.valueChanged += &calendar_valueChanged;

        datePicker = new IupDatePicker();
        datePicker.format = "ddd', 'd' of 'MMMM' ('yy')'";
        datePicker.isZeroPreceded = true;
        datePicker.useShortName = true;
        datePicker.order = "DMY";
        datePicker.valueChanged += &datePicker_valueChanged;

        IupVbox box = new IupVbox();
        box.append(button, calendar, datePicker);
        box.margin = Size(10, 10);
        box.gap = 10;

        this.child = box;
        this.title = "IupCalendar Test";
    }
    private IupCalendar calendar;
    private IupDatePicker datePicker;


    private void button_click(Object sender, CallbackEventArgs e)
    {
        calendar.value = "1970/07/11";
        datePicker.value = "1970/07/11";  // TODO: bug
    }

    private void calendar_valueChanged(Object sender, CallbackEventArgs e)
    {
        writefln("VALUE_CB(%s)", calendar.value);
    }

    private void datePicker_valueChanged(Object sender, CallbackEventArgs e)
    {
        writefln("VALUE_CB(%s)", datePicker.value);
    }


}
