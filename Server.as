#include "RulesCommon.as"
#include "CanvasAction.as"

#define SERVER_ONLY

CanvasAction@[] actions;

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (getCurrentArtist() is null)
	{
		SetCurrentArtist(player);
	}

	SyncEntireCanvas(this, player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync canvas"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;
		if (player.isMyPlayer()) return;

		deserialize(params);
	}
}

void SyncEntireCanvas(CRules@ this, CPlayer@ player)
{
	uint n = actions.size();
	if (n == 0) return;

	CBitStream bs;
	bs.write_u32(n);
	print("Sending " + n + " actions");

	for (uint i = 0; i < n; i++)
	{
		actions[i].Serialize(bs);
	}

	this.SendCommand(this.getCommandID("sync entire canvas"), bs, player);
}

bool deserialize(CBitStream@ bs)
{
	u32 count;
	if (!bs.saferead_u32(count)) return false;

	for (uint i = 0; i < count; i++)
	{
		u8 type;
		if (!bs.saferead_u8(type)) return false;

		switch (type)
		{
			case CanvasActionType::Line:
			{
				LineAction action;
				if (!action.deserialize(bs)) return false;
				actions.push_back(action);
			}
			continue;
		}

		return false;
	}

	return true;
}
