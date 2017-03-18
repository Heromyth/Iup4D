module ContainerTest;

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


// 32x32 8-bit
private const(ubyte)[] img_bits2 = [
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2
        ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2
        ,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2
        ,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2
        ,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2
        ,2,2,2,2,2,2,2,2,2,2,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2
        ,2,2,2,2,2,2,2,2,2,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2
        ,2,2,2,2,2,2,2,2,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        ,3,3,3,0,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        ,3,3,3,0,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        ,3,3,3,0,3,0,3,0,3,3,0,3,3,3,1,1,0,3,3,3,0,0,3,0,3,3,0,0,0,3,3,3
        ,3,3,3,0,3,0,0,3,0,0,3,0,3,0,1,1,3,0,3,0,3,3,0,0,3,0,3,3,3,0,3,3
        ,3,3,3,0,3,0,3,3,0,3,3,0,3,3,1,1,3,0,3,0,3,3,3,0,3,0,3,3,3,0,3,3
        ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        ,3,3,3,0,3,0,3,3,0,3,3,0,3,0,1,1,3,0,3,0,3,3,0,0,3,0,3,3,3,0,3,3
        ,3,3,3,0,3,0,3,3,0,3,3,0,3,3,1,1,0,0,3,3,0,0,3,0,3,3,0,0,0,3,3,3
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,0,3,3,3,3,3,3,3,3
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,0,3,3,3,0,3,3,3,3,3,3,3,3
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,0,0,0,3,3,3,3,3,3,3,3,3
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        ,2,2,2,2,2,2,2,3,3,3,3,3,3,3,1,1,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2
        ,2,2,2,2,2,2,3,3,3,3,3,3,3,3,1,1,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2
        ,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2
        ,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2
        ,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
        ,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
        ,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
        ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
];


public class ExpanderTestDialog : IupDialog
{
    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupImage8 img2 = new IupImage8(32, 32, img_bits2);
        img2.setColor(0, Color.fromRgb(0, 0, 0));
        img2.setColor(1, Color.fromRgb(0, 255, 0));
        img2.useBackground(2);
        img2.setColor(3, Color.parse("255 0 0"));

        IupImage8 image_close = new IupImage8(16, 16, img_plus);
        image_close.useBackground(0);
        image_close.setColor(1, Color.parse("255 255 255"));

        IupImage8 image_high = new IupImage8(16, 16, img_plus);
        image_high.useBackground(0);
        image_high.setColor(1, Color.fromRgb(192, 192, 192));

        IupImage8 image_open = new IupImage8(16, 16, img_minus);
        image_open.useBackground(0);
        image_close.setColor(1, Color.parse("255 255 255"));

        //
        IupButton btn1 = new IupButton("Button Text");
        btn1.padding = Size(5, 5);
        btn1.tipText = "Button TIP";

        IupButton btn2 = new IupButton("Text");
        btn2.padding = Size(5, 5);

        IupVbox vbox1 = new IupVbox(btn1, btn2);

        //
        IupToggle toggle1 = new IupToggle("Toggle Text");
        toggle1.isChecked = true;
        toggle1.tipText = "Toggle TIP";

        IupToggle toggle2 = new IupToggle();
        toggle2.isChecked = true;
        toggle2.image = IupImages.Tecgraf;
        toggle2.imagePressed = img2;

        IupToggle toggle3 = new IupToggle();
        toggle3.isChecked = true;
        toggle3.image = IupImages.Tecgraf;

        IupRadioGroup radioGroup = new IupRadioGroup(new IupVbox(new IupToggle("Toggle Text"),
                                                                 new IupToggle("Toggle Text")));
        IupGroupBox groupBox = new IupGroupBox(radioGroup);
        groupBox.title = "IupRadio";

        IupVbox vbox3 = new IupVbox(toggle1, toggle2, toggle3, groupBox);

        IupBackgroundBox backgroundBox = new IupBackgroundBox(vbox3);
        backgroundBox.backgroundColor = "255 255 255";
        backgroundBox.hasBorder = true;
        //backgroundBox.setPaintEvent(false);

