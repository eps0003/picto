#include "ClickArea.as"
#include "CanvasAction.as"
#include "RulesCommon.as"
#include "Palette.as"
#include "CanvasSync.as"

funcdef SColor COLOR_CALLBACK(int, int);

class Canvas : ClickArea
{
	uint width;
	uint height;

	Palette@ palette;

	CanvasAction@[] actionsToSync;
	CanvasAction@[] actionsToExecute;

	Canvas(uint width, uint height)
	{
		super(Vec2f(0, 0), Vec2f(99999, 99999));
		this.width = width;
		this.height = height;

		GenerateBackground();

		Texture::createBySize("canvas", width, height);
		Clear();

		@palette = Palette();
	}

	private void GenerateBackground()
	{
		ImageData image(width, height);

		SColor color1(255, 200, 200, 200);
		SColor color2(255, 180, 180, 180);

		for (uint x = 0; x < width; x++)
		for (uint y = 0; y < height; y++)
		{
			image.put(x, y, (x / 4 + y / 4) % 2 == 0 ? color1 : color2);
		}

		Texture::createFromData("canvas back", image);
	}

	bool isValidPixel(int x, int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}

	SColor getPixel(int x, int y)
	{
		return Texture::data("canvas").get(x, y);
	}

	void DrawPoint(int x, int y, SColor color)
	{
		if (!isValidPixel(x, y)) return;

		ImageData@ image = Texture::data("canvas");
		image.put(x, y, color);
		Texture::update("canvas", image);

		QueueAction(PointAction(x, y, color));
	}

	void Fill(SColor color)
	{
		ImageData@ image = Texture::data("canvas");

		for (uint x = 0; x < width; x++)
		for (uint y = 0; y < height; y++)
		{
			image.put(x, y, color);
		}

		Texture::update("canvas", image);

		QueueAction(FillAction(color));
	}

	void FillContiguous(int x, int y, SColor color)
	{
		if (!isValidPixel(x, y)) return;

		ImageData@ image = Texture::data("canvas");
		FillContiguous(x, y, color, image);
		Texture::update("canvas", image);

		QueueAction(FillContiguousAction(x, y, color));
	}

	private void FillContiguous(int x, int y, SColor color, ImageData@ image)
	{
		SColor oldColor = image.get(x, y);
		if (oldColor == color) return;

		image.put(x, y, color);

		if (x > 0 && image.get(x - 1, y) == oldColor)
		{
			FillContiguous(x - 1, y, color, image);
		}

		if (y > 0 && image.get(x, y - 1) == oldColor)
		{
			FillContiguous(x, y - 1, color, image);
		}

		if (x < width - 1 && image.get(x + 1, y) == oldColor)
		{
			FillContiguous(x + 1, y, color, image);
		}

		if (y < height - 1 && image.get(x, y + 1) == oldColor)
		{
			FillContiguous(x, y + 1, color, image);
		}
	}

	void Clear()
	{
		Fill(0);
	}

	Vec2f getPosition()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		Vec2f dim = getDimensions();
		return (screenDim - dim) * 0.5f;
	}

	Vec2f getDimensions()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		uint size = Maths::Min(screenDim.x, screenDim.y);
		return Vec2f(size, size);
	}

	Vec2f getMousePosition()
	{
		Vec2f mousePos = getControls().getInterpMouseScreenPos();
		Vec2f pos = getPosition();
		Vec2f dim = getDimensions();
		Vec2f canvasPos = mousePos - pos;
		return Vec2f(
			Maths::Floor(canvasPos.x / dim.x * width),
			Maths::Floor(canvasPos.y / dim.y * height)
		);
	}

	void DrawFilledRect(int x0, int y0, int x1, int y1, SColor color)
	{
		ImageData@ image = Texture::data("canvas");

		if (x0 > x1)
		{
			int temp = x0;
			x0 = x1;
			x1 = temp;
		}

		if (y0 > y1)
		{
			int temp = y0;
			y0 = y1;
			y1 = temp;
		}

		for (int x = x0; x <= x1; x++)
		for (int y = y0; y <= y1; y++)
		{
			image.put(x, y, color);
		}

		Texture::update("canvas", image);
	}

	// Bresenham's line algorithm
	// Reference: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
	// Source: https://stackoverflow.com/a/4672319/10456572
	void DrawLine(int x0, int y0, int x1, int y1, SColor color, u8 r = 1)
	{
		QueueAction(LineAction(x0, y0, x1, y1, color, r));

		int dx = Maths::Abs(x1 - x0);
		int dy = Maths::Abs(y1 - y0);

		s8 sx = x0 < x1 ? 1 : -1;
		s8 sy = y0 < y1 ? 1 : -1;

		int err = dx - dy;
		uint rSq = r * r;

		ImageData@ image = Texture::data("canvas");

		while (true)
		{
			for (int x = x0 - r; x <= x0 + r; x++)
			for (int y = y0 - r; y <= y0 + r; y++)
			{
				uint distX = Maths::Abs(x - x0);
				uint distY = Maths::Abs(y - y0);
				uint distSq = distX * distX + distY * distY;

				if (isValidPixel(x, y) && distSq <= rSq)
				{
					image.put(x, y, color);
				}
			}

			if (x0 == x1 && y0 == y1) break;

			int e2 = 2 * err;
			if (e2 > -dy)
			{
				err -= dy;
				x0 += sx;
			}
			if (e2 < dx)
			{
				err += dx;
				y0 += sy;
			}
		}

		Texture::update("canvas", image);
	}

	private void QueueAction(CanvasAction@ action)
	{
		if (isMyCanvas())
		{
			actionsToSync.push_back(action);
		}
	}

	void Render()
	{
		Render::SetTransformScreenspace();

		if (actionsToExecute.size() > 0)
		{
			actionsToExecute[0].Execute(this);
			actionsToExecute.removeAt(0);
		}

		Vec2f pos = getPosition();
		Vec2f dim = getDimensions();

		Vertex[] vertices;
		vertices.push_back(Vertex(pos.x        , pos.y        , 0, 0, 0, color_white));
		vertices.push_back(Vertex(pos.x        , pos.y + dim.y, 0, 0, 1, color_white));
		vertices.push_back(Vertex(pos.x + dim.x, pos.y + dim.y, 0, 1, 1, color_white));
		vertices.push_back(Vertex(pos.x + dim.x, pos.y        , 0, 1, 0, color_white));

		Render::RawQuads("canvas back", vertices);
		Render::RawQuads("canvas", vertices);

		palette.Render();
	}

	bool isMyCanvas()
	{
		CPlayer@ artist = getCurrentArtist();
		return artist !is null && artist.isMyPlayer();
	}

	void Sync()
	{
		if (actionsToSync.empty() || !isMyCanvas() || isServer()) return;

		CBitStream bs;
		bs.write_netid(getLocalPlayer().getNetworkID());
		Serialize(bs);
		getRules().SendCommand(getRules().getCommandID("sync canvas"), bs, true);

		actionsToSync.clear();
	}

	void Serialize(CBitStream@ bs)
	{
		SerializeCanvasActions(bs, actionsToSync);
	}

	bool deserialize(CBitStream@ bs)
	{
		return deserializeCanvasActions(bs, actionsToExecute);
	}
}

namespace Canvas
{
	Canvas@ get()
	{
		Canvas@ canvas;
		if (!getRules().get("canvas", @canvas))
		{
			@canvas = Canvas(400, 400);
			getRules().set("canvas", @canvas);
		}
		return canvas;
	}
}
