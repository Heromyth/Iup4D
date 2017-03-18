import std.stdio;

import std.algorithm;
//import std.exception;
import std.string;
import std.traits;
import std.conv;
import std.file;
import std.path;

import core.stdc.stdlib; 

import iup;
import cd;

import toolkit.drawing;
import toolkit.event;
import toolkit.input;

version(Windows) { 
    pragma(lib, "iup.lib");

    pragma(lib, "iupimglib.lib"); // required only if function IupImageLibOpen() is called
    pragma(lib, "iupim.lib");
    pragma(lib, "im.lib");

    pragma(lib, "iupgl.lib");
    pragma(lib, "opengl32.lib");

    pragma(lib, "iupcontrols.lib");
    pragma(lib, "iupglcontrols.lib");

    pragma(lib, "iupcd.lib");
    pragma(lib, "cd.lib");
    pragma(lib, "cdgl.lib");
    pragma(lib, "cdpdf.lib"); 
}



/*
 // Hello World example
public class MainForm : IupDialog
{

    this() 
    {
        //this.loaded += &form_Loaded;
        super();
    }

    protected override void initializeComponent()
    {
        this.title = "Hello World 3";
        IupButton button = new IupButton("Ok");
        button.click += &button_click;

        IupButton exitButton = new IupButton("Exit");
        exitButton.click += &exitButton_click;

        IupHbox hbox = new  IupHbox(button, exitButton);
        hbox.margin = Size(10,10);
        hbox.gap = 5;

        IupLabel label = new IupLabel("Hello world from IUP.");
        IupVbox vbox = new IupVbox(label, hbox);
        //vbox.append(button);
        vbox.margin = Size(10,10);
        vbox.gap = 5;


        this.child = vbox;
    }

    private void form_Loaded(Object sender, CallbackEventArgs e)
    {
        MessageBox.show("Notice", "Hello world from IUP.");
    }

    private void button_click(Object sender, CallbackEventArgs e)
    {
        MessageBox.show("Notice", "Hello world from IupButton.");
    }

    private void exitButton_click(Object sender, CallbackEventArgs e)
    {
        Application.exit();
    }
}
*/


class GotoDialog : IupDialog
{
    private IupButton bt_ok;
    private IupButton bt_cancel;
    private IupTextBox textBox;
    private IupLabel label;

    /**
    */
    @property 
	{
        public int lineCount() { return m_lineCount;  }
        public void lineCount(int value) { 
            m_lineCount = value;
            label.title = format("Line Number [1-%d]:", value) ;
        }
        int m_lineCount;


        public int lineNumber() { return m_lineNumber;  }
        protected void lineNumber(int value) { m_lineNumber = value; }
        int m_lineNumber;
	}

    EventHandler!FindNextCallbackEventArgs findNext;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        label = new IupLabel("");
        lineCount = 1;

        textBox = new IupTextBox();
        textBox.mask = NumberMaskStyle.UInt;
        textBox.visibleColumns = 20;

        bt_ok = new IupButton("&OK");
        bt_ok.padding = Size(10,2);
        bt_ok.click += &bt_ok_click;

        bt_cancel = new IupButton("Cancel");
        bt_cancel.padding = Size(10,2);
        bt_cancel.click += &bt_cancel_click;

        IupHbox hbox = new IupHbox(new IupFill(), bt_ok, bt_cancel);
        hbox.sizeNormalization = SizeNormalizationStyle.Horizontal;

        IupVbox vbox = new IupVbox(label,textBox, hbox);
        vbox.alignment = HorizontalAlignment.Left;
        vbox.margin = Size(10,10);
        vbox.gap = 5;

        this.closing += &dialog_closing;

