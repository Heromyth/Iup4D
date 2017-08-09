# Iup4D
Iup4D is a D binding library for IUP with OOP style. Its API is similar to WinForms.

Copyright © 2016-2017 BitWorld. All Rights Reserved.

## License
This software is licensed under the Boost Software License, Version 1.0.

For more details, see the full text of the license in the file Boost.txt.

## Requirements
Tools | Version
--- | ---
DMD | 2.075
DUB | 1.4.0
Visual D | 0.45.0
IUP | 3.22
DerelictGL3 | 2.0

## Build status
Platform | Building | Runing
--- | --- | ---
Windows x86(mscoff) | succeeded | succeeded
Windows x64 | succeeded | IupTest crashed
Linux | Todo | Todo

## Example
```D
module main;

import std.stdio;
import core.stdc.stdlib; 

import iup;
import toolkit;

version(Windows) { 
    pragma(lib, "iup.lib");
    pragma(lib, "iupimglib.lib"); // required only if function IupImageLibOpen() is called
    pragma(lib, "iupim.lib");
    pragma(lib, "im.lib");
    pragma(lib, "iupcontrols.lib");
    pragma(lib, "iupgl.lib");
    pragma(lib, "opengl32.lib");
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
```

## Directories
Name | Description
--- | ---
Iup4D | The core library
DerelictOrg | OpenGL binding library
IupTest | The test program for Iup4D
Examples | Some simple demos for Iup4D
Thirdparties | The import librares from IUP 


## Build

### Preparation

- Windows

1. IUP libraries

Download the IUP develop libraries and extract all `.lib` files to the `Thirdparties` directory. See also, [Readme.md](Thirdparties/lib32mscoff/Readme.md). 

2. Resource compiler

It can be found in `C:\Program Files (x86)\Windows Kits\10\bin\x86` on Windows 10. Make sure that it can be searched in environment variable `PATH`.

### Visual D

You can use Visual D to build Iup4D on Windows.

### DUB

1. build core lib
```sh
dub build --arch=x86_mscoff --build=release --compiler=dmd
```
2. build examples
```sh
dub build :simple-demo --arch=x86_mscoff --build=release --compiler=dmd
dub build :windows-demo --arch=x86_mscoff --build=release --compiler=dmd
dub build :simple-paint --arch=x86_mscoff --build=release --compiler=dmd
dub build :iup-test --arch=x86_mscoff --build=release --compiler=dmd
```

## Screenshots
![Paint](Screenshots/Simple%20Paint.png)
![Button](Screenshots/Button.png)

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