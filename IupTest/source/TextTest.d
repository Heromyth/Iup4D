module TextTest;

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


public class TextTestDialog : IupDialog
{
    private IupButton startBtn;
    private IupMultiLine multitext;
    private IupTextBox textBox;
    private IupCheckBox opt;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        textBox = new IupTextBox();
        textBox.expandOrientation = ExpandOrientation.Horizontal;
        textBox.watermark = "Enter Attribute Value Here";
        textBox.text = "Single Line Text";
        textBox.name = "text";
        textBox.tipText = "Attribute Value";
        //textBox.isFormatting = true;

        opt = new IupCheckBox("Set/Get");
        opt.isChecked = true;

        multitext = new IupMultiLine();
        multitext.name = "multitext";
        //multitext.canWordWrap = true;
        //multitext.canAutoHide = true;
        multitext.canExpand = true;
        //multitext.hasBorder = true;
        //multitext.background = Color.parse("255 0 128");
        //multitext.foreground = Color.parse("0 128 192");
        //multitext.padding = Size(15, 15);
        multitext.text = "First Line\nSecond Line Big Big Big\nThird Line\nmore\nmore\n(多行文本)";
        multitext.tipText = "First Line\nSecond Line\nThird Line";

        //multitext.font = "Helvetica, 14";
        //multitext.mask = NumberMaskStyle.Float;
        //multitext.filterStyle = TextFilterStyle.Uppercase;
        //multitext.textAlignment = HorizontalAlignment.Center;
        //multitext.canFocus = false;
        //multitext.scrollBars.visibility = ScrollBarsVisibility.None;
        //multitext.canHideSelection = false;
        multitext.size = Size(80, 40);

        if(true) /* just to make easier to comment this section */
        {
            /* formatting before Map */
            multitext.isFormatting = true;
            IupExternalElement formattag = new IupExternalElement();

            formattag.setAttribute("ALIGNMENT", "CENTER");
            formattag.setAttribute("SPACEAFTER", "10");
            formattag.setAttribute("FONTSIZE", "24");
            formattag.setAttribute("SELECTION", "3,1:3,50");
            multitext.addFormatStyle(formattag);

            formattag = new IupExternalElement();

            formattag.setAttribute("BGCOLOR", "255 128 64");
            formattag.setAttribute("UNDERLINE", "SINGLE");
            formattag.setAttribute("WEIGHT", "BOLD");
            formattag.setAttribute("SELECTION", "3,7:3,11");
            multitext.addFormatStyle(formattag);

        }

        /* Registers callbacks */
        multitext.caretMove += &multitext_caretMove;
        multitext.fileDropped += &multitext_fileDropped;
        multitext.gotFocus += &multitext_gotFocus;
        multitext.helpRequested += &multitext_helpRequested;
        multitext.keyPress += &multitext_keyPress;
        multitext.lostFocus += &multitext_lostFocus;
        multitext.mouseEnter += &multitext_mouseEnter;
        multitext.mouseLeave += &multitext_mouseLeave;
        multitext.mouseClick += &multitext_mouseClick;
        multitext.mouseMove += &multitext_mouseMove;
        multitext.textChanging += &multitext_textChanging;
        multitext.textChanged += &multitext_textChanged;


        /* Creates buttons */
        IupButton btn_append = new IupButton ("&APPEND");
        btn_append.tipText = "First Line\nSecond Line\nThird Line";
        btn_append.click += &btn_append_click;

        IupButton btn_insert = new IupButton ("INSERT");
        btn_insert.click += &btn_insert_click;

        IupButton btn_caret = new IupButton ("CARET");
        btn_caret.click += &btn_caret_click;

        IupButton btn_readonly = new IupButton ("READONLY");
        btn_readonly.click += &btn_readonly_click;

        IupButton btn_count = new IupButton ("Count");
        btn_count.click += &btn_count_click;

        IupButton btn_selection = new IupButton ("Selection");
        btn_selection.click += &btn_selection_click;

        IupButton btn_selectedtext = new IupButton ("SELECTEDTEXT");
        btn_selectedtext.click += &btn_selectedtext_click;

        IupButton btn_nc = new IupButton ("NC");
        btn_nc.click += &btn_nc_click;

        IupButton btn_value = new IupButton ("VALUE");
        btn_value.click += &btn_value_click;

        IupButton btn_tabsize = new IupButton ("TABSIZE");
        btn_tabsize.click += &btn_tabsize_click;

        IupButton btn_key = new IupButton ("KEY");
        btn_key.click += &btn_key_click;

        IupButton btn_def_enter = new IupButton ("Default Enter");
        btn_def_enter.click += &btn_def_enter_click;

        IupButton btn_def_esc = new IupButton ("Default Esc");
        btn_def_esc.click += &btn_def_esc_click;

        IupButton btn_active = new IupButton("ACTIVE");
        btn_active.click += &btn_active_click;