        IupExpander _frm_3 = new IupExpander(backgroundBox);
        _frm_3.title = "IupExpander";
        _frm_3.foregroundColor = "255 255 255";
        _frm_3.barBackground = "100 150 250";
        _frm_3.animationStyle = ExpanderAnimationStyle.Slide;
        //_frm_3.barSize = 50;
        _frm_3.canTitleExpand = true;
        _frm_3.titleHighlightColor = "192 192 192";
        
        //_frm_3.titleOpenColor = "0 0 192";

        _frm_3.extraButtonsCount = 3;
        _frm_3.setExtraButtonImage(1, image_close);
        _frm_3.setExtraButtonPressedImage(1, image_open);
        _frm_3.setExtraButtonHighlightImage(1, image_high);

        _frm_3.setExtraButtonImage(2, image_close);
        _frm_3.setExtraButtonPressedImage(2, image_open);
        _frm_3.setExtraButtonHighlightImage(2, image_high);

        _frm_3.setExtraButtonImage(3, image_close);
        _frm_3.setExtraButtonPressedImage(3, image_open);
        _frm_3.setExtraButtonHighlightImage(3, image_high);

        _frm_3.stateChanged += &_frm_3_stateChanged;
        _frm_3.stateChanging += &_frm_3_stateChanging;
        _frm_3.extraMouseClick += &_frm_3_extraMouseClick;


        IupHbox _hbox_1 = new IupHbox(
                          //    _frm_1,
                          //    _frm_2,
                          _frm_3,
                          //    _frm_4,
                          //    _frm_5
                          );

        IupVbox _vbox_1 = new IupVbox(
                          _hbox_1);

        _vbox_1.margin = Size(5, 5);
        _vbox_1.gap = 5;


        this.child = _vbox_1;
        this.title = "IupExpander Test";
        this.margin = Size(10, 10);

        this.loaded += &dialog_loaded;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs e)
    {
    }

    private void _frm_3_stateChanged(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writef("ACTION(%s)\n", element.className);
    }

    private void _frm_3_stateChanging(Object sender, CallbackEventArgs e, ExpanderState state)
    {
        IupElement element = cast(IupElement)sender;
        writef("OPENCLOSE_CB(%s, state=%s)\n", element.className, state);
    }

    private void _frm_3_extraMouseClick(Object sender, CallbackEventArgs e, 
                                   int button, MouseState mouseState)
    {
        IupElement element = cast(IupElement)sender;
        writef("EXTRABUTTON_CB(%s, but=%s, press=%s)\n", element.className, button, mouseState);
    }


    // 16x16 8-bit
    private const(ubyte)[] img_plus = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
        0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];

    // 16x16 8-bit
    private const(ubyte)[] img_minus = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
        0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
}


public class GridBoxTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {

        IupLabel col1 = new IupLabel("col1");
        col1.fontStyle = FontStyles.Bold;

        IupLabel col2 = new IupLabel("col2");
        col2.fontStyle = FontStyles.Bold;

        IupLabel lin1 = new IupLabel("lin1");
        lin1.fontStyle = FontStyles.Bold;

        IupLabel lbl = new IupLabel("lbl");
        IupButton but = new IupButton("but");

        IupLabel lin2 = new IupLabel("lin2");
        lin2.fontStyle = FontStyles.Bold;

        IupLabel label = new IupLabel("label");
        IupButton button = new IupButton("button");

        IupLabel lin3 = new IupLabel("lin3");
        lin3.fontStyle = FontStyles.Bold;

        IupLabel largeLabel  = new IupLabel("label large");
        IupButton largeButton = new IupButton("button large");

        IupGridBox gbox = new IupGridBox(new IupLabel(), col1, col2,
                                         lin1, lbl, but,
                                         lin2, label, button,
                                         lin3, largeLabel, largeButton);

        gbox.columnCount = 2;
        gbox.rowCount = 3;

        //gbox.isSameColumnWidth = true;
        //gbox.isSameRowHeight = true;
        //gbox.expandOrientation = ExpandOrientation.Horizontal;

        gbox.divisionNumber = 3;

        //gbox.layoutOrientation = Orientation.Horizontal;
        //gbox.columnCount = 3;
        //gbox.rowCount = 2;

        //gbox.size = Size(70, 0);
        //gbox.divisionNumber = -1;
        //gbox.normalizeSize = NormalizeSize.Both;
        gbox.verticalAlignment = VerticalAlignment.Center;
        gbox.margin = Size(10, 10);
        gbox.rowGap = 5;
        gbox.columnGap = 5;

