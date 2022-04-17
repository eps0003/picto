funcdef SColor COLOR_CALLBACK(int, int);

class Canvas
{
	uint width;
	uint height;

	Canvas(uint width, uint height)
	{
		this.width = width;
		this.height = height;
		Texture::createBySize("canvas", width, height);
		Clear();
	}

	void Clear()
	{
		Fill(getBackgroundColor);
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

	void Fill(COLOR_CALLBACK@ colorCallback)
	{
		ImageData@ image = Texture::data("canvas");

		for (uint x = 0; x < width; x++)
		for (uint y = 0; y < height; y++)
		{
			image.put(x, y, colorCallback(x, y));
		}

		Texture::update("canvas", image);
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

	void Update()
	{
		CControls@ controls = getControls();
		Vec2f mousePos = getMousePosition();

		if (controls.isKeyPressed(KEY_LBUTTON))
		{
			SetPixel(mousePos.x, mousePos.y, SColor(255, 100, 100, 100));
		}
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

		Render::RawQuads("canvas", vertices);
	}
}

SColor getBackgroundColor(int x, int y)
{
	return (x + y) % 2 == 0
		? SColor(255, 100, 100, 100)
		: SColor(255, 200, 200, 200);
}
