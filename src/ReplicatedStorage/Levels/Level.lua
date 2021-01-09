--[[
    The main level class that will contain the blocks that player-made levels consist of
--]]

-- services
local HttpService = game:GetService("HttpService")
local workspace = game:WaitForChild("Workspace")

-- libraries
local Matrix = require(game.ReplicatedStorage.libraries.SimpleMatrix)
local Constants = require(game.ReplicatedStorage.GlobalConstants)
local BlockManager = require(game.ReplicatedStorage.Blocks.BlockManager)
local Blocks = BlockManager.Types

-- types
export type TLevel = {folderInstance: Folder, worldOffset: Vector2, blocks: any, new: () -> TLevel}

-- constants
local Level = {}

function Level.new()
    local level = {
        folderInstance = nil,
        worldOffset = Vector2.new(2, 2), -- this is based on the current baseplate texture pattern
        blocks = Matrix.new(Constants.DEFAULT_LEVEL_SIZE.X, Constants.DEFAULT_LEVEL_SIZE.Y, function()
            return BlockManager.makeBlock(Blocks.AIR)
        end),
    }
    setmetatable(level, Level)
    return level
end

function Level:getBlock(x, y)
    return self.blocks:get(x, y)
end

function Level:activateDoors(color, open)
    self.blocks:forEach(function(block)
        if block.type == Blocks.DOOR and block.color == color then
            if open then
                block:open()
            else
                block:close()
            end
        end
    end)
end

function Level:toggleDoors(color, open)
    self.blocks:forEach(function(block)
        if block.type == Blocks.DOOR and block.color == color then
            block:toggle()
        end
    end)
end

function Level:getBlockWorldPos(worldX, wolrdY)
    local x, y =  self:_computeLevelPosition(Constants.BLOCK_SIZE, Vector2.new(worldX, wolrdY))
    return self.blocks:get(x, y)
end

function Level:indexInBounds(x, y)
    return self.blocks:inBounds(x, y)
end

function Level:worldPosInBounds(worldX, wolrdY)
    local x, y =  self:_computeLevelPosition(Constants.BLOCK_SIZE, Vector2.new(worldX, wolrdY))
    return self.blocks:inBounds(x, y)
end

function Level:setBlock(x, y, type, ...)
    if self:isGenerated() then
        self.blocks:get(x, y):destroyModel()
    end

    if type == Blocks.AIR then
        self.blocks:erase(x, y)
    else
        local block = BlockManager.makeBlock(type, ...)
        self.blocks:set(x, y, block)
        if self:isGenerated() then
            self:_makeBlockModel(x, y, block)
        end
    end
end

function Level:setBlockWorldPos(worldX, wolrdY, type, ...)
    local x, y =  self:_computeLevelPosition(Constants.BLOCK_SIZE, Vector2.new(worldX, wolrdY))
    return self:setBlock(x, y, type, ...)
end

function Level:_computeWorldPosition(blockDimensions : Vector2, levelPosition: Vector2, blockHeight: number) : Vector3
    return Vector3.new(
        self.worldOffset.X + (blockDimensions.X * levelPosition.X) - (blockDimensions.X / 2),
        (blockHeight / 2),
        self.worldOffset.Y + (blockDimensions.Y * levelPosition.Y) - (blockDimensions.Y / 2)
    )
end

function Level:_computeLevelPosition(blockDimensions : Vector2, worldPosition: Vector2)
    local x = math.floor((worldPosition.X - self.worldOffset.X) / blockDimensions.X) + 1
    local y = math.floor((worldPosition.Y - self.worldOffset.Y) / blockDimensions.Y) + 1
    return x, y
end

function Level:_makeBlockModel(x, y, block)
    if not(self.folderInstance) then
        error("Tried to make a block model, when the level folder has not been created")
    end

    local blockModel : Model = block:makeModel()
    if blockModel then
        blockModel.Parent = self.folderInstance
        blockModel.PrimaryPart.CFrame = CFrame.new(self:_computeWorldPosition(Constants.BLOCK_SIZE, Vector2.new(x, y), blockModel.PrimaryPart.Size.Y))
    end
end

function Level:generate()
    if workspace:FindFirstChild("level") then
        error("A level already exists, destroy it before generating a new one")
    end

    self.folderInstance = Instance.new("Folder", workspace)
    self.folderInstance.Name = "Level"

    self.blocks:forEachIndex(function(x, y, block)
        self:_makeBlockModel(x, y, block)
    end)
end

function Level:isGenerated()
    return self.folderInstance ~= nil
end

function Level:destroy()
    if self.folderInstance == nil then
        error("Level folder is nil, check whether the level was already destroyed, or never generated")
    end

    self.blocks:forEach(function(block)
        block:destroyModel()
    end)

    self.folderInstance:Destroy()
    self.folderInstance = nil
end


function Level.fromJson(levelJson)
    local success, levelData = pcall(function()
        return HttpService:JSONDecode(levelJson)
    end)

    if success then
        local level = Level.new()
        for _, data in pairs(levelData) do
            level:setBlock(data.pos[1], data.pos[2], data.type, table.unpack(data.data))
        end
        return level
    else
        error(levelData) -- wont be an error in the future
    end
end

function Level:serializeJson()
    local levelData = {}
    self.blocks:forEachIndex(function(x, y, block)
        local blockData = block:serialize()
        blockData.pos = {x, y}
        table.insert(levelData, blockData)
    end)

    return HttpService:JSONEncode(levelData)
end

Level.__index = Level
return Level