        IupGroupBox groupBox = new IupGroupBox(gbox);
        groupBox.margin = Size(0, 0); /* avoid attribute propagation */

        IupHbox hbox = new IupHbox(groupBox);

        this.child = hbox;
        this.title = "IupGridBox Test";
        this.margin = Size(10, 10);

        this.loaded += &dialog_loaded;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs e)
    {
    }
}


public class GroupBoxTestDialog : IupDialog
{
    private IupGroupBox groupBox1;
    private IupGroupBox groupBox2;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupLabel label = new IupLabel("Label2");
        label.size = Size(70, 0);

        IupVbox vbox = new IupVbox(new IupLabel("Label1"),
                                   label,
                                   new IupLabel("Label3"));

        groupBox1 = new IupGroupBox(vbox);
        groupBox1.title = "Title Text";
        groupBox1.margin = Size(0,0);

        //

        label = new IupLabel("Label4");
        label.expandOrientation = ExpandOrientation.Horizontal;

        vbox = new IupVbox(label,
                           new IupLabel("Label5"),
                           new IupLabel("Label6"));

        groupBox2 = new IupGroupBox(vbox);
        groupBox2.margin = Size(0,0);
        //groupBox1.isSunken = true;

        IupHbox hbox = new IupHbox(groupBox1, groupBox2);

        this.child = hbox;
        this.title = "IupFrame Test";
        this.gap = 5;
        this.margin = Size(10, 10);
        this.fontSize = 14;

        this.loaded += &dialog_loaded;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs e)
    {
        writefln("RASTERSIZE(%s)", groupBox1.rasterSize.toString());
        writefln("CLIENTSIZE(%s)", groupBox1.clientSize.toString());
        writefln("RASTERSIZE(%s)", groupBox2.rasterSize.toString());
        writefln("CLIENTSIZE(%s)", groupBox2.clientSize.toString());
    }
}


public class HboxTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        /* IUP identifiers */
        IupButton b11 = new IupButton("1");
        b11.size = Size(10,10);

        IupButton b12 = new IupButton("2");
        b12.size = Size(20,16);
        //b12.isFloating = true;

        IupButton b13 = new IupButton("3");
        b13.size = Size(30,20);

        /* Creates frame with three top aligned buttons */
        IupHbox h1 = new IupHbox(b11, b12, b13);
        h1.alignment = VerticalAlignment.Top; /* Sets hbox's alignment, gap and size */
        //h1.isHomogeneous = true;
        //h1.canExpandChildren = true;

        /* Creates frame with three top aligned buttons */
        IupGroupBox fr1 = new IupGroupBox(h1);
        fr1.title = "IupHbox";

        /* Creates frame with three buttons */
        IupButton b21 = new IupButton("1");
        b21.size = Size(30,20);

        IupButton b22 = new IupButton("2");
        b22.size = Size(30,40);

        IupButton b23 = new IupButton("3");
        b23.size = Size(30,50);

        IupHbox h2 = new IupHbox(b21, b22, b23);
        h2.alignment = VerticalAlignment.Center;
        h2.gap = 20; /* Sets hbox's alignment and gap */

        IupGroupBox fr2 = new IupGroupBox(h2);
        fr2.title = "ALIGNMENT=ACENTER";
        fr2.gap = 20;

        /* Creates frame with three bottom aligned buttons */
        IupButton b31 = new IupButton("1");
        b31.size = Size(30,30);

        IupButton b32 = new IupButton("2");
        b32.size = Size(30,40);

        IupButton b33 = new IupButton("3");
        b33.size = Size(30,50);

        IupHbox h3 = new IupHbox(new IupFill(), b31, b32, b33, new IupFill());
        h3.alignment = VerticalAlignment.Bottom;
        h3.margin = Size(10, 10);

        IupGroupBox fr3 = new IupGroupBox(h3);
        fr3.title = "ALIGNMENT=ABOTTOM, MARGIN=10x10";

        IupVbox vbox = new IupVbox(fr1, fr2, fr3);
        this.child = vbox;
        this.margin = Size(10, 10);
        this.gap = 10;
        this.title = "IupHbox Test";
    }
}


