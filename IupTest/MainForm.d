module MainForm;

version(Windows) { 
    pragma(lib, "iupcd.lib");
    pragma(lib, "cd.lib");
    pragma(lib, "cdgl.lib");
    pragma(lib, "cdpdf.lib"); 
    //pragma(lib, "gdi32.lib");
}


import std.container.array;
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

import derelict.opengl3.gl;

import iup;
//import im;
//import cd;

import toolkit.event;
import toolkit.drawing;

import ButtonTest;
import CalendarTest;
import CanvasTest;
import ClipboardTest;
import ColorTest;
import ContainerTest;
import HmiControlsTest;
import DialogTest;
import IdleTest;
import LabelTest;
import ListTest;
import MdiTest;
import MenuTest;
import PredefinedDialogsTest;
import ProgressBarTest;
import SliderTest;
import SplitTest;
import SysInfoTest;
import TextTest;
import TextSpinTest;
import TimerTest;
import ToggleTest;
import TrayTest;


public class MainForm : IupDialog
{
    private IupListBox listBox;
    private Array!TestElement testItems; 
    //Appender!TestElement testItems;

    this() 
    {
        initilizeTestItems();
        super();
    }


    protected override void initializeComponent()
    {
        string[] itemIitles = new string[testItems.length];
        for(int i=0; i<testItems.length; i++)
        {
            itemIitles[i] = testItems[i].title;
            //listBox.updateItem(i, testItems[i].title);

            //listBox.items.append(testItems[i].title); // must be run after the map();
        }

        listBox = new IupListBox(itemIitles);
        listBox.visibleLines = 15;
        listBox.canExpand = true;
        listBox.keyPress += &listBox_keyPress;
        listBox.doubleClick += &listBox_doubleClick;

        IupVbox vbox = new IupVbox(listBox);
        this.child = vbox;

        this.margin = Size(10, 10);
        this.title = "IupTests";

        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;

        //resetUserSize();

    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        //for(int i=0; i<testItems.length; i++)
        //{
        //    listBox.items.append(testItems[i].title);
        //}

        // https://github.com/DerelictOrg/DerelictGL3
        DerelictGL.load();  // It must be run after IUP is initilized.
    }


    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        e.result = CallbackResult.Close;
    }

    private void listBox_keyPress(Object sender, CallbackEventArgs e, int key)
    {
        if(key == Keys.Enter)
        {
            testElement(listBox.selectedIndex);
        }
    }

    private void listBox_doubleClick(Object sender, CallbackEventArgs e, int index, string text)
    {
        testElement(index);
    }

    private void testElement(int index)
    {
        writefln("selectedIndex = %d", index);
        if(index <0 || index>=testItems.length)
            return;

        TestElement testElement = testItems[index];

        IupDialog dialog = testElement.dialog;
        if(dialog !is null && dialog.isValid)
            dialog.showXY(ScreenPostionH.Current, ScreenPostionV.Current);
        else
        {
            string testElementName = testElement.name;

            if(testElementName == TestElements.GetColorDialog)
            {
                Color color = Colors.Red;
                DialogResult r = IupColorDialog.getColor(color);
                if(r == DialogResult.OK)
                    writef("RGB = %s  Hex=[%s]\n", color.toRgb, color.toRgb(true));
            }
            else
            {
                dialog = createTestDialog(testElement.name);
                if(dialog !is null)
                {
                    testElement.dialog = dialog;
                    dialog.show();
                }
                else
                    writefln("The test for %s is not supported.", testElement.name);
            }
        }
    }

    private IupDialog createTestDialog(string name)
    {
        IupDialog dialog = null;

        switch(name)
        {
            case TestElements.Button:
                dialog = new ButtonTestDialog();
                break;

            case TestElements.Calendar:
                dialog = new CalendarTestDialog();
                break;

            case TestElements.Canvas:
                dialog = new CanvasTestDialog();
                break;

            case TestElements.CanvasCDSimple:
                dialog = new CanvasCDSimpleTestDialog();
                break;

            case TestElements.CanvasCDDBuffer:
                dialog = new CanvasCDDBufferTestDialog();
                break;

            case TestElements.CanvasOpenGL:
                dialog = new GLCanvasTestDialog();
                break;

            case TestElements.CanvasScrollbar:
                dialog = new CanvasScrollbarTestDialog();
                break;

            case TestElements.Clipboard:
                dialog = new ClipboardTestDialog();
                break;

            case TestElements.ColorBar:
                dialog = new ColorBarTestDialog();
                break;

            case TestElements.ColorBrowser:
                dialog = new ColorBrowserTestDialog();
                break;

            case TestElements.Dial:
                dialog = new DialTestDialog();
                break;

            case TestElements.Dialog:
                dialog = new DialogTestDialog();
                break;

            case TestElements.GridBox:
                dialog = new GridBoxTestDialog();
                break;

            case TestElements.GroupBox:
                dialog = new GroupBoxTestDialog();
                break;

            case TestElements.Hbox:
                dialog = new HboxTestDialog();
                break;

            case TestElements.FlatButton:
                dialog = new FlatButtonTestDialog();
                break;

            case TestElements.Idle:
                dialog = new IdleTestDialog();
                break;

            case TestElements.Label:
                dialog = new LabelTestDialog();
                break;

            case TestElements.LinkLabel:
                dialog = new LinkLabelTestDialog();
                break;

            case TestElements.ListControl:
                dialog = new ListTestDialog();
                break;

            case TestElements.MdiFame:
                dialog = new MdiTestDialog();
                break;

            case TestElements.Menu:
                dialog = new MenuTestDialog();
                break;

            case TestElements.PredefinedDialogs:
                dialog = new PreDialogsTestDialog();
                break;

            case TestElements.ProgressBar:
                dialog = new ProgressBarTestDialog();
                break;

            case TestElements.ProgressDialog:
                dialog = new ProgressDialogTestDialog();
                break;

            case TestElements.Slider:
                dialog = new SliderTestDialog();
                break;

            case TestElements.Sbox:
                dialog = new SboxTestDialog();
                break;

            case TestElements.SplitContainer:
                dialog = new SplitTestDialog();
                break;

            case TestElements.SpinBox:
                dialog = new SpinBoxTestDialog();
                break;

            case TestElements.SysInfo:
                dialog = new SysInfoTestDialog();
                break;

            case TestElements.TextSpin:
                dialog = new TextSpinTestDialog();
                break;

            case TestElements.TabControl:
                dialog = new IupTabControlTestDialog();
                break;

            case TestElements.TextBox:
                dialog = new TextTestDialog();
                break;

            case TestElements.Timer:
                dialog = new TimerTestDialog();
                break;

            case TestElements.Toggle:
                dialog = new ToggleTestDialog();
                break;

            case TestElements.Tray:
                dialog = new TrayTestDialog();
                break;

            case TestElements.Tree:
                dialog = new TreeTestDialog();
                break;

            case TestElements.Vbox: 
                dialog = new VboxTestDialog();
                break;

            case TestElements.Zbox:
                dialog = new ZboxTestDialog();
                break;

            default:
                break;
        }

        return dialog;
    }


    void initilizeTestItems()
    {
        testItems.insertBack(new TestElement(TestElements.Button, TestElements.Button));
        testItems.insertBack(new TestElement(TestElements.Calendar, TestElements.Calendar));
        testItems.insertBack(new TestElement(TestElements.Canvas, TestElements.Canvas));
        testItems.insertBack(new TestElement(TestElements.CanvasCDSimple, TestElements.CanvasCDSimple));
        testItems.insertBack(new TestElement(TestElements.CanvasCDDBuffer, TestElements.CanvasCDDBuffer));
        testItems.insertBack(new TestElement(TestElements.CanvasOpenGL, TestElements.CanvasOpenGL));
        testItems.insertBack(new TestElement(TestElements.CanvasScrollbar, TestElements.CanvasScrollbar));
        testItems.insertBack(new TestElement(TestElements.Clipboard, TestElements.Clipboard));
        testItems.insertBack(new TestElement(TestElements.ColorBar, TestElements.ColorBar));
        testItems.insertBack(new TestElement(TestElements.ColorBrowser, TestElements.ColorBrowser));
        testItems.insertBack(new TestElement(TestElements.Dial, TestElements.Dial));
        testItems.insertBack(new TestElement(TestElements.Dialog, TestElements.Dialog));
        testItems.insertBack(new TestElement(TestElements.FlatButton, TestElements.FlatButton));
        testItems.insertBack(new TestElement(TestElements.GetColorDialog, TestElements.GetColorDialog));
        testItems.insertBack(new TestElement(TestElements.GridBox, TestElements.GridBox));
        testItems.insertBack(new TestElement(TestElements.GroupBox, "GroupBox/IupFrame"));
        testItems.insertBack(new TestElement(TestElements.Hbox, TestElements.Hbox));
        testItems.insertBack(new TestElement(TestElements.Idle, TestElements.Idle));
        testItems.insertBack(new TestElement(TestElements.Label, TestElements.Label));
        testItems.insertBack(new TestElement(TestElements.LinkLabel, TestElements.LinkLabel));
        testItems.insertBack(new TestElement(TestElements.ListControl, TestElements.ListControl));
        testItems.insertBack(new TestElement(TestElements.MdiFame, TestElements.MdiFame));
        testItems.insertBack(new TestElement(TestElements.Menu, TestElements.Menu));
        testItems.insertBack(new TestElement(TestElements.PredefinedDialogs, TestElements.PredefinedDialogs));
        testItems.insertBack(new TestElement(TestElements.ProgressBar, TestElements.ProgressBar));
        testItems.insertBack(new TestElement(TestElements.ProgressDialog, TestElements.ProgressDialog));
        testItems.insertBack(new TestElement(TestElements.Slider, "Val(Slider)"));
        testItems.insertBack(new TestElement(TestElements.Sbox, TestElements.Sbox));
        testItems.insertBack(new TestElement(TestElements.SplitContainer, TestElements.SplitContainer));
        testItems.insertBack(new TestElement(TestElements.SpinBox, TestElements.SpinBox));
        testItems.insertBack(new TestElement(TestElements.SysInfo, TestElements.SysInfo));
        testItems.insertBack(new TestElement(TestElements.TabControl, TestElements.TabControl));
        testItems.insertBack(new TestElement(TestElements.TextBox, TestElements.TextBox));
        testItems.insertBack(new TestElement(TestElements.TextSpin, "TextSpin(UpDown)"));
        testItems.insertBack(new TestElement(TestElements.Timer, TestElements.Timer));
        testItems.insertBack(new TestElement(TestElements.Toggle, "Toggle(CheckBox)"));
        testItems.insertBack(new TestElement(TestElements.Tray, TestElements.Tray));
        testItems.insertBack(new TestElement(TestElements.Tree, TestElements.Tree));
        testItems.insertBack(new TestElement(TestElements.Vbox, TestElements.Vbox));
        testItems.insertBack(new TestElement(TestElements.Zbox, TestElements.Zbox));
    }

}


