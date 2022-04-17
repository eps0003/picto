#include "Canvas.as"

#define CLIENT_ONLY

Canvas canvas(200, 200);

void onRestart(CRules@ this)
{
	canvas.Clear();
}

void onRender(CRules@ this)
{
	canvas.Update();
	canvas.Render();
}
