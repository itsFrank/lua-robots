-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local userInput = game:GetService("UserInputService")

-- libraries
local Roact = require(ReplicatedStorage.libraries.Roact)
local SignalManager = require(ReplicatedStorage.libraries.SignalManager)
local DefaultSyle = require(script.Parent:WaitForChild("DefaultStyle"))
local Blocks = require(ReplicatedStorage.Blocks.BlockManager).init().Types
local Constants = require(ReplicatedStorage.GlobalConstants)

-- locals
local LevelEditorGui = Roact.Component:extend("LevelEditorGui")

-- events
local LevelEditorService = SignalManager:new("LevelEditorService", SignalManager.Enum.SignalType.RemoteFunction)

local ButtonSize = 35
local ButtonPadding = 10

local ButtonIDs = {
    -- ROBOT = "R",
    BUTTON = "B",
    DOOR = "D",
    WALL = "W",
}
local IDBlockTable = {
    -- "R",
    [ButtonIDs.BUTTON] = Blocks.BUTTON,
    [ButtonIDs.DOOR] = Blocks.DOOR,
    [ButtonIDs.WALL] = Blocks.WALL,
}

local InteractableModels = {}
for i, child in pairs(ReplicatedStorage.Models:GetChildren()) do
	InteractableModels[child.Name] = 1
end
InteractableModels["RobotModel"] = nil -- temoprairly make robot uninteractable

function LevelEditorGui:makeLetterButton(letter, position)
    return DefaultSyle.createElement("TextButton", {
        Size = UDim2.fromOffset(ButtonSize, ButtonSize),
        Position = position,
        Text = letter,
        BorderSizePixel = 3,
        BorderColor3 = self.state.activeItem == letter and Color3.fromRGB(114, 42, 178) or nil,

        [Roact.Event.MouseButton1Click] = function(rbx)
            self:setState(function(state)
                if state.activeItem == letter then
                    return { activeItem = Roact.None }
                else
                    return { activeItem = letter }
                end
            end)
        end
    })
end

function LevelEditorGui:makeColorButton(id, color, position)
    return DefaultSyle.createElement("ImageButton", {
        Size = UDim2.fromOffset(ButtonSize, ButtonSize),
        Position = position,
        BorderSizePixel = 3,
        BorderColor3 = self.state.activeColor == id and Color3.fromRGB(114, 42, 178) or nil,

        [Roact.Event.MouseButton1Click] = function(rbx)
            self:setState(function(state)
                return { activeColor = id }
            end)
        end
    },{
        colorSquare = DefaultSyle.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.25, 0.25),
            BackgroundColor3 = color,
        })
    })
end

function LevelEditorGui:makeButtons()
    local offset = ButtonPadding
    local buttons = {}
    for _, letter in pairs(ButtonIDs) do
        buttons[letter] = self:makeLetterButton(letter, UDim2.new(0.5, ButtonSize/-2, 0, offset))
        offset = offset + ButtonSize + ButtonPadding
    end

    buttons["separator"] = DefaultSyle.createElement("Frame", {
        Size = UDim2.new(0.8, 0, 0, 0),
        Position = UDim2.new(0.1, 0, 0, offset)
    })

    offset = offset + 10
    for _, color in pairs(Constants.DOOR_COLOR) do
        buttons[color] = self:makeColorButton(color, Constants.DOOR_PART_COLOR[color], UDim2.new(0.5, ButtonSize/-2, 0, offset))
        offset = offset + ButtonSize + ButtonPadding
    end

    offset = offset + 10 + (ButtonSize*5)
    buttons.serialize = DefaultSyle.createElement("TextButton", {
        Size = UDim2.fromOffset(ButtonSize, ButtonSize),
        Position = UDim2.new(0.5, ButtonSize/-2, 0, offset),
        Text = "S",
        BorderSizePixel = 3,

        [Roact.Event.MouseButton1Click] = function(rbx)
            print(LevelEditorService.SerializeLevel:InvokeServer())
        end
    })
    return buttons
end

function LevelEditorGui:init()
	self:setState({
        collapsed = true,
        activeItem = nil,
        activeColor = Constants.DOOR_COLOR.YELLOW,
	})

	mouse.Button1Up:Connect(function()
        local target = mouse.Target
        local hit = mouse.Hit and mouse.Hit.Position or nil

        if target then
            if target.Name == "Baseplate" and hit then
                if self.state.activeItem and not(userInput:IsKeyDown(Enum.KeyCode.LeftShift)) then
                    LevelEditorService.SetBlock:InvokeServer(hit, IDBlockTable[self.state.activeItem], self.state.activeColor)
                end
            else
                local model = target:FindFirstAncestorWhichIsA("Model")
                if model and InteractableModels[model.Name] then
                    local pos = model.PrimaryPart.Position
                    if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then
                        LevelEditorService.SetBlock:InvokeServer(pos, Blocks.AIR)
                    else
                        if self.state.activeItem then
                            LevelEditorService.SetBlock:InvokeServer(pos, IDBlockTable[self.state.activeItem], self.state.activeColor)
                        end
                    end
                end
            end
        end
	end)
end

function LevelEditorGui:render()
    return Roact.createElement("ScreenGui", {}, {
        MainFrame = DefaultSyle.createElement("Frame", {
            Size = UDim2.new(0, ButtonSize + (2 * ButtonPadding), 0.8, 0),
            Position = UDim2.fromScale(0.0, 0.1),
            Transparency = 0.8,
        },
        self:makeButtons())
    })
end

local PlayerGui = Players.LocalPlayer.PlayerGui
local handle = Roact.mount(Roact.createElement(LevelEditorGui), PlayerGui, "Level Editor UI")
