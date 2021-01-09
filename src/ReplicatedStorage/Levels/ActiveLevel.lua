-- modules
local Level = require(game.ReplicatedStorage.Levels.Level)

local ActiveLevel = {
    _level = nil
}

function ActiveLevel.isOpened()
    return ActiveLevel._level ~= nil
end

function ActiveLevel.get()
    return ActiveLevel._level
end

function ActiveLevel.open(levelJson) -- level code will be used to load stored levels in the future, currnetly useless
    if ActiveLevel._level then
        error("Cannot open a new level without closing the current one")
    end

    if levelJson then
        ActiveLevel._level = Level.fromJson(levelJson)
    else
        ActiveLevel._level = Level.new()
    end
end

function ActiveLevel.close()
    if ActiveLevel._level ~= nil then
        error("Trying to close the active level when none is opened")
    end
    if ActiveLevel._level:isGenerated() then
        ActiveLevel._level:destroy()
    end
    ActiveLevel._level = nil
end

return ActiveLevel

