module iup.button;

import iup.canvas;
import iup.control;
import iup.core;
import iup.image;

import iup.c.core;
import iup.c.api;

import toolkit.event;
import toolkit.drawing;

import std.string;
import std.traits;


/**
*/
public interface IIupButton : IIupObject
{

}


/**
*/
public class IupButtonBase : IupStandardControl
{
	protected class IupAttributes : super.IupAttributes
	{
        enum Alignment = "ALIGNMENT";
        enum Flat = "FLAT";
        enum Image = "IMAGE";
        enum ImInactive = "IMINACTIVE";
        enum ImPress = "IMPRESS";
		enum ImagePosition = "IMAGEPOSITION";
        enum Markup = "MARKUP";
	}

    this()
	{
        super();
	}

	this(string title)
	{
        super(title);
	}


    /* ************* Properties *************** */

    version(GTK) {
        /**
        allows the title string to contains pango markup commands. Works only if a mnemonic is 
        NOT defined in the title. Can be "YES" or "NO". Default: "NO". 
        */
        @property 
        {
            public bool canMarkup () { return getAttribute(IupAttributes.Markup) == FlagIdentifiers.Yes; }

            public void canMarkup (bool value) 
            {
                setAttribute(IupAttributes.Markup, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }

    /**
    */
    @property 
    {
        public bool isFlat() { return getAttribute(IupAttributes.Flat) == FlagIdentifiers.Yes; }

        public void isFlat(bool value) 
        {
            setAttribute(IupAttributes.Flat, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
    }


    /**
    Image name. If set before map defines the behavior of the button to contain an image. 
    The natural size will be size of the image in pixels, plus the button borders. 
    Use IupSetHandle or IupSetAttributeHandle to associate an image to a name. 
    See also IupImage. If TITLE is also defined and not empty both will be shown (except in Motif). (GTK 2.6)
    */
    @property 
    {
        public string image() { return getAttribute(IupAttributes.Image); }

        public void image(string value) 
        {
            setAttribute(IupAttributes.Image, value);
        }

        public void image(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.Image, value);
        }
    }

    /**
    Image name of the element when inactive. If it is not defined then the IMAGE is used and the 
    colors will be replaced by a modified version of the background color creating the disabled 
    effect. GTK will also change the inactive image to look like other inactive objects. (GTK 2.6)
    */
    @property 
    {
        public string imageInactive() { return getAttribute(IupAttributes.ImInactive); }

        public void imageInactive(string value) 
        {
            setAttribute(IupAttributes.ImInactive, value);
        }

        public void imageInactive(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ImInactive, value);
        }
    }

    /**
    Image name of the pressed button. If IMPRESS and IMAGE are defined, the button borders are 
    not shown and not computed in natural size. When the button is clicked the pressed image 
    does not offset. In Motif the button will lose its focus feedback also. (GTK 2.6)
    */
    @property 
    {
        public string imagePressed() { return getAttribute(IupAttributes.ImPress); }

        public void imagePressed(string value) 
        {
            setAttribute(IupAttributes.ImPress, value);
        }

        public void imagePressed(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ImPress, value);
        }
    }

    /**
    Position of the image relative to the text when both are displayed. Can be: LEFT, RIGHT,
    TOP, BOTTOM. Default: LEFT. (since 3.0) (GTK 2.10)
    */
    @property 
    {
        public Position imagePosition() { 
            string c = getAttribute(IupAttributes.ImagePosition);
            return PositionIdentifiers.convert(c); 
        }

        public void imagePosition(Position value) {
            setStrAttribute(IupAttributes.ImagePosition, PositionIdentifiers.convert(value));
        }
    }
}


/**
Creates an interface element that is a button. When selected, this element activates a function
in the application. Its visual presentation can contain a text and/or an image.
*/
public class IupButton : IupButtonBase, IIupButton
{
	protected class IupCallbacks  : super.IupCallbacks
	{
		enum Button = "BUTTON_CB";
    }

	protected class IupAttributes : super.IupAttributes
	{
        enum IupButton = "IupButton";
	}

    this()
    {
        super();
    }

    this(string title)
    {
        super(title);
    }

    protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupButton(null, null);
	}


    protected override void onCreated()
    {    
        super.onCreated();
        registerClickCallback(IupCallbacks.Action);
    }   


    /* ************* Events *************** */

    mixin EventCallback!(IupButton, "click");


    /* ************* Properties *************** */

    /**
    horizontal and vertical alignment. Possible values: "ALEFT", "ACENTER" and "ARIGHT",  
    combined to "ATOP", "ACENTER" and "ABOTTOM". Default: "ACENTER:ACENTER". Partial values 
    are also accepted, like "ARIGHT" or ":ATOP", the other value will be used from the 
    current alignment. In Motif, vertical alignment is restricted to "ACENTER". In GTK, 
    horizontal alignment for multiple lines will align only the text block. (since 3.0)
    */
    @property 
    {
        public ContentAlignment textAlignment() { return m_textAlignment; }

        public void textAlignment(ContentAlignment value) 
        {
            m_textAlignment = value;
            setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
        }
        private ContentAlignment m_textAlignment; 
    }

}


/**
Creates an interface element that is a button, but it does not have native decorations. When
selected, this element activates a function in the application. Its visual presentation can 
contain a text and/or an image.

It behaves just like an IupButton, but since it is not a native control it has more flexibility
for additional options. It can also behave like an IupToggle (without the checkmark).
*/
public class IupFlatButton : IupCanvasBase
{
	protected class IupCallbacks : super.IupCallbacks
	{
		enum FlatAction = "FLAT_ACTION";
		enum ValueChanged = "VALUECHANGED_CB";
    }

