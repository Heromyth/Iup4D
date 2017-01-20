module MainForm;

version(Windows) { 
    pragma(lib, "iupcd.lib");
    pragma(lib, "cd.lib");
    pragma(lib, "cdgl.lib");
    pragma(lib, "cdpdf.lib"); 
}


import std.stdio;
import std.algorithm;
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

class SplashDialog : IupDialog
{
    bool isFirstStage = false;
    IupTimer timer;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        IupImage image = IupImage.create(Application.basePath ~ "images\\TecgrafLogo.png");
        IupLabel imageLabel = new IupLabel();
        imageLabel.image = image;

        this.child = imageLabel;
        this.hasBorder = false;
        this.maximizeBox = false;
        this.canResize = false;
        this.minimizeBox = false;
        this.hasMenuBox = false;
        this.opacityImage = image;

        //this.horizontalPostion = ScreenPostionH.Center;
        //this.verticalPostion = ScreenPostionV.Center;

        this.isTopMost = true;
        this.loaded += &dialog_loaded;

        isFirstStage = true;
        timer = new IupTimer();
        timer.interval = 1000;
        timer.tick += &timer_tick;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        timer.start();
    }

    void timer_tick(Object sender, CallbackEventArgs args)
    {
        timer.stop();

        if(isFirstStage)
        {
            isFirstStage = false;
            timer.interval = 3000;
            timer.start();
            this.show();
        }
        else
        {
            dispose();
            timer.dispose();
        }
    }
}

class ToolboxDialog : IupDialog
{
    private IupToggleButton tb;
    private IupTextBox textBox;
    private IupLabel totalLabel;
    private IupButton colorButton;

    EventHandler!int toolSelected;

    @property 
	{
		public Color selectedColor() { return m_selectedColor; }
		public void selectedColor(Color value) { 
            m_selectedColor = value; 
            //if(colorButton !is null)
                colorButton.backgroundColor = value;
        }
        private Color m_selectedColor; 
	}


    Font selectedFont;
    int currentToolIndex;
    double fillingPercent;
    int selectedLineStyle;
    int selectedLineWidth;

    this() 
    {
        currentToolIndex = 0;
        selectedFont = new Font("Times", FontStyles.Bold |  FontStyles.Italic,  11);
        fillingPercent = 50;
        selectedLineStyle = 0;
        selectedLineWidth = 1;

        super();

        selectedColor = Colors.Black;
    }

    protected override void initializeComponent() 
    {
        IupToggleButton paintPointerButton = new IupToggleButton("Pointer");
        paintPointerButton.isFlat = true;
        paintPointerButton.isChecked = true;
        paintPointerButton.tipText = "Pointer";
        //paintPointerButton.image = IupImages.ZoomOut;
        paintPointerButton.image = new IupImage32(16, 16, paintPointerPixels);
        //string imageName = paintPointerButton.image;
        paintPointerButton.checked += &paintPointerButton_checked;

        IupToggleButton paintColorPicker = new IupToggleButton("Picker");
        paintColorPicker.isFlat = true;
        paintColorPicker.isChecked = false; 
        paintColorPicker.tipText = "Color Picker";
        paintColorPicker.image = new IupImage32(16, 16, paintColorPickerPixels);
        paintColorPicker.checked += &paintColorPicker_checked;

        IupToggleButton paintPencilButton = new IupToggleButton("Pencil");
        paintPencilButton.isFlat = true;
        paintPencilButton.isChecked = false; 
        paintPencilButton.tipText = "Pencil";
        paintPencilButton.image = IupImage.create(Application.basePath ~ "images\\PaintPencil.png");
        paintPencilButton.checked += &paintPencilButton_checked;

        IupToggleButton paintLineButton = new IupToggleButton("Line");
        paintLineButton.isFlat = true;
        paintLineButton.isChecked = false; 
        paintLineButton.tipText = "Line";
        paintLineButton.image = IupImage.create(Application.basePath ~ "images\\PaintLine.png");
        paintLineButton.checked += &paintLineButton_checked;

        IupToggleButton paintRectButton = new IupToggleButton("Rect");
        paintRectButton.isFlat = true;
        paintRectButton.isChecked = false; 
        paintRectButton.tipText = "Hollow Rectangle";
        paintRectButton.image = IupImage.create(Application.basePath ~ "images\\PaintRect.png");
        paintRectButton.checked += &paintRectButton_checked;

        IupToggleButton paintBoxButton = new IupToggleButton("Box");
        paintBoxButton.isFlat = true;
        paintBoxButton.isChecked = false; 
        paintBoxButton.tipText = "Box (Filled Rectangle)";
        paintBoxButton.image = IupImage.create(Application.basePath ~ "images\\PaintBox.png");
        paintBoxButton.checked += &paintBoxButton_checked;

        IupToggleButton paintEllipseButton = new IupToggleButton("Ellipse");
        paintEllipseButton.isFlat = true;
        paintEllipseButton.isChecked = false; 
        paintEllipseButton.tipText = "Hollow Ellipse";
        paintEllipseButton.image = IupImage.create(Application.basePath ~ "images\\PaintEllipse.png");
        paintEllipseButton.checked += &paintEllipseButton_checked;

        IupToggleButton paintOvalButton = new IupToggleButton("Oval");
        paintOvalButton.isFlat = true;
        paintOvalButton.isChecked = false; 
        paintOvalButton.tipText = "Oval (Filled Ellipse)";
        paintOvalButton.image = IupImage.create(Application.basePath ~ "images\\PaintOval.png");
        paintOvalButton.checked += &paintOvalButton_checked;

        IupToggleButton paintTextButton = new IupToggleButton("Text");
        paintTextButton.isFlat = true;
        paintTextButton.isChecked = false; 
        paintTextButton.tipText = "Text";
        paintTextButton.image = IupImage.create(Application.basePath ~ "images\\PaintText.png");
        paintTextButton.checked += &paintTextButton_checked;

        IupToggleButton paintFillButton = new IupToggleButton("Fill");
        paintFillButton.isFlat = true;
        paintFillButton.isChecked = false; 
        paintFillButton.tipText = "Fill Color";
        paintFillButton.image = IupImage.create(Application.basePath ~ "images\\PaintFill.png");
        paintFillButton.checked += &paintFillButton_checked;


        IupGridBox gridBox = new IupGridBox();
        gridBox.rowGap = 2;
        gridBox.columnGap = 2;
        gridBox.margin = Size(5, 10);
        gridBox.divisionNumber = 2;
        gridBox.append(paintPointerButton, paintColorPicker, paintPencilButton, paintLineButton,
                       paintRectButton, paintBoxButton, paintEllipseButton, paintOvalButton, 
                       paintTextButton, paintFillButton);

        // 
        IupLabel colorLabel = new IupLabel("Color:");
        colorLabel.expandOrientation = ExpandOrientation.Horizontal;

        colorButton = new IupButton();
        colorButton.name = "COLOR";
        colorButton.backgroundColor = Colors.Black;
        colorButton.rasterSize = Size(28,21);
        colorButton.click += &colorButton_click;

        IupLabel widthLabel = new IupLabel("Width:");
        widthLabel.expandOrientation = ExpandOrientation.Horizontal;

        IupIntegerUpDown integerUpDown = new IupIntegerUpDown();
        integerUpDown.rasterSize = Size(48,0);
        integerUpDown.maximum = 50;
        integerUpDown.minimum = 1;
        integerUpDown.value = selectedLineWidth;
        integerUpDown.valueChanged += &integerUpDown_valueChanged;

        IupLabel styleLabel = new IupLabel("Style:");
        styleLabel.expandOrientation = ExpandOrientation.Horizontal;

        IupComboBox styleComboBox = new IupComboBox();
        styleComboBox.items.append("____", "----", "....", "....", "-.-.", "-..-..");
        //styleComboBox.updateItem(0, "____");
        //styleComboBox.updateItem(1, "----");
        //styleComboBox.updateItem(2, "....");
        //styleComboBox.updateItem(3, "-.-.");
        //styleComboBox.updateItem(4, "-..-..");
        styleComboBox.selectedIndex = selectedLineStyle;
        //styleComboBox.hasEditBox = true;

        styleComboBox.selectedValueChanged += &styleComboBox_selectedValueChanged;

        totalLabel = new IupLabel("Tol.: 50%");
        totalLabel.name = "FILLTOLLABEL";
        totalLabel.expandOrientation = ExpandOrientation.Horizontal;

        IupSlider iupSlider = new IupSlider();
        iupSlider.maximum = 100;
        iupSlider.minimum = 0;
        iupSlider.rasterSize = Size(60,30);
        iupSlider.value = fillingPercent;
        iupSlider.valueChanged += &iupSlider_valueChanged;

        IupLabel fontLabel = new IupLabel("Font:");
        fontLabel.expandOrientation = ExpandOrientation.Horizontal;

        IupButton fontButton = new IupButton("F");
        fontButton.name = "FONT";
        fontButton.rasterSize = Size(21,21);
        fontButton.font = selectedFont;
        fontButton.click += &fontButton_click;

        IupVbox innerVbox = new IupVbox(colorLabel,  colorButton, widthLabel, integerUpDown,
                                        styleLabel, styleComboBox, totalLabel, iupSlider, 
                                        fontLabel, fontButton);
        innerVbox.margin = Size(3,2);
        innerVbox.gap = 2;
        innerVbox.alignment = HorizontalAlignment.Center;

        IupGroupBox groupBox = new IupGroupBox(innerVbox);

        IupVbox vbox = new IupVbox();
        vbox.append( new IupRadioBox(gridBox), groupBox);
        vbox.alignment = HorizontalAlignment.Center;
        vbox.nmargin = Size(2,2);
        //vbox.gap = 5;

        this.child = vbox;
        this.title = "Tools";
        this.isDialogFrame = true;
        this.fontSize = 8;
        this.isToolbox = true;


        //this.closing += &dialog_closing;

        //
        //this.defaultEnter = nextButton;
        //this.defaultEsc = closeButton;
        resetUserSize();
    }

