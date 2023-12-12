#include "ClickArea.as"

class ColorButton : ClickArea
{
	Palette@ palette;
	SColor color;

	ColorButton(Palette@ palette, Vec2f pos, Vec2f size, SColor color)
	{
		super(pos, size, 1);
		@this.palette = palette;
		this.color = color;
	}

	void onLeftClick()
	{
		palette.SetSelectedColor(color);
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
