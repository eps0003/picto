#include "Utilities.as"

enum CanvasActionType
{
	SetPixel,
	Fill,
	FillContiguous,
	Line
}

class CanvasAction
{
	u8 type;

	CanvasAction(CanvasActionType type)
	{
		this.type = type;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u8(type);
	}

	bool deserialize(CBitStream@ bs)
	{
		return true;
	}

	void Execute(Canvas@ canvas) {}
}

class LineAction : CanvasAction
{
	int x0, y0, x1, y1;
	SColor color;

	LineAction(int x0, int y0, int x1, int y1, SColor color)
	{
		super(CanvasActionType::Line);
		this.x0 = x0;
		this.y0 = y0;
		this.x1 = x1;
		this.y1 = y1;
		this.color = color;
	}

	void Serialize(CBitStream@ bs)
	{
		CanvasAction::Serialize(bs);
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
