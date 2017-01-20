module toolkit.drawing.shape;

import std.format;

struct Point(T) if(is(T == int) || is(T == float) || is(T == double))
{
	T x;
	T y;

	this(T x, T y)
	{
		this.x = x; this.y = y;
	}

    string toString()
    {
        static if(is(T == int))
            return std.format.format("%d, %d", x, y);
        else 
            return std.format.format("%f, %f", x, y);
    }
}

alias PointInt = Point!int;


struct Rectangle(T) if(is(T == int) || is(T == float) || is(T == double))
{
    T x1;
    T y1;
    T x2;
    T y2;

    this(T x1, T y1, T x2, T y2)
    {
        this.x1 = x1; this.y1 = y1;
        this.x2 = x2; this.y2 = y2;
    }

    this(Point!T p1, Point!T p2)
    {
        this.x1 = p1.x; this.y1 = p1.y;
        this.x2 = p2.x; this.y2 = p2.y;
    }


    @property T width() { return x2 - x1;}

    @property T height() { return y2 - y1;}

    string toString()
    {
        static if(is(T == int))
            return std.format.format("(%d, %d) - (%d, %d)", x1, y1, x2, y2);
        else
            return std.format.format("(%f, %f) - (%f, %f)", x1, y1, x2, y2);

    }
}


alias RectangleInt = Rectangle!int;
alias RectangleFloat = Rectangle!float;
alias RectangleDouble = Rectangle!double;
