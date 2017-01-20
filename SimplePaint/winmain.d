module winmain;

import core.runtime;
import core.sys.windows.windows;

import MainForm;
import iup;

version(Windows) { 
    pragma(lib, "iup.lib");
    pragma(lib, "iupimglib.lib"); // required only if function IupImageLibOpen() is called
    pragma(lib, "iupim.lib");
    pragma(lib, "im.lib");
    pragma(lib, "iupgl.lib");
    pragma(lib, "opengl32.lib");
    pragma(lib, "iupglcontrols.lib");
}


extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result = 0;

    try
    {
        Runtime.initialize();

        Application.open();
        Application.useOpenGL();
        Application.useImageLib();

        SplashDialog splashDialog = new SplashDialog();

        splashDialog.show();
        while(splashDialog.isFirstStage)
           Application.loopStep();

        MainForm mainForm = new MainForm();
        Application.run(mainForm);

        splashDialog.dispose();

        Runtime.terminate();
    }
    catch (Throwable o) // catch any uncaught exceptions
    {
        MessageBoxA(null, cast(char *)o.toString(), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}