    private void paintPointerButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        //IupToggleButton tb = cast(IupToggleButton) sender;
        //isCaseSensitive = tb.isChecked;
        if(state.On)
        {
            currentToolIndex = 0;
            toolSelected(this, currentToolIndex);
        }
    }

    private void paintColorPicker_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 1;
            toolSelected(this, currentToolIndex);
        }
    }

    private void paintPencilButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 2;
            toolSelected(this, currentToolIndex);
        }
    }

    private void paintLineButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 3;
            toolSelected(this, currentToolIndex);
        }
    }


    private void paintRectButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 4;
            toolSelected(this, currentToolIndex);
        }
    }


    private void paintBoxButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 5;
            toolSelected(this, currentToolIndex);
        }
    }


    private void paintEllipseButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 6;
            toolSelected(this, currentToolIndex);
        }
    }


    private void paintOvalButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 7;
            toolSelected(this, currentToolIndex);
        }
    }


    private void paintTextButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 8;
            toolSelected(this, currentToolIndex);
        }
    }


    private void paintFillButton_checked(Object sender, CallbackEventArgs args, ToggleState state)
    {
        if(state.On)
        {
            currentToolIndex = 9;
            toolSelected(this, currentToolIndex);
        }
    }


    private void colorButton_click(Object sender, CallbackEventArgs e)
    {
        colorButton = cast(IupButton)sender;

        IupColorDialog dialog = new IupColorDialog();
        dialog.color = selectedColor;

        if(dialog.showDialog() == DialogResult.OK)
        {
            selectedColor =  dialog.color;
        }

        dialog.dispose();
    }

    private void iupSlider_valueChanged(Object sender, CallbackEventArgs e)
    {
        IupSlider iupSlider = cast(IupSlider)sender;
        fillingPercent = iupSlider.value;
        totalLabel.title = std.format.format("Tol.: %.0f%%", fillingPercent);
    }


    private void integerUpDown_valueChanged(Object sender, CallbackEventArgs e)
    {
        IupIntegerUpDown integerUpDown = cast(IupIntegerUpDown)sender;
        selectedLineWidth = integerUpDown.value;

        //totalLabel.title = std.format.format("%d", selectedLineWidth);
    }
    

    private void styleComboBox_selectedValueChanged(Object sender, CallbackEventArgs e)
    {
        IupComboBox styleComboBox = cast(IupComboBox)sender;
        selectedLineStyle = styleComboBox.selectedIndex;
        //totalLabel.title = std.format.format("%d", selectedLineStyle);
    }

    private void fontButton_click(Object sender, CallbackEventArgs e)
    {
        IupFontDialog dialog = new IupFontDialog("IupFontDlg Test");

        //dialog.font = "Times New Roman, Bold 20";
        dialog.selectedFont = selectedFont;

        if(dialog.showDialog() == DialogResult.OK)
        {
            selectedFont =  dialog.selectedFont;
        }

        dialog.dispose();
    }

    private void closeButton_click(Object sender, CallbackEventArgs e)
    {
        this.hide();
        //this.close();
    }


    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        //e.result = CallbackResult.Ignore;
    }

    // 16x16 32-bit
    const(ubyte)[] paintPointerPixels = [
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 162, 180, 203, 255, 162, 180, 203, 84, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 162, 180, 203, 255, 162, 180, 203, 255, 162, 180, 203, 84, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 162, 180, 203, 255, 240, 243, 246, 255, 162, 180, 203, 255, 162, 180, 203, 69, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 162, 180, 203, 255, 255, 255, 255, 255, 241, 244, 247, 255, 161, 179, 202, 255, 161, 179, 202, 57, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 158, 176, 200, 255, 255, 255, 255, 255, 255, 255, 255, 255, 240, 242, 246, 255, 147, 165, 189, 255, 134, 152, 176, 57, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 153, 172, 195, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 227, 231, 236, 255, 129, 147, 171, 255, 115, 134, 158, 48, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 148, 166, 189, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 253, 253, 254, 255, 213, 218, 226, 255, 111, 130, 154, 255, 96, 115, 140, 57, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 141, 159, 183, 255, 254, 255, 255, 255, 252, 253, 254, 255, 250, 251, 253, 255, 247, 248, 251, 255, 243, 246, 250, 255, 206, 213, 223, 255, 91, 110, 136, 255, 73, 92, 118, 48, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 134, 152, 176, 255, 249, 250, 252, 255, 246, 247, 251, 255, 242, 245, 249, 255, 238, 242, 247, 255, 92, 111, 137, 255, 56, 76, 102, 255, 60, 80, 106, 255, 73, 92, 118, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 127, 145, 170, 255, 241, 244, 249, 255, 205, 212, 221, 255, 88, 108, 133, 255, 229, 234, 243, 255, 105, 124, 148, 255, 105, 124, 148, 83, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 119, 138, 163, 255, 203, 209, 220, 255, 63, 83, 109, 255, 102, 121, 145, 255, 197, 206, 221, 255, 187, 197, 214, 255, 89, 108, 133, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 112, 131, 156, 255, 82, 101, 127, 255, 55, 75, 101, 81, 102, 121, 145, 123, 102, 121, 145, 255, 206, 215, 233, 255, 79, 99, 124, 255, 79, 99, 124, 45, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 105, 124, 150, 255, 255, 255, 255, 0, 255, 255, 255, 0, 102, 121, 145, 18, 95, 115, 140, 255, 190, 202, 223, 255, 152, 167, 189, 255, 67, 87, 112, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 95, 115, 140, 150, 84, 104, 129, 255, 164, 178, 202, 255, 58, 78, 104, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 95, 115, 140, 6, 70, 90, 116, 255, 59, 79, 105, 255, 55, 75, 101, 87, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0 
    ];

    // 16x16 32-bit
    const(ubyte)[] paintColorPickerPixels = [
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 1, 1, 1, 85, 0, 0, 1, 192, 0, 0, 0, 192, 0, 0, 0, 85,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 7, 11, 15, 37, 8, 12, 16, 70, 79, 81, 83, 224, 205, 205, 205, 255, 136, 138, 142, 255, 11, 13, 15, 203,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 9, 15, 21, 119, 18, 26, 37, 255, 68, 70, 72, 255, 88, 93, 99, 255, 117, 120, 126, 255, 84, 86, 91, 255, 2, 2, 2, 194,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 15, 21, 30, 31, 23, 34, 49, 235, 49, 56, 65, 255, 70, 72, 72, 255, 54, 56, 58, 255, 21, 22, 22, 199, 0, 0, 0, 85,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 20, 30, 42, 42, 21, 32, 45, 237, 49, 56, 65, 255, 7, 9, 13, 255, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 255, 255, 255, 255, 202, 208, 222, 255, 173, 183, 202, 255, 6, 10, 15, 236, 2, 4, 5, 255, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 255, 255, 255, 255, 202, 208, 222, 255, 143, 156, 181, 255, 68, 88, 114, 255, 1, 1, 3, 33, 0, 0, 0, 111, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 255, 255, 255, 255, 214, 220, 230, 255, 143, 156, 181, 255, 68, 88, 114, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 255, 255, 255, 255, 215, 221, 231, 255, 143, 156, 181, 255, 65, 85, 112, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 255, 255, 255, 255, 216, 220, 231, 255, 143, 156, 181, 255, 65, 85, 112, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 152, 166, 185, 255, 216, 220, 231, 218, 143, 156, 181, 255, 66, 86, 113, 255, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 43, 134, 240, 46, 43, 134, 240, 107, 152, 166, 185, 255, 255, 255, 255, 255, 69, 89, 114, 255, 51, 72, 99, 255, 43, 134, 240, 236, 43, 134, 240, 204, 43, 133, 240, 161, 43, 132, 239, 107, 43, 130, 239, 46, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 43, 133, 239, 170, 43, 133, 240, 255, 87, 105, 130, 255, 79, 97, 123, 255, 43, 134, 240, 255, 43, 134, 240, 255, 43, 135, 240, 255, 43, 134, 240, 255, 43, 134, 240, 255, 43, 134, 240, 255, 43, 133, 239, 170, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 42, 120, 237, 46, 42, 124, 238, 107, 42, 125, 238, 161, 42, 126, 238, 204, 42, 128, 238, 236, 43, 130, 239, 253, 43, 131, 239, 236, 43, 131, 239, 204, 43, 131, 239, 161, 43, 129, 239, 107, 42, 127, 238, 46, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0,
        255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0 
    ];

}