public class ScrollBoxTestDialog : IupDialog
{
    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupImage8 img2 = new IupImage8(32, 32, img_bits2);
        img2.setColor(0, Color.fromRgb(0, 0, 0));
        img2.setColor(1, Color.fromRgb(0, 255, 0));
        img2.useBackground(2);
        img2.setColor(3, Color.parse("255 0 0"));


        //
        IupButton btn1 = new IupButton("Button Text");
        btn1.padding = Size(5, 5);
        btn1.tipText = "Button TIP";

        IupButton btn2 = new IupButton("Text");
        btn2.padding = Size(5, 5);

        IupVbox vbox1 = new IupVbox(btn1, btn2);

        //
        IupToggle toggle1 = new IupToggle("Toggle Text");
        toggle1.isChecked = true;
        toggle1.tipText = "Toggle TIP";

        IupToggle toggle2 = new IupToggle();
        toggle2.isChecked = true;
        toggle2.image = IupImages.Tecgraf;
        toggle2.imagePressed = img2;

        IupToggle toggle3 = new IupToggle();
        toggle3.isChecked = true;
        toggle3.image = IupImages.Tecgraf;

        IupRadioGroup radioGroup = new IupRadioGroup(new IupVbox(new IupToggle("Toggle Text"),
                                                                 new IupToggle("Toggle Text")));
        IupGroupBox groupBox = new IupGroupBox(radioGroup);
        groupBox.title = "IupRadio";

        IupVbox vbox3 = new IupVbox(toggle1, toggle2, toggle3, groupBox);
        IupGroupBox _frm_3 = new IupGroupBox(vbox3);
        _frm_3.title = "IupToggle";


        IupHbox _hbox_1 = new IupHbox(
                                      //    _frm_1,
                                      //    _frm_2,
                                      _frm_3
                                      //    _frm_4,
                                      //    _frm_5
                                      );

        IupVbox _vbox_1 = new IupVbox(
                                      _hbox_1);

        _vbox_1.margin = Size(5, 5);
        _vbox_1.gap = 5;

        IupScrollBox scrollBox = new IupScrollBox(_vbox_1);
        scrollBox.canAutoUpdateLayout = true;

        IupVbox _vbox_2 = new IupVbox(scrollBox);

        this.child = _vbox_2;
        this.title = "IupScrollBox Test";
        this.margin = Size(10, 10);
        this.rasterSize = Size(150, 150);

        this.loaded += &dialog_loaded;
        this.sizeChanged += &dialog_sizeChanged;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs e)
    {
    }


    private void dialog_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("RESIZE_CB(%s, width=%d, height=%d) RASTERSIZE=%s CLIENTSIZE=%s", dialog.title, width, height, 
                 IupSize.format(dialog.rasterSize), IupSize.format(dialog.clientSize));
    }

}


public class SboxTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupButton bt = new IupButton("Button");
        bt.canExpand = true;

        IupSbox box = new IupSbox(bt);
        box.barPosition = Position.Bottom;
        box.color = Color.fromRgb(0, 255, 0);

        IupMultiLine ml = new IupMultiLine();
        ml.canExpand = true;
        ml.visibleLines = 5;

        auto vbox = new IupVbox(box, ml);

        auto lbl = new IupLabel("Label");
        lbl.expandOrientation = ExpandOrientation.Vertical;

        auto hbox = new IupHbox(vbox, lbl);

        this.child = hbox;
        this.margin = Size(10, 10);
        this.gap = 10;
        this.title = "IupSbox Example";
    }
}


public class SpinBoxTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupTextBox textBox = new IupTextBox();
        textBox.size = Size(50, 0);
        textBox.expandOrientation = ExpandOrientation.Horizontal;
        textBox.font = "Times, 24";

        IupSpinBox spinbox = new IupSpinBox(textBox);
        spinbox.spinned += &spinbox_spinned;

        IupVbox vbox = new IupVbox(spinbox);

        this.child = vbox;
        this.title = "IupSpin Test";
        this.margin = Size(10, 10);

        this.loaded += &dialog_loaded;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs e)
    {
    }

    private void spinbox_spinned(Object sender, CallbackEventArgs e, int inc)
    {
        /* does nothing, just print the call */
        writefln("SPIN_CB(%d)", inc);
    }
}


