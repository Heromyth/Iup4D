module iup.c.core;


/******************************************************************************
* Copyright (C) 1994-2016 Tecgraf, PUC-Rio.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/

extern(C) {

	enum IUP_NAME = "IUP - Portable User Interface";
	enum IUP_DESCRIPTION	= "Multi-platform Toolkit for Building Graphical User Interfaces";
	enum IUP_COPYRIGHT = "Copyright (C) 1994-2016 Tecgraf/PUC-Rio";
	enum IUP_VERSION = "3.19";         /* bug fixes are reported only by IupVersion functions */
	enum IUP_VERSION_NUMBER = 319000;
	enum IUP_VERSION_DATE = "2016/06/20";  /* does not include bug fix releases */

	struct Ihandle;

	alias Icallback = int function(Ihandle*) nothrow;
	alias Iparamcb  = int function(Ihandle* dialog, int param_index, void* user_data) nothrow;
}

