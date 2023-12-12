#include "Canvas.as"
#include "ArtistQueue.as"
#include "Utilities.as"

#define CLIENT_ONLY

Canvas@ canvas;
ArtistQueue@ queue;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	getHUD().SetCursorOffset(Vec2f(-5, -5));
	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set("canvas", null);
	@canvas = Canvas::get();
	@queue = ArtistQueue::get();
	canvas.Clear();
}

uint size = 6;

void onTick(CRules@ this)
{
	canvas.Sync();

	CControls@ controls = getControls();
	if (controls.mouseScrollDown && size > 1)
	{
		size--;
	}
	if (controls.mouseScrollUp && size < 20)
	{
		size++;
	}
}

void onRender(CRules@ this)
{
	if (canvas !is null)
	{
		DrawOnCanvas();
		GUI::DrawText("Size: " + size, Vec2f(20, 100), color_white);
	}
}

void Render(int)
{
	if (canvas !is null)
	{
		DrawOnCanvas();
		canvas.Render();
		queue.Render();
	}
}

Vec2f prevMousePos;

void DrawOnCanvas()
{
	CPlayer@ artist = queue.getCurrentArtist();
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
				prevMousePos.x,
				prevMousePos.y,
				mousePos.x,
				mousePos.y,
				canvas.palette.getSelectedColor(),
				size
			);
		}
		else if (controls.isKeyPressed(KEY_RBUTTON))
		{
			canvas.DrawLine(
				prevMousePos.x,
				prevMousePos.y,
				mousePos.x,
				mousePos.y,
				0,
				size
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
