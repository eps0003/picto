#include "ClickArea.as"

class ClickManager
{
	ClickArea@[] areas;
	ClickArea@ currentArea;
	int currentKey;
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

		if (currentArea is null)
		{
			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				for (uint i = 0; i < areas.size(); i++)
				{
					ClickArea@ area = areas[i];
					if (area.containsMouse())
					{
						@currentArea = @area;
						currentKey = KEY_LBUTTON;
						currentArea.onLeftDown();
					}
				}
			}
			else if (controls.isKeyJustPressed(KEY_RBUTTON))
			{
				for (uint i = 0; i < areas.size(); i++)
				{
					ClickArea@ area = areas[i];
					if (area.containsMouse())
					{
						@currentArea = @area;
						currentKey = KEY_RBUTTON;
						currentArea.onRightDown();
					}
				}
			}
		}
		else
		{
			if (currentKey == KEY_LBUTTON)
			{
				if (controls.isKeyJustReleased(KEY_LBUTTON))
				{
					if (currentArea.containsMouse())
					{
						currentArea.onLeftClick();
					}
				}
				else if (!controls.isKeyPressed(KEY_LBUTTON))
				{
					@currentArea = null;
				}
			}
			else if (currentKey == KEY_RBUTTON)
			{
				if (controls.isKeyJustReleased(KEY_RBUTTON))
				{
					if (currentArea.containsMouse())
					{
						currentArea.onRightClick();
					}
				}
				else if (!controls.isKeyPressed(KEY_RBUTTON))
				{
					@currentArea = null;
				}
			}
		}
	}

	void CancelClick()
	{
		@currentArea = null;
	}

	bool isPressed(ClickArea@ area)
	{
		return currentArea is area;
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
