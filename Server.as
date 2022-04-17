#include "RulesCommon.as"

#define SERVER_ONLY

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (getCurrentArtist() is null)
	{
		SetCurrentArtist(player);
	}
}
