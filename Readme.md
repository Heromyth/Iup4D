# Iup4D
Iup4D is a D binding library for IUP with OOP style. Its API is similar to WinForms.

Copyright © 2016-2017 BitWorld. All Rights Reserved.


## Requirements
Library | Version
--- | ---
DMD | 2.071.2
Visual D | 0.3.44 beta 1 (Patched with #67)
IUP | 3.20
DerelictGL3 | 2.0


## Status
It's still under active development and is only tested on Windows X86.

## License
This software is licensed under the Boost Software License, Version 1.0.

For more details, see the full text of the license in the file Boost.txt.

## Example
```D
module main;

import std.stdio;
import core.stdc.stdlib; 

import iup;
import toolkit;

version(Windows) { 
    pragma(lib, "iup.lib");
    pragma(lib, "iupimglib.lib");
    pragma(lib, "iupim.lib");
    pragma(lib, "im.lib");
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
    this()  {    super();    }

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
        // do something after this dialog is loaded
    }

    private void dialog_closing(Object sender, CallbackEventArgs e)
    {
        e.result = CallbackResult.Close;
    }

    private void linkLabel_linkClicked(Object sender, CallbackEventArgs e, string url)
    {
        writefln("url (%s)", url);
    }
}
```

## Screenshots
<img src="Screenshots/Simple Paint.png" />

<img src="Screenshots/Button.png" />

## Todo
- Bind more APIs for more controls
- Port more test examples
- Check and fix memory leak bugs
- Stable API for wrapper librarys

## Acknowledgement
Name | URL
--- | ---
Tecgraf | http://webserver2.tecgraf.puc-rio.br/iup/
DMD | https://dlang.org/
Visual D | https://github.com/dlang/visuald
mogud/iupd | https://github.com/mogud/iupd
carblue/iup | https://github.com/carblue/iup
DerelictOrg | https://github.com/DerelictOrg
DGui | https://bitbucket.org/dgui/dgui