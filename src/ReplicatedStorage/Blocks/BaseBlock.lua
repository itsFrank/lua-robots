--[[
    The basic block that all blocks inherit from
--]]

-- includes
require(game.ReplicatedStorage.Blocks._Types)

local BaseBlock = {}

function BaseBlock.new() : TBlock
    local block = {
        type = nil, -- set by BlockManager:makeBlock()
        model = nil,
    }
    setmetatable(block, BaseBlock)
    return block
end

function BaseBlock:canCollide()
    return false
end

-- override
function BaseBlock:_makeModel()
    error("Called base block _makeModel, make sure your block implements _makeModel()")
end

-- do not override
function BaseBlock:makeModel()
    if self.model then
        error("Block model already exists")
    end

    self.model = self:_makeModel()
    return self.model
end

-- override
-- result will be fed to unpack(data) and provided to the block constructor
function BaseBlock:_serializeData()
    return nil
end

-- do not override
function BaseBlock:serialize()
    return {
        type = self.type.id,
        data = self:_serializeData()
    }
end

function BaseBlock:destroyModel()
    if self.model then
        self.model:Destroy()
        self.model = nil
    end
end

function BaseBlock:hasModel()
    return not(self.model == nil)
end

function BaseBlock:blockEntered(robot)
    -- does nothing by default
end

BaseBlock.__index = BaseBlock
return BaseBlock
