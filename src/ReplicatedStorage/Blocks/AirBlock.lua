-- libraries
local BaseBlock = require(game.ReplicatedStorage.Blocks.BaseBlock)

local AirBlock = BaseBlock.new()
AirBlock.Name = "Air Block"

function AirBlock.new() : TBlock
    local block = {}
    setmetatable(block, AirBlock)
    return block
end

function AirBlock._makeModel() : Model
    return nil
end

AirBlock.__index = AirBlock
return AirBlock

