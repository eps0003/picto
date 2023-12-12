#include "ColorButton.as"
#include "ClickManager.as"

class Palette
{
	SColor[] colors = {
		SColor(255, 229, 59, 68),	// Red
		SColor(255, 255, 173, 52),	// Orange
		SColor(255, 255, 231, 98),	// Yellow
		SColor(255, 99, 198, 77),	// Lime
		SColor(255, 38, 92, 66),	// Dark green
		SColor(255, 0, 149, 233),	// Light blue
		SColor(255, 18, 79, 136),	// Dark blue
		SColor(255, 104, 55, 108),	// Purple
		SColor(255, 24, 20, 37)		// Dark purple
	};

	private ColorButton@[] buttons;
	private SColor selectedColor = colors[0];

	Palette()
	{
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

			ColorButton@ button = ColorButton(this, Vec2f(x, y), size, colors[i]);
			buttons.push_back(button);
		}
	}

	void SetSelectedColor(SColor color)
	{
		print("Selected color: " + color.color);
		selectedColor = color;
	}

	SColor getSelectedColor()
	{
		return selectedColor;
	}

	void Render()
	{
		for (uint i = 0; i < buttons.size(); i++)
		{
			buttons[i].Render();
		}
	}
}
