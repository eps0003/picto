#include "Canvas.as"
#include "RulesCommon.as"
#include "Utilities.as"

#define CLIENT_ONLY

Canvas@ canvas;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	getHUD().SetCursorOffset(Vec2f(-5, -5));
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@canvas = Canvas::get();
	canvas.Clear();
}

void onTick(CRules@ this)
{
	canvas.Sync();
}

void Render(int)
{
	if (canvas !is null)
	{
		DrawOnCanvas();
		canvas.Render();
	}
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
		if (controls.isKeyJustPressed(KEY_LBUTTON) || controls.isKeyJustPressed(KEY_RBUTTON))
		{
			prevMousePos = mousePos;
		}

		if (controls.isKeyPressed(KEY_LBUTTON))
		{
			canvas.DrawLine(
				Maths::Floor(prevMousePos.x),
				Maths::Floor(prevMousePos.y),
				Maths::Floor(mousePos.x),
				Maths::Floor(mousePos.y),
				canvas.palette.getSelectedColor(),
				3
			);
		}
		else if (controls.isKeyPressed(KEY_RBUTTON))
		{
			canvas.DrawLine(
				Maths::Floor(prevMousePos.x),
				Maths::Floor(prevMousePos.y),
				Maths::Floor(mousePos.x),
				Maths::Floor(mousePos.y),
				0,
				3
			);
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
	else if (cmd == this.getCommandID("sync entire canvas"))
	{
		canvas.deserialize(params);
	}
}
