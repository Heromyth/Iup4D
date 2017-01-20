
/** \file
* \brief User API
* IUP - A Portable User Interface Toolkit
* Tecgraf: Computer Graphics Technology Group, PUC-Rio, Brazil
* http://www.tecgraf.puc-rio.br/iup  mailto:iup@tecgraf.puc-rio.br
*
* See Copyright Notice at the end of this file
*/

module iup.c.api;

import iup.c.core;

version(Windows) { 
    pragma(lib, "iup.lib");
    pragma(lib, "iupimglib.lib"); // required only if function IupImageLibOpen() is called
    pragma(lib, "iupcontrols.lib"); // libiupcontrols.so depends on libiup.so, libiupcd.so, libcd.so, ...
}

extern(C) @nogc nothrow {

    /************************************************************************/
    /*                        Main API                                      */
    /************************************************************************/

    int       IupOpen          (int* argc, char*** argv);
    void      IupClose         ();
    void      IupImageLibOpen  (); // libiupimglib.so

    int       IupMainLoop      ();
    int       IupLoopStep      ();
    int       IupLoopStepWait  ();
    int       IupMainLoopLevel ();
    void      IupFlush         ();
    void      IupExitLoop      ();

    int       IupRecordInput(const(char)* filename, int mode);
    int       IupPlayInput(const(char)* filename);

    void      IupUpdate        (Ihandle* ih);
    void      IupUpdateChildren(Ihandle* ih);
    void      IupRedraw        (Ihandle* ih, int children);
    void      IupRefresh       (Ihandle* ih);
    void      IupRefreshChildren(Ihandle* ih);

    int       IupExecute       (const(char)* filename, const(char)* parameters);
    int       IupHelp          (const(char)* url);
    char*     IupLoad          (const(char)* filename);
    char*     IupLoadBuffer    (const(char)* buffer);

    char*     IupVersion       ();
    char*     IupVersionDate   ();
    int       IupVersionNumber ();

    void      IupSetLanguage   (const(char)* lng);
    char*     IupGetLanguage   ();
    void      IupSetLanguageString(const(char)* name, const(char)* str);
    void      IupStoreLanguageString(const(char)* name, const(char)* str);
    char*     IupGetLanguageString(const(char)* name);
    void      IupSetLanguagePack(Ihandle* ih);

    void      IupDestroy       (Ihandle* ih);
    void      IupDetach        (Ihandle* child);
    Ihandle*  IupAppend        (Ihandle* ih, Ihandle* child);
    Ihandle*  IupInsert        (Ihandle* ih, Ihandle* ref_child, Ihandle* child);
    Ihandle*  IupGetChild      (Ihandle* ih, int pos);
    int       IupGetChildPos   (Ihandle* ih, Ihandle* child);
    int       IupGetChildCount (Ihandle* ih);
    Ihandle*  IupGetNextChild  (Ihandle* ih, Ihandle* child);
    Ihandle*  IupGetBrother    (Ihandle* ih);
    Ihandle*  IupGetParent     (Ihandle* ih);
    Ihandle*  IupGetDialog     (Ihandle* ih);
    Ihandle*  IupGetDialogChild(Ihandle* ih, const(char)* name);
    int       IupReparent      (Ihandle* ih, Ihandle* new_parent, Ihandle* ref_child);

    int       IupPopup         (Ihandle* ih, int x, int y);
    int       IupShow          (Ihandle* ih);
    int       IupShowXY        (Ihandle* ih, int x, int y);
    int       IupHide          (Ihandle* ih);
    int       IupMap           (Ihandle* ih);
    void      IupUnmap         (Ihandle* ih);

    void      IupResetAttribute(Ihandle* ih, const(char)* name);
    int       IupGetAllAttributes(Ihandle* ih, char** names, int n);
    Ihandle*  IupSetAtt(const(char)* handle_name, Ihandle* ih, const(char)* name, ...);
    Ihandle*  IupSetAttributes (Ihandle* ih, const(char)* str);
    char*     IupGetAttributes (Ihandle* ih);

    void      IupSetAttribute   (Ihandle* ih, const(char)* name, const(char)* value);
    void      IupSetStrAttribute(Ihandle* ih, const(char)* name, const(char)* value);
    void      IupSetStrf        (Ihandle* ih, const(char)* name, const(char)* format, ...);
    void      IupSetInt         (Ihandle* ih, const(char)* name, int value);
    void      IupSetFloat       (Ihandle* ih, const(char)* name, float value);
    void      IupSetDouble      (Ihandle* ih, const(char)* name, double value);
    void      IupSetRGB         (Ihandle* ih, const(char)* name, ubyte r, ubyte g, ubyte b);

    char*     IupGetAttribute(Ihandle* ih, const(char)* name);
    int       IupGetInt      (Ihandle* ih, const(char)* name);
    int       IupGetInt2     (Ihandle* ih, const(char)* name);
    int       IupGetIntInt   (Ihandle* ih, const(char)* name, int* i1, int* i2);
    float     IupGetFloat    (Ihandle* ih, const(char)* name);
    double    IupGetDouble   (Ihandle* ih, const(char)* name);
    void      IupGetRGB      (Ihandle* ih, const(char)* name, ubyte* r, ubyte* g, ubyte* b);

    void  IupSetAttributeId(Ihandle* ih, const(char)* name, int id, const(char)* value);
    void  IupSetStrAttributeId(Ihandle* ih, const(char)* name, int id, const(char)* value);
    void  IupSetStrfId(Ihandle* ih, const(char)* name, int id, const(char)* format, ...);
    void  IupSetIntId(Ihandle* ih, const(char)* name, int id, int value);
    void  IupSetFloatId(Ihandle* ih, const(char)* name, int id, float value);
    void  IupSetDoubleId(Ihandle* ih, const(char)* name, int id, double value);
    void  IupSetRGBId(Ihandle* ih, const(char)* name, int id, ubyte r, ubyte g, ubyte b);

    char*  IupGetAttributeId(Ihandle* ih, const(char)* name, int id);
    int    IupGetIntId(Ihandle* ih, const(char)* name, int id);
    float  IupGetFloatId(Ihandle* ih, const(char)* name, int id);
    double IupGetDoubleId(Ihandle* ih, const(char)* name, int id);
    void   IupGetRGBId(Ihandle* ih, const(char)* name, int id, ubyte* r, ubyte* g, ubyte* b);

    void  IupSetAttributeId2(Ihandle* ih, const(char)* name, int lin, int col, const(char)* value);
    void  IupSetStrAttributeId2(Ihandle* ih, const(char)* name, int lin, int col, const(char)* value);
    void  IupSetStrfId2(Ihandle* ih, const(char)* name, int lin, int col, const(char)* format, ...);
    void  IupSetIntId2(Ihandle* ih, const(char)* name, int lin, int col, int value);
    void  IupSetFloatId2(Ihandle* ih, const(char)* name, int lin, int col, float value);
    void  IupSetDoubleId2(Ihandle* ih, const(char)* name, int lin, int col, double value);
    void  IupSetRGBId2(Ihandle* ih, const(char)* name, int lin, int col, ubyte r, ubyte g, ubyte b);

    char*  IupGetAttributeId2(Ihandle* ih, const(char)* name, int lin, int col);
    int    IupGetIntId2(Ihandle* ih, const(char)* name, int lin, int col);
    float  IupGetFloatId2(Ihandle* ih, const(char)* name, int lin, int col);
    double IupGetDoubleId2(Ihandle* ih, const(char)* name, int lin, int col);
    void   IupGetRGBId2(Ihandle* ih, const(char)* name, int lin, int col, ubyte* r, ubyte* g, ubyte* b);

    void      IupSetGlobal  (const(char)* name, const(char)* value);
    void      IupSetStrGlobal(const(char)* name, const(char)* value);
    char*     IupGetGlobal  (const(char)* name);

    Ihandle*  IupSetFocus     (Ihandle* ih);
    Ihandle*  IupGetFocus     ();
    Ihandle*  IupPreviousField(Ihandle* ih);
    Ihandle*  IupNextField    (Ihandle* ih);

    Icallback IupGetCallback (Ihandle* ih, const(char)* name);
    Icallback IupSetCallback (Ihandle* ih, const(char)* name, Icallback func);
    Ihandle*  IupSetCallbacks(Ihandle* ih, const(char)* name, Icallback func, ...);

    Icallback IupGetFunction(const(char)* name);
    Icallback IupSetFunction(const(char)* name, Icallback func);

    Ihandle*  IupGetHandle    (const(char)* name);
    Ihandle*  IupSetHandle    (const(char)* name, Ihandle* ih);
    int       IupGetAllNames  (char** names, int n);
    int       IupGetAllDialogs(char** names, int n);
    char*     IupGetName      (Ihandle* ih);

    void      IupSetAttributeHandle(Ihandle* ih, const(char)* name, Ihandle* ih_named);
    Ihandle*  IupGetAttributeHandle(Ihandle* ih, const(char)* name);

    char*     IupGetClassName(Ihandle* ih);
    char*     IupGetClassType(Ihandle* ih);
    int       IupGetAllClasses(char** names, int n);
    int       IupGetClassAttributes(const(char)* classname, char** names, int n);
    int       IupGetClassCallbacks(const(char)* classname, char** names, int n);
    void      IupSaveClassAttributes(Ihandle* ih);
    void      IupCopyClassAttributes(Ihandle* src_ih, Ihandle* dst_ih);
    void      IupSetClassDefaultAttribute(const(char)* classname, const(char)* name, const(char)* value);
    int       IupClassMatch(Ihandle* ih, const(char)* classname);

    Ihandle*  IupCreate (const(char)* classname);
    Ihandle*  IupCreatev(const(char)* classname, void** params);
    Ihandle*  IupCreatep(const(char)* classname, void* first, ...);

    /************************************************************************/
    /*                        Elements                                      */
    /************************************************************************/

    Ihandle*  IupFill       ();
    Ihandle*  IupRadio      (Ihandle* child);
    Ihandle*  IupVbox       (Ihandle* child, ...);
    Ihandle*  IupVboxv      (Ihandle** children);
    Ihandle*  IupZbox       (Ihandle* child, ...);
    Ihandle*  IupZboxv      (Ihandle** children);
    Ihandle*  IupHbox       (Ihandle* child,...);
    Ihandle*  IupHboxv      (Ihandle** children);

    Ihandle*  IupNormalizer (Ihandle* ih_first, ...);
    Ihandle*  IupNormalizerv(Ihandle** ih_list);

    Ihandle*  IupCbox       (Ihandle* child, ...);
    Ihandle*  IupCboxv      (Ihandle** children);
    Ihandle*  IupSbox       (Ihandle* child);
    Ihandle*  IupSplit      (Ihandle* child1, Ihandle* child2);
    Ihandle*  IupScrollBox  (Ihandle* child);
    Ihandle*  IupGridBox    (Ihandle* child, ...);
    Ihandle*  IupGridBoxv   (Ihandle** children);
    Ihandle*  IupExpander   (Ihandle* child);
    Ihandle*  IupDetachBox  (Ihandle* child);
    Ihandle*  IupBackgroundBox(Ihandle* child);

    Ihandle*  IupFrame      (Ihandle* child);

    Ihandle*  IupImage      (int width, int height, const(ubyte)* pixmap);
    Ihandle*  IupImageRGB   (int width, int height, const(ubyte)* pixmap);
    Ihandle*  IupImageRGBA  (int width, int height, const(ubyte)* pixmap);

    Ihandle*  IupItem       (const(char)* title, const(char)* action);
    Ihandle*  IupSubmenu    (const(char)* title, Ihandle* child);
    Ihandle*  IupSeparator  ();
    Ihandle*  IupMenu       (Ihandle* child,...);
    Ihandle*  IupMenuv      (Ihandle** children);

    Ihandle*  IupButton     (const(char)* title, const(char)* action);
    Ihandle*  IupCanvas     (const(char)* action);
    Ihandle*  IupDialog     (Ihandle* child);
    Ihandle*  IupUser       ();
    Ihandle*  IupLabel      (const(char)* title);
    Ihandle*  IupList       (const(char)* action);
    Ihandle*  IupText       (const(char)* action);
    Ihandle*  IupMultiLine  (const(char)* action);
    Ihandle*  IupToggle     (const(char)* title, const(char)* action);
    Ihandle*  IupTimer      ();
    Ihandle*  IupClipboard  ();
    Ihandle*  IupProgressBar();
    Ihandle*  IupVal        (const(char)* type);
    Ihandle*  IupTabs       (Ihandle* child, ...);
    Ihandle*  IupTabsv      (Ihandle** children);
    Ihandle*  IupTree       ();
    Ihandle*  IupLink       (const(char)* url, const(char)* title);
    Ihandle*  IupFlatButton (const(char)* title);
    Ihandle*  IupAnimatedLabel(Ihandle* animation);
    Ihandle*  IupDatePick   ();
    Ihandle*  IupCalendar   ();

    /* Old controls, use SPIN attribute of IupText */
    Ihandle*  IupSpin       ();
    Ihandle*  IupSpinbox    (Ihandle* child);


    /************************************************************************/
    /*                      Utilities                                       */
    /************************************************************************/

    /* String compare utility */
    int  IupStringCompare(const(char)* str1, const(char)* str2, int casesensitive, int lexicographic);

    /* IupImage utility */
    int  IupSaveImageAsText(Ihandle* ih, const(char)* file_name, const(char)* format, const(char)* name);

    /* IupText and IupScintilla utilities */
    void IupTextConvertLinColToPos(Ihandle* ih, int lin, int col, int* pos);
    void IupTextConvertPosToLinCol(Ihandle* ih, int pos, int* lin, int* col);

    /* IupText, IupList, IupTree, IupMatrix and IupScintilla utility */
    int  IupConvertXYToPos(Ihandle* ih, int x, int y);

    /* OLD names, kept for backward compatibility, will never be removed. */
    void IupStoreGlobal(const(char)* name, const(char)* value);
    void IupStoreAttribute(Ihandle* ih, const(char)* name, const(char)* value);
    void IupSetfAttribute(Ihandle* ih, const(char)* name, const(char)* format, ...);
    void IupStoreAttributeId(Ihandle* ih, const(char)* name, int id, const(char)* value);
    void IupSetfAttributeId(Ihandle* ih, const(char)* name, int id, const(char)* f, ...);
    void IupStoreAttributeId2(Ihandle* ih, const(char)* name, int lin, int col, const(char)* value);
    void IupSetfAttributeId2(Ihandle* ih, const(char)* name, int lin, int col, const(char)* format, ...);

    /* IupTree utilities */
    int   IupTreeSetUserId(Ihandle* ih, int id, void* userid);
    void* IupTreeGetUserId(Ihandle* ih, int id);
    int   IupTreeGetId(Ihandle* ih, void* userid);
    void  IupTreeSetAttributeHandle(Ihandle* ih, const(char)* name, int id, Ihandle* ih_named);

    /************************************************************************/
    /*                      Pre-definided dialogs                           */
    /************************************************************************/

    Ihandle* IupFileDlg();
    Ihandle* IupMessageDlg();
    Ihandle* IupColorDlg();
    Ihandle* IupFontDlg();
    Ihandle* IupProgressDlg();

    int  IupGetFile(char* arq);
    void IupMessage(const(char)* title, const(char)* msg);
    void IupMessagef(const(char)* title, const(char)* format, ...);
    int  IupAlarm(const(char)* title, const(char)* msg, const(char)* b1, const(char)* b2, const(char)* b3);
    int  IupScanf(const(char)* format, ...);
    int  IupListDialog(int type, const(char)* title, int size, const(char)** list,
                       int op, int max_col, int max_lin, int* marks);
    int  IupGetText(const(char)* title, char* text, int maxsize);

    /* 
    r, g, b: Pointers to variables that will receive the color selected by the 
    user if the OK button is pressed. The value in the variables at the moment the 
    function is called defines the color being selected when the dialog is shown. 
    If the OK button is not pressed, the r, g and b values are not changed. 
    */
    int  IupGetColor(int x, int y, ubyte* r, ubyte* g, ubyte* b);

    //alias Iparamcb = int function(Ihandle* dialog, int param_index, void* user_data) nothrow;
    int IupGetParam(const(char)* title, Iparamcb action, void* user_data, const(char)* format,...);
    int IupGetParamv(const(char)* title, Iparamcb action, void* user_data, const(char)* format, int param_count, int param_extra, void** param_data);
    Ihandle* IupParam(const(char)* format);
    Ihandle*  IupParamBox(Ihandle* child, ...);
    Ihandle*  IupParamBoxv(Ihandle** children);

    Ihandle* IupLayoutDialog(Ihandle* dialog);
    Ihandle* IupElementPropertiesDialog(Ihandle* elem);


    /************************************************************************/
    /*                                Config                                */
    /************************************************************************/

    Ihandle* IupConfig();

    int IupConfigLoad(Ihandle* ih);
    int IupConfigSave(Ihandle* ih);

    /****************************************************************/

    void IupConfigSetVariableStr(Ihandle* ih, const(char)* group, const(char)* key, const(char)* value);
    void IupConfigSetVariableStrId(Ihandle* ih, const(char)* group, const(char)* key, int id, const(char)* value);
    void IupConfigSetVariableInt(Ihandle* ih, const(char)* group, const(char)* key, int value);
    void IupConfigSetVariableIntId(Ihandle* ih, const(char)* group, const(char)* key, int id, int value);
    void IupConfigSetVariableDouble(Ihandle* ih, const(char)* group, const(char)* key, double value);
    void IupConfigSetVariableDoubleId(Ihandle* ih, const(char)* group, const(char)* key, int id, double value);

    const(char)* IupConfigGetVariableStr(Ihandle* ih, const(char)* group, const(char)* key);
    const(char)* IupConfigGetVariableStrId(Ihandle* ih, const(char)* group, const(char)* key, int id);
    int    IupConfigGetVariableInt(Ihandle* ih, const(char)* group, const(char)* key);
    int    IupConfigGetVariableIntId(Ihandle* ih, const(char)* group, const(char)* key, int id);
    double IupConfigGetVariableDouble(Ihandle* ih, const(char)* group, const(char)* key);
    double IupConfigGetVariableDoubleId(Ihandle* ih, const(char)* group, const(char)* key, int id);

    const(char)* IupConfigGetVariableStrDef(Ihandle* ih, const(char)* group, const(char)* key, const(char)* def);
    const(char)* IupConfigGetVariableStrIdDef(Ihandle* ih, const(char)* group, const(char)* key, int id, const(char)* def);
    int    IupConfigGetVariableIntDef(Ihandle* ih, const(char)* group, const(char)* key, int def);
    int    IupConfigGetVariableIntIdDef(Ihandle* ih, const(char)* group, const(char)* key, int id, int def);
    double IupConfigGetVariableDoubleDef(Ihandle* ih, const(char)* group, const(char)* key, double def);
    double IupConfigGetVariableDoubleIdDef(Ihandle* ih, const(char)* group, const(char)* key, int id, double def);

    /****************************************************************/

    void IupConfigRecentInit(Ihandle* ih, Ihandle* menu, Icallback recent_cb, int max_recent);
    void IupConfigRecentUpdate(Ihandle* ih, const(char)* filename);

    void IupConfigDialogShow(Ihandle* ih, Ihandle* dialog, const(char)* name);
    void IupConfigDialogClosed(Ihandle* ih, Ihandle* dialog, const(char)* name);

    char* iupKeyCodeToName(int code); 


    /************************** Iup Controls **************************/

    int  IupControlsOpen();

    Ihandle* IupColorbar();
    Ihandle* IupCells();
    Ihandle* IupColorBrowser();
    Ihandle* IupGauge();
    Ihandle* IupDial(const(char)* type);
    Ihandle* IupMatrix(const(char)* action);
    Ihandle* IupMatrixList();


    /************************ Canvas Draw API ************************/

    /* all functions can be used only in IUP canvas and inside the ACTION callback */

    void IupDrawBegin(Ihandle* ih);
    void IupDrawEnd(Ihandle* ih);

    /* all primitives can be called only between calls to Begin and End */

    void IupDrawSetClipRect(Ihandle* ih, int x1, int y1, int x2, int y2);
    void IupDrawResetClip(Ihandle* ih);

    /* color controlled by the attribute DRAWCOLOR */
    /* line style or fill controlled by the attribute DRAWSTYLE */

    void IupDrawParentBackground(Ihandle* ih);
    void IupDrawLine(Ihandle* ih, int x1, int y1, int x2, int y2);
    void IupDrawRectangle(Ihandle* ih, int x1, int y1, int x2, int y2);
    void IupDrawArc(Ihandle* ih, int x1, int y1, int x2, int y2, double a1, double a2);
    void IupDrawPolygon(Ihandle* ih, int* points, int count);
    void IupDrawText(Ihandle* ih, const(char)* text, int len, int x, int y);
    void IupDrawImage(Ihandle* ih, const(char)* name, int make_inactive, int x, int y);
    void IupDrawSelectRect(Ihandle* ih, int x1, int y1, int x2, int y2);
    void IupDrawFocusRect(Ihandle* ih, int x1, int y1, int x2, int y2);

    void IupDrawGetSize(Ihandle* ih, int *w, int *h);
    void IupDrawGetTextSize(Ihandle* ih, const(char)* str, int *w, int *h);
    void IupDrawGetImageInfo(const(char)* name, int *w, int *h, int *bpp);


} // extern(C) @nogc nothrow

