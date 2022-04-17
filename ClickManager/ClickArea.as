class ClickArea
{
	Vec2f pos;
	Vec2f size;
	int zIndex; // Don't change this after it is set

	private ClickManager@ clickManager;

	ClickArea(Vec2f pos, Vec2f size, int zIndex = 0)
	{
		this.pos = pos;
		this.size = size;
		this.zIndex = zIndex;

		@clickManager = ClickManager::get();
		clickManager.Listen(this);
	}

	bool containsMouse()
	{
		Vec2f mousePos = getControls().getInterpMouseScreenPos();
		return (
			mousePos.x >= pos.x &&
			mousePos.y >= pos.y &&
			mousePos.x <= pos.x + size.x &&
			mousePos.y <= pos.y + size.y);
	}

	bool isPressed()
	{
		return clickManager.isPressed(this);
	}

	void onLeftDown() {}
	void onRightDown() {}

	void onLeftClick() {}
	void onRightClick() {}
}
