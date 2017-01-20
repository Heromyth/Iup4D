module cd.utility;

import im.core;
import im.image;
import cd.canvas;

void imcdCanvasPutImage(CdCanvas cdCanvas, ImImage image, 
                        int x, int y, int w, int h, 
                        int xmin, int xmax, int ymin, int ymax)
{
    if(image.colorSpace == ImColorSpace.RGB)
    {
        const(ubyte)[][] matrixData = cast(const(ubyte)[][])image.matrixData;
        if(image.hasAlpha())
        {
            cdCanvas.putImageRectRGBA(image.width, image.height, matrixData,
                                      x,y,w, h, xmin, xmax, ymin, ymax);
        }
        else
        {
            cdCanvas.putImageRectRGB(image.width, image.height, matrixData,
                                     x,y,w, h, xmin, xmax, ymin, ymax);
        }
    }
    else
    {
        cdCanvas.putImageRectMap(image.width, image.height, image.linearData,
                                 x,y,w, h, xmin, xmax, ymin, ymax);
    }
}