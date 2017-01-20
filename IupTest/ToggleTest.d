module ToggleTest;


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

public class ToggleTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        //
        IupImage8 image1 = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8);
        Color background = image1.background;
        image1.setColor(0, background);
        //image1.useBackground(0);
        image1.setColor(1, Color.fromRgb(255, 0, 0));
        image1.setColor(2, Color.fromRgb(0, 255, 0));
        image1.setColor(3, Color.fromRgb(0, 0, 255));
        image1.setColor(4, Color.fromRgb(255, 255, 255));
        image1.setColor(5, Color.fromRgb(0, 0, 0));

        IupImage8 image1i = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8_inactive);
        background = image1i.background;
        image1i.setColor(0, background);
        image1i.setColor(1, Color.fromRgb(255, 0, 0));
        image1i.setColor(2, Color.fromRgb(0, 255, 0));
        image1i.setColor(3, Color.fromRgb(0, 0, 255));
        image1i.setColor(4, Color.fromRgb(255, 255, 255));
        image1i.setColor(5, Color.fromRgb(0, 0, 0));

        IupImage8 image1p = new IupImage8(TEST_IMAGE_SIZE, TEST_IMAGE_SIZE, image_data_8_pressed);
        background = image1p.background;
        image1p.setColor(0, background);
        image1p.setColor(1, Color.fromRgb(255, 0, 0));
        image1p.setColor(2, Color.fromRgb(0, 255, 0));
        image1p.setColor(3, Color.fromRgb(0, 0, 255));
        image1p.setColor(4, Color.fromRgb(255, 255, 255));
        image1p.setColor(5, Color.fromRgb(0, 0, 0));

        //
        IupImage32 image2 = new IupImage32(16, 16, image_data_32);

        IupToggleButton toggle1 = new IupToggleButton();
        toggle1.checked += &toggle_checked;
        toggle1.image = image1;
        toggle1.imageInactive = image1i;
        toggle1.imagePressed = image1p;
        toggle1.name = "1";

        //toggle1.padding = Size(10,10);
        //toggle1.rasterSize = Size(160, 160);
        //toggle1.size = Size(160, 160);
        //toggle1.canFocus = false;
        //toggle1.isFlat = true;
        //toggle1.imageAlignment = ContentAlignment.MiddleRight;


        IupToggleButton toggle2 = new IupToggleButton();
        toggle2.checked += &toggle_checked;
        toggle2.image = image2;
        toggle2.isFlat = true;
        toggle2.name = "2";

        IupToggleButton toggle3 = new IupToggleButton("&Text Toggle");
        toggle3.checked += &toggle_checked;
        toggle3.name = "3";

        IupToggleButton toggle4 = new IupToggleButton("&Radio Text");
        toggle4.checked += &toggle_checked;
        toggle4.name = "4";

        IupToggleButton toggle5 = new IupToggleButton("red background color");
        toggle5.checked += &toggle_checked;
        toggle5.name = "5";
        toggle5.backgroundColor = Color.fromRgb(255, 0, 0);
        toggle5.hasRightButton = true;

        IupToggleButton toggle6 = new IupToggleButton("multiple lines\nsecond line");
        toggle6.checked += &toggle_checked;
        toggle6.name = "6";
        toggle6.tooltip.text  = "Toggle Tip";

        IupToggleButton toggle7 = new IupToggleButton("INACTIVE");
        toggle7.checked += &toggle7_checked;
        toggle7.name = "7";
        toggle7.hasRightButton = true;

        toggle8 = new IupToggleButton("Courier 14 Bold font");
        toggle8.checked += &toggle_checked;
        toggle8.name = "8";
        toggle8.font = Font.parse("Courier, Bold 14");

        IupToggleButton toggle9 = new IupToggleButton("3 State");
        toggle9.checked += &toggle9_checked;
        toggle9.name = "9";
        toggle9.isThreeState = true;

        IupVbox vbox1 = new IupVbox(toggle1, toggle2, toggle3, toggle7, toggle9);
        IupVbox vbox2 = new IupVbox(toggle4, toggle5, toggle6, toggle8);
        IupRadioGroup radioGroup = new IupRadioGroup(vbox2);

        IupGroupBox groupBox = new IupGroupBox(radioGroup);
        groupBox.title = "Radio in a Frame";

        box3 = new IupHbox(vbox1, groupBox);
        this.child = box3;
        this.title = "IupToggle Test";
        this.margin = Size(5, 5);
        this.gap = 5;
    }
    private IupHbox box3;
    private IupToggleButton toggle8;

    private void toggle_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;

        if(state == ToggleState.On)
            writefln("Toggle %s - ON",tb.name);
        else

            writefln("Toggle %s - OFF",tb.name);
    }

    private void toggle7_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        box3.enabled = (state != ToggleState.On);
        IupToggleButton tb = cast(IupToggleButton) sender;
        tb.enabled = true;
    }

    private void toggle9_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;

        if(state == ToggleState.On)
            writefln("Toggle 9 - ON");
        else if(state == ToggleState.Off)
            writefln("Toggle 9 - OFF");
        else
            writefln("Toggle 9 - NOTDEF");

        toggle8.isChecked = state == ToggleState.On;
    }
   

    enum TEST_IMAGE_SIZE = 20;

    const(ubyte)[] image_data_8 = [
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,3,4,4,4,4,4,4,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
    ];

    const(ubyte)[] image_data_8_pressed = [
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,5,1,1,1,1,1,2,2,2,2,2,5,0,0,0,5, 
        5,0,0,0,1,5,1,1,1,1,2,2,2,2,5,2,0,0,0,5, 
        5,0,0,0,1,1,5,1,1,1,2,2,2,5,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,5,1,1,2,2,5,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,5,1,2,5,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,1,5,5,2,2,2,2,2,0,0,0,5, 
        5,0,0,0,3,3,3,3,3,5,5,4,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,5,3,4,5,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,5,3,3,4,4,5,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,5,3,3,3,4,4,4,5,4,4,0,0,0,5, 
        5,0,0,0,3,5,3,3,3,3,4,4,4,4,5,4,0,0,0,5, 
        5,0,0,0,5,3,3,3,3,3,4,4,4,4,4,5,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
    ];

    const(ubyte)[] image_data_8_inactive = [
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,5,5,1,1,1,1,1,1,1,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,5,5,5,1,5,5,5,5,5,5,0,0,0,5, 
        5,0,0,0,5,5,1,1,1,1,1,1,1,5,5,5,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
    ];



    // 16x16*4
    const(ubyte)[] image_data_32 = [
        255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 183, 182, 245, 255, 183, 182, 245, 255, 179, 178, 243, 255, 174, 173, 241, 255, 168, 167, 238, 255, 162, 161, 234, 255, 155, 154, 231, 255, 148, 147, 228, 255, 143, 142, 224, 255, 136, 135, 221, 255, 129, 128, 218, 255, 123, 122, 214, 255, 117, 116, 211, 255, 112, 111, 209, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 179, 178, 243, 255, 190, 189, 255, 255, 147, 146, 248, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 75, 88, 190, 255, 89, 88, 176, 255, 89, 88, 176, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 173, 172, 240, 255, 190, 189, 255, 255, 138, 137, 239, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 63, 82, 184, 255, 51, 51, 103, 255, 86, 85, 170, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 167, 166, 237, 255, 190, 189, 255, 255, 129, 128, 230, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 52, 77, 179, 255, 122, 121, 223, 255, 83, 82, 164, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 159, 158, 233, 255, 190, 189, 255, 255, 119, 118, 220, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 210, 219, 234, 255, 40, 71, 173, 255, 114, 113, 215, 255, 80, 79, 159, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 152, 151, 229, 255, 190, 189, 255, 255, 110, 109, 211, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 210, 219, 234, 255, 198, 209, 229, 255, 28, 65, 167, 255, 103, 103, 204, 255, 77, 77, 154, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 146, 145, 226, 255, 190, 189, 255, 255, 103, 102, 204, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 248, 251, 255, 234, 238, 246, 255, 222, 229, 240, 255, 210, 219, 234, 255, 198, 209, 229, 255, 189, 202, 225, 255, 17, 59, 161, 255, 92, 93, 194, 255, 74, 74, 148, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 139, 138, 223, 255, 188, 187, 255, 255, 183, 182, 255, 255, 96, 99, 201, 255, 86, 94, 196, 255, 75, 88, 190, 255, 63, 82, 184, 255, 52, 77, 179, 255, 40, 71, 173, 255, 28, 65, 167, 255, 17, 59, 161, 255, 92, 93, 193, 255, 84, 86, 186, 255, 71, 71, 143, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 132, 131, 219, 255, 180, 179, 255, 255, 174, 173, 255, 255, 164, 163, 252, 255, 143, 142, 244, 255, 135, 134, 236, 255, 129, 128, 230, 255, 122, 121, 223, 255, 114, 113, 215, 255, 108, 107, 209, 255, 92, 93, 193, 255, 84, 86, 186, 255, 76, 80, 178, 255, 68, 68, 137, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 124, 123, 215, 255, 170, 169, 255, 255, 160, 159, 251, 255, 148, 147, 245, 255, 75, 91, 113, 255, 75, 91, 113, 255, 75, 91, 113, 255, 75, 91, 113, 255, 82, 98, 118, 255, 91, 106, 125, 255, 84, 86, 186, 255, 76, 79, 178, 255, 68, 73, 170, 255, 65, 65, 131, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 118, 117, 212, 255, 160, 159, 255, 255, 145, 144, 245, 255, 135, 134, 236, 255, 75, 91, 113, 255, 0, 0, 0, 255, 52, 60, 71, 255, 206, 217, 233, 255, 212, 221, 236, 255, 103, 116, 133, 255, 67, 75, 174, 255, 68, 73, 170, 255, 60, 66, 163, 255, 62, 62, 125, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 112, 111, 209, 255, 154, 153, 255, 255, 135, 134, 236, 255, 129, 128, 230, 255, 75, 91, 113, 255, 52, 60, 71, 255, 104, 120, 141, 255, 216, 224, 237, 255, 224, 231, 241, 255, 115, 127, 143, 255, 53, 65, 163, 255, 60, 66, 162, 255, 53, 61, 156, 255, 60, 59, 120, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 108, 107, 207, 255, 143, 142, 243, 255, 129, 128, 230, 255, 36, 68, 170, 255, 33, 50, 71, 255, 171, 180, 195, 255, 179, 187, 198, 255, 188, 193, 202, 255, 196, 200, 206, 255, 72, 77, 86, 255, 51, 62, 158, 255, 54, 61, 156, 255, 49, 57, 152, 255, 57, 57, 114, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 108, 107, 207, 84, 101, 100, 195, 255, 86, 85, 170, 255, 83, 82, 164, 255, 80, 79, 159, 255, 77, 77, 154, 255, 74, 74, 148, 255, 71, 71, 143, 255, 68, 68, 137, 255, 65, 65, 131, 255, 60, 59, 120, 255, 60, 59, 120, 255, 57, 57, 114, 255, 55, 54, 110, 255, 255,  0, 255, 255,
        255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255,  0, 255, 255, 255, 0, 255, 255
    ];
}