	protected class IupAttributes : super.IupAttributes
	{
        enum IupFlatButton = "IupFlatButton";
        enum Alignment = "ALIGNMENT";
        enum BackImage = "BACKIMAGE";
        enum BackImageHighlight = "BACKIMAGEHIGHLIGHT";
        enum BackImageInactive = "BACKIMAGEINACTIVE";
        enum BackImagePress = "BACKIMAGEPRESS";
        enum BorderColor = "BORDERCOLOR";
        enum BorderPsColor = "BORDERPSCOLOR";
        enum BorderHlColor = "BORDERHLCOLOR";
        enum BorderWidth = "BORDERWIDTH";
        enum FitToBackImage = "FITTOBACKIMAGE";
        enum FrontImage = "FRONTIMAGE";
        enum FrontImageHighlight = "FRONTIMAGEHIGHLIGHT";
        enum FrontImageInactive = "FRONTIMAGEINACTIVE";
        enum FrontImagePress = "FRONTIMAGEPRESS";
        enum HlColor = "HLCOLOR";
        enum PsColor = "PSCOLOR";
        enum Image = "IMAGE";
        enum ImInactive = "IMINACTIVE";
        enum ImPress = "IMPRESS";
        enum ImagePosition = "IMAGEPOSITION";
        enum Radio = "RADIO";
        enum Spacing = "SPACING";
        enum Toggle = "TOGGLE";
	}


	this(){ super(); }

    this(string title)
    {
        super(title);
    }

    protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupFlatButton(null);
	}

    protected override void onCreated()
    {    
        super.onCreated();
        registerClickCallback(IupCallbacks.FlatAction);
    }   


    /* ************* Events *************** */

    mixin EventCallback!(IupFlatButton, "click");


    /* ************* Properties *************** */

