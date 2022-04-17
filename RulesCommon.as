CPlayer@ getCurrentArtist()
{
	string username = getRules().get_string("artist");
	return getPlayerByUsername(username);
}

void SetCurrentArtist(CPlayer@ player)
{
	getRules().set_string("artist", player.getUsername());
	getRules().Sync("artist", true);
}
