#include "Canvas.as"
#include "Palette.as"
#include "RulesCommon.as"
#include "Utilities.as"

#define CLIENT_ONLY

Canvas@ canvas;

void onInit(CRules@ this)
{
	onRestart(this);
	getHUD().SetCursorOffset(Vec2f(-5, -5));
}

void onRestart(CRules@ this)
{
	@canvas = Canvas(400, 400);
	canvas.Clear();
}

void onTick(CRules@ this)
{
	canvas.Sync();
}

void onRender(CRules@ this)
{
	DrawOnCanvas();
	canvas.Render();
}

Vec2f prevMousePos;

void DrawOnCanvas()
{
	CPlayer@ artist = getCurrentArtist();
	if (artist is null || !artist.isMyPlayer()) return;

	CControls@ controls = getControls();
	Vec2f mousePos = canvas.getMousePosition();

	if (canvas.isPressed())
	{
		if (controls.isKeyJustPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON))
		{
			prevMousePos = mousePos;
		}

		if (controls.isKeyPressed(KEY_LBUTTON))
		{
			canvas.DrawLine(prevMousePos, mousePos, canvas.palette.getSelectedColor());
		}
		else if (controls.isKeyPressed(KEY_RBUTTON))
		{
			canvas.DrawLine(prevMousePos, mousePos, SColor(0, 0, 0, 0));
		}
	}

	prevMousePos = mousePos;
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync canvas"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;
		if (player.isMyPlayer()) return;

		canvas.deserialize(params);
	}
}