/************************************************************************/
/*                   Common Flags and Return Values                     */
/************************************************************************/
enum {
	IUP_ERROR      =   1,
	IUP_NOERROR    =   0,
	IUP_OPENED     =  -1,
	IUP_INVALID    =  -1,
	IUP_INVALID_ID = -10,
}

/************************************************************************/
/*                   Callback Return Values                             */
/************************************************************************/
enum {
	IUP_IGNORE    = -1,
	IUP_DEFAULT   = -2,
	IUP_CLOSE     = -3,
	IUP_CONTINUE  = -4,
}

/************************************************************************/
/*           IupPopup and IupShowXY Parameter Values                    */
/************************************************************************/
enum {
	IUP_CENTER        = 0xFFFF,  /* 65535 */
	IUP_LEFT          = 0xFFFE,  /* 65534 */
	IUP_RIGHT         = 0xFFFD,  /* 65533 */
	IUP_MOUSEPOS      = 0xFFFC,  /* 65532 */
	IUP_CURRENT       = 0xFFFB,  /* 65531 */
	IUP_CENTERPARENT  = 0xFFFA,  /* 65530 */
	IUP_TOP       = IUP_LEFT,
	IUP_BOTTOM    = IUP_RIGHT,
}

/************************************************************************/
/*               SHOW_CB Callback Values                                */
/************************************************************************/
enum {IUP_SHOW, IUP_RESTORE, IUP_MINIMIZE, IUP_MAXIMIZE, IUP_HIDE};

