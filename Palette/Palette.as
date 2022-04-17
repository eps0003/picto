#include "ColorButton.as"
#include "ClickManager.as"

class Palette
{
	SColor[] colors = {
		SColor(255, 255, 100, 100),
		SColor(255, 100, 255, 100),
		SColor(255, 100, 100, 255)
	};

	ColorButton@[] buttons;

	Palette()
	{
		ClickManager@ clickManager = ClickManager::get();
		Vec2f screenDim = getDriver().getScreenDimensions();

		Vec2f size(60, 60);
		uint spacing = 10;
		uint margin = 20;

		uint n = colors.size();

		for (uint i = 0; i < n; i++)
		{
			int index = i - (n - 1) * 0.5f;
			int x = screenDim.x * 0.5f + index * (size.x + spacing) - size.x * 0.5f;
			int y = screenDim.y - size.y - margin;

			ColorButton@ button = ColorButton(Vec2f(x, y), size, colors[i]);
			buttons.push_back(button);
		}
	}

	void Render()
	{
		for (uint i = 0; i < buttons.size(); i++)
		{
			buttons[i].Render();
		}
	}
}
