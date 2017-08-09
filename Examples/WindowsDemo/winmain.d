module winmain;

import std.stdio;
import core.stdc.stdlib; 

import iup;
import toolkit;

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

int main(string[] argv)
{
    Application.open();
    Application.useImageLib();

    MainForm mainForm = new MainForm();
    Application.run(mainForm);

	return EXIT_SUCCESS;
}


class MainForm : IupDialog
{
    this()  { super(); }

    protected override void initializeComponent()
    {
        IupLinkLabel linkButton = new IupLinkLabel("http://www.tecgraf.puc-rio.br/iup", "IUP Toolkit");
        linkButton.linkClicked += &linkLabel_linkClicked;

        IupVbox vbox = new IupVbox(linkButton);
        vbox.alignment = HorizontalAlignment.Center;

        this.child = vbox;
        this.margin = Size(10, 10);
        this.title = "Iup Demo";
        this.rasterSize = Size(300, 200);

        this.loaded += &dialog_loaded;
        this.closing += &dialog_closing;
    }

    private void dialog_loaded(Object sender, CallbackEventArgs args)
    {
        // do something after the dialog is loaded
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        e.result = IupElementAction.Close;
    }

    private void linkLabel_linkClicked(Object sender, CallbackEventArgs e, string url)
    {
        writefln("url (%s)", url);
    }
}