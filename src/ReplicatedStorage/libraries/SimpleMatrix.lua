--[[
    A simple 2d matrix class allowing access without nested tables
--]]
local MatrixHelper = {}
MatrixHelper.__index = function(table, key)
    return key
end

local Matrix = {}

function Matrix.new(rows, cols, defaultValue)
    local matrix = {
        rows = rows,
        cols = cols,
        _elements = {},
        _defaultValue = defaultValue,
    }
    setmetatable(matrix, Matrix)
    return matrix
end

function Matrix:inBounds(x, y)
    return not(x < 1 or y < 1 or x > self.rows or y > self.cols)
end

function Matrix:_checkBounds(x, y)
    if x < 1 then
        error("index out of bounds (x): " .. tostring(x))
    elseif y < 1 then
        error("index out of bounds (y): " .. tostring(y))
    elseif x > self.rows then
        error("index out of bounds (rows = " .. tostring(self.rows) .. "(x): " .. tostring(x))
    elseif y > self.cols then
        error("index out of bounds (cols = " .. tostring(self.cols) .. "(y): " .. tostring(y))
    end
end

function Matrix:_getDefaultValue()
    if typeof(self._defaultValue == "function") then
        return self._defaultValue()
    end
    return self._defaultValue
end

function Matrix:get(x, y)
    self:_checkBounds(x, y)
    local index = self.cols * (x-1) + (y-1) + 1
    local e = self._elements[index]
    return e and e or self:_getDefaultValue()
end

function Matrix:set(x, y, e)
    self:_checkBounds(x, y)
    local index = self.cols * (x-1) + (y-1) + 1
    self._elements[index] = e
end

function Matrix:erase(x, y)
    self:set(x, y, nil)
end

function Matrix:forEach(op)
    for _, e in pairs(self._elements) do
        op(e)
    end
end

function Matrix:forEachIndex(op)
    for i, e in pairs(self._elements) do
        local x = math.floor(i / self.rows + 1)
        local y = i % self.cols
        op(x, y, e)
    end
end

Matrix.__index = Matrix
return Matrix