        IupButton btn_remformat = new IupButton("REMOVEFORMATTING");
        btn_remformat.click += &btn_remformat_click;

        IupButton btn_overwrite = new IupButton("OVERWRITE");
        btn_overwrite.click += &btn_overwrite_click;


        IupLabel lbl = new IupLabel("&Multiline:");
        lbl.padding = Size(2, 2);

        IupGroupBox groupBox = new IupGroupBox("Clipboard");

        IupButton btn_clip_copy = new IupButton ("Copy");
        btn_clip_copy.click += &btn_clip_copy_click;

        IupButton btn_clip_paste = new IupButton ("Paste");
        btn_clip_paste.click += &btn_clip_paste_click;

        IupButton btn_clip_cut = new IupButton ("Cut");
        btn_clip_cut.click += &btn_clip_cut_click;

        IupButton btn_clip_del = new IupButton ("Delete");
        btn_clip_del.click += &btn_clip_del_click;
        groupBox.child =  new IupHbox (btn_clip_copy, btn_clip_paste, btn_clip_cut, btn_clip_del);


        IupVbox vbox = new IupVbox(lbl,
                                   multitext, 
                                   new IupHbox (textBox, opt),
                                   new IupHbox (btn_append, btn_insert, btn_caret, btn_readonly, btn_count, btn_selection),
                                   groupBox,
                                   new IupHbox (btn_selectedtext, btn_nc, btn_value, btn_tabsize), 
                                   new IupHbox (btn_def_enter, btn_def_esc, btn_active, btn_remformat, btn_overwrite));

        this.child = vbox;
        this.gap = 10;
        this.margin = Size(10, 10);
        this.title = "IupText Test";
        this.defaultEnter = btn_def_enter;
        this.defaultEsc = btn_def_esc;
        this.canShrink = true;
        this.startFocus = multitext;
        this.loaded += &dialog_loaded;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        /* formatting after Map */
        IupExternalElement formattag = new IupExternalElement();

        formattag.setAttribute("ITALIC", "YES");
        formattag.setAttribute("STRIKEOUT", "YES");
        formattag.setAttribute("SELECTION", "2,1:2,12");
        multitext.addFormatStyle(formattag);

