-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ActiveLevel = require(ReplicatedStorage.Levels.ActiveLevel)
local SignalManager = require(ReplicatedStorage.libraries.SignalManager)

-- locals
local levelEditorSignalManager = SignalManager:new("LevelEditorService", SignalManager.Enum.SignalType.RemoteFunction)

-- Set block at world coord
levelEditorSignalManager.SetBlock = function(player, worldPos, type, ...)
    if not(worldPos) or not(type) then
        return
    end

    if ActiveLevel.isOpened() and ActiveLevel.get():worldPosInBounds(worldPos.X, worldPos.Z) then
        ActiveLevel.get():setBlockWorldPos(worldPos.X, worldPos.Z, type.id, ...) -- use id because client-server comms stripped functions
    end
end

levelEditorSignalManager.SerializeLevel = function(player)
    if ActiveLevel.isOpened() then
        return ActiveLevel.get():serializeJson()
    end
    return nil
end
