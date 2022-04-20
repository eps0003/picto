#include "ArtistQueue.as"

ArtistQueue@ queue;

void onInit(CRules@ this)
{
	this.addCommandID("queue sync");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set("artist queue", null);
	@queue = ArtistQueue::get();

	if (isServer())
	{
		queue.AddAll();
		queue.Scramble();
		queue.Sync();
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer() && !queue.isQueued(player))
	{
		queue.Add(player);
		queue.Sync();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("queue sync"))
	{
		queue.deserialize(params);
	}
}