    /**
    image name to be used as background. It will be zoomed to fill the background (it does not
    includes the border). Use IupSetHandle or IupSetAttributeHandle to associate an image to 
    a name. See also IupImage. 
    */
    @property 
    {
        public string backImage() { return getAttribute(IupAttributes.BackImage); }

        public void backImage(string value) 
        {
            setAttribute(IupAttributes.BackImage, value);
        }

        public void backImage(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.BackImage, value);
        }
    }

    /**
    background image name of the element in highlight state. If it is not defined then the 
    BACKIMAGE is used.
    */
    @property 
    {
        public string backImageHighlight() { return getAttribute(IupAttributes.BackImageHighlight); }

        public void backImageHighlight(string value) 
        {
            setAttribute(IupAttributes.BackImageHighlight, value);
        }

        public void backImageHighlight(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.BackImageHighlight, value);
        }
    }

    /**
    background image name of the element when inactive. If it is not defined then the BACKIMAGE 
    is used and its colors will be replaced by a modified version creating the disabled effect.
    */
    @property 
    {
        public string backImageInactive() { return getAttribute(IupAttributes.BackImageInactive); }

        public void backImageInactive(string value) 
        {
            setAttribute(IupAttributes.BackImageInactive, value);
        }

        public void backImageInactive(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.BackImageInactive, value);
        }
    }

    /**
    background image name of the element in pressed state. If it is not defined then the BACKIMAGE is used.
    */
    @property 
    {
        public string backImagePressed() { return getAttribute(IupAttributes.BackImagePress); }

        public void backImagePressed(string value) 
        {
            setAttribute(IupAttributes.BackImagePress, value);
        }

        public void backImagePressed(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.BackImagePress, value);
        }
    }

    /**
    color used for borders. Default: "50 150 255". This is for the IupFlatButton drawn border.
    */
    @property 
    {
        Color borderColor() { 
            string c = getAttribute(IupAttributes.BorderColor);
            return Color.parse(c); 
        }

        void borderColor(Color value)  { setAttribute(IupAttributes.BorderColor, value.toRgb()); }
    }

    /**
    color used for borders when pressed or selected. Default use BORDERCOLOR. (since 3.19)
    */
    @property 
    {
        Color borderPressedColor() { 
            string c = getAttribute(IupAttributes.BorderPsColor);
            return Color.parse(c); 
        }

        void borderPressedColor(Color value)  { setAttribute(IupAttributes.BorderPsColor, value.toRgb()); }
    }

    /**
    color used for borders when highlighted. Default use BORDERCOLOR. (since 3.19)
    */
    @property 
    {
        Color borderHighlightedColor() { 
            string c = getAttribute(IupAttributes.BorderHlColor);
            return Color.parse(c); 
        }

        void borderHighlightedColor(Color value)  { setAttribute(IupAttributes.BorderHlColor, value.toRgb()); }
    }

    /**
    line width used for borders. Default: "1". Any borders can be hidden by simply setting 
    this value to 0. This is for the IupFlatButton drawn border.*/
    @property 
	{
		public int borderWidth()  {  return getIntAttribute(IupAttributes.BorderWidth); }
        public void borderWidth(int value) { setIntAttribute(IupAttributes.BorderWidth, value);}
	}

    /**
    enable the natural size to be computed from the BACKIMAGE. If BACKIMAGE is not defined 
    will be ignored. When set to Yes it will set BORDERWIDTH to 0. Can be Yes or No. Default: No.
    */
    @property 
	{
		public bool canFitToBackImage() { return getAttribute(IupAttributes.FitToBackImage) == FlagIdentifiers.Yes; }

		public void canFitToBackImage(bool value) 
		{
            setAttribute(IupAttributes.FitToBackImage, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    image name to be used as foreground. It will be zoomed to fill the foreground (it does 
    not includes the border). The foreground has the same are as the background, but it is 
    drawn at last. Use IupSetHandle or IupSetAttributeHandle to associate an image to a 
    name. See also IupImage.
    */
    @property 
    {
        public string frontImage() { return getAttribute(IupAttributes.FrontImage); }

        public void frontImage(string value) 
        {
            setAttribute(IupAttributes.FrontImage, value);
        }

        public void frontImage(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.FrontImage, value);
        }
    }

    /**
    foreground image name of the element in highlight state. If it is not defined then the
    FRONTIMAGE is used.
    */
    @property 
    {
        public string frontImageHighlight() { return getAttribute(IupAttributes.FrontImageHighlight); }

        public void frontImageHighlight(string value) 
        {
            setAttribute(IupAttributes.FrontImageHighlight, value);
        }

        public void frontImageHighlight(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.FrontImageHighlight, value);
        }
    }

    /**
    foreground image name of the element when inactive. If it is not defined then the FRONTIMAGE
    is used and its colors will be replaced by a modified version creating the disabled effect.
    */
    @property 
    {
        public string frontImageInactive() { return getAttribute(IupAttributes.FrontImageInactive); }

        public void frontImageInactive(string value) 
        {
            setAttribute(IupAttributes.FrontImageInactive, value);
        }

        public void frontImageInactive(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.FrontImageInactive, value);
        }
    }

    /**
    foreground image name of the element in pressed state. If it is not defined then the 
    FRONTIMAGE is used.    
    */
    @property 
    {
        public string frontImagePressed() { return getAttribute(IupAttributes.FrontImagePress); }

        public void frontImagePressed(string value) 
        {
            setAttribute(IupAttributes.FrontImagePress, value);
        }

        public void frontImagePressed(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.FrontImagePress, value);
        }
    }

    /**
    color used to indicate a highlight state. Default: "200 225 245".
    */
    @property 
    {
        Color highlightColor() { 
            string c = getAttribute(IupAttributes.HlColor);
            return Color.parse(c); 
        }

        void highlightColor(Color value)  { setAttribute(IupAttributes.HlColor, value.toRgb()); }
    }


    /**
    Image name. If set before map defines the behavior of the button to contain an image. 
    The natural size will be size of the image in pixels, plus the button borders. 
    Use IupSetHandle or IupSetAttributeHandle to associate an image to a name. 
    See also IupImage. If TITLE is also defined and not empty both will be shown (except in Motif). (GTK 2.6)
    */
    @property 
    {
        public string image() { return getAttribute(IupAttributes.Image); }

        public void image(string value) 
        {
            setAttribute(IupAttributes.Image, value);
        }

        public void image(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.Image, value);
        }
    }

    /**
    Image name of the element when inactive. If it is not defined then the IMAGE is used and the 
    colors will be replaced by a modified version of the background color creating the disabled 
    effect. GTK will also change the inactive image to look like other inactive objects. (GTK 2.6)
    */
    @property 
    {
        public string imageInactive() { return getAttribute(IupAttributes.ImInactive); }

        public void imageInactive(string value) 
        {
            setAttribute(IupAttributes.ImInactive, value);
        }

        public void imageInactive(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ImInactive, value);
        }
    }

    /**
    Image name of the pressed button. If IMPRESS and IMAGE are defined, the button borders are 
    not shown and not computed in natural size. When the button is clicked the pressed image 
    does not offset. In Motif the button will lose its focus feedback also. (GTK 2.6)
    */
    @property 
    {
        public string imagePressed() { return getAttribute(IupAttributes.ImPress); }

        public void imagePressed(string value) 
        {
            setAttribute(IupAttributes.ImPress, value);
        }

        public void imagePressed(iup.image.IupImage value) 
        {
            setHandleAttribute(IupAttributes.ImPress, value);
        }
    }


    /**
    Position of the image relative to the text when both are displayed. Can be: LEFT, RIGHT,
    TOP, BOTTOM. Default: LEFT. (since 3.0) (GTK 2.10)
    */
    @property 
    {
        public Position imagePosition() { 
            string c = getAttribute(IupAttributes.ImagePosition);
            return PositionIdentifiers.convert(c); }

        public void imagePosition(Position value) 
        {
            setStrAttribute(IupAttributes.ImagePosition, PositionIdentifiers.convert(value));
        }
    }

    /**
    Toggle's state. Values can be "ON", "OFF" or "TOGGLE". Default: "OFF". The TOGGLE option 
    will invert the current state. Valid only when TOGGLE=Yes. Can only be set to Yes for a 
    toggle inside a radio, it will automatically set to OFF the previous toggle that was ON.
    */
    @property 
    {
        public bool isChecked()  {  
            return getAttribute(IupAttributes.Value) == ToggleStateIdentifiers.On;
        }

        public void isChecked(bool value) 
        { 
            setAttribute(IupAttributes.Value, value ? ToggleStateIdentifiers.On : ToggleStateIdentifiers.Off);
        }
    }

    /**
    returns if the toggle is inside a radio. Can be "YES" or "NO". Valid only after the element
    is mapped and TOGGLE=Yes, before returns NULL.
    */
    @property 
	{
		public bool isRadioItem() { return getAttribute(IupAttributes.Radio) == FlagIdentifiers.Yes; }
	}

    /**
    enabled the toggle behavior. Default: NO.
    */
    @property 
	{
		public bool isToggle() { return getAttribute(IupAttributes.Toggle) == FlagIdentifiers.Yes; }

		public void isToggle(bool value) 
		{
            setAttribute(IupAttributes.Toggle, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
		}
	}

    /**
    color used to indicate a press state. Default: "150 200 235".
    */
    @property 
    {
        Color pressColor() { 
            string c = getAttribute(IupAttributes.PsColor);
            return Color.parse(c); 
        }

        void pressColor(Color value)  { setAttribute(IupAttributes.PsColor, value.toRgb()); }
    }

    /**
    defines the spacing between the image associated and the button's text. Default: "2".
    */
    @property 
	{
		public int spacing()  {  return getIntAttribute(IupAttributes.Spacing); }
        public void spacing(int value) { setIntAttribute(IupAttributes.Spacing, value);}
	}

    /**
    horizontal and vertical alignment. Possible values: "ALEFT", "ACENTER" and "ARIGHT",  
    combined to "ATOP", "ACENTER" and "ABOTTOM". Default: "ACENTER:ACENTER". Partial values 
    are also accepted, like "ARIGHT" or ":ATOP", the other value will be used from the 
    current alignment. In Motif, vertical alignment is restricted to "ACENTER". In GTK, 
    horizontal alignment for multiple lines will align only the text block. (since 3.0)
    */
    @property 
    {
        // TODO:
        public ContentAlignment textAlignment() { return m_textAlignment; }

        public void textAlignment(ContentAlignment value) 
        {
            m_textAlignment = value;
            setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
        }
        private ContentAlignment m_textAlignment; 
    }

}


