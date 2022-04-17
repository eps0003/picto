#include "Canvas.as"

#define CLIENT_ONLY

Canvas canvas(100, 100);

void onRestart(CRules@ this)
{
	canvas.Clear();
}

void onRender(CRules@ this)
{
	canvas.Update();
	canvas.Render();
}