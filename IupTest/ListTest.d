module ListTest;


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


public class ListTestDialog : IupDialog
{
    private IupButton startBtn;
    private IupListControl listControl;
    private IupLabel label;
    private IupTextBox textBox;

    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {
        string[] list1Items = ["US$ 1000", "US$ 2000", "US$ 300.000.000", "US$ 4000"];
        IupComboBox list1 = new IupComboBox(list1Items);
        list1.name = "list1";
        list1.text = "Edit Here";
        list1.tipText = "Edit+Drop";
        //list1.canDropExpand = true;
        //list1.isReadOnly = true;
        //list1.padding = Size(10, 10);
        setComboBox(list1);
        
        //
        list1Items = ["Banana", "Apple", "Orange", "Strawberry", "Grape"];
        IupComboBox list2 = new IupComboBox(list1Items);
        list2.name = "list2";
        list2.tipText = "Drop";
        list2.dropDownStyle = ComboBoxStyle.DropDownList;
        setComboBox(list2);


        //
        list1Items = ["Char A", "Char A", "Char CCCCC", 
        "Char D", "Char E", "Char F"];

        IupComboBox list3 = new IupComboBox(list1Items);
        list3.name = "list3";
        list3.text = "Edit Here";
        list3.tipText = "Edit+List";
        list3.dropDownStyle = ComboBoxStyle.Simple;
        //list3.spacing = 10;
        setComboBox(list3);

        //
        list1Items = ["Number 3", "Number 4", "Number 2", "Number 1", "Number 6", 
        "Number 5", "Number 7"];
        IupListBox list4 = new IupListBox(list1Items);
        list4.name = "list4";
        list4.text = "+--++--";
        list4.tipText = "List";
        list4.isMultiSelectable = true;
        list4.multiSelected += &list4_multiSelected;
        setComboBox(list4);

        writefln("COUNT(list1)=%s", list1.items.count);
        writefln("COUNT(list2)=%s", list2.items.count);
        writefln("COUNT(list3)=%s", list3.items.count);
        writefln("COUNT(list4)=%s", list4.items.count);

        IupGroupBox groupBox1 = new IupGroupBox(new IupVbox(list1));
        groupBox1.title = "EDITBOX+DROPDOWN";


        IupGroupBox groupBox2 = new IupGroupBox(new IupVbox(list2));
        groupBox2.title = "DROPDOWN";

        IupGroupBox groupBox3 = new IupGroupBox(new IupVbox(list3));
        groupBox3.title = "EDITBOX";

        IupGroupBox groupBox4 = new IupGroupBox(new IupVbox(list4));
        groupBox4.title = "MULTIPLE";

        IupButton btok = new IupButton("Default Enter");
        btok.click += &btok_click;

        IupButton btcancel = new IupButton ("Default Esc");
        btcancel.click += &btcancel_click;


        IupHbox listsHbox = new IupHbox(new IupVbox(groupBox1, groupBox2),
                                        groupBox3, groupBox4,
                                        new IupVbox(btok, btcancel)
                                        );
        listsHbox.margin = Size(10, 10);
        listsHbox.gap = 10;


        //
        textBox = new IupTextBox();
        textBox.expandOrientation = ExpandOrientation.Horizontal;
        textBox.name = "text";

        IupButton getValueBtn = new IupButton("Get(VALUE)");
        getValueBtn.click += &getValueBtn_click;

        IupButton setValueBtn = new IupButton("Set(VALUE)");
        setValueBtn.click += &setValueBtn_click;

        IupButton getCountBtn = new IupButton("Get(COUNT)");
        getCountBtn.click += &getCountBtn_click;

        IupHbox buttonHbox1 = new IupHbox(getValueBtn, setValueBtn, getCountBtn);
        buttonHbox1.margin = Size(5, 5);
        buttonHbox1.gap = 5;

        //
        IupButton index3Btn = new IupButton("3");
        index3Btn.click += &index3Btn_click;

        IupButton insertItem3Btn = new IupButton("INSERTITEM3");
        insertItem3Btn.click += &insertItem3Btn_click;

        IupButton appendItemBtn = new IupButton("APPENDITEM");
        appendItemBtn.click += &appendItemBtn_click;

        IupButton removeItemBtn = new IupButton("REMOVEITEM");
        removeItemBtn.click += &removeItemBtn_click;

        IupButton showDropDownBtn = new IupButton("SHOWDROPDOWN");
        showDropDownBtn.click += &showDropDownBtn_click;

        IupButton topItemBtn = new IupButton("TOPITEM");
        topItemBtn.click += &topItemBtn_click;

        IupHbox buttonHbox2 = new IupHbox(index3Btn, insertItem3Btn, appendItemBtn, 
                                         removeItemBtn, showDropDownBtn, topItemBtn);
        buttonHbox2.margin = Size(5, 5);
        buttonHbox2.gap = 5;

        //
        IupButton appendBtn = new IupButton("APPEND");
        appendBtn.click += &appendBtn_click;

        IupButton getCaretBtn = new IupButton("Get(CARET)");
        getCaretBtn.click += &getCaretBtn_click;

        IupButton setReadonlyBtn = new IupButton("Set(READONLY)");
        setReadonlyBtn.click += &setReadonlyBtn_click;

        IupButton getSelectedTextBtn = new IupButton("Get(SELECTEDTEXT)");
        getSelectedTextBtn.click += &getSelectedTextBtn_click;

        IupButton getSelectionBtn = new IupButton("Get(SELECTION)");
        getSelectionBtn.click += &getSelectionBtn_click;

        IupHbox buttonHbox3 = new IupHbox(appendBtn, getCaretBtn, setReadonlyBtn); 
        // , getSelectedTextBtn, getSelectionBtn
        buttonHbox3.margin = Size(5, 5);
        buttonHbox3.gap = 5;

        //
        IupHbox hbox2 = new IupHbox(new IupLabel("Attrib. Value:  "), textBox);
        label = new IupLabel();
        label.expandOrientation = ExpandOrientation.Horizontal;

        IupHbox hbox3 = new IupHbox(new IupLabel("Current List:  "), label);

        //
        IupVbox box = new IupVbox(listsHbox, hbox2, buttonHbox1, buttonHbox2, buttonHbox3, hbox3);

        //startBtn = new IupButton("Start timer");
        //startBtn.click += &startBtn_click;


        this.child = box;
        //this.gap = 10;
        this.title = "IupList Test";
        this.defaultEnter = btok;
        this.defaultEsc = btcancel;
    }