/************************************************************************/
/*               SCROLL_CB Callback Values                              */
/************************************************************************/
enum {IUP_SBUP,   IUP_SBDN,    IUP_SBPGUP,   IUP_SBPGDN,    IUP_SBPOSV, IUP_SBDRAGV,
IUP_SBLEFT, IUP_SBRIGHT, IUP_SBPGLEFT, IUP_SBPGRIGHT, IUP_SBPOSH, IUP_SBDRAGH};

/************************************************************************/
/*               Mouse Button Values and Macros                         */
/************************************************************************/
enum : char {
	IUP_BUTTON1   = '1',
	IUP_BUTTON2   = '2',
	IUP_BUTTON3   = '3',
	IUP_BUTTON4   = '4',
	IUP_BUTTON5   = '5',
}

bool iup_isshift(string _s) {
	if (_s.length > 0)
		return _s[0] == 'S';
	return false;
}

bool iup_iscontrol(string _s){
	if (_s.length > 1)
		return _s[1]=='C';
	return false;
}

bool iup_isbutton1(string _s){
	if (_s.length > 2)
		return _s[2]=='1';
	return false;
}

bool iup_isbutton2(string _s){
	if (_s.length > 3)
		return _s[3]=='2';
	return false;
}

bool iup_isbutton3(string _s){
	if (_s.length > 4)
		return _s[4]=='3';
	return false;
}

