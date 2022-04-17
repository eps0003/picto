bool saferead_color(CBitStream@ bs, SColor &out color)
{
	uint col;
	if (!bs.saferead_u32(col)) return false;
	color.set(col);
	return true;
}

bool saferead_player(CBitStream@ bs, CPlayer@ &out player)
{
	u16 id;
	if (!bs.saferead_netid(id)) return false;

	@player = getPlayerByNetworkId(id);
	return player !is null;
}
