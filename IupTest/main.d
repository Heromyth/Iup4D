module main;

import std.stdio;

import core.stdc.stdlib; 

import MainForm;
import iup;

version(Windows) { 
    pragma(lib, "iup.lib");

    pragma(lib, "iupimglib.lib"); // required only if function IupImageLibOpen() is called
    pragma(lib, "iupim.lib");
    pragma(lib, "im.lib");

    pragma(lib, "iupgl.lib");
    pragma(lib, "opengl32.lib");

    pragma(lib, "iupcontrols.lib");
    pragma(lib, "iupglcontrols.lib");
}


int main(string[] argv)
{

    Application.open();
    Application.useIupControls();
    Application.useOpenGL();
    Application.useImageLib();

    MainForm mainForm = new MainForm();
    Application.run(mainForm);

	return EXIT_SUCCESS;
}
