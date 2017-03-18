module DialogTest;

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

import core.sys.windows.windef;
import core.sys.windows.winuser;
import core.sys.windows.wingdi;

import core.stdc.stdlib; 

import iup;
import im;
import cd;

import toolkit.event;
import toolkit.input;
import toolkit.drawing;

version(Windows) { 
    pragma(lib, "gdi32.lib");
}


public class DialogTestDialog : IupDialog
{
    private IupImage m_Ico;
    private IupImage m_Cursor;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {

        string msg = "Press a key for a dialog test:\n" ~
            "1 = new with SIZE=FULLxFULL\n" ~
            "2 = new with dialog decorations\n" ~
            "3 = new with NO decorations\n" ~
            "4 = new changing PLACEMENT\n" ~
            "5 = new using IupPopup\n" ~
            "6 = new with FULLSCREEN=YES\n" ~
            "7 = new with CUSTOMFRAME=YES\n" ~
            "p = PLACEMENT=MAXIMIZED\n" ~
            "pp = PLACEMENT=MINIMIZED\n" ~
            "ppp = PLACEMENT=NORMAL\n" ~
            "pppp = PLACEMENT=FULL\n" ~
            "s = IupShow(main)\n" ~
            "f = toggle FULLSCREEN state\n" ~
            "c = return IUP_CLOSE;\n" ~
            "h = IupHide\n" ~
            "r = RASTERSIZE+IupRefresh\n" ~
            "Esc = quit";

        IupLabel label = new IupLabel(msg);
        IupVbox vbox = new IupVbox(label);

        this.child = vbox;
        this.rasterSize = Size(500, 500);
        this.title = "IupDialog Test";
        this.tooltip.text  = "IupDialog as a main window,\n" ~
            "all decorations.\n" ~
            "rastersize+centered.";

        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;
        this.destroying += &dialog_destroying;
        this.mapped += &dialog_mapped;
        this.keyPress += &dialog_keyPress;
        this.gotFocus += &dialog_gotFocus;
        this.lostFocus += &dialog_lostFocus;
        this.helpRequested += &dialog_helpRequested;
        this.mouseEnter += &dialog_mouseEnter;
        this.mouseLeave += &dialog_mouseLeave;
        this.move += &dialog_move;
        this.tipPopup += &dialog_tipPopup;
        this.sizeChanged += &dialog_sizeChanged;
        this.stateChanged += &dialog_stateChanged;
        this.fileDropped += &dialog_fileDropped;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        // Notice: It runs after redraw().
        IupDialog dialog = cast(IupDialog)sender;
        writefln("loaded(%s)", dialog.title);

        IupImage8 image = new IupImage8(11, 11, pixmap_x_8);
        //Color background = image.background;
        //image.setColor(0, background);
        image.useBackground(0);
        image.setColor(1, Color.fromRgb(0, 1, 0));
        image.setColor(2, Color.fromRgb(255, 0, 0));
        image.setColor(3, Color.fromRgb(255, 255, 0));

        m_Ico = image;

        //
        image = new IupImage8(32, 32, pixmap_cursor_8);
        //Color background = image.background;
        //image.setColor(0, background);
        image.useBackground(0); /* always for cursor */
        image.setColor(1, Color.fromRgb(255, 0, 0));
        image.setColor(2, Color.fromRgb(0, 255, 0));
        image.setColor(3, Color.fromRgb(128, 0, 0));
        image.hotspot = Point!int(21, 10);

        m_Cursor = image;
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("CLOSE_CB(%s) with IupDestroy", dialog.title);
        //this.dispose();
        //e.result = IupElementAction.Ignore;
    }

