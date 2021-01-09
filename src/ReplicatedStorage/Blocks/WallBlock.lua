-- libraries
local BaseBlock = require(game.ReplicatedStorage.Blocks.BaseBlock)
local Constants = require(game.ReplicatedStorage.GlobalConstants)

-- local constants
local BLOCK_HEIGHT = 2

local WallBlock = BaseBlock.new()
WallBlock.Name = "Wall Block"

function WallBlock.new() : TBlock
    local block = {}
    setmetatable(block, WallBlock)
    return block
end

function WallBlock:canCollide()
    return true
end

function WallBlock:_makeModel() : Model
    local model = Instance.new("Model")

    local part = Instance.new("Part", model)
    part.Size = Vector3.new(Constants.BLOCK_SIZE.X, BLOCK_HEIGHT, Constants.BLOCK_SIZE.Y)
    part.Color = Constants.WALL_COLOR
    part.Anchored = true
    part.CanCollide = true
    part.TopSurface = "Smooth"
    part.BottomSurface = "Smooth"

    model.PrimaryPart = part
    model.Name = "WallModel"

    return model
end

WallBlock.__index = WallBlock
return WallBlock

