module GridTest;

import std.algorithm;
import std.ascii;
import std.container.array;
import std.conv;
import std.format;
import std.file;
import std.math;
import std.path;
import std.stdio;
import std.string;
import std.traits;

import core.stdc.stdlib; 

import iup;
import im;
import cd;

import toolkit.event;
import toolkit.input;
import toolkit.drawing;


public class CellsCheckboardTestDialog : IupDialog
{
    private IupCells cells;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        cells = new IupCells();
        cells.hasBorder = false;
        cells.rasterSize = Size(400, 400);

        cells.columnWidthNeeded += &cells_columnWidthNeeded;
        cells.rowHeightNeeded += &cells_rowHeightNeeded;
        cells.columnCountNeeded += &cells_columnCountNeeded;
        cells.rowCountNeeded += &cells_rowCountNeeded;
        cells.scrolling += &cells_scrolling;
        cells.paint += &cells_paint;

        this.child = cells;
        this.gap = 10;
        this.margin = Size(200, 100);
        this.title = "IupCells Test";
    }

    private void cells_columnWidthNeeded(Object sender, IntCallbackResult r, int i)
    {
        r.value = 50;
    }

    private void cells_rowHeightNeeded(Object sender, CallbackResult!(int) r, int j)
    {
        r.value = 50;
    }

    private void cells_columnCountNeeded(Object sender, IntCallbackResult r)
    {
        r.value = 8;
    }

    private void cells_rowCountNeeded(Object sender, IntCallbackResult r)
    {
        r.value = 8;
    }

    private void cells_scrolling(Object sender, ActionCallbackResult r,
                                        int row, int col)
    {
        writefln("SCROLLING_CB: row=%d, col=%d", row, col);
    }

    private void cells_paint(Object sender, ActionCallbackResult r, int row, int col, 
                             RectangleInt rect, IupCdCanvas canvas)
    {
        if (((row%2) && (col%2)) || (((row+1)%2) && ((col+1)%2)))
            canvas.foreground(Colors.White);
        else
            canvas.foreground(Colors.Black);

        canvas.drawBox(rect);
    }
}


public class CellsDegradeTestDialog : IupDialog
{
    private IupCells cells;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        cells = new IupCells();
        cells.isBoxed = false;
        cells.rasterSize = Size(300, 200);

        cells.columnWidthNeeded += &cells_columnWidthNeeded;
        cells.rowHeightNeeded += &cells_rowHeightNeeded;
        cells.columnCountNeeded += &cells_columnCountNeeded;
        cells.rowCountNeeded += &cells_rowCountNeeded;
        cells.scrolling += &cells_scrolling;
        cells.paint += &cells_paint;
        cells.mouseClick += &cells_mouseClick;
        cells.horizontalSpanNeeded += &cells_horizontalSpanNeeded;
        cells.verticalSpanNeeded += &cells_verticalSpanNeeded;

        IupVbox box = new IupVbox(cells);
        box.margin = Size(10, 10);

