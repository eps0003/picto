class Canvas
{
	uint width;
	uint height;

	Canvas(uint width, uint height)
	{
		this.width = width;
		this.height = height;
		Texture::createBySize("canvas", width, height);

		for (uint y = 0; y < height; y++)
		for (uint x = 0; x < width; x++)
		{
			AddPixel(x, y, ((x + y) % 2) == 0 ? SColor(255, 100, 100, 100) : SColor(255, 200, 200, 200));
		}
	}

	void AddPixel(int x, int y, SColor color)
	{
		ImageData@ image = Texture::data("canvas");
		image.put(x, y, color);
		Texture::update("canvas", image);
	}

	void ErasePixel(int x, int y)
	{
		AddPixel(x, y, SColor(0, 0, 0, 0));
	}

	void Render()
	{
		Render::SetTransformScreenspace();

		Vec2f screenDim = getDriver().getScreenDimensions();
		uint size = Maths::Min(screenDim.x, screenDim.y);
		uint x = (screenDim.x - size) / 2;
		uint y = (screenDim.y - size) / 2;

		Vertex[] vertices;
		vertices.push_back(Vertex(x       , y       , 0, 0, 0, color_white));
		vertices.push_back(Vertex(x       , y + size, 0, 0, 1, color_white));
		vertices.push_back(Vertex(x + size, y + size, 0, 1, 1, color_white));
		vertices.push_back(Vertex(x + size, y       , 0, 1, 0, color_white));

		Render::RawQuads("canvas", vertices);
	}
}
