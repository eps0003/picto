#include "ToolButton.as"
#include "ClickManager.as"

class Toolkit
{
	private ToolButton@[] buttons;
	private string[] tools = { "Pen", "Eraser", "Fill", "Line", "Square", "Circle" };
	private string selectedTool = tools[0];

	Toolkit()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();

		Vec2f size(120, 60);
		uint spacing = 10;
		uint margin = 20;

		uint n = tools.size();

		for (uint i = 0; i < n; i++)
		{
			int y = screenDim.y - margin - (n - i) * (size.y + spacing);

			ToolButton@ button = ToolButton(this, Vec2f(margin, y), size, tools[i]);
			buttons.push_back(button);
		}
	}

	void SetSelectedTool(ToolButton@ button)
	{
		print("Selected tool: " + button.title);
		selectedTool = button.title;
	}

	bool isSelected(ToolButton@ button)
	{
		return selectedTool == button.title;
	}

	void Render()
	{
		for (uint i = 0; i < buttons.size(); i++)
		{
			buttons[i].Render();
		}
	}
}
