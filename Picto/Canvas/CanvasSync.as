#include "CanvasAction.as"

void SerializeCanvasActions(CBitStream@ bs, CanvasAction@[] actions)
{
	uint n = actions.size();
	bs.write_u32(n);

	for (uint i = 0; i < n; i++)
	{
		actions[i].Serialize(bs);
	}
}

bool deserializeCanvasActions(CBitStream@ bs, CanvasAction@[]@ targetArray)
{
	uint count;
	if (!bs.saferead_u32(count)) return false;

	for (uint i = 0; i < count; i++)
	{
		u8 type;
		if (!bs.saferead_u8(type)) return false;

		CanvasAction@ action;
		switch (type)
		{
			case CanvasActionType::Point:
				@action = PointAction();
				break;
			case CanvasActionType::Line:
				@action = LineAction();
				break;
			case CanvasActionType::Fill:
				@action = FillAction();
				break;
			case CanvasActionType::FillContiguous:
				@action = FillContiguousAction();
				break;
			default:
				return false;
		}

		if (!action.deserialize(bs)) return false;
		targetArray.push_back(action);
	}

	return true;
}
