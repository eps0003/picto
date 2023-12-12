class ArtistQueue
{
	private string[] usernames;
	private u16 index = 0;
	private Random@ random;

	ArtistQueue()
	{
		@random = Random(Time());
	}

	ArtistQueue(uint seed)
	{
		@random = Random(seed);
	}

	bool isQueued(CPlayer@ player)
	{
		return getIndex(player) != -1;
	}

	CPlayer@ getCurrentArtist()
	{
		return getCount() > 0 ? getPlayerByUsername(usernames[index]) : null;
	}

	CPlayer@[] getQueue()
	{
		CPlayer@[] queue;
		for (uint i = 0; i < usernames.size(); i++)
		{
			CPlayer@ p = getPlayerByUsername(usernames[i]);
			if (p !is null)
			{
				queue.push_back(p);
			}
		}
		return queue;
	}

	uint getCount()
	{
		return usernames.size();
	}

	void Add(CPlayer@ player)
	{
		usernames.push_back(player.getUsername());
	}

	void AddAll()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			if (p !is null)
			{
				Add(p);
			}
		}
	}

	void Remove(CPlayer@ player)
	{
		int index = getIndex(player);
		if (index != -1)
		{
			usernames.removeAt(index);
		}
	}

	void Clear()
	{
		usernames.clear();
		Restart();
	}

	void Next()
	{
		index = (index + 1) % usernames.size();
		// TODO: clear canvas
	}

	int getIndex(CPlayer@ player)
	{
		for (uint i = 0; i < usernames.size(); i++)
		{
			if (usernames[i] == player.getUsername())
			{
				return i;
			}
		}
		return -1;
	}

	void Scramble()
	{
		// Fisher-Yates shuffle
		for (int i = usernames.size() - 1; i > 0; i--)
		{
			uint j = random.NextRanged(i + 1);
			string temp = usernames[i];
			usernames[i] = usernames[j];
			usernames[j] = temp;
		}
	}

	void Restart()
	{
		index = 0;
	}

	void Render()
	{
		GUI::SetFont("menu");

		CPlayer@[] queue = getQueue();
		CPlayer@ artist = getCurrentArtist();
		for (uint i = 0; i < queue.size(); i++)
		{
			CPlayer@ p = queue[i];
			string text = p.getUsername();
			if (p is artist)
			{
				text += " (artist)";
			}
			GUI::DrawText(text, Vec2f(20, 20 + i * 20), color_white);
		}
	}

	void Sync()
	{
		CBitStream bs;
		Serialize(bs);
		getRules().SendCommand(getRules().getCommandID("queue sync"), bs, true);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(index);
		bs.write_u16(usernames.size());
		for (uint i = 0; i < usernames.size(); i++)
		{
			bs.write_string(usernames[i]);
		}
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!bs.saferead_u16(index)) return false;

		u16 size;
		if (!bs.saferead_u16(size)) return false;

		usernames.clear();

		for (uint i = 0; i < size; i++)
		{
			string username;
			if (!bs.saferead_string(username)) return false;

			usernames.push_back(username);
		}

		return true;
	}
}

namespace ArtistQueue
{
	ArtistQueue@ get()
	{
		ArtistQueue@ queue;
		if (!getRules().get("artist queue", @queue))
		{
			@queue = ArtistQueue();
			getRules().set("artist queue", @queue);
		}
		return queue;
	}
}