struct TestElements
{
    enum Button = "Button";
    enum Calendar = "Calendar";
    enum Canvas = "Canvas";
    enum CanvasCDSimple = "CanvasCDSimple";
    enum CanvasCDDBuffer = "CanvasCDDBuffer";
    enum CanvasOpenGL = "CanvasOpenGL";
    enum CanvasScrollbar = "CanvasScrollbar";
    enum Clipboard = "Clipboard";
    enum ColorBar = "ColorBar";
    enum ColorBrowser = "ColorBrowser";
    enum Dialog = "Dialog";
    enum Dial = "Dial";
    enum FlatButton = "FlatButton";
    enum GetColorDialog = "GetColorDialog";
    enum GridBox = "GridBox";
    enum GroupBox = "GroupBox";
    enum Hbox = "Hbox";
    enum Idle = "Idle";
    enum Label = "Label";
    enum LinkLabel = "LinkLabel";
    enum ListControl = "ListControl";
    enum Menu = "Menu";
    enum MdiFame = "MdiFame";
    enum PredefinedDialogs = "PredefinedDialogs";
    enum ProgressBar = "ProgressBar";
    enum ProgressDialog = "ProgressDialog";
    enum Slider = "Slider";
    enum Sbox = "Sbox";
    enum SplitContainer = "SplitContainer";
    enum SpinBox = "SpinBox";
    enum SysInfo = "SysInfo";
    enum TextBox = "TextBox";
    enum TabControl = "TabControl";
    enum TextSpin = "TextSpin";
    enum Timer = "Timer";
    enum Toggle = "Toggle";
    enum Tray = "Tray";
    enum Tree = "Tree";
    enum Vbox = "Vbox";
    enum Zbox = "Zbox";
}


public class TestElement
{
    string name;
    string title;

    IupDialog dialog;

    this(string name, string title)
    {
        this.name = name;
        this.title = title;
    }
}