        this.child = box;
        this.title = "IupCells Test";
    }

    private void cells_columnWidthNeeded(Object sender, IntCallbackResult r, int col)
    {
        r.value = cast(int)(50 + col * 1.5);
    }

    private void cells_rowHeightNeeded(Object sender, CallbackResult!(int) r, int row)
    {
        r.value = cast(int)(30 + row * 1.5);
    }

    private void cells_columnCountNeeded(Object sender, IntCallbackResult r)
    {
        r.value = 7;
    }

    private void cells_rowCountNeeded(Object sender, IntCallbackResult r)
    {
        r.value = 7;
    }

    private void cells_scrolling(Object sender, ActionCallbackResult r,
                                 int row, int col)
    {
        writefln("SCROLL: (%02d, %02d)", row, col);
    }

    private void cells_paint(Object sender, ActionCallbackResult r, int row, int col, 
                             RectangleInt rect, IupCdCanvas canvas)
    {
        int xm = (rect.x1 + rect.x2) / 2;
        int ym = (rect.y1 + rect.y2) / 2;

        if (row == 1 && col == 2)
            return;
        if (row == 2 && col == 1)
            return;
        if (row == 2 && col == 2)
            return;
        if (row == 5 && col == 6)
            return;
        if (row == 6 && col == 5)
            return;
        if (row == 6 && col == 6)
            return;

        if (row == 1 && col == 1)
            canvas.foreground(Colors.White);
        else
        {
            Color color = Color.fromRgb(cast(ubyte)(row*20), cast(ubyte)(col*20), cast(ubyte)(row+100));
            canvas.foreground(color);
        }

        canvas.drawBox(rect);
        canvas.textAlignment = TextAlignment.Center;
        canvas.foreground(Colors.Black);

        string v =std.format.format("(%02d, %02d)", row, col);
        canvas.drawText(xm, ym, v);
    }

    private void cells_mouseClick(Object sender, ActionCallbackResult r, 
                                  MouseButtons button, MouseState mouseState, 
                                  int row, int column, int x, int y, string status)
    {
        writefln("CLICK: %s: (%02d, %02d)", button, row, column);
    }

    private void cells_horizontalSpanNeeded(Object sender, IntCallbackResult r, int row, int col)
    {
        if (row == 1 && col == 1)
            r.value = 2;

        if (row == 5 && col == 5)
            r.value = 2;

        r.value = 1;
    }

    private void cells_verticalSpanNeeded(Object sender, IntCallbackResult r, int row, int col)
    {
        if (row == 1 && col == 1)
            r.value = 2;

        if (row == 5 && col == 5)
            r.value = 2;

        r.value = 1;
    }
}


public class CellsNumberingTestDialog : IupDialog
{
    private IupCells cells;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        cells = new IupCells();
        cells.isBoxed = false;
        cells.rasterSize = Size(300, 200);

        cells.columnWidthNeeded += &cells_columnWidthNeeded;
        cells.rowHeightNeeded += &cells_rowHeightNeeded;
        cells.columnCountNeeded += &cells_columnCountNeeded;
        cells.rowCountNeeded += &cells_rowCountNeeded;
        cells.paint += &cells_paint;
        cells.mouseClick += &cells_mouseClick;

        IupVbox box = new IupVbox(cells);
        box.margin = Size(10, 10);

        this.child = box;
        this.title = "IupCells Test";
    }

    private void cells_columnWidthNeeded(Object sender, IntCallbackResult r, int col)
    {
        r.value = 70;
    }

    private void cells_rowHeightNeeded(Object sender, CallbackResult!(int) r, int row)
    {
        r.value = 30;
    }

    private void cells_columnCountNeeded(Object sender, IntCallbackResult r)
    {
        r.value = 20;
    }

    private void cells_rowCountNeeded(Object sender, IntCallbackResult r)
    {
        r.value = 50;
    }

    private void cells_paint(Object sender, ActionCallbackResult r, int row, int col, 
                             RectangleInt rect, IupCdCanvas canvas)
    {
        int xm = (rect.x1 + rect.x2) / 2;
        int ym = (rect.y1 + rect.y2) / 2;

        Color color = Color.fromRgb(cast(ubyte)(row*20), cast(ubyte)(col*20), cast(ubyte)(row+100));
        canvas.foreground(color);
        canvas.drawBox(rect);

        canvas.textAlignment = TextAlignment.Center;
        canvas.foreground(Colors.Black);

        string v =std.format.format("(%02d, %02d)", row, col);
        canvas.drawText(xm, ym, v);
    }

    private void cells_mouseClick(Object sender, ActionCallbackResult r, 
                                  MouseButtons button, MouseState mouseState, 
                                  int row, int column, int x, int y, string status)
    {
        string msg = std.format.format("CLICK: %s: (%02d, %02d)", button, row, column);
        IupMessageBox.show("Hi!", msg);
    }
}


public class MatrixTestDialog : IupDialog
{
    private IupMatrix mat;

    this() 
    {
        super();
    }

    protected override void initializeComponent() 
    {
        createMatrix();
        IupVbox box = new IupVbox(mat);
        box.margin = Size(10, 10);

        this.child = box;
        this.gap = 10;
        this.margin = Size(200, 100);
        this.title = "IupMatrix Simple Test";
    }

    private void createMatrix()
    {
        mat = new IupMatrix();
        mat.rowCount = 20;
        mat.columnCount = 8;


    }

}