bool iup_isdouble(string _s){
	if (_s.length > 5)
		return _s[5]=='D';
	return false;
}

bool iup_isalt(string _s){
	if (_s.length > 6)
		return _s[6]=='A';
	return false;
}

bool iup_issys(string _s){
	if (_s.length > 7)
		return _s[7]=='Y';
	return false;
}

bool iup_isbutton4(string _s){
	if (_s.length > 8)
		return _s[8]=='4';
	return false;
}

bool iup_isbutton5(string _s){
	if (_s.length > 9)
		return _s[9]=='5';
	return false;
}

/* Old definitions for backward compatibility */
alias isshift     = iup_isshift;
alias iscontrol   = iup_iscontrol;
alias isbutton1   = iup_isbutton1;
alias isbutton2   = iup_isbutton2;
alias isbutton3   = iup_isbutton3;
alias isdouble    = iup_isdouble;
alias isalt       = iup_isalt;
alias issys       = iup_issys;
alias isbutton4   = iup_isbutton4;
alias isbutton5   = iup_isbutton5;


/************************************************************************/
/*                      Pre-Defined Masks                               */
/************************************************************************/
const(char)* IUP_MASK_FLOAT       = "[+/-]?(/d+/.?/d*|/./d+)";
const(char)* IUP_MASK_UFLOAT            = "(/d+/.?/d*|/./d+)";
const(char)* IUP_MASK_EFLOAT      = "[+/-]?(/d+/.?/d*|/./d+)([eE][+/-]?/d+)?";
const(char)* IUP_MASK_FLOATCOMMA  = "[+/-]?(/d+/,?/d*|/,/d+)";
const(char)* IUP_MASK_UFLOATCOMMA =       "(/d+/,?/d*|/,/d+)";
const(char)* IUP_MASK_INT         =  "[+/-]?/d+";
const(char)* IUP_MASK_UINT        =        "/d+";

