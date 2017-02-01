module iup.color;

import iup.canvas;
import iup.control;
import iup.core;

import iup.c;

import std.string;

import toolkit.drawing;
import toolkit.event;


class ColorBarCallbackEventArgs : CallbackEventArgs
{
    Color color;

    this()  { super(); }
}

/**
Creates a color palette to enable a color selection from several samples. It can select 
one or two colors. The primary color is selected with the left mouse button, and the 
secondary color is selected with the right mouse button. You can double click a cell 
to change its color and you can double click the preview area to switch between primary 
and secondary colors.

This is an additional control that depends on the CD library. It is included in the 
IupControls library. It inherits from IupCanvas. 
*/
public class IupColorBar : IupCanvasBase
{
	class IupAttributes : super.IupAttributes
	{
        enum IupColorBar = "IupColorBar";
        enum BufferSize = "BUFFERSIZE";
        enum Cell = "CELL";
        enum NumCells = "NUM_CELLS";
        enum Count = "COUNT";
        enum NumParts = "NUM_PARTS";
        enum Orientation = "ORIENTATION";
        enum PreviewSize = "PREVIEW_SIZE";
        enum ShowPreview = "SHOW_PREVIEW";
        enum ShowSecondary = "SHOW_SECONDARY";
        enum PrimaryCell = "PRIMARY_CELL";
        enum SecondaryCell = "SECONDARY_CELL";
        enum Squared = "SQUARED";
        enum Shadowed = "SHADOWED";
        enum Transparency = "TRANSPARENCY";
	}

    class IupCallbacks : super.IupCallbacks
    {
		enum Cell = "CELL_CB";
		enum Extended = "EXTENDED_CB";
		enum Select = "SELECT_CB";
		enum Switch = "SWITCH_CB";
    }