/**
Creates the toggle interface element. It is a two-state (on/off) button that, when selected, 
generates an action that activates a function in the associated application. Its visual 
representation can contain a text or an image.
*/
public class IupToggleButton : IupButtonBase
{

	protected class IupAttributes : super.IupAttributes
	{
        enum IupToggleButton = "IupToggleButton";
        enum RightButton = "RIGHTBUTTON";
        enum ThreeState = "3STATE";
	}

    this() { super(); }

	this(string title)
	{
        super(title);
	}

    /* ************* Protected methods *************** */

    protected override Ihandle* createIupObject()
	{
		return iup.c.api.IupToggle(null, null);
	}


    protected override void onCreated()
    {    
        super.onCreated();
        registerCheckedCallback(IupCallbacks.Action);
    }   


    /* ************* Events *************** */

    /**
    state: 1 if the toggle's state was shifted to ON; 0 if it was shifted to OFF. If 
    SHOW3STATE=YES, −1 if it was shifted to NOTDEF.
    */
    public EventHandler!(CallbackEventArgs, ToggleState)  checked;
    mixin EventCallbackAdapter!(IupToggleButton, "checked", int);

    private CallbackResult onChecked(int state) nothrow
    {
        CallbackResult r = CallbackResult.Default;
        try
        {
            auto callbackArgs = new CallbackEventArgs();
            checked(this, callbackArgs, cast(ToggleState)state);
            r = callbackArgs.result;
        }
        catch(Exception ex) { /* do nothing. */ }

        return r;
    }