public class MainForm : IupDialog
{
    private IupCanvas canvas;
    private IupMenu recent_menu;
    private IupMenuItem item_save;
    private IupMenuItem item_revert;
    private IupMenuItem item_copy;
    private IupMenuItem item_cut;
    private IupMenuItem item_paste;
    private IupMenuItem item_delete;
    private IupMenuItem item_select_all;
    private IupMenuItem item_toolbox;

    private IupConfig config;
    private IupControl toolbar;
    private ToolboxDialog toolbox;

    private bool isTextChanged;

    enum ThisFormName = "MainForm";

    this() 
    {
        super();
    }

    protected override void initializeComponent()
    {

        isTextChanged = false;

        config = new IupConfig();
        //config.useHomeDirection("simple_notepad");
        config.useAppDirectory(Application.basePath, "SimplePaint");
        //config.useCustomDirection("z:\\abc.ini");

        config.load();
        string color = config.getVariableAsStringWithDefault("Canvas", "Background", Colors.Black.toString());
        background = Color.parse(color);

        this.title = "Simple Notepad";
        //this.size = Size(200, 100);
        this.sizeMode = WindowSizeMode.Half;

        // menu
        this.menu = createMenus();

        // toolbar
        toolbar =  createToolbar();

        // Canvas
        canvas = new IupCanvas();
        canvas.name = "CANVAS";
        canvas.scrollBars.visibility = ScrollBarsVisibility.Both;
        canvas.paint += &canvas_paint;
        canvas.mapped += &canvas_mapped;
        canvas.unmapped += &canvas_unmapped;
        canvas.sizeChanged += &canvas_sizeChanged;
        canvas.wheel += &canvas_wheel;
        canvas.mouseMove += &canvas_mouseMove;
        canvas.mouseClick += &canvas_mouseClick;
        canvas.gotFocus += &canvas_focused;

        // statusbar
        statusbar = createStatusbar();

        IupVbox vbox = new IupVbox(toolbar, canvas, statusbar);
        this.child = vbox;

        this.keyPress += &dialog_keyPress;
        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;
        this.stateChanged += &dialog_stateChanged;
        this.fileDropped += &dialog_fileDropped;
        this.move += &dialog_move;

        toolbox = new ToolboxDialog();
        toolbox.parent = this;
        toolbox.isTopMost = true;
        toolbox.closing += &toolbox_closing;


        new_file();

        //cdCanvasActivate(canvas);
    }

    private void toolbox_closing(Object sender, CallbackEventArgs args)
    {
        item_toolbox.checked = !item_toolbox.checked;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        // Notice: It runs after redraw().

        //cdCanvas.activate();
        toolbox.show();
    }

    private void dialog_fileDropped(Object sender, CallbackEventArgs e,
                                    string fileName, int number, int x, int y)
    {
        if(number == 0)
            openFile(fileName);
    }

    private void dialog_move(Object sender, CallbackEventArgs e, int x, int y)
    {
        if (old_x == x && old_y == y)
            return ;

        if(toolbox.isVisible)
        {
            Point!int location = toolbox.location;
            int tb_x = location.x + x - old_x;
            int tb_y = location.y + y - old_y;
            toolbox.showXY(tb_x, tb_y);
        }

        old_x = x;  old_y = y;
    }
    int old_x, old_y;
    

    private void canvas_mapped(Object sender, CallbackEventArgs args)
    {
        // Notice: It must run after calling redraw().
        cdCanvas = new IupDBufferCdCanvas(canvas);

        //Font f = cdCanvas.font;
        //background = Colors.Red; 
        //uint ii = background.toUInt();
    }
    private CdCanvas cdCanvas;

    private void canvas_unmapped(Object sender, CallbackEventArgs args)
    {
        cdCanvas.dispose();
    }

    private void canvas_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        if(currentImage is null)
            return;

        //double zoom_index = iupSlider.value;
        double zoom_factor = pow(2, iupSlider.value);

        float old_center_x, old_center_y;
        int view_width = cast(int)(zoom_factor * currentImage.width);
        int view_height = cast(int)(zoom_factor * currentImage.height);

        old_center_x = canvas.scrollBars.posX + canvas.scrollBars.dx/2.0;
        old_center_y = canvas.scrollBars.posY + canvas.scrollBars.dy/2.0;