    private void setComboBox(IupListControl listControl)
    {
        if(typeid(listControl) == typeid(IupComboBox))
        {
            IupComboBox groupBox = cast(IupComboBox)listControl;
            groupBox.dropDown += &groupBox_dropDown;
            groupBox.textChanging += &groupBox_textChanging;
            groupBox.caretMove += &groupBox_caretMove;
        }

        listControl.selectedItemChanged += &listControl_selectedItemChanged;
        listControl.selectedValueChanged += &listControl_selectedValueChanged;
        listControl.gotFocus += &listControl_gotFocus;
        //listControl.lostFocus += &listControl_lostFocus;
        //listControl.keyPress += &listControl_keyPress;
        //listControl.mouseEnter += &listControl_mouseEnter;
        //listControl.mouseLeave += &listControl_mouseLeave;
        listControl.helpRequested += &listControl_helpRequested;
        listControl.doubleClick += &listControl_doubleClick;
        //listControl.mouseClick += &listControl_mouseClick;
        //listControl.mouseMove += &listControl_mouseMove;

        //listControl.scrollBars.visibility = ScrollBarsVisibility.None;
        //listControl.autoHideScrollbar = false;

        listControl.visibleItems = 20;
        //listControl.visibleColumns = 7;
        listControl.visibleLines = 4;
    }

    private void list4_multiSelected(Object sender, CallbackEventArgs e, string s)
    {
        writefln("MULTISELECT_CB(%s)", s);
    }

    private void groupBox_dropDown(Object sender, CallbackEventArgs e, bool isShown)
    {
        IupElement element = cast(IupElement)sender;
        writefln("DROPDOWN_CB[%s] = %s", element.name, isShown);
    }

    private void groupBox_textChanging(Object sender, CallbackEventArgs e, int code, string newValue)
    {
        writefln("EDIT_CB(%d - %s)", code, newValue);
    }

    private void groupBox_caretMove(Object sender, CallbackEventArgs e, 
                                    int lin, int col, int pos)
    {
        writefln("CARET_CB(lin=%d, col=%d, pos=%d)", lin, col, pos);
    }

    private void listControl_selectedItemChanged(Object sender, CallbackEventArgs e, 
                                          int index, string text, bool isSelected)
    {
        IupElement element = cast(IupElement)sender;
        writefln("ACTION[%s]: index=%d, text=%s, isSelected=%s", element.name, index, text, isSelected);
    }

    private void listControl_selectedValueChanged(Object sender, CallbackEventArgs e)
    {
        IupListControl control = cast(IupListControl)sender;
        writefln("VALUECHANGED_CB[%s] = %s", control.name, control.text);
    }

    private void listControl_keyPress(Object sender, CallbackEventArgs e, int key)
    {
        IupElement element = cast(IupElement)sender;

        if(isPrintable(key))
        {
            writefln("keyPress(%s, %d = %s \'%c\')", element.name, key,  Keys.toName(key), cast(char)key);
        }
        else
        {
            writefln("keyPress(%s, %d = %s)", element.name, key, Keys.toName(key));
        }

        //writefln("ModifierKeyState(%s)", Keys.getModifierKeyState()); 
    }