        this.child = vbox;
        this.title = "Go To Line";
        this.isDialogFrame = true;
        this.defaultEnter = bt_ok;
        this.defaultEsc = bt_cancel;
        //resetUserSize();
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        //e.result = IupElementAction.Ignore;
    }

    private void bt_ok_click(Object sender, CallbackEventArgs e)
    {
        string v = textBox.text;

        if(v.empty)
        {
            IupMessageBox.show("Error", "Can't be empty.");
            return;
        }
        
        try
        {
            lineNumber = to!int(v);
        }
        catch(Exception ex)
        {
            IupMessageBox.show("Error", "Invalid input!");
            return;
        }

        if(lineNumber<1 || lineNumber > lineCount)
        {
            IupMessageBox.show("Error", "Invalid line number.");
            return;
        }

        dialogResult = DialogResult.OK;
        e.isHandled = true;
        e.result = IupElementAction.Close;
        //this.close(DialogResult.OK);
    }

    private void bt_cancel_click(Object sender, CallbackEventArgs e)
    {
        dialogResult = DialogResult.Cancel;
        e.result = IupElementAction.Close;
        //this.close(DialogResult.Cancel);
    }

}


class FindDialog : IupDialog
{
    private IupToggleButton tb;
    private IupTextBox textBox;
    private FindNextCallbackEventArgs findNextCallbackEventArgs;
    
    EventHandler!FindNextCallbackEventArgs findNext;
    bool isCaseSensitive;

    this() 
    {
        isCaseSensitive = false;
        super();
    }

    protected override void initializeComponent() 
    {
        IupLabel label = new IupLabel("Find What:");

        textBox = new IupTextBox();
        textBox.visibleColumns = 20;
        //textBox.isExpand = true;


        tb = new IupToggleButton("Case Sensitive");
        tb.checked += &tb_checked;
        tb.isChecked = isCaseSensitive;
        //tb.isThreeState = true;

        IupButton nextButton = new IupButton("Find Next");
        nextButton.padding = Size(10,2);
        nextButton.click += &nextButton_click;

        IupButton closeButton = new IupButton("Close");
        closeButton.padding = Size(10,2);
        closeButton.click += &closeButton_click;

        IupHbox hbox = new IupHbox(new IupFill(), nextButton, closeButton);
        hbox.sizeNormalization = SizeNormalizationStyle.Horizontal;

        IupVbox vbox = new IupVbox(label);
        vbox.append(textBox, tb, hbox);
        vbox.alignment = HorizontalAlignment.Left;
        vbox.margin = Size(10,10);
        vbox.gap = 5;

        this.child = vbox;
        this.title = "Find";
        this.isDialogFrame = true;
        this.defaultEnter = nextButton;
        this.defaultEsc = closeButton;
        resetUserSize();
    }


    private void tb_checked(Object sender, CallbackEventArgs args, ToggleState e)
    {
        IupToggleButton tb = cast(IupToggleButton) sender;
        isCaseSensitive = tb.isChecked;
    }

    private void nextButton_click(Object sender, CallbackEventArgs e)
    {
        if(findNextCallbackEventArgs is null)
            findNextCallbackEventArgs = new FindNextCallbackEventArgs();

        findNextCallbackEventArgs.text = textBox.text;
        if(isCaseSensitive)
            findNextCallbackEventArgs.caseSensitive = std.string.CaseSensitive.yes;
        else
            findNextCallbackEventArgs.caseSensitive = std.string.CaseSensitive.no;

        findNext(this, findNextCallbackEventArgs);
    }

    private void closeButton_click(Object sender, CallbackEventArgs e)
    {
        this.hide();
        //this.close();
    }

}


public class FindNextCallbackEventArgs : CallbackEventArgs
{
    std.string.CaseSensitive  caseSensitive;
    string text;
}


public class MainForm : IupDialog
{
    private IupTextBox multitext;
    private IupMenu recent_menu;
    private IupMenuItem item_save ;
    private IupMenuItem item_revert;
    private IupMenuItem item_copy;
    private IupMenuItem item_cut;
    private IupMenuItem item_paste;
    private IupMenuItem item_delete;
    private IupMenuItem item_select_all;
    private IupMenuItem item_goto;
    private IupConfig config;
    private IupControl toolbar;
    private IupLabel statusbar;

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
        config.useAppDirectory(Application.basePath, "simple_notepad");
        //config.useCustomDirection("z:\\abc.ini");