        scroll_update(view_width, view_height);
        scroll_center(old_center_x, old_center_y);

    } 


    private void canvas_mouseMove(Object sender, CallbackEventArgs args, int x, int y, string status)
    {
        if(currentImage is null)
            return;

        // updateViewRect();

        int cursor_x = x, cursor_y = y;

        Size canvasSize = canvas.drawSize;

        /* y is top-down in IUP */
        int canvas_height = canvasSize.height;
        y = canvas_height - y - 1;

        /* inside image area */
        if (x <= view_x || y <= view_y || 
            x >= view_x + view_width || 
            y >= view_y + view_height)
            return;

        x -= view_x;
        y -= view_y;

        x = cast(int)(x / zoom_factor);
        y = cast(int)(y / zoom_factor);

        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (x > currentImage.width - 1) 
            x = currentImage.width - 1;
        if (y > currentImage.height - 1) 
            y = currentImage.height - 1;

        //

        ubyte[][] matrixData = currentImage.matrixData;
        int offset = y * currentImage.width + x; 
        ubyte r, g, b;

        r = matrixData[0][offset];
        g = matrixData[1][offset];
        b = matrixData[2][offset];

        //statusLabel.title = std.format.format("(%4d, %4d) = %3d %3d %3d", x, y,cast(int)r, cast(int)g, cast(int)b); 

        /* button1 is pressed */
        if(!Keys.hasButton1(status))
            return;

        int tool_index = toolbox.currentToolIndex;

        if(tool_index == 0) /* Pointer */
        {
        }
        else if (tool_index == 2)  /* Pencil */
        {
            double res = Environment.Screen.dpi / 25.4;
            statusLabel.title = std.format.format("Pencil (%4d, %4d) = %3d %3d",
                                                  x, y,start_x, start_y); 

            ///* do not use line style here */
            IupImageRgbCanvas cd_canvas = new IupImageRgbCanvas(currentImage.width, currentImage.height, 
                                                                matrixData, res);
            cd_canvas.foreground = toolbox.selectedColor;
            cd_canvas.lineWidth = toolbox.selectedLineWidth;
            cd_canvas.drawLine(start_x, start_y, x, y);
            cd_canvas.dispose();

            //
            canvas.update();

            start_x = x; start_y = y;
        }
        else if (tool_index >= 3 && tool_index <= 8)  /* Shapes */
        {
            end_x = x; end_y = y;
            canvas.update();
        }
    }

    private void canvas_mouseClick(Object sender, CallbackEventArgs args, 
        MouseButtons button, MouseState mouseState, int x, int y, string status)
    {
        if(currentImage is null)
            return;

        int cursor_x = x, cursor_y = y;
        Size canvasSize = canvas.drawSize;

        /* y is top-down in IUP */
        int canvas_height = canvasSize.height;
        y = canvas_height - y - 1;

        /* inside image area */
        if (x <= view_x || y <= view_y || 
            x >= view_x + view_width || 
            y >= view_y + view_height)
            return;

        x -= view_x;
        y -= view_y;

        x = cast(int)(x / zoom_factor);
        y = cast(int)(y / zoom_factor);

        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (x > currentImage.width - 1) 
            x = currentImage.width - 1;
        if (y > currentImage.height - 1) 
            y = currentImage.height - 1;


        if(button == MouseButtons.Left)
        {
            int tool_index = toolbox.currentToolIndex;

            if(mouseState == MouseState.Pressed)
            {
                start_x = x; start_y = y;
                startCursorX = cursor_x;
                startCursorY = cursor_y;

                if (tool_index >= 3 && tool_index <= 8)  /* Shapes */
                    overlayShape = availableShapes[tool_index - 3];
                else
                    overlayShape = OverlayShapes.Undefined;
            }
            else
            {
                if(tool_index == 1)  /* Color Picker */
                {
                    ubyte[][] matrixData = currentImage.matrixData;
                    int offset = y * currentImage.width + x; 
                    ubyte r, g, b;

                    r = matrixData[0][offset];
                    g = matrixData[1][offset];
                    b = matrixData[2][offset];

                    toolbox.selectedColor = Color.fromRgb(r, g, b);
                }
                else if (tool_index == 2)  /* Pencil */
                {
                    double res = Environment.Screen.dpi / 25.4;
                    ubyte[][] matrixData = currentImage.matrixData;

                    /* do not use line style here */
                    IupImageRgbCanvas cd_canvas = new IupImageRgbCanvas(currentImage.width, currentImage.height, 
                                                                        matrixData, res);
                    cd_canvas.foreground = toolbox.selectedColor;
                    cd_canvas.lineWidth = toolbox.selectedLineWidth;
                    cd_canvas.drawLine(start_x, start_y, x, y);
                    cd_canvas.dispose();

                    //
                    canvas.update();

                    start_x = x; start_y = y;
                } 
                else if (tool_index >= 3 && tool_index <= 8)  /* Shapes */
                {

                    if(overlayShape != OverlayShapes.Undefined)
                    {
                        double res = Environment.Screen.dpi / 25.4;
                        ubyte[][] matrixData = currentImage.matrixData;


                        ///* do not use line style here */
                        IupImageRgbCanvas cd_canvas = new IupImageRgbCanvas(currentImage.width, currentImage.height, 
                                                                            matrixData, res);
                        handleOverlayShape(cd_canvas, x, y);
                        cd_canvas.dispose();

                        //
                        canvas.update();
                        overlayShape = OverlayShapes.Undefined;
                    }
                }
                else if (tool_index == 9)  /* Fill Color */
                {
                    image_flood_fill(currentImage, x ,y, toolbox.selectedColor, toolbox.fillingPercent);
                }
            }
        }
    }
    int start_x, start_y;
    int end_x, end_y;
    int startCursorX, startCursorY;

    private void handleOverlayShape(CdCanvas cd_canvas, int x, int y )
    {
        int lineWidth = toolbox.selectedLineWidth;
        cd_canvas.foreground = toolbox.selectedColor;
        cd_canvas.lineWidth = lineWidth;
        if(lineWidth == 1)
            cd_canvas.lineStyle = cast(LineStyle)toolbox.selectedLineStyle;

        if(overlayShape == OverlayShapes.Line)
            cd_canvas.drawLine(start_x, start_y, x, y);
        else if(overlayShape == OverlayShapes.Rect)
            cd_canvas.drawRect(Rectangle!int(start_x, start_y,  x,  y));
        else if(overlayShape == OverlayShapes.Box)
            cd_canvas.drawBox(start_x, x, start_y, y);
        else if(overlayShape == OverlayShapes.Ellipse)
            cd_canvas.drawArc((x + start_x) / 2, (y + start_y) / 2, std.math.abs(x - start_x), std.math.abs(y - start_y), 0, 360);
        else if(overlayShape == OverlayShapes.Oval)
            cd_canvas.drawSector((x + start_x) / 2, (y + start_y) / 2, std.math.abs(x - start_x), std.math.abs(y - start_y), 0, 360);
        else if(overlayShape == OverlayShapes.Text)
        {
            // TODO:
        }

    }

    private enum OverlayShapes
    {
        Line, Rect, Box, Ellipse, Oval, Text, Undefined
    }

    private OverlayShapes[] availableShapes = [OverlayShapes.Line,  OverlayShapes.Rect, 
       OverlayShapes.Box, OverlayShapes.Ellipse, OverlayShapes.Oval, OverlayShapes.Text];

    OverlayShapes overlayShape = OverlayShapes.Undefined;
    
    private void image_flood_fill(ImImage image, int x, int y, Color color, double percent)
    {
         // TODO:
    }


    private void canvas_wheel(Object sender, CallbackEventArgs args, float delta, int x, int y, string status)
    {

        //if(getGlobalAttributeInt(GlobalAttributes.ControlKey) > 0)
        if(Keys.hasControl(status))
        {
            if (delta < 0)
                zoomOutBtn_click(null, null);
            else
                zoomInBtn_click(null, null);
        }
        else
        {
            float posy = canvas.scrollBars.posY;
            posy -= delta * canvas.scrollBars.dy / 10.0f;
            canvas.scrollBars.posY = posy;
            canvas.update();
            statusLabel.title  = format("posy: %g", posy);
        }

    }


    private void canvas_focused(Object sender, CallbackEventArgs e)
    {
        //background = toolbox.selectedColor;
        //cdCanvas.lineWidth = toolbox.selectedLineWidth;
        //cdCanvas.lineStyle = cast(LineStyle)toolbox.selectedLineStyle;
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        performExit();
        //e.result = CallbackResult.Ignore;
        e.result = CallbackResult.Close;
    }


    private void dialog_stateChanged(Object sender, CallbackEventArgs args, DialogState state)
    {
        statusLabel.title  = format("Dialog State: %s", state);
        if(state == DialogState.Show)
        {
            // loaded;
        }
    }

    private void dialog_keyPress(Object sender, CallbackEventArgs args, int key)
    {
        //statusLabel.title  = format("press key: %d", key);

        if(key == Keys.combinateCtrl(Keys.N))
        {
            item_new_click(this, null);
        }
        else if(key == (ModifierKeys.Control | Keys.O))
        {
            openMenuItem_click(this, null);
        }
        else  if(key == Keys.combinateCtrl(Keys.S))
        {
            saveMenuItem_click(this, null);
        }

    }


    private IupHbox createStatusbar()
    {
        statusLabel = new IupLabel("(0, 0) = [0   0   0]");
        statusLabel.padding = Size(10,5);
        statusLabel.expandOrientation = ExpandOrientation.Horizontal;

        sizeLabel = new IupLabel("0 x 0");
        zoomLabel = new IupLabel("100%");

        IupButton zoomOutBtn = new IupButton();
        zoomOutBtn.image = IupImages.ZoomOut;
        zoomOutBtn.isFlat = true;
        //zoomOutBtn.canfocus = false;
        zoomOutBtn.tipText = "Zoom Out (Ctrl+-)";
        zoomOutBtn.click += &zoomOutBtn_click;

        iupSlider = new IupSlider();
        iupSlider.maximum = 6;
        iupSlider.minimum = -6;
        iupSlider.rasterSize = Size(150,25);
        iupSlider.value = 0;
        iupSlider.valueChanged += &iupSlider_valueChanged;

        IupButton zoomInBtn = new IupButton();
        zoomInBtn.image = IupImages.ZoomIn;
        zoomInBtn.isFlat = true;
        //zoomInBtn.canfocus = false;
        zoomInBtn.tipText = "Zoom In (Ctrl++)";
        zoomInBtn.click += &zoomInBtn_click;

        IupButton actualSizeBtn = new IupButton();
        actualSizeBtn.image = IupImages.ZoomActualSize;
        actualSizeBtn.isFlat = true;
        //actualSizeBtn.canfocus = false;
        actualSizeBtn.tipText = "Zoom In (Ctrl++)";
        actualSizeBtn.click += &actualSizeBtn_click;

        IupHbox box = new IupHbox(statusLabel, new IupSeparator(Orientation.Vertical),
                                  sizeLabel, new IupSeparator(Orientation.Vertical),
                                  zoomLabel, zoomOutBtn,iupSlider,zoomInBtn, actualSizeBtn
                                  );
        box.alignment = VerticalAlignment.Center;

        box.margin = Size(5,5);
        box.gap = 5;

        return box;
    }
    private IupHbox statusbar;
    private IupLabel statusLabel;
    private IupLabel sizeLabel;
    private IupLabel zoomLabel;
    private IupSlider iupSlider;

    private IupHbox createToolbar()
    {

        IupButton newBtn = new IupButton();
        newBtn.image = IupImages.FileNew;
        newBtn.isFlat = true;
        newBtn.canFocus = false;
        newBtn.tipText = "New (Ctrl+N)";
        newBtn.click += &item_new_click;

        IupButton openBtn = new IupButton();
        openBtn.image  = IupImages.FileOpen;
        openBtn.isFlat = true;
        openBtn.canFocus = false;
        newBtn.tipText = "Open (Ctrl+O)";
        openBtn.click += &openMenuItem_click;

        IupButton saveBtn = new IupButton();
        saveBtn.image  = IupImages.FileSave;
        saveBtn.isFlat = true;
        saveBtn.canFocus = false;
        saveBtn.click += &saveasMenuItem_click;


        IupSeparator separatorLabel = new IupSeparator();
        separatorLabel.orientation = Orientation.Vertical;

        IupHbox box = new IupHbox(newBtn, openBtn, saveBtn, separatorLabel);

        box.margin = Size(5,5);
        box.gap = 5;

        return box;
    }

    private IupMenu createMenus()
    {
        // File

        IupItem item_new = new IupItem("New\tCtrl+N");
        item_new.image = IupImages.FileNew;
        item_new.click += &item_new_click;

        IupItem item_open = new IupItem("Open...");
        item_open.image = IupImages.FileOpen;
        item_open.click += &openMenuItem_click;

        item_save = new IupItem("Save\tCtrl+S");
        item_save.image = IupImages.FileSave;
        item_save.click += &saveMenuItem_click;

        IupItem item_saveas = new IupItem("Save &As...");
        item_saveas.click += &saveasMenuItem_click;

        item_revert = new IupMenuItem("Revert");
        item_revert.click += &item_revert_click;

        IupMenuItem pageSetupMenuItem = new IupMenuItem("Page Set&up...");
        pageSetupMenuItem.click += &pageSetupMenuItem_click;

        IupMenuItem printMenuItem = new IupMenuItem("&Print...\tCtrl+P");
        printMenuItem.click += &printMenuItem_click;

        IupMenuSeparator separator = new IupMenuSeparator();

        recent_menu = new IupMenu();
        IupSubmenu recentSub_menu = new IupSubmenu("Recent &Files", recent_menu);

        IupMenuItem item_exit =  new IupMenuItem("E&xit");
		item_exit.click += &exitMenuItem_click;

        IupMenu file_menu = new IupMenu( item_new, item_open, item_save, item_saveas, item_revert,
                                         new IupMenuSeparator(), pageSetupMenuItem, printMenuItem,
                                         separator, recentSub_menu, item_exit);
        file_menu.opened += &file_menu_opened;

        IupSubmenu fileSub_menu = new IupSubmenu("File", file_menu);
        //sub1_menu.title = "文件(&F)";


        // Edit
		IupMenuItem item_undo =  new IupMenuItem("&Undo");
		IupMenuItem item_redo =  new IupMenuItem("&Redo");
        IupMenuSeparator editSeparator1 = new IupMenuSeparator();

		item_cut =  new IupMenuItem("C&ut\tCtrl+X");
        item_cut.click  +=  &item_cut_click;

		item_copy =  new IupMenuItem("&Copy\tCtrl+C");
        item_copy.click  +=  &item_copy_click;

		item_paste =  new IupMenuItem("&Paste\tCtrl+V");
        item_paste.click  +=  &item_paste_click;

		item_delete =  new IupMenuItem("&Delete\tDel");
        item_delete.click  +=  &item_delete_click;

        IupMenuSeparator editSeparator2 = new IupMenuSeparator();

        item_select_all =  new IupMenuItem("Select All\tCtrl+A");
        item_select_all.click  +=  &item_select_all_click;

        IupSeparator editSeparator3 = new IupSeparator();

		IupMenu edit_menu = new IupMenu(  item_undo,item_redo,
                                          editSeparator1,
                                        item_cut,  item_copy,  item_paste, item_delete,
                                        editSeparator2,
                                        item_select_all,
                                        );
        edit_menu.opened += &edit_menu_opened;
        edit_menu.closed += &edit_menu_closed;

        IupSubmenu editSub_menu = new IupSubmenu("&Edit", edit_menu);

        // format
        //IupMenuItem item_font =  new IupMenuItem("Font...");
        //item_font.click += &fontMenuItem_click;
        //
        //IupMenu format_menu = new IupMenu( item_font);
        //
        //IupSubmenu formatSub_menu = new IupSubmenu("Fo&rmat", format_menu);

        // View

		IupMenuItem item_background =  new IupMenuItem("&Background...");
        item_background.click += &backgroundMenuItem_click;

		IupMenuItem item_toolbar =  new IupMenuItem("&Toobar");
        item_toolbar.click += &item_toolbar_click;
        item_toolbar.checked = true;

		item_toolbox =  new IupMenuItem("&Toobox");
        item_toolbox.click += &item_toolbox_click;
        item_toolbox.checked = true;

		IupMenuItem item_statusbar =  new IupMenuItem("&Statusbar");
        item_statusbar.click += &item_statusbar_click;
        item_statusbar.checked = true;

		IupMenu view_menu = new IupMenu(item_background, 
                                        new IupMenuSeparator(), 
                                        item_toolbar, 
                                        item_toolbox,
                                        item_statusbar);
        IupSubmenu viewSub_menu = new IupSubmenu("&View", view_menu);

        // Help
		IupMenuItem item_help =  new IupMenuItem("&Online Support...");
        item_help.click += &item_help_click;

		IupMenuItem item_about =  new IupMenuItem("About...");
        item_about.click += &aboutMenuItem_click;

		IupMenu help_menu = new IupMenu(item_help, item_about);

        IupSubmenu helpSub_menu = new IupSubmenu("&Help", help_menu);


        //
        IupMenu mainMenu = new IupMenu(fileSub_menu);
		mainMenu.items.append(editSub_menu, 
                        //formatSub_menu, 
                        viewSub_menu,
                        helpSub_menu);


        config.initRecentMenu(recent_menu, &openFile, 10);

        return mainMenu;
    }

    private void zoomOutBtn_click(Object sender, CallbackEventArgs e)
    {
        double zoom_index = iupSlider.value;
        zoom_index--;
        if (zoom_index < iupSlider.minimum)
            zoom_index = iupSlider.minimum;

        iupSlider.value = zoom_index;
        zoom_update(zoom_index);
    }

    private void zoomInBtn_click(Object sender, CallbackEventArgs e)
    {
        double zoom_index = iupSlider.value;
        zoom_index++;
        if (zoom_index > iupSlider.maximum)
            zoom_index = iupSlider.maximum;

        iupSlider.value = zoom_index;
        zoom_update(zoom_index);
    }

    private void actualSizeBtn_click(Object sender, CallbackEventArgs e)
    {
        iupSlider.value = 0;
        zoom_update(0);
    }

    private void zoom_update(double zoom_index)
    {
        statusLabel.title  = format("iupSlider = %g", zoom_index);
        double zoom_factor = pow(2, zoom_index);
        zoomLabel.title = std.format.format("%.0f%%", floor(zoom_factor * 100));
        if(currentImage is null)
            return;

        float old_center_x, old_center_y;
        int view_width = cast(int)(zoom_factor * currentImage.width);
        int view_height = cast(int)(zoom_factor * currentImage.height);

        old_center_x = canvas.scrollBars.posX + canvas.scrollBars.dx/2.0;
        old_center_y = canvas.scrollBars.posY + canvas.scrollBars.dy/2.0;

        scroll_update(view_width, view_height);
        scroll_center(old_center_x, old_center_y);

        canvas.update();
    }

    /* extracted from the SCROLLBAR attribute documentation */
    private void scroll_update(int view_width, int view_height)
    {
        /* view_width and view_height is the virtual space size */
        /* here we assume XMIN=0, XMAX=1, YMIN=0, YMAX=1 */
        int elem_width, elem_height;
        int canvas_width, canvas_height;
        int scrollbar_size = getGlobalAttributeInt(GlobalAttributes.ScrollBarSize);
        int border = canvas.hasBorder ? 1 : 0;

        Size rasterSize = canvas.rasterSize;
        elem_width  = rasterSize.width;
        elem_height = rasterSize.height;

        /* if view is greater than canvas in one direction,
        then it has scrollbars,
        but this affects the opposite direction */
        elem_width -= 2 * border;  /* remove BORDER (always size=1) */
        elem_height -= 2 * border;
        canvas_width = elem_width;
        canvas_height = elem_height;
        if (view_width > elem_width)  /* check for horizontal scrollbar */
            canvas_height -= scrollbar_size;  /* affect vertical size */
        if (view_height > elem_height)
            canvas_width -= scrollbar_size;
        if (view_width <= elem_width && view_width > canvas_width)  /* check if still has horizontal scrollbar */
            canvas_height -= scrollbar_size;
        if (view_height <= elem_height && view_height > canvas_height)
            canvas_width -= scrollbar_size;
        if (canvas_width < 0) canvas_width = 0;
        if (canvas_height < 0) canvas_height = 0;

        canvas.scrollBars.dx = cast(float)canvas_width / cast(float)view_width;
        canvas.scrollBars.dy = cast(float)canvas_height / cast(float)view_height;
    }


    void scroll_center(float old_center_x, float old_center_y)
    {
        /* always update the scroll position
        keeping it proportional to the old position
        relative to the center of the ih. */

        float dx = canvas.scrollBars.dx;
        float dy = canvas.scrollBars.dy;

        float posx = old_center_x - dx / 2.0f;
        float posy = old_center_y - dy / 2.0f;

        if (posx < 0) posx = 0;
        if (posx > 1 - dx) posx = 1 - dx;

        if (posy < 0) posy = 0;
        if (posy > 1 - dy) posy = 1 - dy;

        canvas.scrollBars.posX = posx;
        canvas.scrollBars.posY = posy;
    }


    private void iupSlider_valueChanged(Object sender, CallbackEventArgs e)
    {
        zoom_update(iupSlider.value);
    }

    private void canvas_paint(Object sender, CallbackEventArgs e, float posx, float posy)
    {
        // Size size = canvas.drawSize;
        //statusLabel.title  = format("width = %d, height=%d", size.width, size.height);
        redraw();
    }

    private void redraw()
    {

        /* draw the background */
        cdCanvas.activate();
        cdCanvas.background = background;
        cdCanvas.clear();

        //cdCanvas.drawText(50,150, "Test");
        //cdCanvas.drawText(50,100, "中文\n换行");

        /* draw the image at the center of the canvas */
        if(currentImage is null)
            return;

        string outText;

        outText = std.format.format("resolution : %d x %d", currentImage.width, currentImage.height);
        outText ~= std.format.format("\ndepth : %d", currentImage.planeNumber);
        outText ~= std.format.format("\nsize(bytes) : %d", currentImage.size);
        outText ~= std.format.format("\nisAlpha : %s", to!string(currentImage.hasAlpha));
        cdCanvas.drawText(20,200, outText);
        cdCanvas.drawLine(0, 0, 50, 50);

        //currentImage.width

        updateViewRect();

        /* black line around the image */
        cdCanvas.foreground = Colors.Black;
        cdCanvas.lineStyle = LineStyle.Continuous;
        cdCanvas.lineWidth = 1;
        cdCanvas.drawRect(Rectangle!int(view_x - 1, view_y - 1, view_x + view_width, view_y + view_height));

        // draw the image in a CD library canvas.
        // Works only for data_type IM_BYTE, and color spaces: IM_RGB, IM_MAP, IMGRAY and IM_BINARY.
        imcdCanvasPutImage(cdCanvas, currentImage, view_x, view_y, view_width, view_height, 0, 0, 0, 0);

        // draw grid

        // draw line
        if(overlayShape != OverlayShapes.Undefined)
        {
            cdCanvas.transformTranslate(view_x, view_y);
            cdCanvas.transformScale(cast(double)view_width / cast(double)currentImage.width,
                                    view_height / cast(double)currentImage.height);
            handleOverlayShape(cdCanvas, end_x, end_y);
            cdCanvas.transform(null);
        }

        cdCanvas.flush();
    }
    private Color background;
    private ImImage currentImage;

    private void updateViewRect()
    {
        Size canvasSize = canvas.drawSize;

        double zoom_index = iupSlider.value;
        zoom_factor = pow(2, zoom_index);

        float posx = canvas.scrollBars.posX;
        float posy = canvas.scrollBars.posY;

        view_width = cast(int)(zoom_factor * currentImage.width);
        view_height = cast(int)(zoom_factor * currentImage.height);


        if (canvasSize.width < view_width)
            view_x = cast(int)floor(-posx*view_width);
        else
            view_x = (canvasSize.width - view_width) / 2;

        if (canvasSize.height < view_height)
        {
            /* posy is top-bottom, CD is bottom-top.
            invert posy reference (YMAX-DY - POSY) */
            float dy = canvas.scrollBars.dy;
            posy = 1.0f - dy - posy;
            view_y = cast(int)floor(-posy*view_height);
        }
        else
            view_y = (canvasSize.height - view_height) / 2;
    }
    int view_x, view_y, view_width, view_height;
    double zoom_factor;


    private void item_new_click(Object sender, CallbackEventArgs e)
    {
        if(saveCheck())
            new_file();
    }

    private void new_file()
    {
        this.title = "Untitled - Simple Paint";
        this.isTextChanged = false;
        fileName = "";

        ImImage newImage = new ImImage(320, 240);
        fillWhite(newImage);

        canvas.update();

        sizeLabel.title = std.format.format("%d x %d px", newImage.width, newImage.height);
        iupSlider.value = 0;

        if(currentImage !is null)
            currentImage.dispose();
        currentImage = newImage;
    }

    private void fillWhite(ImImage image)
    {
        ubyte[][] data = image.matrixData;
        int x, y, offset;

        for (y = 0; y < image.height; y++)
        {
            for (x = 0; x < image.width; x++)
            {
                offset = y * image.width + x;
                data[0][offset] = 255;
                data[1][offset] = 255;
                data[2][offset] = 255;
            }
        }
    }


    private void showErrorCode(ImErrorCodes code)
    {
        IupMessageDialog dialog = new IupMessageDialog();
        dialog.dialogType = MessageDialogType.Error;
        dialog.parent = this;
        dialog.title = "Error";

        switch(code)
        {
            case ImErrorCodes.Open:
                dialog.message = "Error Opening File.";
                break;

            case ImErrorCodes.Access:
                dialog.message = "Error Accessing File.";
                break;

            case ImErrorCodes.Format:
                dialog.message = "Invalid Format.";
                break;

            case ImErrorCodes.Data:
                dialog.message = "Image type not Supported.";
                break;

            case ImErrorCodes.Compress:
                dialog.message = "Invalid or unsupported compression.";
                break;

            case ImErrorCodes.Mem:
                dialog.message = "Insufficient memory.";
                break;

            default:
                dialog.message = "Unknown Error.";
                break;

        }

        dialog.showDialog();
        dialog.dispose();
    }

    private void openFile(string fileName)
    {
        //if(!saveCheck())
        //    return;

        config.updateMenuRecent(fileName);
        this.fileName = fileName;
        this.title = stripExtension(baseName(fileName)) ~ " - Simple Paint";

        if(currentImage !is null)
            currentImage.dispose();

        currentImage = loadImImage(fileName);
        if(currentImage is null)
            return;

        sizeLabel.title = std.format.format("%d x %d px", currentImage.width, currentImage.height);
        iupSlider.value = 0;
        canvas.update();
    }
    private string fileName;

    private ImImage loadImImage(string fileName)
    {
        ImImage image = new ImImage();
        auto code = image.load(fileName);
        if(code != ImErrorCodes.None)
        {
            showErrorCode(code);
            image = null;
        }
        else
        {
            // image.removeAlpha();
            if(image.colorSpace != ImColorSpace.RGB)
            {
                ImImage oldImage = image;
                image = new ImImage(image, ImColorSpace.RGB);
                image.convertColorSpace(oldImage);
                oldImage.destroy();
            }
        }

        return image;
    }


    private ubyte[] readFile(string name)
    {
        File f = File(name, "r");

        /* calculate file size */
        f.seek(0, SEEK_END);
        auto fileSize = cast(uint)f.tell();
        f.seek(0, SEEK_SET);

        ubyte[] buffer = new ubyte[fileSize + 1];
        f.rawRead(buffer);  // Only UTF-8
        buffer[fileSize] = '\0';
        f.close();

        return buffer;
    }

    private void writeFile(string name, string text)
    {
        File f = File(name, "w");  
        f.write(text);
        f.close();
    }

    private void file_menu_opened(Object sender, CallbackEventArgs e)
    {
        item_save.enabled = isTextChanged;

        if(isTextChanged && !fileName.empty)
        {
            item_revert.enabled = true;
        }
        else
        {
            item_revert.enabled = false;
        }
    }

    private void openMenuItem_click(Object sender, CallbackEventArgs e)
    {
        //if(!saveCheck())
        //    return;

        IupFileDialog dialog = new IupFileDialog();
        dialog.parent = this;
        dialog.dialogType = FileDialogType.Open;
        dialog.extFilter = "Image Files|*.bmp;*.jpg;*.png;*.tif;*.tga|All Files|*.*|";

        if(dialog.showDialog() == DialogResult.OK)
        {
            openFile(dialog.fileName);
            string dir = dialog.initialDirectory;
            config.setVariable(ThisFormName, "LastDirectory", dir);
        }

        dialog.close();
        delete dialog;
    }

    private bool saveCheck()
    {
        if(isTextChanged)
        {
            DialogResult r = IupMessageBox.show("Warning", "File not saved! Save it now?", 
                                             MessageBoxButtons.YesNoCancel);
            if(r == DialogResult.Yes)
            {
                isTextChanged = false;
            }
            else if(r == DialogResult.Cancel)
                return false;
        }

        return true;
    }


    private void saveMenuItem_click(Object sender, CallbackEventArgs e)
    {
        if(fileName.empty)
        {
            saveasMenuItem_click(sender,  e);
        }
        else
        {
            isTextChanged = false;
        }
    }


    private void saveasMenuItem_click(Object sender, CallbackEventArgs e)
    {
        IupFileDialog dialog = new IupFileDialog();

        dialog.dialogType = FileDialogType.Save;
        dialog.extFilter = "Text Files|*.txt|All Files|*.*|";
        dialog.fileName = fileName;
        if(dialog.showDialog() == DialogResult.OK)
        {
            //
            fileName = dialog.fileName;
            this.title = stripExtension(baseName(fileName)) ~ " - Simple Notepad";
            config.updateMenuRecent(fileName);


            isTextChanged = false;
            //MessageBox.show("File", text);
        }

        //dialog.close();
    }


    private void item_revert_click(Object sender, CallbackEventArgs e)
    {
        if(saveCheck())
            openFile(fileName);
    }


    private void pageSetupMenuItem_click(Object sender, CallbackEventArgs e)
    {

    }

    private void printMenuItem_click(Object sender, CallbackEventArgs e)
    {
        string title = stripExtension(baseName(fileName));
        CdCanvas cdCanvas = new PrinterCdCanvas(title);
        if(!cdCanvas.isValid)
            return;

        cdCanvas.background = background;
        cdCanvas.clear();

        if(currentImage is null)
        {
            cdCanvas.dispose();
            return;
        }


        int x, y, canvas_width, canvas_height, view_width, view_height;
        double canvas_width_mm, canvas_height_mm;

        /* draw the image at the center of the canvas */
        int margin_width = 20;
        int margin_height = 20;

        cdCanvas.getSize(canvas_width, canvas_height, canvas_width_mm, canvas_height_mm);

        /* convert to pixels */
        margin_width = cast(int)((margin_width * canvas_width) / canvas_width_mm);
        margin_height = cast(int)((margin_height * canvas_height) / canvas_height_mm);

        int image_height = currentImage.height;
        int image_width = currentImage.width;

        int trueCanvasWidth, trueCanvasHeight;
        trueCanvasWidth= canvas_width - 2 * margin_width;
        trueCanvasHeight = canvas_height - 2 * margin_height;

        view_width = trueCanvasWidth;
        view_height =  (trueCanvasWidth * image_height) / image_width;
        if (view_height > trueCanvasHeight)
        {
            view_height = trueCanvasHeight;
            view_width = (trueCanvasHeight * image_width) / image_height;
        }

        x = (canvas_width - view_width) / 2;
        y = (canvas_height - view_height) / 2;

        if(currentImage.colorSpace == ImColorSpace.RGB)
        {
            const(ubyte)[][] matrixData = cast(const(ubyte)[][])currentImage.matrixData;
            if(currentImage.hasAlpha())
            {
                cdCanvas.putImageRectRGBA(currentImage.width, currentImage.height, matrixData,
                                          x,y,currentImage.width, currentImage.height, 0, 0, 0, 0);
            }
            else
            {
                cdCanvas.putImageRectRGB(currentImage.width, currentImage.height, matrixData,
                                         x,y,currentImage.width, currentImage.height, 0, 0, 0, 0);
            }

        }
        else
        {
            cdCanvas.putImageRectMap(currentImage.width, currentImage.height, currentImage.linearData,
                                     x,y,currentImage.width, currentImage.height, 0, 0, 0, 0);

        }


        cdCanvas.dispose();
    }

    private void edit_menu_opened(Object sender, CallbackEventArgs e)
    {
        statusLabel.title  = "edit_menu_opened";

        item_paste.enabled = IupClipboard.isImageAvailable;

        string selectedText = "";
        if(currentImage is null)
        {
            item_cut.enabled = false;
            item_copy.enabled = false;
            item_delete.enabled = false;
        }
        else
        {
            item_cut.enabled = true;
            item_copy.enabled = true;
            item_delete.enabled = true;
        }
    }

    private void edit_menu_closed(Object sender, CallbackEventArgs e)
    {
        statusLabel.title  = "edit_menu_closed";
    }

    private void item_cut_click(Object sender, CallbackEventArgs e)
    {
    }

    private void item_copy_click(Object sender, CallbackEventArgs e)
    {
        if(currentImage !is null)
            IupClipboard.setNativeImage(currentImage);
    }

    private void item_paste_click(Object sender, CallbackEventArgs e)
    {
        ImImage image = IupClipboard.getNativeImage();
        if(image is null)
        {
            IupMessageDialog dialog = new IupMessageDialog();
            dialog.dialogType = MessageDialogType.Error;
            dialog.parent = this;
            dialog.title = "Error";
            dialog.message = "Invalid Clipboard Data";

            dialog.showDialog();
            dialog.dispose();

            return;
        }

        if(image.colorSpace != ImColorSpace.RGB)
        {
            ImImage oldImage = image;
            image = new ImImage(image, ImColorSpace.RGB);
            image.convertColorSpace(oldImage);
            oldImage.destroy();
        }

        if(currentImage !is null)
            currentImage.destroy();

        currentImage = image;
        canvas.update();
    }

    private void item_delete_click(Object sender, CallbackEventArgs e)
    {
    }

    private void item_select_all_click(Object sender, CallbackEventArgs e)
    {
    }

    private void fontMenuItem_click(Object sender, CallbackEventArgs e)
    {
        IupFontDialog dialog = new IupFontDialog("IupFontDlg Test");

        //dialog.font = "Times New Roman, Bold 20";

        if(dialog.showDialog() == DialogResult.OK)
        {
            Font font =  dialog.font;

            config.setVariable(ThisFormName, "Font", font.toString());
        }

        dialog.dispose();
    }

    private void backgroundMenuItem_click(Object sender, CallbackEventArgs e)
    {
        IupColorDialog dialog = new IupColorDialog();

        if(dialog.showDialog() == DialogResult.OK)
        {
            background =  dialog.color;
            config.setVariable("Canvas", "Background", background.toString());
            redraw();
        }

        dialog.dispose();
    }



    private void multitext_caretPositionChanged(Object sender, 
                                                CallbackEventArgs args, int row, int col, int pos)
    {
        statusLabel.title  = format("row %d, col %d", row, col);
    }

    private void multitext_textChanged(Object sender, CallbackEventArgs e)
    {
        isTextChanged = true;
    }


    private void multitext_fileDropped(Object sender, CallbackEventArgs e,
                                       string fileName, int number, int x, int y)
    {
        if(number == 0)
            openFile(fileName);
        //statusLabel.title  = format("fileName:%s, Number=%d, x=%d, y=%d", fileName, number, x, y);

        //if(number < 2)
        //    e.result = CallbackResult.Ignore;
    }


    private void item_toolbar_click(Object sender, CallbackEventArgs e)
    {
        IupMenuItem menuItem = cast(IupMenuItem) sender;
        bool isChecked = !menuItem.checked;

        menuItem.checked = isChecked;
        toolbar.isFloating = !isChecked;
        toolbar.isVisible = isChecked;
        toolbar.refresh();
        config.setVariable(ThisFormName, "Toolbar", to!string(isChecked));
    }

    private void item_toolbox_click(Object sender, CallbackEventArgs e)
    {
        IupMenuItem menuItem = cast(IupMenuItem) sender;
        bool isChecked = !menuItem.checked;
        menuItem.checked = isChecked;

        if(isChecked)
            toolbox.show();
        else
            toolbox.hide();
    }
    

    private void item_statusbar_click(Object sender, CallbackEventArgs e)
    {        
        IupMenuItem menuItem = cast(IupMenuItem) sender;
        bool isChecked = !menuItem.checked;

        menuItem.checked = isChecked;
        statusbar.isFloating = !isChecked;
        statusbar.isVisible = isChecked;
        statusbar.refresh();

        config.setVariable(ThisFormName, "Statusbar", to!string(isChecked));
    }

    private void item_help_click(Object sender, CallbackEventArgs e)
    {
        IupHelp("http://www.tecgraf.puc-rio.br/iup");
    }

    private void aboutMenuItem_click(Object sender, CallbackEventArgs e)
    {
        IupMessageBox.show("About", "   Simple Notepad\n\nAutors:\n   Gustavo Lyrio" ~
                        "\n   Antonio Scuri\n   Heromyth(Ported to D)");
    }

    //override int show() {
    //    config.onDialogShow(this, ThisFormName);
    //    return 0;
    //}


    private void exitMenuItem_click(Object sender, CallbackEventArgs e)
    {
        if(saveCheck())
        {
            performExit();
            //config.dispose();
            //this.close();
            e.result = CallbackResult.Close;
        }
        else
            e.result = CallbackResult.Ignore;
    }

    private void performExit()
    {
        string s = config.fileName;
        config.onDialogClosed(this, ThisFormName);
        config.save();
        s = config.fileName;
    }
}

