module PredefinedDialogsTest;

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
import std.windows.charset;

version(Windows)
{
    import core.sys.windows.windef;
    import core.sys.windows.winuser;
    import core.sys.windows.wingdi;
}

import core.stdc.stdlib; 

import derelict.opengl3.gl;

import iup;
import im;
import cd;

import toolkit.event;
import toolkit.input;
import toolkit.drawing;


public class PreDialogsTestDialog : IupDialog
{
    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {
        string msg ="Press a key for a pre-defined dialog:\n" ~
            "e = IupMessageDlg(ERROR)\n" ~
            "i = IupMessageDlg(INFORMATION)\n" ~
            "w = IupMessageDlg(WARNING)\n" ~
            "q = IupMessageDlg(QUESTION)\n" ~
            "--------------------\n" ~
            "o = IupFileDlg(OPEN)\n" ~
            "O = IupFileDlg(OPEN+PREVIEW)\n" ~
            "G = IupFileDlg(OPEN+PREVIEW+OPENGL)\n" ~
            "s = IupFileDlg(SAVE)\n" ~
            "d = IupFileDlg(DIR)\n" ~
            "--------------------\n" ~
            "c = IupColorDlg\n" ~
            "f = IupFontDlg\n" ~
            "--------------------\n" ~
            "m = IupMessage\n" ~
            "a = IupAlarm\n" ~
            "t = IupGetText\n" ~
            //"g = IupGetFile\n" ~
            //"l = IupListDialog\n" ~
            "y = IupLayoutDialog\n" ~
            "--------------------\n" ~
            "Esc = quit";

        IupLabel label = new IupLabel(msg);
        IupVbox vbox = new IupVbox(label);

        this.child = vbox;

        this.margin = Size(10, 10);
        //this.size = Size(100, 100);
        this.title = "Pre-defined Dialogs Test";

        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;
        this.keyPress += &dialog_keyPress;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs e)
    {
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        //this.dispose(); // can' be run here
    }

    private void dialog_helpRequested(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HELP_CB(%s)", IupElement.title);
    }

    private void dialog_colorUpdated(Object sender, CallbackEventArgs args)
    {
        IupColorDialog dialog = cast(IupColorDialog)sender;
        writefln("  colorUpdated(%s)", dialog.rgbValue);
    }

    private void testIupColorDialog()
    {
        IupColorDialog dialog = new IupColorDialog("IupColorDialog Test");
        dialog.color = Color.parse("128 0 255");

        Color c = dialog.color;

        dialog.alpha = 142;
        //dialog.colorTable = ";;177 29 234;;;0 0 23;253 20 119";
        dialog.canShowAlpha = true;
        dialog.canShowHex = true;
        dialog.canShowColorTable = true;
        dialog.canShowHelp = true;

        dialog.colorUpdated += &dialog_colorUpdated; 
        dialog.helpRequested += &dialog_helpRequested; 

        DialogResult r = dialog.showDialog(this);
        writefln("DialogResult(%s)", r);

        if(r == DialogResult.OK)
        {
            if(dialog.canShowAlpha)
                writefln("  VALUE(%s)", dialog.color.toRgb);
            else
                writefln("  VALUE(%s)", dialog.color.toString());

            writefln("  rgbValue(%s)", dialog.rgbValue);
            writefln("  hsiValue(%s)", dialog.hsiValue);
            writefln("  hexValue(%s)", dialog.hexValue);
            writefln("  COLORTABLE(%s)", dialog.colorTable);
        }

        dialog.dispose();
    }