        config.load();

        this.title = "Simple Notepad";
        //this.size = Size(200, 100);
        this.sizeMode = WindowSizeMode.Half;

        // menu
        this.menu = createMenus();

        // toolbar
        toolbar =  createToolbar();

        // TextBox
        multitext = new IupTextBox();
        multitext.multiline = true;
        multitext.expandOrientation = ExpandOrientation.Both;
        multitext.fileDropped += &multitext_fileDropped;
        multitext.caretMove += &multitext_caretMove;
        multitext.textChanged += &multitext_textChanged;

        // statusbar
        statusbar = new IupLabel("Lin 1, Col 1");
        statusbar.name = "STATUSBAR";
        statusbar.padding = Size(10,5);
        statusbar.expandOrientation = ExpandOrientation.Horizontal;

        IupVbox vbox = new IupVbox(toolbar, multitext, statusbar);
        this.child = vbox;


        this.keyPress += &dialog_keyPress;
        this.stateChanged += &dialog_stateChanged;
        this.closing += &dialog_closing;
        this.fileDropped += &dialog_fileDropped;

        new_file();
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        performExit();
        //e.result = IupElementAction.Ignore;
    }

    private void dialog_stateChanged(Object sender, CallbackEventArgs args, DialogState state)
    {
        statusbar.title  = format("Dialog State: %s", state);
        if(state == DialogState.Show)
        {
            // loaded;
        }
    }

    private void dialog_keyPress(Object sender, CallbackEventArgs args, int key)
    {
        //statusbar.title  = format("press key: %d", key);

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
        else if(key == Keys.combinateCtrl(Keys.F))
        {
            findMenuItem_click(this, null);
        }
        else if(key == Keys.combinateCtrl(Keys.G))
        {
            item_goto_click(this, null);
        }

    }

    private IupHbox createToolbar()
    {

        IupButton newBtn = new IupButton();
        newBtn.image = IupImages.FileNew;
        newBtn.isFlat = true;
        newBtn.canFocus = false;
        newBtn.tipText  = "New (Ctrl+N)";
        newBtn.click += &item_new_click;

        IupButton openBtn = new IupButton();
        openBtn.image  = IupImages.FileOpen;
        openBtn.isFlat = true;
        openBtn.canFocus = false;
        newBtn.tipText  = "Open (Ctrl+O)";
        openBtn.click += &openMenuItem_click;

        IupButton saveBtn = new IupButton();
        saveBtn.image  = IupImages.FileSave;
        saveBtn.isFlat = true;
        saveBtn.canFocus = false;
        saveBtn.click += &saveasMenuItem_click;

        IupButton findBtn = new IupButton();
        findBtn.image  = IupImages.EditFind;
        findBtn.isFlat = true;
        findBtn.canFocus = false;
        findBtn.click +=  &findMenuItem_click;

        IupSeparator separatorLabel = new IupSeparator();
        separatorLabel.orientation = Orientation.Vertical;

        IupHbox box = new IupHbox(newBtn, openBtn, saveBtn, separatorLabel, findBtn);
        //box.alignment = HorizontalAlignment.Left.

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


        IupMenuSeparator separator = new IupMenuSeparator();
        
        recent_menu = new IupMenu();
        IupSubmenu recentSub_menu = new IupSubmenu("Recent &Files", recent_menu);

        IupMenuItem item_exit =  new IupMenuItem("E&xit");
		item_exit.click += &exitMenuItem_click;

        IupMenu file_menu = new IupMenu( item_new, item_open, item_save, item_saveas, item_revert,
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

        IupMenuSeparator editSeparator3 = new IupMenuSeparator();

		IupMenuItem item_find =  new IupMenuItem("&Find...\tCtrl+F");
        item_find.click +=  &findMenuItem_click;

		item_goto =  new IupMenuItem("&Go To...\tCtrl+G");
        item_goto.click +=  &item_goto_click;

		IupMenu edit_menu = new IupMenu(  item_undo,item_redo,
                                          editSeparator1,
                                          item_cut,  item_copy,  item_paste, item_delete,
                                        editSeparator2,
                                          item_select_all,
                                          editSeparator3,
                                          item_find, item_goto
                                        );
        edit_menu.opened += &edit_menu_opened;
        edit_menu.closed += &edit_menu_closed;

        IupSubmenu editSub_menu = new IupSubmenu("&Edit", edit_menu);

        // format
		IupMenuItem item_font =  new IupMenuItem("Font...");
        item_font.click += &fontMenuItem_click;

		IupMenu format_menu = new IupMenu( item_font);

        IupSubmenu formatSub_menu = new IupSubmenu("Fo&rmat", format_menu);

        // View
		IupMenuItem item_toolbar =  new IupMenuItem("&Toobar");
        item_toolbar.click += &item_toolbar_click;
        item_toolbar.checked = true;

		IupMenuItem item_statusbar =  new IupMenuItem("&Statusbar");
        item_statusbar.click += &item_statusbar_click;
        item_statusbar.checked = true;

		IupMenu view_menu = new IupMenu(item_toolbar, item_statusbar);
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
                        formatSub_menu, 
                        viewSub_menu,
                        helpSub_menu);


        config.initRecentMenu(recent_menu, &openFile, 10);

        return mainMenu;
    }


    private void item_new_click(Object sender, CallbackEventArgs e)
    {
        if(saveCheck())
            new_file();
    }

    private void new_file()
    {
        this.title = "Untitled - Simple Notepad";
        this.isTextChanged = false;
        multitext.text = "";
        fileName = "";
    }


    void openFile(string fileName)
    {
        if(!saveCheck())
            return;

        config.updateMenuRecent(fileName);
        this.fileName = fileName;
        this.title = stripExtension(baseName(fileName)) ~ " - Simple Notepad";

        if(exists(fileName))
            multitext.text = cast(string)readFile(fileName);
        else
            multitext.text = "";
    }
    private string fileName;

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
        if(!saveCheck())
            return;

        IupFileDialog dialog = new IupFileDialog();

        dialog.parent = this;

        dialog.dialogType = FileDialogType.Open;
        dialog.extFilter = "Text Files|*.txt|All Files|*.*|";
        if(dialog.showDialog() == DialogResult.OK)
        {
            openFile(dialog.fileName);
            //multitext.text = cast(string)readFile(fileName);
        }

        dialog.close();
        //delete dialog;
    }

    private bool saveCheck()
    {
        if(isTextChanged)
        {
            DialogResult r = IupMessageBox.show("Warning", "File not saved! Save it now?", 
                                             MessageBoxButtons.YesNoCancel);
            if(r == DialogResult.Yes)
            {
                string text = multitext.text;
                writeFile(fileName, text);
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
            string text = multitext.text;
            writeFile(fileName, text);
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

            int size = multitext.textLength;
            string text = multitext.text;
            writeFile(fileName, text);

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

    private void edit_menu_opened(Object sender, CallbackEventArgs e)
    {
        statusbar.title  = "edit_menu_opened";

        item_paste.enabled = IupClipboard.isTextAvailable;

        string selectedText = multitext.selectedText;
        if(selectedText.length == 0)
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
        statusbar.title  = "edit_menu_closed";
    }

    private void item_cut_click(Object sender, CallbackEventArgs e)
    {
        string selectedText = multitext.selectedText;
        IupClipboard.text = selectedText;
        multitext.selectedText = "";
    }

    private void item_copy_click(Object sender, CallbackEventArgs e)
    {
        string selectedText = multitext.selectedText;
        IupClipboard.text = selectedText;
    }

    private void item_paste_click(Object sender, CallbackEventArgs e)
    {
        string text = IupClipboard.text;
        multitext.insert(text);
    }

    private void item_delete_click(Object sender, CallbackEventArgs e)
    {
        multitext.selectedText = "";
    }

    private void item_select_all_click(Object sender, CallbackEventArgs e)
    {
        multitext.selectAll();
    }

    private void fontMenuItem_click(Object sender, CallbackEventArgs e)
    {
        IupFontDialog dialog = new IupFontDialog("IupFontDlg Test");

        //dialog.font = "Times New Roman, Bold 20";
        dialog.font = multitext.font;

        if(dialog.showDialog() == DialogResult.OK)
        {
            multitext.font = dialog.selectedFont;

            config.setVariable(ThisFormName, "Font", font.toString());
        }

        dialog.dispose();
    }


    private void findMenuItem_click(Object sender, CallbackEventArgs e)
    {
        if(dialog is null)
        {
            dialog = new FindDialog();
            dialog.parent = this;
            dialog.findNext += &dialog_findNext;
        }
        dialog.show();

        //tb.isChecked = !tb.isChecked;
    }
    private FindDialog dialog;

    private void dialog_findNext(Object sender, FindNextCallbackEventArgs e)
    {
        string text = multitext.text;

        // TODO: support UTF-8
        // position in byte
        int pos = indexOf(text, e.text, find_pos, e.caseSensitive);
        if(pos == -1)
        {
            IupMessageBox.show("Warning", "Text not found.");
            find_pos = 0;
        }
        else
        {
            // TODO: 算上BOM占用字节数
            int searchTextLength = e.text.length;
            find_pos = pos + searchTextLength;  // position in character

            multitext.focus();
            multitext.select(pos, searchTextLength);

            int row, col;
            multitext.convertPosToLinCol(pos, row, col);
            pos = multitext.convertLinColToPos(row, 0);  /* position at col=0, just scroll lines */
            multitext.scrollTo(pos);
        }

    }
    private int find_pos = 0;


    private void item_goto_click(Object sender, CallbackEventArgs e)
    {
        GotoDialog dialog = new GotoDialog();
        dialog.lineCount = multitext.lineCount;

        DialogResult r = dialog.showDialog();
        if(r == DialogResult.OK)
        {
            int lineNumber = dialog.lineNumber;
            int pos = multitext.convertLinColToPos(lineNumber, 0);
            multitext.caretIndex = pos;
            multitext.scrollTo(pos);
        }

        dialog.dispose();
    }
    
    
    private void multitext_caretMove(Object sender, 
                                                CallbackEventArgs args, int row, int col, int pos)
    {
        statusbar.title  = format("row %d, col %d", row, col);
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
        //statusbar.title  = format("fileName:%s, Number=%d, x=%d, y=%d", fileName, number, x, y);

        //if(number < 2)
        //    e.result = IupElementAction.Ignore;
    }

    private void dialog_fileDropped(Object sender, CallbackEventArgs e,
                                       string fileName, int number, int x, int y)
    {
        if(number == 0)
           openFile(fileName);
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
            e.result = IupElementAction.Close;
        }
        else
            e.result = IupElementAction.Ignore;
    }

    private void performExit()
    {
        string s = config.fileName;
        config.onDialogClosed(this, ThisFormName);
        config.save();
        s = config.fileName;
    }
}



int main(string[] args)
{
	Application.open();
    Application.useImageLib();
    Application.useIupControls();
    Application.useOpenGL();

    MainForm mainForm = new MainForm();
    Application.run(mainForm);

	return EXIT_SUCCESS;
}


/*
// test01

MessageBox.show("Hello World 1", "Hello world from IUP.\n\n来自IUP的问候。");
//Application.mainLoop();
Application.close();
*/

/*

IupLabel label = new IupLabel("Hello world from IUP.");
IupVbox vbox = new IupVbox(label);
IupDialog dialog = new IupDialog(vbox);
dialog.title = "Hello World 2-中文";
dialog.horizontalPostion = ScreenPostionH.Left;

*/