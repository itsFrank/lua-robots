-- sevices
local TweenService = game:GetService("TweenService")

-- libraries
local BaseBlock = require(game.ReplicatedStorage.Blocks.BaseBlock)
local Constants = require(game.ReplicatedStorage.GlobalConstants)

-- constant
local LOWER_DISTANCE = 1.9
local LOWER_TIME = 0.5

local DoorBlock : TBlock = BaseBlock.new()
DoorBlock.Name = "Door Block"

function DoorBlock.new(color) : TBlock
    local block = {
        color = color,
        opened = false
    }
    setmetatable(block, DoorBlock)
    return block
end

function DoorBlock:toggle()
    if self.opened then
        self:close()
    else
        self:open()
    end
end

function DoorBlock:_tweenAnimation(lower)
    local goal = {}
	if lower then
		goal.CFrame = self.model.PrimaryPart.CFrame - Vector3.new(0, LOWER_DISTANCE, 0)
	else
		goal.CFrame = self.model.PrimaryPart.CFrame + Vector3.new(0, LOWER_DISTANCE, 0)
	end

	local tweenInfo = TweenInfo.new(LOWER_TIME, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(self.model.PrimaryPart, tweenInfo, goal)
	tween:Play()
end

function DoorBlock:open()
    if self.opened then
        return
    end
    self:_tweenAnimation(true)
    self.opened = true
end

function DoorBlock:close()
    if not(self.opened) then
        return
    end
    self:_tweenAnimation(false)
    self.opened = false
end

function DoorBlock:canCollide()
    return not(self.opened)
end

function DoorBlock:_makeModel() : Model
    local model = game.ReplicatedStorage.Models.DoorModel:Clone()

    model.Frame.Color = Constants.WALL_COLOR
    model.Body.Color = Constants.DOOR_PART_COLOR[self.color]

    return model
end

function BaseBlock:_serializeData()
    return {self.color}
end

DoorBlock.__index = DoorBlock
return DoorBlock

