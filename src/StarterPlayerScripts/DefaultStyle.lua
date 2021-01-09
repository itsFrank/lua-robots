--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.libraries.Roact)

-- easily create bool tables using a list interface
function Set (list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
	return set
end

-- universal styling
local defaultTable = {
	BackgroundColor3 = Color3.fromRGB(46, 47, 56),
	BorderColor3 = Color3.fromRGB(0,0,0),
	BorderMode = Enum.BorderMode.Outline,
	BorderSizePixel = 2,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.Code,
	TextSize = 18
}

-- override style for specific elements
local overrideTable = {
	TextLabel = {
		BackgroundTransparency = 100
	},
	TextButton = {
		BackgroundColor3 = Color3.fromRGB(66,66,85)
	},
	ImageButton = {
		BackgroundColor3 = Color3.fromRGB(66,66,85)
	},
	TextBox = {
		BackgroundColor3 = Color3.fromRGB(66, 67, 76),
	},
	LabelledCheckbox = {
		BorderSizePixel = 0,
		CheckBackgroundColor3 = Color3.fromRGB(66,66,85)
	},
}

-- prevent certain styles from being captured
local allowedPropSets = {
	Frame = Set{"BackgroundColor3", "BorderColor3", "BorderMode", "BorderSizePixel"},
	ScrollingFrame = Set{"BackgroundColor3", "BorderColor3", "BorderMode", "BorderSizePixel"},
	TextLabel = Set{"TextColor3", "Font", "TextSize"},
	TextBox = Set{"TextColor3", "Font", "TextSize"},
	TextButton = Set{"BackgroundColor3", "BorderColor3", "BorderMode", "BorderSizePixel", "TextColor3", "Font", "TextSize"},
	ImageButton = Set{"BackgroundColor3", "BorderColor3", "BorderMode", "BorderSizePixel"},
	LabelledCheckbox = Set{"BackgroundColor3", "BorderColor3", "BorderMode", "BorderSizePixel", "TextColor3", "Font", "TextSize"},
}

local function mergeDefaultStyle(host, props)
	local merged = {}

	for key, value in pairs(defaultTable) do
		if allowedPropSets[host] and allowedPropSets[host][key] then
			merged[key] = value
		end
	end

	if overrideTable[host] then
		for key, value in pairs(overrideTable[host]) do
			merged[key] = value
		end
	end

	for key, value in pairs(props) do
		merged[key] = value
	end

	return merged
end

local DefaultStyle = {}

-- Call patterns:
--	host, props, children
--	hostName, host, props, children
function DefaultStyle.createElement(p1, p2, p3, p4)
	-- createElement("elemName", { props }, { children })
	local hostName = p1
	local host = p1
	local props = p2
	local children = p3

	-- createElement("elemName", elemFunc, { props }, { children })
	if typeof(p2) == "function" then
		hostName = p1
		host = p2
		props = p3
		children = p4
	end

	local styledProps = mergeDefaultStyle(hostName, props)
	return Roact.createElement(host, styledProps, children)
end



function DefaultStyle.getValue(host, prop)
	if overrideTable[host] and overrideTable[host][prop] then
		return overrideTable[host][prop]
	else
		return defaultTable[prop]
	end
end

return DefaultStyle