        if (true)
        {
            int start = multitext.textLength;
            multitext.append("Append Test");

            formattag = new IupExternalElement();
            formattag.setAttribute("FGCOLOR", "0 128 64");
            formattag.setAttribute(IupTextBoxBase.IupAttributes.SelectionPos, //  "SELECTIONPOS"
                                   std.format.format("%d:%d", start+1, multitext.textLength));
            multitext.addFormatStyle(formattag);
        }
    }

    private void btn_append_click(Object sender, CallbackEventArgs e)
    {
        multitext.append(textBox.text);
    }

    private void btn_insert_click(Object sender, CallbackEventArgs e)
    {
        multitext.insert(textBox.text);
    }

    private void btn_caret_click(Object sender, CallbackEventArgs e)
    {
        if(opt.isChecked)
        {
            multitext.caretLocation = textBox.text;
        }
        else
        {
            string pos = multitext.caretLocation;
            textBox.text = pos;
        }
    }

    private void btn_readonly_click(Object sender, CallbackEventArgs e)
    {
        multitext.isReadOnly = !multitext.isReadOnly;
        textBox.text = to!string(multitext.isReadOnly);
    }

    private void btn_count_click(Object sender, CallbackEventArgs e)
    {
        textBox.text = to!string(multitext.textLength);
    }


    private void btn_selection_click(Object sender, CallbackEventArgs e)
    {
        if(opt.isChecked)
        {
            multitext.selectionPos = textBox.text;
        }
        else
        {
            string pos = multitext.selectionPos;
            textBox.text = pos;
        }
    }


    private void btn_selectedtext_click(Object sender, CallbackEventArgs e)
    {
        if(opt.isChecked)
        {
            multitext.selectedText = textBox.text;
        }
        else
        {
            textBox.text = multitext.selectedText;
        }

    }


    private void btn_nc_click(Object sender, CallbackEventArgs e)
    {
        if(opt.isChecked)
        {
            textBox.text = to!string(multitext.maxLength);
        }
        else
        {

            int length = 0;
            try
            {
                length = to!int(textBox.text);
            }
            catch(Exception ex)
            {
                writefln("bad number format: %s", ex.msg);
            }

            multitext.maxLength = length;
        }

    }


    private void btn_value_click(Object sender, CallbackEventArgs e)
    {
        if(opt.isChecked)
        {
            multitext.text = textBox.text;
        }
        else
        {
            textBox.text = multitext.text;
        }
    }


    private void btn_tabsize_click(Object sender, CallbackEventArgs e)
    {
        if(opt.isChecked)
        {
            textBox.text = to!string(multitext.tabSize);
        }
        else
        {

            int length = 0;
            try
            {
                length = to!int(textBox.text);
            }
            catch(Exception ex)
            {
                writefln("bad number format: %s", ex.msg);
            }

            multitext.tabSize = length;
        }
    }


    private void btn_clip_copy_click(Object sender, CallbackEventArgs e)
    {
        multitext.copy();
    }

    private void btn_clip_paste_click(Object sender, CallbackEventArgs e)
    {
        multitext.paste();
    }

    private void btn_clip_cut_click(Object sender, CallbackEventArgs e)
    {
        multitext.cut();
    }

    private void btn_clip_del_click(Object sender, CallbackEventArgs e)
    {
        multitext.del();
    }


    private void btn_key_click(Object sender, CallbackEventArgs e)
    {

    }


    private void btn_def_enter_click(Object sender, CallbackEventArgs e)
    {
        writefln("DEFAULTENTER");
    }

    private void btn_def_esc_click(Object sender, CallbackEventArgs e)
    {
        writefln("DEFAULTESC");
    }

    private void btn_active_click(Object sender, CallbackEventArgs e)
    {
        multitext.enabled = !multitext.enabled;
        textBox.text = to!string(multitext.enabled);
    }

    private void btn_remformat_click(Object sender, CallbackEventArgs e)
    {

    }

    private void btn_overwrite_click(Object sender, CallbackEventArgs e)
    {
        multitext.isOverwrite = !multitext.isOverwrite;
        textBox.text = to!string(multitext.isOverwrite);
    }

    private void multitext_textChanging(Object sender, CallbackEventArgs e, int key, string text)
    { 
        if(isPrintable(key))
        {
            writefln("ACTION(%d = %s \'%c\', %s)", key,  Keys.toName(key), cast(char)key, text);
        }
        else
        {
            writefln("ACTION(%d = %s, %s)", key,  Keys.toName(key), cast(char)key, text);
        }
    }

    private void multitext_textChanged(Object sender, CallbackEventArgs e)
    {
        writefln("VALUECHANGED_CB()=%s", multitext.text);
    }


    private void multitext_fileDropped(Object sender, CallbackEventArgs e,
                                       string fileName, int number, int x, int y)
    {
        writefln("DROPFILES_CB(%s, Number=%d, x=%d, y=%d", fileName, number, x, y);
    }


    private void multitext_helpRequested(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HELP_CB(%s)", element.title);
    }

    private void multitext_gotFocus(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("GETFOCUS_CB(%s)", element.title);
    }

    private void multitext_lostFocus(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("KILLFOCUS_CB(%s)", element.title);
    }

    private void multitext_mouseEnter(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("ENTERWINDOW_CB(%s)", element.title);
    }

    private void multitext_mouseLeave(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("LEAVEWINDOW_CB(%s)", element.title);
    }

    private void multitext_mouseClick(Object sender, CallbackEventArgs args, 
                                   MouseButtons button, MouseState mouseState, 
                                   int x, int y, string status)
    {
        IupMultiLine multitext = cast(IupMultiLine)sender;

        int lin, col, pos;
        writefln("BUTTON_CB(but=%s (%s), x=%d, y=%d [%s])", button, mouseState, x, y, status);

        pos = multitext.convertToPos(x, y);
        multitext.convertPosToLinCol(pos, lin, col);
        writefln("         (lin=%d, col=%d, pos=%d)", lin, col, pos);
    }

    private void multitext_mouseMove(Object sender, CallbackEventArgs args, int x, int y, string status)
    {
        writefln("MOTION_CB(x=%d, y=%d [%s])",x, y, status);

        int lin, col, pos;
        pos = multitext.convertToPos(x, y);
        multitext.convertPosToLinCol(pos, lin, col);
        writefln("         (lin=%d, col=%d, pos=%d)", lin, col, pos);
    }

    private void multitext_keyPress(Object sender, CallbackEventArgs args, int key)
    {
        if(isPrintable(key))
        {
            writefln("ACTION(%d = %s \'%c\')", key,  Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("ACTION(%d = %s)", key,  Keys.toName(key), cast(char)key);
        }
        //
        //writefln("  MODKEYSTATE(%s)", Keys.getModifierKeyState()); 
        //
        //writefln("  isShiftXkey(%s)", Keys.isShiftXkey(key));
        //writefln("  isCtrlXkey(%s)", Keys.isCtrlXkey(key));
        //writefln("  isAltXkey(%s)", Keys.isAltXkey(key));
    }

    private void multitext_caretMove(Object sender, 
                                     CallbackEventArgs args, int row, int col, int pos)
    {
        IupMultiLine multitext = cast(IupMultiLine)sender;
        
        writefln("CARET_CB(%d, %d - %d)", row, col, pos);
        writefln("  CARET(%s - %s)\n", multitext.caretLocation, multitext.caretIndex);
    }
}