    private void listControl_lostFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("lostFocus(%s)", element.name); 
    }

    private void listControl_gotFocus(Object sender, CallbackEventArgs e)
    {
        listControl = cast(IupListControl)sender;
        //IupElement element = cast(IupElement)sender;
        writefln("gotFocus(%s)", listControl.name); 
        label.title = listControl.name;
    }


    private void listControl_mouseEnter(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MouseEnter(%s)", element.name); 
    }

    private void listControl_mouseLeave(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("MouseLeave(%s)", element.name); 
    }

    private void listControl_helpRequested(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HelpRequested(%s)", element.name); 
    }

    private void listControl_doubleClick(Object sender, CallbackEventArgs e, int index, string text)
    {
        writefln("DBLCLICK_CB(%d - %s)", index, text);
    }

    private void listControl_mouseClick(Object sender, CallbackEventArgs args, 
                                      MouseButtons button, MouseState mouseState, 
                                      int x, int y, string status)
    {
        IupListControl listControl = cast(IupListControl)sender;

        int lin, col, pos;
        pos = listControl.convertToPos(x, y);
        writefln("BUTTON_CB(but=%s (%s), x=%d, y=%d [%s]) - [pos=%d]", 
                 button, mouseState, x, y, status, pos);

        //listControl.convertPosToLinCol(pos, lin, col);
        //writefln("         (lin=%d, col=%d, pos=%d)", lin, col, pos);
    }

    private void listControl_mouseMove(Object sender, CallbackEventArgs args, int x, int y, string status)
    {
        IupListControl listControl = cast(IupListControl)sender;
        int lin, col, pos;
        pos = listControl.convertToPos(x, y);

        writefln("MOTION_CB(x=%d, y=%d [%s]) - [pos=%d]",x, y, status, pos);

        //multitext.convertPosToLinCol(pos, lin, col);
        //writefln("         (lin=%d, col=%d, pos=%d)", lin, col, pos);
    }


    private void btok_click(Object sender, CallbackEventArgs e)
    {
        writefln("Default Enter");
    }

    private void btcancel_click(Object sender, CallbackEventArgs e)
    {
        writefln("Default Esc");
    }

    private void getValueBtn_click(Object sender, CallbackEventArgs e)
    {
        textBox.text = listControl.text;
    }

    private void setValueBtn_click(Object sender, CallbackEventArgs e)
    {
        listControl.text = textBox.text;
    }

    private void getCountBtn_click(Object sender, CallbackEventArgs e)
    {
        writefln("COUNT=%d", listControl.items.count);
    }

    private void index3Btn_click(Object sender, CallbackEventArgs e)
    {
        listControl.items[3-1] = textBox.text;
    }

    private void insertItem3Btn_click(Object sender, CallbackEventArgs e)
    {
        listControl.items.insert(3-1, textBox.text);
    }

    private void appendItemBtn_click(Object sender, CallbackEventArgs e)
    {
        listControl.items.append(textBox.text);
    }

    private void removeItemBtn_click(Object sender, CallbackEventArgs e)
    {
        listControl.items.insert(3-1, textBox.text);
    }

    private void showDropDownBtn_click(Object sender, CallbackEventArgs e)
    {
        if(typeid(listControl) == typeid(IupComboBox))
        {
            IupComboBox groupBox = cast(IupComboBox)listControl;
            groupBox.toggleDropdown();
        }
    }

    private void topItemBtn_click(Object sender, CallbackEventArgs e)
    {
        try
        {
            listControl.scrollToItem(to!int(textBox.text));
        }
        catch(Exception ex)
        {
            writefln("Error: " ~ ex.msg);
        }
    }

    private void appendBtn_click(Object sender, CallbackEventArgs e)
    {
        if(typeid(listControl) == typeid(IupComboBox))
        {
            IupComboBox groupBox = cast(IupComboBox)listControl;
            groupBox.appendText(textBox.text);
        }
    }

    private void getCaretBtn_click(Object sender, CallbackEventArgs e)
    {
        if(typeid(listControl) == typeid(IupComboBox))
        {
            IupComboBox groupBox = cast(IupComboBox)listControl;
            textBox.text = to!string(groupBox.caretLocation);
        }
    }

    private void setReadonlyBtn_click(Object sender, CallbackEventArgs e)
    {
        if(typeid(listControl) == typeid(IupComboBox))
        {
            IupComboBox groupBox = cast(IupComboBox)listControl;
            groupBox.isReadOnly = !groupBox.isReadOnly;
            writefln("ReadOnly: %s", groupBox.isReadOnly);
        }
    }

    private void getSelectedTextBtn_click(Object sender, CallbackEventArgs e)
    {
        // TODO:
    }

    private void getSelectionBtn_click(Object sender, CallbackEventArgs e)
    {
    }
}


version = v1;

public class TreeTestDialog : IupDialog
{
    private IupTree tree;