public class VboxTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        /* IUP identifiers */

        IupButton btn_11 = new IupButton("1");
        btn_11.size = Size(20,30);

        IupButton btn_12 = new IupButton("2");
        btn_12.size = Size(30,20);
        //btn_12.expandOrientation = ExpandOrientation.Vertical;
        //btn_12.expandWeight = 1.3f;
        //btn_12.isFloating = true;

        IupButton btn_13 = new IupButton("3");
        btn_13.size = Size(40,30);

        IupVbox vbox_1 = new IupVbox(new IupFill(), btn_11, btn_12, btn_13, new IupFill());
        vbox_1.alignment = HorizontalAlignment.Left;
        vbox_1.margin = Size(20,20);
        vbox_1.gap = 10;
        //vbox_1.isHomogeneous = true;
        //vbox_1.canExpandChildren = true;
        //vbox_1.normalizeSize = NormalizeSize.Both;

        IupGroupBox fr1 = new IupGroupBox(vbox_1);
        fr1.title = "ALIGNMENT=ALEFT";
        fr1.gap = 0;
        fr1.margin = Size(0, 0);


        /* Creates frame 2 */

        IupButton btn_21 = new IupButton("1");
        btn_21.size = Size(20,30);

        IupButton btn_22 = new IupButton("2");
        btn_22.size = Size(30,30);
        btn_22.expandOrientation = ExpandOrientation.Vertical;

        IupButton btn_23 = new IupButton("3");
        btn_23.size = Size(40,30);
        btn_23.expandOrientation = ExpandOrientation.Vertical;

        IupVbox vbox_2 = new IupVbox(new IupFill(), btn_21, btn_22, btn_23, new IupFill());
        vbox_2.alignment = HorizontalAlignment.Center;

        IupGroupBox fr2 = new IupGroupBox(vbox_2);
        fr2.title = "ALIGNMENT=ACENTER";
        fr2.gap = 0;
        fr2.margin = Size(0, 0);

        /* Creates frame 3 */

        IupButton btn_31 = new IupButton("1");
        btn_31.size = Size(20,30);

        IupButton btn_32 = new IupButton("2");
        btn_32.size = Size(30,30);

        IupButton btn_33 = new IupButton("3");
        btn_33.size = Size(40,30);

        IupVbox vbox_3 = new IupVbox(new IupFill(), btn_31, btn_32, btn_33, new IupFill());
        vbox_3.alignment = HorizontalAlignment.Right;

        IupGroupBox fr3 = new IupGroupBox(vbox_3);
        fr3.title = "ALIGNMENT=ACENTER";
        fr3.gap = 0;
        fr3.margin = Size(0, 0);

        IupHbox hbox = new IupHbox(fr1, new IupFill(), fr2, new IupFill(), fr3);
        this.child = hbox;
        this.margin = Size(10, 10);
        this.gap = 10;
        this.title = "IupVbox Test";
    }
}



public class ZboxTestDialog : IupDialog
{

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupComboBox comboBox = new IupComboBox("Test", "XXX");
        comboBox.selectedIndex = 0;

        IupGroupBox frame = new IupGroupBox(comboBox);
        frame.name = "GroupBox";
        frame.title = "List";
        //frame.child = comboBox;

        IupTextBox textBox = new IupTextBox();
        textBox.name = "text";
        textBox.canExpand = true;
        textBox.text = "Enter your text here";

        /* Creates a label */
        IupLabel label = new IupLabel("This element is a label");
        label.name = "lbl";

        /* Creatas a button */
        IupButton btn = new IupButton("This button does nothing");
        btn.name = "btn";

        availableControls.insertBack(frame);
        availableControls.insertBack(textBox);
        availableControls.insertBack(label);
        availableControls.insertBack(btn);

        /* Creates zbox with four elements */
        zbox = new IupZbox(frame, textBox, label, btn);
        zbox.alignment = ContentAlignment.MiddleCenter;
        zbox.currentControl = textBox;
        //zbox.currentIndex = 1;

        IupListBox listBox = new IupListBox();
        listBox.items.append("GroupBox", "TextBox", "Label", "Button");
        listBox.selectedItemChanged += &listBox_selectedItemChanged;
        listBox.selectedIndex = 1;

        IupHbox hbox = new IupHbox();
        hbox.append(listBox);

        /* Creates frame */

