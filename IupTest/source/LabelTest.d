module LabelTest;

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



public class LabelTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupVbox box1 = new IupVbox();
        box1.margin = Size(5, 5);
        box1.gap = 5;
        box1.backgroundColor = Color.parse("75 150 170"); /* label must be transparent for BGCOLOR */
        box1.padding = Size(5,5);

        IupLabel label = new IupLabel("Text Labels (标签)");
        label.padding = Size(0, 0);
        label.tipText = "Text Label";
        box1.append(label);

        IupSeparator separator = new IupSeparator(Orientation.Horizontal);
        box1.append(separator);

        label = new IupLabel("Text &Label\nSecond Line");
        label.foregroundColor = Color.parse("0 0 255");
        label.rasterSize = Size(200, 70);
        //label.canWordWrap = true;
        //label.hasEllipsis = true;
        label.textAlignment = ContentAlignment.TopLeft;
        box1.append(label);

        label = new IupLabel("Text\nSecond Line");
        label.rasterSize = Size(200, 70);
        label.textAlignment = ContentAlignment.MiddleCenter;
        label.font = Font.parse("Helvetica, Underline 14");
        //label.fontSize = 14;
        box1.append(label);

        label = new IupLabel("Text\n<b>Second Line</b>");
        label.rasterSize = Size(200, 70);
        label.textAlignment = ContentAlignment.BottomRight;
        version(GTK) { label.canMarkup = true; }
        box1.append(label);

        //
        IupVbox box2 = new IupVbox();
        box2.margin = Size(5, 5);
        box2.gap = 5;
        box2.backgroundColor = Color.parse("75 150 170");

        //
        const int ImageSize = 20;
        IupImage8 image1 = new IupImage8(ImageSize, ImageSize, image_data_8);

        image1.useBackground(0);
        image1.setColor(1, Color.fromRgb(255, 0, 0));
        image1.setColor(2, Color.parse("0 255 0"));
        image1.setColor(3, Color.parse("0 0 255"));
        image1.setColor(4, Color.parse("255 255 255"));
        image1.setColor(5, Color.parse("0 0 0"));

        //
        label = new IupLabel();
        //label.image = image1;
        label.image = IupImages.Tecgraf;
        //label.image = "images/tecgraf.bmp";
        //label.image = "images/file_large.xbm";  // dosen't work
        label.padding = Size(0, 0);
        label.tipText = "Image Label";
        box2.append(label);

        separator = new IupSeparator(Orientation.Horizontal);
        box2.append(separator);

        //
        IupFill fill = new IupFill();
        fill.size = Size(20, 0);
        box2.append(fill);

        label = new IupLabel();
        label.image = image1;
        label.rasterSize = Size(150, 50);
        box2.append(label);

        //
        IupImage24 image2 = new IupImage24(ImageSize, ImageSize, image_data_24);

        label = new IupLabel();
        label.image = image2;
        label.rasterSize = Size(150, 50);
        label.textAlignment = ContentAlignment.MiddleCenter;
        box2.append(label);

        //
        IupImage32 image3 = new IupImage32(ImageSize, ImageSize, image_data_32);

        label = new IupLabel();
        label.image = image3;
        label.rasterSize = Size(150, 50);
        label.textAlignment = ContentAlignment.MiddleRight;
        label.mouseClick += &label_mouseClick;
        box2.append(label);

        IupAnimatedLabel animatedLabel = new IupAnimatedLabel();
        animatedLabel.animation = IupImages.CircleProgressAnimation;
        animatedLabel.start();
        box2.append(animatedLabel);

        IupHbox hbox = new IupHbox(box1, new IupSeparator(Orientation.Vertical), box2);
        this.child = hbox;
        this.title = "IupLabel Test";
    }

    private void label_mouseClick(Object sender, CallbackEventArgs args, 
                                   MouseButtons button, MouseState mouseState, 
                                   int x, int y, string status)
    {
        writefln("BUTTON_CB(but=%s (%s), x=%d, y=%d [%s])", button, mouseState, x, y, status);
    }



    // 20x20 8-bit
    private const(ubyte)[] image_data_8 = [
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


    // 20x20 24-bit
    private const(ubyte)[] image_data_24 = [
        000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000, 
        000,000,000,255,255,255,255,255,255,255,255,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,000,000,000,
        000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
    ];


    // 20x20 32-bit
    private const(ubyte)[] image_data_32 = [
        000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255, 
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,000,000,255,255,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,255,255,255,192,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,255,
        000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255,000,000,000,255
    ];
}


public class LinkLabelTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupLinkLabel linkEmpty = new IupLinkLabel(); // new IupLinkLabel(null, "Nothing");
        linkEmpty.title = "Nothing";
        linkEmpty.linkClicked += &linkLabel_linkClicked;

        IupLinkLabel linkButton = new IupLinkLabel("http://www.tecgraf.puc-rio.br/iup", "IUP Toolkit");
        linkButton.linkClicked += &linkLabel_linkClicked;

        IupLinkLabel linkButtonLabel = new IupLinkLabel("http://www.upf.br/", "Universidade de Passo Fundo");
        linkButtonLabel.linkClicked += &linkLabel_linkClicked;

        IupVbox vbox = new IupVbox(linkEmpty, linkButton, linkButtonLabel);
        vbox.gap = 10;

        this.child = vbox;
        this.title = "LinkLabel Test";
        this.margin = Size(10, 10);
        this.rasterSize = Size(500, 500);
    }

    private void linkLabel_linkClicked(Object sender, CallbackEventArgs e, string url)
    {
        IupLinkLabel label = cast(IupLinkLabel)sender;
        writefln("ACTION (%s)", url);
        writefln("url (%s)", label.url);
    }
}