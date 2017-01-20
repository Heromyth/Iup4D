module iup.layout;

import iup.control;
import iup.container;
import iup.core;
import iup.c;

import std.conv;
import std.string;
import std.format;

import toolkit.drawing;


public class IupFlatLayoutControl : IupContainerControl
{

    protected class IupAttributes : super.IupAttributes
	{
        enum Gap = "GAP";
        enum CMargin = "CMARGIN";
        enum ExpandChildren = "EXPANDCHILDREN";
        enum Homogeneous = "HOMOGENEOUS";
        enum Margin = "MARGIN";
        enum NMargin = "NMARGIN";
        enum NCMargin = "NCMARGIN";
        enum NormalizeSize = "NORMALIZESIZE";
        enum Padding = "PADDING";
	}

    this(IupControl[] children...)
	{
        super(children);
	}



    protected override void onCreated()
    {
        //alignment = VerticalAlignment.Left;
    }

    /* ************* Properties *************** */


    /**
    forces all children to expand horizontally and to fully occupy its space available inside
    the box. Default: "NO". This has the same effect as setting EXPAND=HORIZONTAL on each child. (since 3.0)
    */
    @property 
	{
		public bool canExpandChildren()  {  return getAttribute(IupAttributes.ExpandChildren) == FlagIdentifiers.Yes; }

        public void canExpandChildren(bool value) {
            setAttribute(IupAttributes.ExpandChildren, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    forces all children to get equal vertical space. The space height will be  based on the 
    highest child. Default: "NO". Notice that this does not changes the children size, only 
    the available space for each one of them to expand. (since 3.0)
    */
    @property 
	{
		public bool isHomogeneous()  {  return getAttribute(IupAttributes.Homogeneous) == FlagIdentifiers.Yes; }

        public void isHomogeneous(bool value) {
            setAttribute(IupAttributes.Homogeneous, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

    /**
    Defines a margin in pixels, CMARGIN is in the same units of the SIZE attribute. Its value has the format "widthxheight",
    where width and height are integer values corresponding to the horizontal and vertical margins, respectively. 
    Default: "0x0" (no margin). (CMARGIN since 3.0)
    */
    @property 
	{
		public Size cmargin() { return m_cmargin; }

		public void cmargin(Size value) 
		{
			m_cmargin = value;
			setAttribute(IupAttributes.CMargin, IupSize.format(value));
		}
        private Size m_cmargin; 
	}

    /// ditto
    @property 
	{
		public Size margin() { return m_margin; }

		public void margin(Size value) 
		{
			m_margin = value;
			setAttribute(IupAttributes.Margin, IupSize.format(value));
		}
        private Size m_margin; 
	}

    /// ditto
    @property 
	{
		public Size nmargin() { return m_nmargin; }

		public void nmargin(Size value) 
		{
			m_nmargin = value;
			setAttribute(IupAttributes.NMargin, IupSize.format(value));
		}
        private Size m_nmargin; 
	}

    /// ditto
    @property 
	{
		public Size ncmargin() { return m_ncmargin; }

		public void ncmargin(Size value) 
		{
			m_ncmargin = value;
			setAttribute(IupAttributes.NCMargin, IupSize.format(value));
		}
        private Size m_ncmargin; 
	}

    /**
    * Defines a vertical space in pixels between the children, CGAP is in the same units of 
    the SIZE attribute for the height. Default: "0". (CGAP since 3.0)
    */
    @property 
	{
		public int gap() { return m_gap; }

		public void gap(int value) 
		{
			m_gap = value;
			const(char) * str = iupToStringz(value);
			iup.c.IupSetAttribute(handle, IupAttributes.Gap, str);
		}
        private int m_gap; 
	}

    /**
    normalizes all children natural size to be the biggest natural size among them. 
    All natural width will be set to the biggest width, and all natural height will 
    be set to the biggest height according to is value. Can be NO, HORIZONTAL, VERTICAL 
    or BOTH. Default: "NO". Same as using IupNormalizer. (since 3.0)
    */
    @property 
	{
		public SizeNormalizationStyle sizeNormalization() { 
            string s = getAttribute(IupAttributes.NormalizeSize);
            return SizeNormalizationStyleIdentifiers.convert(s); 
        }

		public void sizeNormalization(SizeNormalizationStyle value) {
			setAttribute(IupAttributes.NormalizeSize, SizeNormalizationStyleIdentifiers.convert(value));
		}
	}

    /**
    internal margin. Works just like the MARGIN attribute of the IupHbox and IupVbox containers, 
    but uses a different name to avoid inheritance problems. Default value: "0x0".
    */
    @property 
	{
		public Size padding() 
        { 
            string s = getAttribute(IupAttributes.Padding);
            return IupSize.parse(s); 
        }

		public void padding(Size value) 
		{
			setAttribute(IupAttributes.Padding, IupSize.format(value));
		}
	}

}



public class IupHbox : IupFlatLayoutControl
{

	this(IupControl[] children...)
	{
		super(children);
	}


    /* ************* Protected methods *************** */

	protected override Ihandle* createIupObject()
	{
		return iup.c.IupHbox(null);
	}


    /* ************* Properties *************** */

    /**
    * Vertically aligns the elements. Possible values: "ATOP", "ACENTER", "ABOTTOM". Default: "ATOP".
    */
    @property 
	{
		public VerticalAlignment alignment() { 
            string s = getAttribute(IupAttributes.Alignment);
            return AlignmentIdentifiers.convertVerticalAlignment(s); 
        }

		public void alignment(VerticalAlignment value) {
			setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
		}
	}

}


/**
Creates a void container that allows its child to be resized. Allows expanding and 
contracting the child size in one direction.

It does not have a native representation but it contains also a IupCanvas to implement 
the bar handler.
*/
public class IupSbox : IupContainerControl
{
    protected class IupAttributes : super.IupAttributes
	{
        enum IupSbox = "IupSbox";
        enum Color = "COLOR";
        enum Direction = "DIRECTION";
	}

	this(IupControl[] children...)
	{
		super(children);
	}

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupSbox(null);
	}


    /* ************* Properties *************** */

    /**
    Changes the color of the bar handler. The value should be given in "R G B" color 
    style. Default: "192 192 192".
    */
    @property 
	{
		public Color color()  
        {  
            string c = getAttribute(IupAttributes.Color);
            return Color.parse(c); 
        }

        public void color(Color value) { setAttribute(IupAttributes.Color, value.toRgb()); }

        void color(string value)  { setAttribute(IupAttributes.Color, value); }
	}

    /**
    Indicates the direction of the resize and the position of the bar handler. 
    Possible values are "NORTH", "SOUTH" (vertical direction), "EAST" or "WEST" 
    (horizontal direction). Default: "EAST".
    */
    @property 
	{
		public Position barPosition()  {  
            return DirectionIdentifiers.convert(getAttribute(IupAttributes.Direction)); 
        }

        public void barPosition(Position value) { 
            setAttribute(IupAttributes.Direction, DirectionIdentifiers.convert(value));
        }
	}
}


/**
Creates a void container for composing elements vertically. It is a box that arranges the elements it contains from top to bottom.

It does not have a native representation.
*/
public class IupVbox : IupFlatLayoutControl
{

	this(IupControl[] children...)
	{
		super(children);
	}

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupVbox(null);
	}


    /* ************* Properties *************** */

    /**
    * Horizontally aligns the elements. Possible values: "ALEFT", "ACENTER", "ARIGHT". Default: "ALEFT".
    */
    @property 
	{
		public HorizontalAlignment alignment() {
            string s = getAttribute(IupAttributes.Alignment);
            return AlignmentIdentifiers.convertHorizontalAlignment(s); 
        }

		public void alignment(HorizontalAlignment value) {
			setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
		}
	}

}


/**
Creates a void container for composing elements in hidden layers with only one layer visible. 
It is a box that piles up the children it contains, only the one child is visible.

It does not have a native representation. 

Zbox works by changing the VISIBLE attribute of its children, so if any of the grand children 
has its VISIBLE attribute directly defined then Zbox will NOT change its state.

Its children automatically receives a name when the child is appended or inserted into the tabs.

The ZBOX relies on the VISIBLE attribute. If a child that is hidden by the zbox has its 
VISIBLE attribute changed then it can be made visible regardless of the zbox configuration. 
*/
public class IupZbox : IupContainerControl
{
    protected class IupAttributes : super.IupAttributes
	{
        enum IupZbox = "IupZbox";
        enum ValueHandle = "VALUE_HANDLE";
        enum ValuePos = "VALUEPOS";
	}

	this(IupControl[] children...)
	{
        m_alignment = ContentAlignment.MiddleCenter;
		super(children);
	}

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupZbox(null);
	}

    protected override void onCreated()
    {
        //super.onCreated();
        this.canExpand = true;
    }

    /**
    * Horizontally aligns the elements. Possible values: "ALEFT", "ACENTER", "ARIGHT". Default: "ALEFT".
    */
    @property 
	{
		public ContentAlignment alignment() { return m_alignment; }

		public void alignment(ContentAlignment value) 
		{
			m_alignment = value;
			setAttribute(IupAttributes.Alignment, IupZbox.toIupIdentifier(value));
		}
        private ContentAlignment m_alignment; 
	}


    /**
    The visible child accessed by its handle. The value passed must be the handle of a 
    child contained in the zbox. When the zbox is created, the first element inserted 
    is set as the visible child. (since 3.0)
    */
    @property 
	{
		public IupControl currentControl() {
            //Ihandle * m_handle = iup.c.api.IupGetAttributeHandle (handle, "VALUE_HANDLE"); // bug: null
            Ihandle* m_handle = cast(Ihandle*) getPointerAttribute(IupAttributes.ValueHandle);
            return getChild(m_handle); 
        }

		public void currentControl(IupControl value) 
		{
            setPointerAttribute(IupAttributes.ValueHandle, value.handle);
            //iup.c.api.IupSetAttributeHandle (handle, std.string.toStringz(IupAttributes.ValueHandle), 
            //                                 value.handle); // bug
		}
	}

    /**
    The visible child accessed by its position. The value passed must be the index of a 
    child contained in the zbox, starting at 0. When the zbox is created, the first element 
    inserted is set as the visible child. (since 3.0)
    */
    @property 
	{
		public int currentIndex() { return getIntAttribute(IupAttributes.ValuePos); }

		public void currentIndex(int value) 
		{
			setIntAttribute(IupAttributes.ValuePos, value);
		}
	}

    protected static string toIupIdentifier(ContentAlignment a)
    {
        switch(a)
        {
            case ContentAlignment.TopLeft:
                return "NW";

            case ContentAlignment.TopCenter:
                return "NORTH";

            case ContentAlignment.TopRight:
                return "NE";

            case ContentAlignment.MiddleLeft:
                return "WEST";

            case ContentAlignment.MiddleRight:
                return "EAST";

            case ContentAlignment.BottomLeft:
                return "SW";

            case ContentAlignment.BottomCenter:
                return "SOUTH";

            case ContentAlignment.BottomRight:
                return "SE";

            default:
                return "ACENTER";
        }
    }
}



/**
Creates a void container for composing elements in a regular grid. It is a box that arranges the elements it contains 
from top to bottom and from left to right, but can distribute the elements in lines or in columns.

Notice that the total number of spaces can be larger than the number of actual children, the last line or column can be incomplete.

The column sizes will be based only on the width of the children of the reference line, usually line 0. The line sizes 
will be based only on the height of the children of the reference column, usually column 0.

It does not have a native representation.
*/
public class IupGridBox : IupFlatLayoutControl
{

    protected class IupAttributes : super.IupAttributes
	{
        enum IupGridBox = "IupGridBox";
        enum AlignmentLin = "ALIGNMENTLIN";
        enum AlignmentCol = "ALIGNMENTCOL";
        enum ExpandChildren = "EXPANDCHILDREN";
        enum FitToChildren = "FITTOCHILDREN";
        enum GapLin = "GAPLIN";
        enum CGapLin = "CGAPLIN";
        enum GapCol = "GAPCOL";
        enum CGapCol = "CGAPCOL";
        enum NGapLin = "NGAPLIN";
        enum NCGapLin = "NCGAPLIN";
        enum NGapCol = "NGAPCOL";
        enum NCGapCol = "NCGAPCOL";
        enum HomogeneousLin = "HOMOGENEOUSLIN";
        enum HomogeneousCol = "HOMOGENEOUSCOL";
        enum NumDiv = "NUMDIV";
        enum NumCol = "NUMCOL";
        enum NumLin = "NUMLIN";
        enum Orientation = "ORIENTATION";
        enum SizeCol = "SIZECOL";
        enum SizeLin = "SIZELIN";
	}

	this(IupControl[] children...)
	{
		super(children);
	}

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupGridBox(null);
	}

    protected override void onCreated()
    {
    }


    /* ************* Properties *************** */

    /**
    forces all children to expand in the given direction and to fully occupy its space available
    inside the box. Can be YES (both directions), HORIZONTAL, VERTICAL or NO. Default: "NO".
    This has the same effect as setting EXPAND on each child.
    */
    @property 
	{
		public SimpleExpandOrientation childrenExpandOrientation() { 
            string s = getAttribute(IupAttributes.ExpandChildren);
            return SimpleExpandIdentifiers.convert(s); 
        }

		public void childrenExpandOrientation(SimpleExpandOrientation value) {
			setAttribute(IupAttributes.ExpandChildren, SimpleExpandIdentifiers.convert(value));
		}
	}

    /**
    controls the number of divisions along the distribution according to ORIENTATION. When 
    ORIENTATION=HORIZONTAL, NUMDIV is the number of columns, when ORIENTATION=VERTICAL, 
    NUMDIV is the number of lines. When value is AUTO, its actual value will be calculated
    to fit the maximum number of elements in the orientation direction. The number of -1 
    means AUTO. Default: AUTO. 
    */
    @property 
	{
		public int divisionNumber()  {  
            string v = getAttribute(IupAttributes.NumDiv);
            if(v == "AUTO")
                return -1;
            else
                return to!int(v); 
        }

        public void divisionNumber(int value) { 
            if(value <= 0)
                setAttribute(IupAttributes.NumDiv, "AUTO");
            else
                setIntAttribute(IupAttributes.NumDiv, value);}
	}

    /**
    * Horizontally aligns the elements within each column. Possible values: "ALEFT", "ACENTER", 
    "ARIGHT". Default: "ALEFT". 
    */
    @property 
	{
		public HorizontalAlignment horizontalAlignment() {
            string s = getAttribute(IupAttributes.AlignmentCol);
            return AlignmentIdentifiers.convertHorizontalAlignment(s); 
        }

		public void horizontalAlignment(HorizontalAlignment value) {
			setAttribute(IupAttributes.AlignmentCol, AlignmentIdentifiers.convert(value));
		}
	}

    /**
    * Vertically aligns the elements within each line. Possible values: "ATOP", "ACENTER", 
    "ABOTTOM". Default: "ATOP". 
    */
    @property 
	{
		public VerticalAlignment verticalAlignment() { 
            string s = getAttribute(IupAttributes.AlignmentLin);
            return AlignmentIdentifiers.convertVerticalAlignment(s); 
        }

		public void verticalAlignment(VerticalAlignment value) {
			setAttribute(IupAttributes.AlignmentLin, AlignmentIdentifiers.convert(value));
		}
	}

    /**
    forces all columns to have the same horizontal space, or width. The column width will be  
    based on the widest child of the reference line (See SIZELIN). Default: "NO". Notice that
    this does not changes the children size, only the available space for each one of them to expand.
    */
    @property 
    {
        public bool isSameColumnWidth() { return getAttribute(IupAttributes.HomogeneousCol) == FlagIdentifiers.Yes; }

        public void isSameColumnWidth(bool value) {
            setAttribute(IupAttributes.HomogeneousCol,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    forces all lines to have the same vertical space, or height. The line height will be  
    based on the highest child of the reference column (See SIZECOL). Default: "NO". Notice 
    that this does not changes the children size, only the available space for each one 
    of them to expand.
    */
    @property 
    {
        public bool isSameRowHeight() { return getAttribute(IupAttributes.HomogeneousLin) == FlagIdentifiers.Yes; }

        public void isSameRowHeight(bool value) {
            setAttribute(IupAttributes.HomogeneousLin,  value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }

    /**
    controls the distribution of the children in lines or in columns. Can be: HORIZONTAL or 
    VERTICAL. Default: HORIZONTAL. 
    */
    @property 
	{
		public Orientation layoutOrientation() { 
            string s =getAttribute(IupAttributes.Orientation); 
            return OrientationIdentifiers.convert(s);
        }

		public void layoutOrientation(Orientation value) {
			setAttribute(IupAttributes.Orientation, OrientationIdentifiers.convert(value));
		}
	}

    /**
    Defines a vertical space in pixels between lines, CGAPLIN is in the same units of the SIZE
    attribute for the height. Default: "0".
    */
    @property 
	{
		public int rowGap()  {  return getIntAttribute(IupAttributes.GapLin); }
        public void rowGap(int value) { setIntAttribute(IupAttributes.GapLin, value);}
	}

    /**
    Defines a horizontal space in pixels between columns, CGAPCOL is in the same units of the 
    SIZE attribute for the height. Default: "0".
    */
    @property 
	{
		public int columnGap()  {  return getIntAttribute(IupAttributes.GapCol); }
        public void columnGap(int value) { setIntAttribute(IupAttributes.GapCol, value);}
	}

    /**
    returns the number of lines.
    */
    @property 
	{
		public int rowCount()  {  return getIntAttribute(IupAttributes.NumLin); }
        public void rowCount(int value) { setIntAttribute(IupAttributes.SizeLin, value);}
	}

    /**
    returns the number of columns.
    */
    @property 
	{
		public int columnCount()  {  return getIntAttribute(IupAttributes.NumCol); }
        public void columnCount(int value) { setIntAttribute(IupAttributes.SizeCol, value);}
	}

    /**
    Vertically aligns the elements within each line. Possible values: "ATOP", "ACENTER", 
    "ABOTTOM". Default: "ATOP". The alignment of a single line can also be set using 
    "ALIGNMENTLINL", where "L" is the line index, starting at 0 from top to bottom.
    */
    void setRowAlignment(int index, VerticalAlignment value) {
        setAttribute(IupAttributes.AlignmentLin ~ to!string(index), AlignmentIdentifiers.convert(value));
    }

    /// ditto
    VerticalAlignment getRowAlignment(int index) {
        string s = getAttribute(IupAttributes.AlignmentLin ~ to!string(index));
        return AlignmentIdentifiers.convertVerticalAlignment(s);
    }

    /**
    Horizontally aligns the elements within each column. Possible values: "ALEFT", "ACENTER",
    "ARIGHT". Default: "ALEFT". The alignment of a single column can also be set using 
    "ALIGNMENTCOLC", where "C" is the column index, starting at 0 from left to right.
    */
    void setColumnAlignment(int index, HorizontalAlignment value) {
        setAttribute(IupAttributes.AlignmentCol ~ to!string(index), AlignmentIdentifiers.convert(value));
    }

    /// ditto
    HorizontalAlignment getColumnAlignment(int index) {
        string s = getAttribute(IupAttributes.AlignmentCol ~ to!string(index));
        return AlignmentIdentifiers.convertHorizontalAlignment(s);
    }
}




/**
Creates void element, which dynamically occupies empty spaces always trying to expand itself. Its parent should be an IupHbox, 
an IupVbox or a IupGridBox, or else this type of expansion will not work. If an EXPAND is set on at least one of the other 
children of the box, then the fill expansion is ignored.

It does not have a native representation.
*/
public class IupFill : IupContainerControl
{
	protected class IupAttributes : super.IupAttributes
	{
        enum IupFill = "IupFill";
	}

	this()
	{
		super();
	}

	override protected Ihandle* createIupObject()
	{
		return iup.c.IupFill();
	}
}



/**
normalizes all children natural size to be the biggest natural size 
among the reference line and/or the reference column. 
All natural width will be set to the biggest width, and all natural 
height will be set to the biggest height according to is value. 
Can be NO, HORIZONTAL (width only), VERTICAL (height only) or BOTH.
Default: "NO". Same as using IupNormalizer. 
Notice that this is different from the HOMOGENEOUS* attributes in 
the sense that the children will have their sizes changed.
*/
enum SizeNormalizationStyle
{
    No,
    Horizontal,
    Vertical,
    Both
}


struct SizeNormalizationStyleIdentifiers
{
	enum No =	"NO";
	enum Horizontal  =	"HORIZONTAL";
	enum Vertical  =	"VERTICAL";
	enum Both  =	"BOTH";

    static SizeNormalizationStyle convert(string s)
    {
        switch(s)
        {
            case No:
                return SizeNormalizationStyle.No;

            case Horizontal:
                return SizeNormalizationStyle.Horizontal;

            case Vertical:
                return SizeNormalizationStyle.Vertical;

            case Both:
                return SizeNormalizationStyle.Both;

            default:
                assert(0, "Not supported");
        }
    }


    static string convert(SizeNormalizationStyle n)
    {
        final switch(n)
        {
            case SizeNormalizationStyle.No:
                return No;

            case SizeNormalizationStyle.Horizontal:
                return Horizontal;

            case SizeNormalizationStyle.Vertical:
                return Vertical;

            case SizeNormalizationStyle.Both:
                return Both;
        }
    }
}