    private void testIupFileDialog(FileDialogType dialogtype, int preview)
    {
        IupFileDialog dialog = new IupFileDialog("IupFileDialog Test");
        dialog.dialogType = dialogtype;
        dialog.initialDirectory = r"C:\Users\";

        if(dialogtype != FileDialogType.Dir)
        {
            //dialog.filter = "*.bmp";
            //dialog.filterInfo = "Bitmap Files";
            //dialog.filter = "*.jpg;*.jpeg;*.bmp;*.gif;*.tif;*.tiff;*.png";
            //dialog.extFilter = "Text files|*.txt;*.doc|Image files|*.jpg;*.bmp;*.gif|";
            //dialog.file = r"C:\Windows\explorer.exe";

            dialog.extFilter = "All Files|*.*|Image Files|*.bmp;*.jpg|Text Files|*.txt|";

        }

        dialog.helpRequested += &dialog_helpRequested; 
        dialog.initialFile = "test.bmp";
        dialog.restoreDirectory = false;

        if(dialogtype == FileDialogType.Open)
        {
            dialog.canMultiSelect = true;
        }

        //dialog.rasterSize = Size(800, 600);
        dialog.fileSelected += &dialog_fileSelected;
        dialog.defaultExt = "txt";


        if(preview>0)
        {
            dialog.canShowPreview = true;
            dialog.isPreviewAtRight = true;

            if(preview == 2)
            {
                IupGLCanvas glcanvas = new IupGLCanvas();
                glcanvas.bufferMode = GlBufferMode.Double;
                dialog.gLCanvas = glcanvas;
            }
        }

        DialogResult r = dialog.showDialog(this);
        writefln("DialogResult(%s)", r);

        if(r == DialogResult.OK)
        {
            writefln("  Initial directory(%s)", dialog.initialDirectory);

            if(dialog.dialogType == FileDialogType.Save)
            {
                writefln("  New file - VALUE(%s)", dialog.fileName);
            }
            else
            {
                writefln("  File exists - VALUE(%s)", dialog.fileName);

                if(dialog.canMultiSelect)
                {
                    int count = dialog.selectionCount;
                    writefln("  MULTIVALUECOUNT(%d)", count);

                    for(int i=0; i<count; i++)
                    {
                        writefln("  MULTIVALUE%d = %s", i, dialog.getSelection(i));
                    }
                }
            }
        }

        dialog.dispose();
    }

    private void dialog_fileSelected(Object sender, CallbackEventArgs args, 
                                     string fileName, string status)
    {
        printf("FILE_CB(%s - %s)\n", status.ptr,   toMBSz(fileName)); // TODO:
        //writefln("FILE_CB(%s - %s)", status,   toMBSz(fileName));
        IupFileDialog dialog = cast(IupFileDialog)sender;

        if(status == "PAINT")
        {
            writefln("  SIZE(%d x %d)", dialog.previewHeight, dialog.previewWidth);
            IupGLCanvas glcanvas = dialog.gLCanvas;

            if(glcanvas is null)
                drawTest(dialog);
            else
            {
                drawTestGL(dialog);
            }
        }
        else if(status == "FILTER")
        {
            //dialog.initialFile = "test";
            //args.result = IupElementActionContinue;
        }
        else if(status == "OK")
        {
            //dialog.initialFile = "test";
            //args.result = IupElementActionContinue;
        }

    }

    private void drawTestGL(IupFileDialog dialog)
    {
        IupGLCanvas glcanvas = dialog.gLCanvas;

        if (glcanvas is null)
            return;

        int w = dialog.previewWidth;
        int h = dialog.previewHeight;

        glcanvas.makeCurrent();

        glViewport(0,0,w,h); // 

        glClearColor(1.0, 0.0, 1.0, 1.0f);  /* pink */
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glColor3f(1.0,0.0,0.0);  /* red */
        glBegin(GL_QUADS); 
        glVertex2f(0.9f,0.9f); 
        glVertex2f(0.9f,-0.9f); 
        glVertex2f(-0.9f,-0.9f); 
        glVertex2f(-0.9f,0.9f); 
        glEnd();
        
        glcanvas.swapBuffers();
    }

    private void drawTest(IupFileDialog dialog)
    {
        RECT rect;
        HPEN oldPen;
        HDC hDC = dialog.deviceContext;
        int w = dialog.previewWidth;
        int h = dialog.previewHeight;

        SetRect(&rect, 0, 0, w, h);
        FillRect(hDC, &rect, GetStockObject(WHITE_BRUSH));

        oldPen = SelectObject(hDC, GetStockObject(DC_PEN));
        SetDCPenColor(hDC, RGB(255, 0, 0));

        MoveToEx(hDC, 0, 0, NULL);
        LineTo(hDC, w-1, h-1);
        MoveToEx(hDC, 0, h-1, NULL);
        LineTo(hDC, w-1, 0);

        SelectObject(hDC, oldPen);
    }

    private void testIupFontDialog()
    {
        IupFontDialog dialog = new IupFontDialog("IupFontDialog Test");
        dialog.color = Color.parse("128 0 255");
        dialog.backgroundColor = Color.parse("173 177 194");
        dialog.selectedFont = Font.parse("Times, Bold 20");
        dialog.helpRequested += &dialog_helpRequested; 

        DialogResult r = dialog.showDialog(this);
        writefln("DialogResult(%s)", r);

        if(r == DialogResult.OK)
        {
            writefln("  VALUE(%s)", dialog.selectedFont);
            writefln("  COLOR(%s)", dialog.color.toRgb());
        }

        dialog.dispose();
    }