        IupGroupBox frm = new IupGroupBox(hbox);
        frm.title = "Select an element";

        IupVbox vbox = new IupVbox(frm, zbox);

        this.child = vbox;
        this.margin = Size(10, 10);
        this.gap = 10;
        this.title = "IupZbox Example";
    }

    private IupZbox zbox;
    private Array!IupControl availableControls; 

    private void listBox_selectedItemChanged(Object sender, CallbackEventArgs e, 
                                             int index, string text, bool isSelected)
    {
        writefln("ItemChanged: index=%d, text=%s, isSelected=%s", index, text, isSelected);

        if(isSelected)
        {
            IupControl d = zbox.currentControl;

            IupControl selectedItem = availableControls[index];
            zbox.currentControl = selectedItem;  // TODO: test

            //zbox.currentIndex = index; // ok
        }
    }
}


public class IupTabControlTestDialog : IupDialog
{
    private IupTabControl tabControl;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupCheckBox topCheckBox = new IupCheckBox("TOP");
        topCheckBox.checked += &positionCheckBox_checked;

        IupCheckBox leftCheckBox = new IupCheckBox("LEFT");
        leftCheckBox.checked += &positionCheckBox_checked;

        IupCheckBox bottomCheckBox = new IupCheckBox("BOTTOM");
        bottomCheckBox.checked += &positionCheckBox_checked;

        IupCheckBox rightCheckBox = new IupCheckBox("RIGHT");
        rightCheckBox.checked += &positionCheckBox_checked;

        IupVbox vbox1 = new IupVbox(topCheckBox, leftCheckBox, bottomCheckBox, rightCheckBox);
        IupGroupBox frm1 = new IupGroupBox(new IupRadioBox(vbox1));

        version(Windows)
        {
            frm1.enabled = false;
        }

        //
        IupCheckBox horizontalCheckBox = new IupCheckBox("HORIZONTAL");
        horizontalCheckBox.checked += &orientationCheckBox_checked;

        IupCheckBox verticalCheckBox = new IupCheckBox("VERTICAL");
        verticalCheckBox.checked += &orientationCheckBox_checked;

        IupVbox vbox2 = new IupVbox(horizontalCheckBox, verticalCheckBox);
        IupGroupBox frm2 = new IupGroupBox(new IupRadioBox(vbox2));

        //
        IupButton addButton = new IupButton("Add Tab");
        addButton.click += &addButton_click;
        addButton.tipText = "Button Tip";

        IupButton insertButton = new IupButton("Insert Tab");
        insertButton.click += &insertButton_click;

        IupButton removeButton = new IupButton("Remove Tab");
        removeButton.click += &removeButton_click;

        IupButton unhideButton = new IupButton("UnHide All Tabs");
        unhideButton.click += &unhideButton_click;

        IupCheckBox inactiveCheckBox = new IupCheckBox("Inactive");
        inactiveCheckBox.checked += &inactiveCheckBox_checked;

        IupButton testButton = new IupButton("Test");
        testButton.click += &testButton_click;

        IupVbox vbox3 = new IupVbox(addButton, insertButton, removeButton, 
                                    unhideButton, inactiveCheckBox, testButton);

        //
        creatTabs();
        IupHbox hbox = new IupHbox(tabControl, frm1, frm2, vbox3);

