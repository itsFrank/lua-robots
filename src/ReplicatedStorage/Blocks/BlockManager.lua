require(game.ReplicatedStorage.Blocks._Types)

-- globals
local currentId = 1

local BlockManager: TBlockManager = {}

BlockManager.Types = {}
BlockManager._typesByID = {}
BlockManager._blockNames = {}
BlockManager._blockClasses = {}
BlockManager.initialized = false

function BlockManager.init()
    if BlockManager.initialized then
        return
    end

    local NoneBlock = require(game.ReplicatedStorage.Blocks.NoneBlock)
    local AirBlock = require(game.ReplicatedStorage.Blocks.AirBlock)
    local WallBlock = require(game.ReplicatedStorage.Blocks.WallBlock)
    local DoorBlock = require(game.ReplicatedStorage.Blocks.DoorBlock)
    local ButtonBlock = require(game.ReplicatedStorage.Blocks.ButtonBlock)

    BlockManager._registerBlock(NoneBlock.Name, "NONE", NoneBlock)
    BlockManager._registerBlock(AirBlock.Name, "AIR", AirBlock)
    BlockManager._registerBlock(WallBlock.Name, "WALL", WallBlock)
    BlockManager._registerBlock(DoorBlock.Name, "DOOR", DoorBlock)
    BlockManager._registerBlock(ButtonBlock.Name, "BUTTON", ButtonBlock)

    for _, type in pairs(BlockManager.Types) do
        BlockManager._typesByID[type.id] = type
    end

    BlockManager.initialized = true

    return BlockManager
end

function BlockManager._typeEq(a, b)
    return a.id == b.id
end

function BlockManager._createBlockType(id)
    local blockType = {
        id = id,
        clone = function() return BlockManager._createBlockType(id) end
    }

    local metatable = {}
    metatable.__eq = BlockManager._typeEq
    function metatable:__tostring()
        return BlockManager._blockNames[id]
    end

    setmetatable(blockType, metatable)
    return blockType
end

function BlockManager._registerBlock(blockName, typeName, blockClass)
    local id = currentId
    currentId = currentId + 1

    local blockType = BlockManager._createBlockType(id)

    BlockManager._blockNames[id] = blockName
    BlockManager._blockClasses[id] = blockClass
    BlockManager.Types[typeName] = blockType
end

function BlockManager.makeBlock(type, ...)
    if not BlockManager.initialized then
        error("BlockManager was not initialized")
    end

    if type == nil then
        error("Invalid block type")
    end

    if typeof(type) == "number" then
        type = BlockManager._typesByID[type]
    end
    local block = BlockManager._blockClasses[type.id].new(...)
    block.type = type
    return block
end

-- used to provide a separate table to robot scripts so that they cant modify the real table
function BlockManager.cloneTypeTable()
    if not BlockManager.initialized then
        error("BlockManager was not initialized")
    end

    local newTypes = {}
    for name, type in pairs(BlockManager.Types) do
        newTypes[name] = type:clone()
    end
    return newTypes
end

BlockManager.__index = BlockManager
return BlockManager
