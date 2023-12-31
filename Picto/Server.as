#include "CanvasAction.as"
#include "CanvasSync.as"

#define SERVER_ONLY

CanvasAction@[] actions;

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (actions.size() > 0)
	{
		CBitStream bs;
		SerializeCanvasActions(bs, actions);
		this.SendCommand(this.getCommandID("sync entire canvas"), bs, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync canvas"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		deserializeCanvasActions(params, actions);
	}
}
