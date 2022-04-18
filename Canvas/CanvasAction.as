#include "Utilities.as"
#include "Canvas.as"

enum CanvasActionType
{
	Point,
	Line,
	Fill,
	FillContiguous
}

interface CanvasAction
{
	void Serialize(CBitStream@ bs);
	bool deserialize(CBitStream@ bs);
	void Execute(Canvas@ canvas);
}

// TODO: serialize (x,y) as a single int index

class PointAction : CanvasAction
{
	int x, y;
	SColor color;

	PointAction(int x, int y, SColor color)
	{
		this.x = x;
		this.y = y;
		this.color = color;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(CanvasActionType::Point);
		bs.write_s16(x);
		bs.write_s16(y);
		bs.write_u32(color.color);
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!bs.saferead_s16(x)) return false;
		if (!bs.saferead_s16(y)) return false;
		if (!saferead_color(bs, color)) return false;
		return true;
	}

	void Execute(Canvas@ canvas)
	{
		canvas.DrawPoint(x, y, color);
	}
}

class LineAction : CanvasAction
{
	int x0, y0, x1, y1;
	SColor color;

	LineAction(int x0, int y0, int x1, int y1, SColor color)
	{
		this.x0 = x0;
		this.y0 = y0;
		this.x1 = x1;
		this.y1 = y1;
		this.color = color;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(CanvasActionType::Line);
		bs.write_s16(x0);
		bs.write_s16(y0);
		bs.write_s16(x1);
		bs.write_s16(y1);
		bs.write_u32(color.color);
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!bs.saferead_s16(x0)) return false;
		if (!bs.saferead_s16(y0)) return false;
		if (!bs.saferead_s16(x1)) return false;
		if (!bs.saferead_s16(y1)) return false;
		if (!saferead_color(bs, color)) return false;
		return true;
	}

	void Execute(Canvas@ canvas)
	{
		canvas.DrawLine(Vec2f(x0, y0), Vec2f(x1, y1), color);
	}
}

class FillAction : CanvasAction
{
	SColor color;

	FillAction(SColor color)
	{
		this.color = color;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(CanvasActionType::Fill);
		bs.write_u32(color.color);
	}

	bool deserialize(CBitStream@ bs)
	{
		return saferead_color(bs, color);
	}

	void Execute(Canvas@ canvas)
	{
		canvas.Fill(color);
	}
}

class FillContiguousAction : CanvasAction
{
	int x, y;
	SColor color;

	FillContiguousAction(int x, int y, SColor color)
	{
		this.x = x;
		this.y = y;
		this.color = color;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(CanvasActionType::FillContiguous);
		bs.write_s16(x);
		bs.write_s16(y);
		bs.write_u32(color.color);
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!bs.saferead_s16(x)) return false;
		if (!bs.saferead_s16(y)) return false;
		if (!saferead_color(bs, color)) return false;
		return true;
	}

	void Execute(Canvas@ canvas)
	{
		canvas.FillContiguous(x, y, color);
	}
}