        this.child = hbox;
        this.title = "IupTabs Test";
    }

    private void positionCheckBox_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;

        string title = tb.title;
        if(state == ToggleState.On)
        {
            writefln("Toggle %s - ON",title);
            if(title[0] == 'T')
                tabControl.tabPosition = Position.Top;
            else if(title[0] == 'L')
                tabControl.tabPosition = Position.Left;
            else if(title[0] == 'R')
                tabControl.tabPosition = Position.Right;
            else 
                tabControl.tabPosition = Position.Bottom;

            // BUG: Can't work.
            tabControl.refresh(); /* update children layout */
        }
        else
            writefln("Toggle %s - OFF",title);
    }

    private void orientationCheckBox_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;

        if(state == ToggleState.On)
            writefln("Toggle %s - ON",tb.name);
        else

            writefln("Toggle %s - OFF",tb.name);
    }

    private void addButton_click(Object sender, CallbackEventArgs e)
    {
        IupButton childButton = new IupButton("Button XXX");
        childButton.click += &childButton_click;

        IupVbox vboxA = new IupVbox(new IupLabel("Label XXX"), childButton);
        IupGroupBox groupBox = new IupGroupBox(vboxA);
        groupBox.title = "TABS XXX";
        
        tabControl.addTabPage(groupBox, "XXX");

        //tabControl.items.append(groupBox);
        //
        //int count = tabControl.count;
        //tabControl.setTabTitle(count-1, "XXX");
        //
        //groupBox.map();
        //tabControl.refresh(); /* update children layout */
    }

    private void insertButton_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
    }

    private void removeButton_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
    }

    private void removeThisButton_click(Object sender, CallbackEventArgs e)
    {
    }

    private void hideButton_click(Object sender, CallbackEventArgs e)
    {
    }

    private void unhideButton_click(Object sender, CallbackEventArgs e)
    {
    }

    private void inactiveCheckBox_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;
    }

    private void testButton_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
    }

    private void childButton_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
    }


    private void tabControl_tabRightClick(Object sender, CallbackEventArgs e, int index)
    {
        writefln("tab index = %d", index);

        // 
        IupMenu popupMenu = new IupMenu();

        IupMenuItem addTabMenuItem = new IupMenuItem("Add Tab");
        addTabMenuItem.click += &addButton_click;
        popupMenu.items.append(addTabMenuItem);

        IupMenuItem insertTabMenuItem = new IupMenuItem("Insert Tab");
        insertTabMenuItem.click += &insertButton_click;
        popupMenu.items.append(insertTabMenuItem);

        IupMenuItem removeTabMenuItem = new IupMenuItem("Remove Current Tab");
        removeTabMenuItem.click += &removeButton_click;
        popupMenu.items.append(removeTabMenuItem);

        IupMenuItem removeThisTabMenuItem = new IupMenuItem("Remove This");
        removeThisTabMenuItem.click += &removeThisButton_click;
        popupMenu.items.append(removeThisTabMenuItem);

        IupMenuItem hideTabMenuItem = new IupMenuItem("Hide This");
        hideTabMenuItem.click += &hideButton_click;
        popupMenu.items.append(hideTabMenuItem);

        //

        popupMenu.popup();

        popupMenu.dispose();
    }

    private void tabControl_selectedIndexChanged(Object sender, CallbackEventArgs e,
                                                  int new_tab, int old_tab)
    {
        writef("new Tab: %d, old Tab: %d\n", new_tab, old_tab);
    }
    
    private void tabControl_tabClosing(Object sender, CallbackEventArgs e, int index)
    {
        writef("Tab closed: %d\n", index);
    }

    private void creatTabs()
    {
        IupButton childButton = new IupButton("Button AAA");
        childButton.click += &childButton_click;

        IupVbox vboxA = new IupVbox(new IupFill(), new IupLabel("Label AAA"), childButton);
        IupGroupBox groupBox = new IupGroupBox(vboxA);
        groupBox.title = "TABS A";

        //
        childButton = new IupButton("Button FFF");
        childButton.click += &childButton_click;

        IupVbox vboxF = new IupVbox(new IupLabel("Label FFF"), childButton);

        tabControl = new IupTabControl(groupBox, vboxF);

        //
        tabControl.setTabTitle(0, "A");
        tabControl.setTabImage(0, IupImages.Tecgraf);

        tabControl.setTabTitle(1, "&FFFFFF");

        //
        IupCanvas canvas = new IupCanvas();
        canvas.clearAttribute(IupCanvas.IupCallbacks.Action);

        IupVbox vboxI = new IupVbox(new IupLabel("Canvas"), canvas);
        vboxI.backgroundColor = "32 192 32";
        tabControl.addTabPage(vboxI, "Canvas1");


        // events
        tabControl.selectedIndexChanged += &tabControl_selectedIndexChanged;
        tabControl.tabRightClick += &tabControl_tabRightClick;
        tabControl.tabClosing += &tabControl_tabClosing;

        //
        // In Windows, must be set before map
        //tabControl.isMultiline = true;
        tabControl.tabPosition = Position.Bottom;

        //
        tabControl.canShowClose = true;
        tabControl.tipText = "IupTabs Tip";
        tabControl.rasterSize = Size(300, 200); /* initial size */

    }


}