    private void dialog_closing2(Object sender, CallbackEventArgs e)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("CLOSE_CB(%s) with IUP_IGNORE", dialog.title);
        e.result = IupElementAction.Ignore;
    }

    private void dialog_destroying(Object sender, CallbackEventArgs args)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("DESTROY_CB(%s)", dialog.title);
    }

    private void dialog_mapped(Object sender, CallbackEventArgs args)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("MAP_CB(%s)", dialog.title);
    }

    private void dialog_keyPress(Object sender, CallbackEventArgs args, int key)
    {
        IupDialog dialog = cast(IupDialog)sender;

        if(isPrintable(key))
        {
            writefln("K_ANY(%s, %d = %s \'%c\')", dialog.name, key,  Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("K_ANY(%s, %d = %s)", dialog.name, key, Keys.toName(key));
        }

        writefln("  MODKEYSTATE(%s)", Keys.getModifierKeyState()); 

        switch(key)
        {
            case Keys.x:
                Point!int location = dialog.location;
                writefln("  X,Y=%s,%s", location.x, location.y);
                break;

            case Keys.y:
                dialog.showXY(100, 100);
                break;

            case Keys.r:
                dialog.rasterSize(Size(300, 300));
                dialog.refresh();
                Application.flush(); 
                writefln("RASTERSIZE=%s", IupSize.format(dialog.rasterSize));
                break;

            case Keys.D1:
                IupDialog dialog1 = createSubDialog(1, "SIZE=FULLxFULL + IupShow.\n" ~
                                "Check also F1 = RASTERSIZE+IupRefresh.\n" ~
                                "close_cb returns IGNORE.");
                dialog1.show();

                break;

            case Keys.D2:
                IupDialog dialog2 = createSubDialog(2, "Only common dlg decorations.\n" ~
                                                    "ShowXY.\nmin/max size.");
                dialog2.showXY(100, 100);
                break;

            case Keys.D3:
                IupDialog dialog3 = createSubDialog(3, "NO decorations");
                dialog3.showXY(ScreenPostionH.Right, ScreenPostionV.Center);
                break;

            case Keys.D4:
                IupDialog dialog4 = createSubDialog(4, "PLACEMENT.\nRepeat key to test variations.");
                dialog4.show();
                break;

            case Keys.D5:
                IupDialog dialog5 = createSubDialog(5, "IupPopup");
                dialog5.showDialog(ScreenPostionH.Current, ScreenPostionV.Current);
                break;

            case Keys.D6:
                IupDialog dialog6 = createSubDialog(6, "FULLSCREEN");
                dialog6.show();
                break;

            case Keys.D7:
                IupDialog dialog7 = createSubDialog(7, "CUSTOMFRAME");
                dialog7.show();
                break;

            case Keys.p:
                if(count_p == 0)
                    dialog.windowState = WindowState.Maximize;
                else  if(count_p == 1)
                    dialog.windowState = WindowState.Minimize;
                else  if(count_p == 2)
                    dialog.windowState = WindowState.Normal;
                else 
                    dialog.windowState = WindowState.Full;

                count_p = (count_p + 1) % 4;
                writefln("count_p = %d", count_p);
                dialog.show();
                break;

            case Keys.s:
                this.show();
                break;

            case Keys.f:

                break;

            case Keys.ESC:
                dialog.close();
                args.result = IupElementAction.Ignore;
                break;

            case Keys.c:
                args.result = IupElementAction.Close;
                break;

            case Keys.h:
                dialog.hide();
                break;

            case Keys.d:
                //this.destroy();
                this.dispose();
                break;

            default:
                break;
        }
    }
    private int count_4;
    private int count_p;

    private IupDialog createSubDialog(int number, string tip)
    {
        IupDialog dialog = new IupDialog();

        dialog.parent = this;
        dialog.cursor = IupCursors.Cross;
        dialog.tooltip.text  = tip;

        if(number == 1)
        {
            dialog.sizeMode = WindowSizeMode.Full;
            dialog.closing += &dialog_closing2;
        }
        else
        {
            dialog.closing += &dialog_closing;
            if(number != 6)
                dialog.rasterSize = Size(500, 500);
        }

        if(number == 2)
        {
            dialog.title = "dlg2(对话框)";
            dialog.cursor = m_Cursor;
            dialog.ico = m_Ico;

            if(count2 == 0)
            {
                dialog.minSize = Size(300, 300);
                dialog.maxSize = Size(600, 600);
            }
            else if(count2 == 1)
            {
                dialog.font = Font.parse("Times, Italic 14");
                IupTooltip m_tip = dialog.tooltip;
                m_tip.backgroundColor = Color.parse("255 128 128");
                m_tip.foregroundColor = Color.parse("0 92 255");
                version(Windows)
                {
                    m_tip.hasBalloon = true;
                    m_tip.balloonTitle = "Tip Title Test";
                    m_tip.balloonIco = BalloonIco.Warning;
                }
                //tip.delay = 5000;
            }
            else if(count2 == 2)
            {
                dialog.opacity = 128;
                version(Windows)
                {
                    dialog.isTopMost = true;
                    dialog.isToolbox = true; // NOT working in Windows 8
                }
            }

            count2++;
        }
        else if(number == 3)
        {
            dialog.backgroundColor = Color.parse("255 0 255");
            dialog.canResize = false;
            dialog.hasMenuBox = false;
            dialog.hasMaxBox = false;
            dialog.hasMinBox = false;
            dialog.hasBorder = false;
            dialog.rasterSize = Size(500, 500);
        }
        else
        {
            dialog.title = std.format.format("dlg%d", number);

            if(number == 4)
            {
                if(count_4 == 0)
                {
                    dialog.windowState = WindowState.Minimize;
                    dialog.tipText = dialog.tipText ~ "\n.PLACEMENT=MINIMIZED.";
                }
                else if(count_4 == 1)
                {
                    dialog.windowState = WindowState.Maximize;
                    dialog.tipText = dialog.tipText ~ "\n.PLACEMENT=MAXIMIZED.";
                }
                else
                {
                    dialog.windowState = WindowState.Full;
                    dialog.tipText = dialog.tipText ~ "\n.PLACEMENT=FULL.";
                }

                count_4 = (count_4 + 1) % 3; // cicle from 0 to 2
                writefln("count_4 = %d", count_4);

            }
            else if(number == 5)
            {
                dialog.isDialogFrame = true;
                dialog.hasHelpButton = true;
            }
            else if(number == 6)
            {
                dialog.isFullScreen = true;
            }
            else if(number == 7)
            {
                version(Windows)
                {
                    dialog.isCustomFrame = true;
                    dialog.customFrameCaptionLimits = "0:30";

                    IupLabel label = new IupLabel("Label Test");
                    label.canExpand = true;

                    IupBackgroundBox box = new IupBackgroundBox(label);
                    box.backgroundColor = Color.parse("0 255 0");

                    dialog.child = box;
                    dialog.customFramePainted += &dialog_customFramePainted;
                }
            }
        }


        return dialog;
    }
    private int count2 = 0;

    version(Windows)
    {
        private void dialog_customFramePainted(Object sender, CallbackEventArgs args)
        {
            IupDialog dialog = cast(IupDialog)sender;
            writefln("dialog_customFramePainted(%s)", dialog.title);

            RECT rect;
            HPEN oldPen;
            HDC hDC = dialog.hdcWmPaint;
            Size size = dialog.rasterSize;

            SetRect(&rect, 0, 0, size.width, size.height);
            FillRect(hDC, &rect, GetStockObject(BLACK_BRUSH)); //WHITE_BRUSH

            oldPen = SelectObject(hDC, GetStockObject(DC_PEN));
            SetDCPenColor(hDC, RGB(255, 0, 0));

            MoveToEx(hDC, 0, 0, NULL);
            LineTo(hDC, size.width, size.height);
            MoveToEx(hDC, 0, size.height, NULL);
            LineTo(hDC, size.width, 0);

            SelectObject(hDC, oldPen);
        }
    }

    private void dialog_gotFocus(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("GETFOCUS_CB(%s)", element.title);
    }

    private void dialog_lostFocus(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("KILLFOCUS_CB(%s)", element.title);
    }

    private void dialog_helpRequested(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HELP_CB(%s)", element.title);
    }

    private void dialog_mouseEnter(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("ENTERWINDOW_CB(%s)", element.title);
    }

    private void dialog_mouseLeave(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("LEAVEWINDOW_CB(%s)", element.title);
    }

    private void dialog_move(Object sender, CallbackEventArgs e, int x, int y)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("MOVE_CB(%s, %d, %d)", dialog.title, x, y);
        Point!int location = dialog.location;
        writefln("  X,Y=%s,%s", location.x, location.y);
    }

    private void dialog_tipPopup(Object sender, CallbackEventArgs e, int x, int y)
    {
        IupElement element = cast(IupElement)sender;
        writefln("TIPS_CB(%s, %d, %d)", element.title, x, y);
    }

    private void dialog_sizeChanged(Object sender, CallbackEventArgs args, int width, int height)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("RESIZE_CB(%s, width=%d, height=%d) RASTERSIZE=%s CLIENTSIZE=%s", dialog.title, width, height, 
               IupSize.format(dialog.rasterSize), IupSize.format(dialog.clientSize));
    }

    private void dialog_stateChanged(Object sender, CallbackEventArgs args, DialogState state)
    {
        IupDialog dialog = cast(IupDialog)sender;
        writefln("SHOW_CB(%s, %s)", dialog.title, state);
    }

    private void dialog_fileDropped(Object sender, CallbackEventArgs e,
                                       string fileName, int number, int x, int y)
    {
        IupDialog dialog = cast(IupDialog)sender;

        writefln("DROPFILES_CB(%s, %s, %d, %d, %d)", dialog.title, fileName, number, x, y);
    }


    private void startBtn_click(Object sender, CallbackEventArgs e)
    {
    }


    // 11x11 8-bit
    const(ubyte)[] pixmap_x_8 = [
        1,2,3,3,3,3,3,3,3,2,1, 
        2,1,2,3,3,3,3,3,2,1,2, 
        0,2,1,2,3,3,3,2,1,2,0, 
        0,0,2,1,2,3,2,1,2,0,0, 
        0,0,0,2,1,2,1,2,0,0,0, 
        0,0,0,0,2,1,2,0,0,0,0, 
        0,0,0,2,1,2,1,2,0,0,0, 
        0,0,2,1,2,3,2,1,2,0,0, 
        0,2,1,2,3,3,3,2,1,2,0, 
        2,1,2,3,3,3,3,3,2,1,2, 
        1,2,3,3,3,3,3,3,3,2,1
    ];

    // 32x32 8-bit
    const(ubyte)[] pixmap_cursor_8 = [
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,2,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ];

}