    private void testAlarm()
    {
        Application.parentDialog = this;
        int r = IupMessageBox.show("IupAlarm Test", "Message Text\nSecond Line", "But 1", "Button 2", "B3");
        writefln("Button(%d)", r);
    }

    private void dialog_keyPress(Object sender, CallbackEventArgs args, int key)
    {
        IupDialog dialog = cast(IupDialog)sender;

        if(isPrintable(key))
        {
            writefln("K_ANY(%s, %d = %s \'%c\')", dialog.name, key,
                     Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("K_ANY(%s, %d = %s)", dialog.name, key, Keys.toName(key));
        }

        writefln("  MODKEYSTATE(%s)", Keys.getModifierKeyState()); 

        switch(key)
        {
            case Keys.m:
                IupMessageBox.show("IupMessage Test", "Message Text\nSecond Line.");
                break;

            case Keys.e:
                IupMessageDialog d = new IupMessageDialog("IupMessageDlg Test", "Message Text\nSecond Line",
                                                               MessageBoxButtons.OK, MessageDialogType.Error);
                d.helpRequested += &dialog_helpRequested; 
                DialogResult r = d.showDialog();
                writefln("BUTTONRESPONSE(%s)", r);
                d.dispose();
                break;

            case Keys.i:
                IupMessageDialog d = new IupMessageDialog("IupMessageDlg Test", "Message Text\nSecond Line",
                                                          MessageBoxButtons.OK, MessageDialogType.Information);
                d.horizontalPostion = ScreenPostionH.CenterParent;
                d.verticalPostion = ScreenPostionV.CenterParent;
                d.parent = this;   // bug: not works
                DialogResult r = d.showDialog();
                writefln("BUTTONRESPONSE(%s)", r);
                d.dispose();
                break;

            case Keys.w:
                IupMessageDialog d = new IupMessageDialog("IupMessageDlg Test", "Message Text\nSecond Line",
                                                          MessageBoxButtons.OkCancel, MessageDialogType.Warning);
                d.horizontalPostion = ScreenPostionH.CenterParent;
                d.verticalPostion = ScreenPostionV.CenterParent;
                d.parent = this;   // bug: not works
                d.helpRequested += &dialog_helpRequested;
                d.defaultResult = DialogResult.Cancel;
                DialogResult r = d.showDialog();
                writefln("BUTTONRESPONSE(%s)", r);
                d.dispose();
                break;

            case Keys.q:
                IupMessageDialog d = new IupMessageDialog("IupMessageDlg Test", "Message Text\nSecond Line",
                                                          MessageBoxButtons.YesNo, MessageDialogType.Question);
                d.horizontalPostion = ScreenPostionH.CenterParent;
                d.verticalPostion = ScreenPostionV.CenterParent;
                d.parent = this;   // bug: not works
                d.helpRequested += &dialog_helpRequested;
                DialogResult r = d.showDialog();
                writefln("BUTTONRESPONSE(%s)", r);
                d.dispose();
                break;

            case Keys.c:
                testIupColorDialog();
                break;

            case Keys.f:
                testIupFontDialog();
                break;

            case Keys.o:
                testIupFileDialog(FileDialogType.Open, 0);
                break;

            case Keys.O:
                testIupFileDialog(FileDialogType.Open, 1);
                break;

            case Keys.G:
                testIupFileDialog(FileDialogType.Open, 2);
                break;

            case Keys.s:
                testIupFileDialog(FileDialogType.Save, 0);
                break;

            case Keys.d:
                testIupFileDialog(FileDialogType.Dir, 0);
                break;

            case Keys.a:
                testAlarm();
                break;

            case Keys.y:
                IupLayoutDialog d = new IupLayoutDialog();
                d.show();
                break;

            case Keys.g:
                break;

            case Keys.t:
                IupTextInputDialog d = new IupTextInputDialog("IupGetText Text");
                DialogResult r = d.showDialog("text first line\nsecond line");

                writefln("return(%s)", r);
                if(r == DialogResult.OK)
                {
                    writefln("Text(%s)", d.text);
                }

                break;

            case Keys.l:
                break;

            case Keys.ESC:
                dialog.close();
                args.result = IupElementAction.Ignore;
                break;

                default:
                    break;
        }
    }
}