    /* ************* Properties *************** */


    /**
    Toggle's state. Values can be "ON", "OFF" or "TOGGLE". If 3STATE=YES then can also be "NOTDEF". Default: "OFF". 
    The TOGGLE option will invert the current state (since 3.7). 
    In GTK if you change the state of a radio, the unchecked toggle will receive an ACTION callback notification. 
    Can only be set to Yes for a toggle inside a radio, it will automatically set to OFF the previous toggle that was ON.
    */
    @property 
    {
        public bool isChecked()  {  
            return toggleState == ToggleState.On;
        }

        public void isChecked(bool value) { 
            if(value)
                toggleState = ToggleState.On;
            else
                toggleState = ToggleState.Off;
        }
    }

    /// ditto
    @property 
    {
        public ToggleState toggleState()  {  
            string v = getAttribute(IupAttributes.Value);
            return ToggleStateIdentifiers.convert(v);
        }
    }

    /// ditto
    @property 
    {
        public void toggleState(ToggleState value) { 
            setAttribute(IupAttributes.Value, ToggleStateIdentifiers.convert(value));
        }
    }

    version(Windows)
    {
        /**
        place the check button at the right of the text. Can be "YES" or "NO". Default: "NO".
        */
        @property 
        {
            public bool hasRightButton()  {  
                return getAttribute(IupAttributes.RightButton) == FlagIdentifiers.Yes; 
            }

            public void hasRightButton(bool value) { 
                setAttribute(IupAttributes.RightButton, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
            }
        }
    }


    /**
    horizontal and vertical alignment when IMAGE is defined. Possible values: "ALEFT",
    "ACENTER" and "ARIGHT",  combined to "ATOP", "ACENTER" and "ABOTTOM". Default: 
    "ACENTER:ACENTER". Partial values are also accepted, like "ARIGHT" or ":ATOP", 
    the other value will be used from the current alignment. In Motif, vertical 
    alignment is restricted to "ACENTER". In Windows works only when Visual Styles 
    is active. Text is always left aligned. (since 3.0)

    // BUG: must set isFlat to true.
    */
    @property 
    {
        public ContentAlignment imageAlignment() { return m_imageAlignment; }

        public void imageAlignment(ContentAlignment value) 
        {
            m_imageAlignment = value;
            setAttribute(IupAttributes.Alignment, AlignmentIdentifiers.convert(value));
        }
        private ContentAlignment m_imageAlignment; 
    }

    /**
    Enable a three state toggle. Valid for toggles with text only and that do not belong to a radio. 
    Can be "YES" or NO". Default: "NO".
    */
    @property 
	{
		public bool isThreeState()  {  return getAttribute(IupAttributes.ThreeState) == FlagIdentifiers.Yes; }

        public void isThreeState(bool value) { 
            setAttribute(IupAttributes.ThreeState, value ? FlagIdentifiers.Yes : FlagIdentifiers.No);
        }
	}

}

alias IupToggle = IupToggleButton;

/**
*/
class IupCheckBox : IupToggleButton
{
    this() { super(); }

	this(string title)
	{
        super(title);
	}
}


/**
*/
class IupRadioButton : IupToggleButton
{
    this() { super(); }

	this(string title)
	{
        super(title);
	}
}