public class ProgressDialogTestDialog : IupDialog
{

    private IupButton startBtn;
    private IupProgressDialog dialog;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        startBtn = new IupButton("Start");
        startBtn.click += &startBtn_click;

        IupVbox vbox = new IupVbox(startBtn);
        vbox.alignment = HorizontalAlignment.Center;

        this.child = vbox;
        this.rasterSize = Size(300, 300);
        this.title = "IupProgressDlg Test";
    }

    private void startBtn_click(Object sender, CallbackEventArgs e)
    {
        if(dialog is null)
        {
            dialog = new IupProgressDialog("IupProgressDlg Test");
            //dialog.title = "IupProgressDlg Test";
            dialog.description = "Description first line\nSecond Line";
            dialog.totalCount = 1000;

            dialog.cancel += &dialog_cancel;
            dialog.loaded += &dialog_loaded;
        }
        dialog.count = 0;
        dialog.state = ProgressDialogState.Idle;

        dialog.showDialog(this);
    }

    private void dialog_cancel(Object sender, CallbackEventArgs args)
    {
        DialogResult r = IupMessageBox.show("Warning!", "Interrupt Processing?",
                                            MessageBoxButtons.YesNo);

        if(r == DialogResult.Yes) /* Yes Interrupt */
        {
            //Application.exitLoop();
            dialog.hide();
        }
        else
        {
            //dialog.state = ProgressDialogState.Processing;
            args.result = IupElementAction.Continue;
        }
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        int i, j;
        writefln("Begin");
        for (i = 0; i < dialog.totalCount; i++)
        {
            for (j = 0; j < dialog.totalCount; j++)
            {
                double x = fabs(sin(j * 100.0) + cos(j * 100.0));
                x = sqrt(x * x);
            }

            dialog.increment();
            Application.loopStep();
            writefln("Step(%d)", i);

            if(dialog.state == ProgressDialogState.Aborted)
                break;
        }
        writefln("End");
        Application.exitLoop();
        //args.result = IupElementActionClose;
    }


}