    this() 
    {
        super();
    }


    protected override void initializeComponent() 
    {
        createTree(); /* Initializes IupTree */

        IupButton butactv = new IupButton("Active");
        butactv.click += &butactv_click;
        
        IupButton butnext = new IupButton("Next");
        butnext.click += &butnext_click;

        IupButton butprev = new IupButton("Prev");
        butprev.click += &butprev_click;

        IupButton butmenu = new IupButton("Menu");
        butmenu.click += &butmenu_click;

        IupHbox hbox = new IupHbox(tree, new IupVbox(butactv, butnext, butprev, butmenu));

        this.child = hbox;
        this.margin = Size(10, 10);
        this.gap = 10;
        this.title = "IupTree Test";
        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;

        //this.map();
        //initTreeNodes();
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        initTreeNodes(); /* Initializes attributes*/
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        if(popupMenu !is null)
            popupMenu.dispose();
    }

    private void butactv_click(Object sender, CallbackEventArgs e)
    {
        tree.enabled = !tree.enabled;
    }

    private void butnext_click(Object sender, CallbackEventArgs e)
    {
        tree.gotoNext();
    }

    private void butprev_click(Object sender, CallbackEventArgs e)
    {
        tree.gotoPrevious();
    }

    private void butmenu_click(Object sender, CallbackEventArgs e)
    {
        showPopup();
    }

    private void showPopup()
    {
        if(popupMenu is null)
            createPopupMenu();

        popupMenu.popup(ScreenPostionH.MousePos, ScreenPostionV.MousePos);
    }


    /**
    Initializes IupTree and registers callbacks 
    */
    private void createTree()
    {
        tree = new IupTree();

        //tree.spacing = 10;

        tree.selectionMode = NodeSelectionMode.Multiple;
        //tree.canRename = true;
        tree.canDragDrop = true;
        //tree.canToggle = true;
        //tree.canRename = true;

        tree.toggleMode = ToggleButtonVisibility.TreeState;
        tree.isDropDragEqual = true;
        tree.isAddExpanded = true;
        //tree.canHideLines = true;
        //tree.canHideButtons = true;
        //tree.canFocus = tree;
        //tree.indentation = 40;
        tree.tipText = "Tree Tip";
        //tree.canShowInfoTip = false;
        //tree.highlightColor = "240 116 64";       
        //tree.tooltip.background = "255 128 128";
        //tree.tooltip.foreground = "0 92 255";

        //tree.tooltip.hasBalloon = true;
        //tree.tooltip.balloonTitle = "Tip Title";
        //tree.tooltip.balloonIco = BalloonIco.Warning; 

        //tree.canAddRoot = false;

        //tree.map();

        tree.branchCollapsed += &tree_branchCollapsed;
        tree.branchExpanded += &tree_branchExpanded;
        tree.dragDrop += &tree_dragDrop;
        tree.executeLeaf += &tree_executeLeaf;
        tree.nodeRemoved += &tree_nodeRemoved;
        tree.nodeRenaming += &tree_nodeRenaming;
        tree.nodeRenamed += &tree_nodeRenamed;
        tree.rightClick += &tree_rightClick;
        tree.selectionStateChanged += &tree_selectionStateChanged;
        tree.multipleSelected += &tree_multipleSelected;
        tree.toggleStateChanged += &tree_toggleStateChanged;

        tree.helpRequested += &tree_helpRequested;
        //tree.gotFocus += &tree_gotFocus;
        //tree.lostFocus += &tree_lostFocus;
        tree.keyPress += &tree_keyPress;

        //tree.tipPopup += &tree_tipPopup;  
        //tree.mouseEnter += &tree_mouseEnter;
        //tree.mouseLeave += &tree_mouseLeave;
        //tree.mouseClick += &tree_mouseClick;
        //tree.mouseMove += &tree_mouseMove;
    }

    private void tree_branchCollapsed(Object sender, CallbackEventArgs e, int id)
    {
        writefln("BRANCHOPEN_CB (%d)", id);
    }

    private void tree_branchExpanded(Object sender, CallbackEventArgs e, int id)
    {
        writefln("BRANCHCLOSE_CB (%d)", id);
    }

    private void tree_dragDrop(Object sender, CallbackEventArgs e, 
                               int drag_id, int drop_id, bool isShift, bool isControl)
    {
        writefln("DRAGDROP_CB (%d)->(%d) shift=%s ctrl=%s", drag_id, drop_id, isShift, isControl);
        e.result = IupElementAction.Continue;
    }

    private void tree_executeLeaf(Object sender, CallbackEventArgs e, int id)
    {
        writefln("EXECUTELEAF_CB (id=%d)", id);
    }

