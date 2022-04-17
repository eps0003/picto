#include "ClickManager.as"

#define CLIENT_ONLY

ClickManager@ clickManager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set("click manager", null);
	@clickManager = ClickManager::get();
}

void onTick(CRules@ this)
{
	clickManager.HandleClicks();

	if (!isWindowFocused())
	{
		clickManager.CancelClick();
	}
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	clickManager.CancelClick();
}
