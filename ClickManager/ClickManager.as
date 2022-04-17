#include "ClickArea.as"

class ClickManager
{
	ClickArea@[] areas;
	ClickArea@ currentArea;
	CControls@ controls = getControls();

	void Listen(ClickArea@ area)
	{
		for (uint i = 0; i < areas.size(); i++)
		{
			if (areas[i].zIndex > area.zIndex)
			{
				areas.insert(i, area);
				return;
			}
		}

		areas.push_back(area);
	}

	void HandleClicks()
	{
		Vec2f mousePos = controls.getMouseScreenPos();

		if (controls.isKeyJustPressed(KEY_LBUTTON))
		{
			for (uint i = 0; i < areas.size(); i++)
			{
				ClickArea@ area = areas[i];
				if (area.containsMouse())
				{
					@currentArea = @area;
					currentArea.onDown();
				}
			}
		}

		if (currentArea !is null)
		{
			if (controls.isKeyJustReleased(KEY_LBUTTON))
			{
				if (currentArea.containsMouse())
				{
					currentArea.onClick();
				}
			}
			else if (!controls.isKeyPressed(KEY_LBUTTON))
			{
				@currentArea = null;
			}
		}
	}

	void CancelClick()
	{
		@currentArea = null;
	}

	bool isPressed(ClickArea@ area)
	{
		return currentArea is area && controls.isKeyPressed(KEY_LBUTTON);
	}

	bool isMousePressed()
	{
		return currentArea is null && controls.isKeyPressed(KEY_LBUTTON);
	}

	bool isMouseJustPressed()
	{
		return currentArea is null && controls.isKeyJustPressed(KEY_LBUTTON);
	}

	bool isMouseJustReleased()
	{
		return currentArea is null && controls.isKeyJustReleased(KEY_LBUTTON);
	}
}

namespace ClickManager
{
	ClickManager@ get()
	{
		ClickManager@ manager;
		if (!getRules().get("click manager", @manager))
		{
			@manager = ClickManager();
			getRules().set("click manager", @manager);
		}
		return manager;
	}
}