    private void tree_nodeRemoved(Object sender, CallbackEventArgs e, void* userData)
    {
        // TODO: bad data
        string s = cast(string)std.string.fromStringz(cast(char*) userData);

        //string s = cast(string)(cast(char*) userData);
        writefln("NODEREMOVED_CB(userdata=%s)", s);
    }

    private void tree_nodeRenaming(Object sender, CallbackEventArgs e, int id)
    {
        writefln("SHOWRENAME_CB(%d)", id);
        if (id == 6)
            e.result = IupElementAction.Ignore;
    }

    private void tree_nodeRenamed(Object sender, CallbackEventArgs e, int id, string title)
    {
        writefln("RENAME_CB (%d=%s)", id, title);
        if (title == "fool")
            e.result = IupElementAction.Ignore;
    }

    private void tree_rightClick(Object sender, CallbackEventArgs e, int id)
    {
        showPopup();
    }

    private void tree_selectionStateChanged(Object sender, CallbackEventArgs e, int id, bool isSelected)
    {
        writefln("SELECTION_CB(id=%d, isSelected=%d)", id, isSelected);
        // TODO:
        //writefln("    USERDATA=%s", IupGetAttributeId(ih, "USERDATA", id));
    }

    private void tree_multipleSelected(Object sender, CallbackEventArgs e, int[] ids)
    {
        writef("MULTISELECTION_CB(");
        int n = ids.length;
        for (int i = 0; i < n; i++)
            writef("%d, ", ids[i]);
        writef("length=%d)\n", n);
    }

    private void tree_toggleStateChanged(Object sender, CallbackEventArgs e, 
                                         int id, ToggleState state)
    {
        writefln("TOGGLEVALUE_CB(%d, state=%s)", id, state);
    }


    private void tree_keyPress(Object sender, CallbackEventArgs e, int key)
    {
        if(key == Keys.Delete)
            tree.deleteSelectedNodes();

        //IupElement element = cast(IupElement)sender;
        //if(isPrintable(key))
        //{
        //    writefln("keyPress(%s, %d = %s \'%c\')", element.name, key,  Keys.toName(key), cast(char)key);
        //}
        //else
        //{
        //    writefln("keyPress(%s, %d = %s)", element.name, key, Keys.toName(key));
        //}
        //
        //writefln("ModifierKeyState(%s)", Keys.getModifierKeyState()); 
    }


