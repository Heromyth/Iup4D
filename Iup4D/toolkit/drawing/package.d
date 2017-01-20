module toolkit.drawing;

public
{
    import toolkit.drawing.color;
    import toolkit.drawing.font;
    import toolkit.drawing.shape;
    import toolkit.drawing.image;
}


import std.format;

struct Size
{
	int width;
	int height;

	this(int width, int height)
	{
		this.width = width; this.height = height;
	}

    string toString()
    {
        return std.format.format("%d, %d", width, height);
    }
}


struct OffsetXY
{
	int dx;
	int dy;

	this(int dx, int dy)
	{
		this.dx = dx; this.dy = dy;
	}

    string toString()
    {
        return std.format.format("%d, %d", dx, dy);
    }
}





