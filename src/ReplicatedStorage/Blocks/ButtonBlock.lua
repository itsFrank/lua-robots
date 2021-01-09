-- libraries
local ActiveLevel = require(game.ReplicatedStorage.Levels.ActiveLevel)
local BaseBlock = require(game.ReplicatedStorage.Blocks.BaseBlock)
local Constants = require(game.ReplicatedStorage.GlobalConstants)

local ButtonBlock : TBlock = BaseBlock.new()
ButtonBlock.Name = "Button Block"

function ButtonBlock.new(color) : TBlock
    local block = {
        color = color,
        activated = false,
    }
    setmetatable(block, ButtonBlock)
    return block
end

function ButtonBlock:canCollide()
    return false
end

function ButtonBlock:blockEntered(robot)
    -- self.model.Button.Transparency = 1.0
    -- ActiveLevel.get():activateDoors(self.color, true)
    ActiveLevel.get():toggleDoors(self.color)
end

function ButtonBlock:_makeModel() : Model
    local model = game.ReplicatedStorage.Models.ButtonModel:Clone()

    model.Base.Color = Constants.WALL_COLOR
    model.Button.Color = Constants.DOOR_PART_COLOR[self.color]

    return model
end

function BaseBlock:_serializeData()
    return {self.color}
end

ButtonBlock.__index = ButtonBlock
return ButtonBlock