    private void tree_lostFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("lostFocus(%s)", element.name); 
    }

    private void tree_gotFocus(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("gotFocus(%s)", element.name); 
    }

    private void tree_helpRequested(Object sender, CallbackEventArgs e)
    {
        IupElement element = cast(IupElement)sender;
        writefln("HelpRequested(%s)", element.name); 
    }

    private void tree_tipPopup(Object sender, CallbackEventArgs e, int x, int y)
    {
        IupElement element = cast(IupElement)sender;
        writefln("TIPS_CB(%s, %d, %d)", element.title, x, y);
    }
    private void tree_mouseEnter(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("ENTERWINDOW_CB(%s)", element.title);
    }

    private void tree_mouseLeave(Object sender, CallbackEventArgs args)
    {
        IupElement element = cast(IupElement)sender;
        writefln("LEAVEWINDOW_CB(%s)", element.title);
    }


    private void tree_mouseClick(Object sender, CallbackEventArgs args, 
                                        MouseButtons button, MouseState mouseState, 
                                        int x, int y, string status)
    {
        int pos;
        pos = tree.convertToPos(x, y);
        writefln("BUTTON_CB(but=%s (%s), x=%d, y=%d [%s]) - [pos=%d]", 
                 button, mouseState, x, y, status, pos);
    }

    private void tree_mouseMove(Object sender, CallbackEventArgs args, int x, int y, string status)
    {
        int  pos = tree.convertToPos(x, y);
        writefln("MOTION_CB(x=%d, y=%d [%s]) - [pos=%d]",x, y, status, pos);
    }

    private void initTreeNodes()
    {
        /* create from bottom to top */
        /* the current node is the ROOT */
        version(v2)
        {
            /* create from bottom to top */
            /* the current node is the ROOT */
            tree.title = "Figures";  /* title of the root, id=0 */
            tree.addBranch("3D"); /* 3D=1 */
            tree.addLeaf("2D"); /* add to the root, so it will be before "3D", now 2D=1, 3D=2 */
            tree.addBranch("parallelogram"); /* id=1 */ 
            tree.addLeaf(1, "diamond");
            tree.addLeaf(1, "square");
            tree.addBranch("triangle");
            tree.addLeaf(1, "scalenus");
            tree.addLeaf(1, "isoceles");
            tree.addLeaf(1, "equilateral");
            tree.addLeaf("Other");
        }
        else
        {
            /* create from top to bottom */
            if(tree.canAddRoot)
                tree.setNodeTitle(0, "Figures");
            else
                tree.addBranch(-1, "Figures");
            tree.addLeaf(0, "Other"); /* new id=1 */
            tree.addBranch(1, "triangle"); /* new id=2 */ 
            tree.addLeaf(2, "equilateral"); /* ... */
            tree.addLeaf(3, "isoceles"); 
            tree.addLeaf(4, "scalenus"); 
            tree.setNodeState(2, NodeState.Collapsed); 
            tree.insertBranch(2, "parallelogram"); /* same depth as id=2, new id=6 */
            tree.addLeaf(6, "square very long string at tree node"); 
            tree.addLeaf(7, "diamond"); 
            tree.insertLeaf(6, "2D"); /* new id=9 */
            tree.insertBranch(9, "3D");
            tree.insertBranch(10, "Other (其他)");

            tree.setNodeToggleState(2, ToggleState.On);
            tree.setNodeToggleState(6, ToggleState.On);
            //tree.setNodeToggleState(9, ToggleState.Indeterminate);

            //tree.canAutoRedraw = true;
            tree.setNodeToggleVisible(7, false);

            //IupSetAttribute(tree, "NODEACTIVE5", "No");
            tree.setNodeSelectionState(1, true);
            tree.setNodeSelectionState(8, true);

            tree.setCurrentNode(6);
            tree.clearAttribute(IupAttributes.RasterSize);

            tree.setNodeColor(8, "92 92 255");

            IupImage32 tecgrafLogo = new IupImage32(16, 16, TecgrafLogo_data_32); 
            tree.setNodeImage(8, tecgrafLogo);
            tree.setNodeImage(6, tecgrafLogo);

            for(int i=0; i<10; i++)
            {
                string s= "TestUserData" ~ to!string(i);
                // todo: check
                tree.setNodeUserData(i, cast(void*)s.ptr);
            }
        }

        tree.expandAll();
    }

    private void createPopupMenu()
    {       
        //
        popupMenu = new IupMenu();

        //
        IupMenuItem nodeInfoMenuItem = new IupMenuItem("Node Info");
        nodeInfoMenuItem.click += &nodeInfoMenuItem_click;
        popupMenu.items.append(nodeInfoMenuItem);

        IupMenuItem renameNodeMenuItem = new IupMenuItem("Rename Node");
        renameNodeMenuItem.click += &renameNodeMenuItem_click;
        popupMenu.items.append(renameNodeMenuItem);

        popupMenu.items.append(new IupMenuSeparator()); 

        IupMenuItem addLeafMenuItem = new IupMenuItem("Add Leaf");
        addLeafMenuItem.click += &addLeafMenuItem_click;
        popupMenu.items.append(addLeafMenuItem);

        IupMenuItem addBranchMenuItem = new IupMenuItem("Add Branch");
        addBranchMenuItem.click += &addBranchMenuItem_click;
        popupMenu.items.append(addBranchMenuItem);

        IupMenuItem insertLeafMenuItem = new IupMenuItem("Insert Leaf");
        insertLeafMenuItem.click += &insertLeafMenuItem_click;
        popupMenu.items.append(insertLeafMenuItem);

        IupMenuItem insertBranchMenuItem = new IupMenuItem("Insert Branch");
        insertBranchMenuItem.click += &insertBranchMenuItem_click;
        popupMenu.items.append(insertBranchMenuItem);

        IupMenuItem removeNodeMenuItem = new IupMenuItem("Remove Node");
        removeNodeMenuItem.click += &removeNodeMenuItem_click;
        popupMenu.items.append(removeNodeMenuItem);

        IupMenuItem removeChildrenMenuItem = new IupMenuItem("Remove Children");
        removeChildrenMenuItem.click += &removeChildrenMenuItem_click;
        popupMenu.items.append(removeChildrenMenuItem);

        IupMenuItem removeMarkedMenuItem = new IupMenuItem("Remove Marked");
        removeMarkedMenuItem.click += &removeMarkedMenuItem_click;
        popupMenu.items.append(removeMarkedMenuItem);

        IupMenuItem removeAllMenuItem = new IupMenuItem("Remove All");
        removeAllMenuItem.click += &removeAllMenuItem_click;
        popupMenu.items.append(removeAllMenuItem);

        IupMenuItem toggleStateMenuItem = new IupMenuItem("Toggle State");
        toggleStateMenuItem.click += &toggleStateMenuItem_click;
        popupMenu.items.append(toggleStateMenuItem);

        IupMenuItem expandAllMenuItem = new IupMenuItem("Expand All");
        expandAllMenuItem.click += &expandAllMenuItem_click;
        popupMenu.items.append(expandAllMenuItem);

        IupMenuItem contractAllMenuItem = new IupMenuItem("Contract All");
        contractAllMenuItem.click += &contractAllMenuItem_click;
        popupMenu.items.append(contractAllMenuItem);

        // 
        IupMenu focusMenu = new IupMenu();

        IupMenuItem selectNodeMenuItem = new IupMenuItem("ROOT");
        selectNodeMenuItem.click += &gotoFirstMenuItem_click;
        focusMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("LAST");
        selectNodeMenuItem.click += &gotoLastMenuItem_click;
        focusMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("PGUP");
        selectNodeMenuItem.click += &pageUpMenuItem_click;
        focusMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("PGDN");
        selectNodeMenuItem.click += &pageDownMenuItem_click;
        focusMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("NEXT");
        selectNodeMenuItem.click += &gotoNextMenuItem_click;
        focusMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("PREVIOUS");
        selectNodeMenuItem.click += &gotoPreviousMenuItem_click;
        focusMenu.items.append(selectNodeMenuItem);

        IupSubmenu focusSubmenu = new IupSubmenu("Focus", focusMenu);
        popupMenu.items.append(focusSubmenu);

        // 
        IupMenu markMenu = new IupMenu();

        selectNodeMenuItem = new IupMenuItem("INVERT");
        selectNodeMenuItem.click += &invertCurrentMenuItem_click;
        markMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("BLOCK");
        selectNodeMenuItem.click += &selectBlockMenuItem_click;
        markMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("CLEARALL");
        selectNodeMenuItem.click += &clearAllSelectionMenuItem_click;
        markMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("MARKALL");
        selectNodeMenuItem.click += &selectAllMenuItem_click;
        markMenu.items.append(selectNodeMenuItem);

        selectNodeMenuItem = new IupMenuItem("INVERTALL");
        selectNodeMenuItem.click += &invertAllSelectionMenuItem_click;
        markMenu.items.append(selectNodeMenuItem);

        IupSubmenu markSubmenu = new IupSubmenu("Mark", markMenu);
        popupMenu.items.append(markSubmenu);

    }
    private IupMenu popupMenu;


    private void nodeInfoMenuItem_click(Object sender, CallbackEventArgs e)
    {
        int branch = 0;
        int id = tree.currentNodeId;
        writef("\nTree Info:\n");
        writef("  TOTALCOUNT=%s\n",tree.nodeCount);
        if (id == -1)
            return ;

        writef("Node Info:\n");
        writef("  ID=%d\n", id);
        writef("  TITLE=%s\n", tree.getNodeTitle(id));
        writef("  DEPTH=%s\n", tree.getNodeDepth(id));
        TreeNodeKind kind = tree.getNodeKind(id);
        writef("  KIND=%s\n", kind);
        writef("  IMAGE=%s\n", tree.getNodeImageName(id));

        if (kind == TreeNodeKind.Branch)
        {
            writef("  STATE=%s\n",  tree.getNodeState(id));
            writef("  IMAGEBRANCHEXPANDED=%s\n", tree.getExpandedBranchesImageName());
        }

        writef("  MARKED=%s\n", tree.getNodeState(id));
        writef("  COLOR=%s\n", tree.getNodeColorAsRGB(id));
        writef("  PARENT=%d\n", tree.getNodeParentId(id));
        writef("  CHILDCOUNT=%d\n", tree.getNodeChildCount(id));
        //writef("  USERDATA=%p\n", IupGetAttribute(tree, "USERDATA"));

    }

    private void gotoFirstMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.gotoFirst();
    }

    private void gotoLastMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.gotoLast();
    }

    private void pageUpMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.scrollUp();
    }

    private void pageDownMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.scrollDown();
    }

    private void gotoNextMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.gotoNext();
    }

    private void gotoPreviousMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.gotoPrevious();
    }

    private void invertCurrentMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.invertCurrentSelection();
    }

    private void selectBlockMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.selectBlock();
    }

    private void clearAllSelectionMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.clearAllSelection();
    }

    private void selectAllMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.selectAll();
    }

    private void invertAllSelectionMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.invertAllSelection();
    }


    private void selectNodeMenuItem_click(Object sender, CallbackEventArgs e)
    {
    }

    private void renameNodeMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.renameNode();
    }

    private void addLeafMenuItem_click(Object sender, CallbackEventArgs e)
    {
        int nodeId = tree.currentNodeId;
        tree.addLeaf(nodeId, "new leaf");
    }

    private void addBranchMenuItem_click(Object sender, CallbackEventArgs e)
    {
        int nodeId = tree.currentNodeId;
        tree.addBranch(nodeId, "new leaf");
    }

    private void insertLeafMenuItem_click(Object sender, CallbackEventArgs e)
    {
        int nodeId = tree.currentNodeId;
        tree.insertLeaf(nodeId, "new leaf");
    }

    private void insertBranchMenuItem_click(Object sender, CallbackEventArgs e)
    {
        int nodeId = tree.currentNodeId;
        tree.insertBranch(nodeId, "new leaf");
    }

    private void removeNodeMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.removeSelectedNodes();
    }

    private void removeChildrenMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.removeChildren();
    }

    private void removeMarkedMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.removeMarkedNodes();
    }

    private void removeAllMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.removeAll();
    }

    private void toggleStateMenuItem_click(Object sender, CallbackEventArgs e)
    {
        int nodeId = tree.currentNodeId;
        NodeState state = tree.getNodeState(nodeId);
        if(state == NodeState.Collapsed)
            tree.setNodeState(nodeId, NodeState.Expanded);
        else if(state == NodeState.Expanded)
            tree.setNodeState(nodeId, NodeState.Collapsed);
        else
            writefln("Leaf (id=%d)", nodeId);

    }

    private void expandAllMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.expandAll();
    }

    private void contractAllMenuItem_click(Object sender, CallbackEventArgs e)
    {
        tree.collapseAll();
    }


    // 16x16 32-bit
    private const(ubyte)[] TecgrafLogo_data_32 = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 108, 120, 143, 125, 132, 148, 178, 173, 133, 149, 178, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 110, 130, 48, 130, 147, 177, 254, 124, 139, 167, 254, 131, 147, 176, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 115, 128, 153, 134, 142, 159, 191, 194, 47, 52, 61, 110, 114, 128, 154, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 143, 172, 192, 140, 156, 188, 99, 65, 69, 76, 16, 97, 109, 131, 251, 129, 144, 172, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 131, 147, 175, 232, 140, 157, 188, 43, 0, 0, 0, 0, 100, 112, 134, 211, 126, 141, 169, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 78, 88, 26, 48, 52, 57, 60, 135, 150, 178, 254, 108, 121, 145, 83, 105, 118, 142, 76, 106, 119, 143, 201, 118, 133, 159, 122, 117, 129, 152, 25, 168, 176, 190, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        118, 128, 145, 3, 104, 117, 140, 92, 114, 127, 152, 180, 131, 147, 177, 237, 133, 149, 178, 249, 38, 42, 50, 222, 137, 152, 180, 249, 126, 142, 170, 182, 114, 128, 154, 182, 104, 117, 140, 227, 95, 107, 128, 238, 83, 93, 112, 248, 84, 95, 113, 239, 104, 117, 141, 180, 115, 129, 155, 93, 127, 140, 165, 4,
        98, 109, 130, 153, 109, 123, 147, 254, 145, 163, 195, 153, 138, 154, 182, 56, 115, 123, 138, 5, 92, 99, 109, 35, 134, 149, 177, 230, 0, 0, 0, 0, 0, 0, 0, 0, 120, 133, 159, 143, 135, 151, 181, 115, 86, 89, 93, 5, 41, 45, 51, 54, 40, 45, 53, 150, 107, 120, 144, 254, 122, 137, 164, 154,
        51, 57, 66, 147, 83, 93, 112, 255, 108, 121, 145, 159, 113, 126, 151, 62, 123, 136, 159, 8, 87, 93, 103, 35, 125, 141, 169, 230, 0, 0, 0, 0, 0, 0, 0, 0, 129, 143, 169, 143, 140, 156, 184, 115, 134, 147, 172, 8, 124, 138, 165, 60, 124, 139, 167, 155, 131, 147, 177, 255, 131, 147, 176, 153,
        64, 68, 73, 2, 36, 39, 45, 86, 41, 46, 54, 173, 60, 67, 80, 232, 75, 84, 101, 251, 89, 100, 120, 228, 105, 118, 142, 250, 110, 123, 148, 187, 118, 132, 158, 187, 126, 141, 169, 229, 134, 149, 177, 239, 136, 152, 179, 250, 136, 152, 181, 234, 139, 156, 186, 175, 130, 145, 173, 90, 124, 134, 151, 3,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 71, 74, 79, 19, 60, 64, 73, 50, 92, 103, 124, 254, 86, 95, 111, 84, 90, 100, 117, 76, 126, 141, 168, 201, 113, 126, 150, 119, 99, 105, 117, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 93, 105, 125, 231, 135, 151, 181, 46, 0, 0, 0, 0, 137, 154, 184, 212, 123, 137, 164, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 83, 98, 191, 133, 149, 179, 102, 111, 121, 139, 17, 134, 150, 180, 252, 126, 140, 166, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 48, 57, 132, 121, 136, 164, 197, 121, 135, 161, 115, 130, 146, 175, 221, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 47, 52, 46, 87, 98, 118, 254, 126, 142, 170, 254, 124, 139, 166, 135, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 51, 57, 67, 118, 115, 128, 152, 170, 127, 140, 164, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];

    // 16x16 8-bit
    private const(ubyte)[] image_data_8 = [
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,1,1,1,1,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,2,2,2,2,0,0,0,5, 
        5,0,0,0,1,1,1,1,2,2,2,2,0,0,0,5, 
        5,0,0,0,3,3,3,3,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,4,4,4,4,0,0,0,5, 
        5,0,0,0,3,3,3,3,4,4,4,4,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
    ];
}