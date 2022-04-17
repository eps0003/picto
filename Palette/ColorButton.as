#include "ClickManager.as"

class ColorButton : ClickArea
{
	SColor color;

	ColorButton(Vec2f pos, Vec2f size, SColor color)
	{
		super(pos, size, 1);
		this.color = color;
	}

	void onLeftClick()
	{
		print("Selected color: " + color.color);
	}

	void Render()
	{
		if (isPressed() && containsMouse())
		{
			GUI::DrawPane(pos, pos + size);
		}
		else
		{
			GUI::DrawPane(pos, pos + size, color);
		}
	}
}
