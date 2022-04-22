#include "ClickArea.as"

class ToolButton : ClickArea
{
	string title;
	Toolkit@ toolkit;

	ToolButton(Toolkit@ toolkit, Vec2f pos, Vec2f size, string title)
	{
		super(pos, size, 1);
		@this.toolkit = toolkit;
		this.title = title;
	}

	void onLeftClick()
	{
		toolkit.SetSelectedTool(this);
	}

	void Render()
	{
		if (toolkit.isSelected(this) || (isPressed() && containsMouse()))
		{
			GUI::DrawSunkenPane(pos, pos + size);
		}
		else
		{
			GUI::DrawPane(pos, pos + size);
		}

		GUI::DrawTextCentered(title, pos + size * 0.5f, color_white);
	}
}
