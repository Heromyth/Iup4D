module ClipboardTest;

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


//version = CUSTOM_FORMAT;

public class ClipboardTestDialog : IupDialog
{
    enum CustomFormat = "TESTFORMAT";

    private IupMultiLine multiLine;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        multiLine = new IupMultiLine();
        multiLine.size = Size(80, 60);
        multiLine.canExpand = true;

        IupButton copyBtn = new IupButton("Copy");
        copyBtn.click += &copyBtn_click;

        IupButton pasteBtn = new IupButton("Paste");
        pasteBtn.click += &pasteBtn_click;

        IupVbox vbox = new IupVbox(multiLine, copyBtn, pasteBtn);

        this.child = vbox;
        this.gap = 10;
        this.margin = Size(20, 20);
        this.title = "Clipboard Test";

        version(CUSTOM_FORMAT)
        {
            IupClipboard.open();
            IupClipboard.addFormat(CustomFormat);
            IupClipboard.dispose();
        }
    }

    private void pasteBtn_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;
        IupClipboard.open();

        version(CUSTOM_FORMAT)
        {
            IupClipboard.setFormat(CustomFormat);
            void* data = IupClipboard.formatData;
            int len = IupClipboard.formatDataSize;
            string text = cast(string)(data[0..len]);
            multiLine.text = text;
        }
        else
        {
            multiLine.text = IupClipboard.text;
        }
        IupClipboard.dispose();

    }

    private void copyBtn_click(Object sender, CallbackEventArgs e)
    {
        IupButton button = cast(IupButton)sender;

        IupClipboard.open();
        version(CUSTOM_FORMAT)
        {
            string text = multiLine.text;
            IupClipboard.setFormat(CustomFormat);
            IupClipboard.formatDataSize = text.length;
            IupClipboard.formatData =cast(void*)text.ptr;
        }
        else
        {
            IupClipboard.text = multiLine.text;
        }
        IupClipboard.dispose();
    }
}