	this() { super(); }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.IupColorbar();
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerCellDoubleClickedCallback(IupCallbacks.Cell);
        registerExtendedRightClickCallback(IupCallbacks.Extended);
        registerColorSelectedCallback(IupCallbacks.Select);
        registerSelectionSwitchedCallback(IupCallbacks.Switch);
    }


    /* ************* Events *************** */

    /**
    called when the user double clicks a color cell to change its value. 

    cell: index of the selected cell. If the user double click a preview cell, the respective
    index is returned.

    color: a new color or NULL (nil in Lua) to ignore the change. By default nothing is changed.
    */
    public EventHandler!(ColorBarCallbackEventArgs, int)  cellDoubleClicked;

    private void registerCellDoubleClickedCallback(string actionName)
    {
        iup.c.IupSetCallback(this.handle, std.string.toStringz(actionName), cast(Icallback)&cellDoubleClickedCallbackAdapter);
    }

    extern(C) static private nothrow char* cellDoubleClickedCallbackAdapter(Ihandle *ih, int args) 
    {
        char* p = iup.c.api.IupGetAttribute(ih, "IupObject");
        IupColorBar d = cast(IupColorBar)(p);
        return d.onCellDoubleClicked(args);
    }

    private char* onCellDoubleClicked(int index) nothrow
    {
        try
        {
            ColorBarCallbackEventArgs r = new ColorBarCallbackEventArgs();
            cellDoubleClicked(this, r, index);

            if( r.result == CallbackResult.Ignore)
                return  null;

            string color = r.color.toRgb();
            return cast(char*)color.ptr;
        }
        catch(Exception ex)
        { 
            return  null; 
        }
    }

    /**
    called when the user right click a cell with the Shift key pressed. It is independent of 
    the SHOW_SECONDARY attribute.

    cell: index of the selected cell.
    Returns: If IUP_IGNORE the cell is not redrawn. By default the cell is always redrawn.
    */
    mixin EventCallback!(IupColorBar, "extendedRightClick", int);

    /**
    called when a color is selected. The primary color is selected with the left mouse button, 
    and if existent the secondary is selected with the right mouse button.

    cell: index of the selected cell.
    type: indicates if the user selected a primary or secondary color. In can be: 
    IUP_PRIMARY(-1) or IUP_SECONDARY(-2).

    Returns: If IUP_IGNORE the selection is not accepted. By default the selection is always accepted.
    */
    mixin EventCallback!(IupColorBar, "colorSelected", int, int);

    /**
    called when the user double clicks the preview area outside the preview cells to switch 
    the primary and secondary selections. It is only called if SHOW_SECONDARY=YES.

    prim_cell: index of the actual primary cell.
    sec_cell: index of the actual secondary cell. 

    Returns: If IUP_IGNORE the switch is not accepted. By default the switch is always accepted.
    */
    mixin EventCallback!(IupColorBar, "selectionSwitched", int, int);


    /* ************* Properties *************** */

    /**
    Controls the display of the preview area. Default: "YES". 
    */
    @property 
    {
        public bool canShowPreview() { return getAttribute(IupAttributes.ShowPreview) == FlagIdentifiers.Yes; }

        public void canShowPreview(bool value)  {
            setAttribute(IupAttributes.ShowPreview, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Controls the existence of a secondary color selection. Default: "NO". 
    */
    @property 
    {
        public bool canShowSecondary() { return getAttribute(IupAttributes.ShowSecondary) == FlagIdentifiers.Yes; }

        public void canShowSecondary(bool value)  {
            setAttribute(IupAttributes.ShowSecondary, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Disables the automatic redrawing of the control, so many attributes can be changed 
    without many redraws. Default: "NO". When set to "NO" the control is redrawn.
    */
    @property 
    {
        public bool isBufferSizeEnabled() { return getAttribute(IupAttributes.BufferSize) == FlagIdentifiers.Yes; }

        public void isBufferSizeEnabled (bool value)  {
            setAttribute(IupAttributes.BufferSize, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Contains the number of color cells. Default: "16". The maximum number of colors is 256. 
    The default colors use the same set of IupImage.
    */
    @property 
	{
		public int cellCount()  {  return getIntAttribute(IupAttributes.Count); }
		public int cellNumber()  {  return getIntAttribute(IupAttributes.NumCells); }
        public void cellNumber(int value) { setIntAttribute(IupAttributes.NumCells, value);}
	}

    /**
    Contains the number of lines or columns. Default: "1". 
    */
    @property 
	{
		public int groupNumber()  {  return getIntAttribute(IupAttributes.NumParts); }
        public void groupNumber(int value) { setIntAttribute(IupAttributes.NumParts, value);}
	}

    /**
    Controls the 3D effect of the color cells. Default: "YES". 
    */
    @property 
    {
        public bool isShadowed() { return getAttribute(IupAttributes.Shadowed) == FlagIdentifiers.Yes; }

        public void isShadowed(bool value)  {
            setAttribute(IupAttributes.Shadowed, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Controls the aspect ratio of the color cells. Non square cells expand equally to occupy
    all of the control area. Default: "YES". 
    */
    @property 
    {
        public bool isSquared() { return getAttribute(IupAttributes.Squared) == FlagIdentifiers.Yes; }

        public void isSquared(bool value)  {
            setAttribute(IupAttributes.Squared, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    Controls the orientation. It can be "VERTICAL" or "HORIZONTAL". Default: "VERTICAL".
    */
    @property 
	{
		public Orientation orientation() { 
            string s = getAttribute(IupAttributes.Orientation); 
            return OrientationIdentifiers.convert(s);
        }

		public void orientation(Orientation value) {
			setAttribute(IupAttributes.Orientation, OrientationIdentifiers.convert(value));
		}
	}

    /**
    Fixes the size of the preview area in pixels. The default size is dynamically calculated 
    from the size of the control. The size is reset to the default when SHOW_PREVIEW=NO.
    */
    @property 
	{
		public int previewSize()  {  return getIntAttribute(IupAttributes.PreviewSize); }
        public void previewSize(int value) { setIntAttribute(IupAttributes.PreviewSize, value);}

        //public Size previewSize() 
        //{ 
        //    string s = getAttribute(IupAttributes.PreviewSize);
        //    return IupSize.parse(s); 
        //}
        //
        //public void previewSize(Size value) { 
        //    setAttribute(IupAttributes.PreviewSize, IupSize.format(value));
        //}
	}

    /**
    Contains the index of the primary color. Default "0" (black). 
    */
    @property 
	{
		public int primaryCellIndex()  {  return getIntAttribute(IupAttributes.PrimaryCell); }
        public void primaryCellIndex(int value) { setIntAttribute(IupAttributes.PrimaryCell, value);}
	}

    /**
    Contains the index of the secondary color. Default "15" (white). 
    */
    @property 
	{
		public int secondaryCellIndex()  {  return getIntAttribute(IupAttributes.SecondaryCell); }
        public void secondaryCellIndex(int value) { setIntAttribute(IupAttributes.SecondaryCell, value);}
	}



    /* ************* Public methods *************** */

    /**
    Contains the color of the "n" cell. "n" can be from 0 to NUM_CELLS-1.
    */
    Color getCellColor(int index)
    {
        string v = getIdAttributeAsString(IupAttributes.Cell, index);
        return Color.parse(v);
    }

    /// ditto
    void setCellColor(int index, Color color)
    {
        setIdAttribute(IupAttributes.Cell, index, color.toRgb);
    }

    /// ditto
    void setCellColor(string color)
    {
        setAttribute(IupAttributes.Cell, color);
    }
}


/**
Creates an element for selecting a color. The selection is done using a cylindrical 
projection of the RGB cube. The transformation defines a coordinate color system 
called HSI, that is still the RGB color space but using cylindrical coordinates.

This is an additional control that depends on the CD library. It is included in the 
IupControls library.

For a dialog that simply returns the selected color, you can use function IupGetColor
or IupColorDlg.
*/
public class IupColorBrowser : IupCanvasBase
{
	class IupAttributes : super.IupAttributes
	{
        enum IupColorBrowser = "IupColorBrowser";
        enum RGB = "RGB";
        enum HSI = "HSI";
	}

    class IupCallbacks : super.IupCallbacks
    {
		enum Change = "CHANGE_CB";
		enum Drag = "DRAG_CB";
		enum ValueChanged = "VALUECHANGED_CB";
    }

	this() { super(); }


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.IupColorBrowser();
	}

    protected override void onCreated()
    {    
        super.onCreated();

        registerMouseUpCallback(IupCallbacks.Change);
        registerMouseMoveCallback(IupCallbacks.Drag);
        registerValueChangedCallback(IupCallbacks.ValueChanged);
    }


    /* ************* Events *************** */

    /**
    Called when the user releases the left mouse button over the control, defining the 
    selected color.

    r, g, b: color value.
    */
    mixin EventCallback!(IupColorBrowser, "mouseUp", ubyte, ubyte, ubyte);

    /**
    Called several times while the color is being changed by dragging the mouse over 
    the control.

    r, g, b: color value.
    */
    mixin EventCallback!(IupColorBrowser, "mouseMove", ubyte, ubyte, ubyte);

    /**
    Called after the value was interactively changed by the user. It is called whenever
    a CHANGE_CB or a DRAG_CB would also be called, it is just  called after them. 
    */
    mixin EventCallback!(IupColorBrowser, "valueChanged");


    /* ************* Properties *************** */

    /**
    the color selected in the control, in the "r g b" format; r, g and b are integers 
    ranging from 0 to 255. Default: "255 0 0".
    */
    @property 
	{
        Color rgb()  {  
            string c = getAttribute(IupAttributes.RGB);
            return Color.parse(c);
        }

        void rgb(Color value) { 
            setAttribute(IupAttributes.RGB, value.toRgb());
        }

        void rgb(string value) { 
            setAttribute(IupAttributes.RGB, value);
        }
	}

    /**
    the color selected in the control, in the "h s i" format; h, s and i are floating
    point numbers ranging from 0-360, 0-1 and 0-1 respectively. 
    */
    @property 
	{
        HsiColor hsi()  {  
            string c = getAttribute(IupAttributes.HSI);
            return HsiColor.parse(c);
        }

        void hsi(HsiColor value) { 
            setAttribute(IupAttributes.HSI, value.toString());
        }

        void hsi(string value) { 
            setAttribute(IupAttributes.HSI, value);
        }
	}
}

