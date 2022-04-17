#include "Canvas.as"

#define CLIENT_ONLY

Canvas canvas(100, 100);

void onInit(CRules@ this)
{
	print("Hello World!");
}

void onRender(CRules@ this)
{
	canvas.Render();
}