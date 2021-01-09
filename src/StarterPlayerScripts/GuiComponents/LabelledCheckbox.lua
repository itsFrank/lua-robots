-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- libraries
local Roact = require(ReplicatedStorage.libraries.Roact)

-- constants
local enabledImage = "rbxassetid://1489284025"

local defaultProps = {
	-- Custom
	Text = "",
	Font = nil,
	TextSize = nil,
	TextColor3 = nil,
	CheckBoxSize = 12.0,
	TextCheckPadding = 0.0,
	-- Image Button
	Size = UDim2.new(0, 20, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
    -- TextLabel
    BackgroundTransparency = 0.0,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderSizePixel = 1,
	BorderColor3 = Color3.fromRGB(0, 0, 0),
    -- ImageLabel
	CheckBackgroundTransparency = 0.0,
	CheckBackgroundColor3 = Color3.fromRGB(192, 192, 255),
	CheckBorderSizePixel = 1,
	CheckBorderColor3 = Color3.fromRGB(0, 0, 0),
}

local function mergeProps(props)
	local result = {}

	for key, value in pairs(defaultProps) do
		result[key] = value
	end

	for key, value in pairs(props) do
		result[key] = value
	end

	return result
end

local function LabelledCheckbox(props)
	local instanceProps = mergeProps(props)

	local Value = instanceProps.Value
	local SetValue = instanceProps.SetValue

	return Roact.createElement("ImageButton", {
		Size = instanceProps.Size,
		Position = instanceProps.Position,
		BackgroundTransparency = 1.0,
		ImageTransparency = 1.0,

		[Roact.Event.MouseButton1Click] = function(rbx)
			-- nil -> true, false -> true, true -> false
			if SetValue then
				SetValue(Value ~= true)
			end
		end,
	}, {
		Label = Roact.createElement("TextLabel", {
			Text = instanceProps.Text,
			Font = instanceProps.Font,
			TextSize = instanceProps.TextSize,
			TextColor3 = instanceProps.TextColor3,
			Size = UDim2.new(1, -instanceProps.CheckBoxSize + instanceProps.TextCheckPadding, 1, 0),
			BackgroundTransparency = instanceProps.BackgroundTransparency,
			BackgroundColor3 = instanceProps.BackgroundColor3,
			BorderSizePixel = instanceProps.BorderSizePixel,
			BorderColor3 = instanceProps.BorderColor3,
		},
		{
			CheckImage = Roact.createElement("ImageLabel", {
				Image = Value and enabledImage or "",
				Size = UDim2.new(0, instanceProps.CheckBoxSize, 0, instanceProps.CheckBoxSize),
				Position = UDim2.new(1, -instanceProps.CheckBoxSize, 0.5, instanceProps.CheckBoxSize / -2),

				BackgroundTransparency = instanceProps.CheckBackgroundTransparency or 0.0,
				BackgroundColor3 = instanceProps.CheckBackgroundColor3 or Color3.fromRGB(192, 192, 255),
				BorderSizePixel = instanceProps.CheckBorderSizePixel or 1,
				BorderColor3 = instanceProps.CheckBorderColor3 or Color3.fromRGB(0, 0, 0),
			})
		})
	})
end

return LabelledCheckbox