/* Old definitions for backward compatibility */
alias IUPMASK_FLOAT     = IUP_MASK_FLOAT;
alias IUPMASK_UFLOAT    = IUP_MASK_UFLOAT;
alias IUPMASK_EFLOAT    = IUP_MASK_EFLOAT;
alias IUPMASK_INT       = IUP_MASK_INT;
alias IUPMASK_UINT      = IUP_MASK_UINT;


/************************************************************************/
/*                   IupGetParam Callback situations                    */
/************************************************************************/
enum {
	IUP_GETPARAM_BUTTON1 = -1,
	IUP_GETPARAM_INIT    = -2,
	IUP_GETPARAM_BUTTON2 = -3,
	IUP_GETPARAM_BUTTON3 = -4,
	IUP_GETPARAM_CLOSE   = -5,
	IUP_GETPARAM_OK     = IUP_GETPARAM_BUTTON1,
	IUP_GETPARAM_CANCEL = IUP_GETPARAM_BUTTON2,
	IUP_GETPARAM_HELP   = IUP_GETPARAM_BUTTON3,
}

/************************************************************************/
/*                   Record Input Modes                                 */
/************************************************************************/
enum {IUP_RECBINARY, IUP_RECTEXT};


/* Used by IupColorbar */
enum {
    IUP_PRIMARY   = -1,
    IUP_SECONDARY = -2,
}