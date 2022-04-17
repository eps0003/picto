#include "ClickManager.as"

funcdef SColor COLOR_CALLBACK(int, int);

class Canvas : ClickArea
{
	uint width;
	uint height;

	Canvas(uint width, uint height)
	{
		super(Vec2f(0, 0), Vec2f(99999, 99999));
		this.width = width;
		this.height = height;

		Texture::createBySize("canvas back", width, height);
		Fill(getBackgroundColor, "canvas back");

		Texture::createBySize("canvas", width, height);
		Clear();
	}

	void onClick()
	{
		print("Click canvas");
	}

	void Clear()
	{
		Fill(SColor(0, 0, 0, 0));
	}

	bool isValidPixel(int x, int y)
	{
		return x >= 0 && x < width && y >= 0 && y < height;
	}

	SColor getPixel(int x, int y)
	{
		ImageData@ image = Texture::data("canvas");
		return image.get(x, y);
	}

	void SetPixel(int x, int y, SColor color)
	{
		if (!isValidPixel(x, y)) return;

		ImageData@ image = Texture::data("canvas");
		image.put(x, y, color);
		Texture::update("canvas", image);
	}

	void ErasePixel(int x, int y)
	{
		if (!isValidPixel(x, y)) return;

		ImageData@ image = Texture::data("canvas");
		image.put(x, y, SColor(0, 0, 0, 0));
		Texture::update("canvas", image);
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
	}

	void Fill(COLOR_CALLBACK@ colorCallback, string texture = "canvas")
	{
		ImageData@ image = Texture::data(texture);

		for (uint x = 0; x < width; x++)
		for (uint y = 0; y < height; y++)
		{
			image.put(x, y, colorCallback(x, y));
		}

		Texture::update(texture, image);
	}

	void FillContiguous(int x, int y, SColor color)
	{
		if (!isValidPixel(x, y)) return;

		ImageData@ image = Texture::data("canvas");
		FillContiguous(x, y, color, image);
		Texture::update("canvas", image);
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

	void FillContiguous(int x, int y, COLOR_CALLBACK@ colorCallback)
	{
		if (!isValidPixel(x, y)) return;

		ImageData@ image = Texture::data("canvas");
		FillContiguous(x, y, colorCallback, image);
		Texture::update("canvas", image);
	}

	private void FillContiguous(int x, int y, COLOR_CALLBACK@ colorCallback, ImageData@ image)
	{
		SColor oldColor = image.get(x, y);
		SColor color = colorCallback(x, y);
		if (oldColor == color) return;

		image.put(x, y, color);

		if (x > 0 && image.get(x - 1, y) == oldColor)
		{
			FillContiguous(x - 1, y, colorCallback);
		}

		if (y > 0 && image.get(x, y - 1) == oldColor)
		{
			FillContiguous(x, y - 1, colorCallback);
		}

		if (x < width - 1 && image.get(x + 1, y) == oldColor)
		{
			FillContiguous(x + 1, y, colorCallback);
		}

		if (y < height - 1 && image.get(x, y + 1) == oldColor)
		{
			FillContiguous(x, y + 1, colorCallback);
		}
	}

	Vec2f getPosition()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		Vec2f dim = getDimensions();
		return (screenDim - dim) / 2;
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

	private Vec2f prevMousePos = getMousePosition();

	void Update()
	{
		CControls@ controls = getControls();
		Vec2f mousePos = getMousePosition();

		if (isPressed())
		{
			if (controls.isKeyJustPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON))
			{
				prevMousePos = mousePos;
			}

			if (controls.isKeyPressed(KEY_LBUTTON))
			{
				Line(prevMousePos, mousePos, SColor(255, 200, 100, 100));
			}
			else if (controls.isKeyPressed(KEY_RBUTTON))
			{
				Line(prevMousePos, mousePos, SColor(0, 0, 0, 0));
			}
		}

		prevMousePos = mousePos;
	}

	// Bresenham's line algorithm
	// Reference: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
	// Source: https://stackoverflow.com/a/4672319/10456572
	private void Line(Vec2f start, Vec2f end, SColor color)
	{
		int x0 = Maths::Floor(start.x);
		int y0 = Maths::Floor(start.y);
		int x1 = Maths::Floor(end.x);
		int y1 = Maths::Floor(end.y);

		int dx = Maths::Abs(x1 - x0);
		int dy = Maths::Abs(y1 - y0);

		s8 sx = x0 < x1 ? 1 : -1;
		s8 sy = y0 < y1 ? 1 : -1;

		int err = dx - dy;

		ImageData@ image = Texture::data("canvas");

		while (isValidPixel(x0, y0))
		{
			image.put(x0, y0, color);

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

	void Render()
	{
		Render::SetTransformScreenspace();

		Vec2f pos = getPosition();
		Vec2f dim = getDimensions();

		Vertex[] vertices;
		vertices.push_back(Vertex(pos.x        , pos.y        , 0, 0, 0, color_white));
		vertices.push_back(Vertex(pos.x        , pos.y + dim.y, 0, 0, 1, color_white));
		vertices.push_back(Vertex(pos.x + dim.x, pos.y + dim.y, 0, 1, 1, color_white));
		vertices.push_back(Vertex(pos.x + dim.x, pos.y        , 0, 1, 0, color_white));

		Render::RawQuads("canvas back", vertices);
		Render::RawQuads("canvas", vertices);
	}
}

SColor getBackgroundColor(int x, int y)
{
	return (x / 4 + y / 4) % 2 == 0
		? SColor(255, 200, 200, 200)
		: SColor(255, 180, 180, 180);
}
