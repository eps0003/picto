#include "Canvas.as"
#include "Palette.as"

#define CLIENT_ONLY

Canvas@ canvas;
Palette@ palette;

void onInit(CRules@ this)
{
	onRestart(this);
	getHUD().SetCursorOffset(Vec2f(-5, -5));
}

void onRestart(CRules@ this)
{
	@canvas = Canvas(200, 200);
	@palette = Palette();
	canvas.Clear();
}

void onRender(CRules@ this)
{
	canvas.Update();
	canvas.Render();
	palette.Render();
}
