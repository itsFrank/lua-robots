--[[
    This is a block type that represents an invalid block
    A None Block cannot be created
--]]

-- globals
local NoneBlock = {}
NoneBlock.Name = "Invalid Block"

function NoneBlock.new()
    error("A None Block cannot be instantiated")
end

NoneBlock.__index = NoneBlock
return NoneBlock
