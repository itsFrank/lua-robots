local scripts = {
	{
		name = "Hello Robot",
		text = [[-- make the robot move forward
robot:moveForward()
]]
	},{
		name = "API Reference",
		text = [[
-- You have access to two objects: 'robot' and 'Blocks'
-- 'robot' lets you control the robot you clicked on
-- 'Blocks' contains the block types of all blocks levels may contain

-- Moving the robot
robot:moveForward()
robot:moveBackward()

-- Turning the robot
robot:turnLeft()
robot:turnRight()

-- Sensing the level
-- senseFront() will return the block type in front of the robot, compare it with elements in 'Blocks'
-- Types: AIR, WALL, DOOR, BUTTON
if robot:senseFront() == Blocks.AIR then
    robot:tirnRight()
end

-- blockedFront() will tell you if the block in front of the robot will impede it's movement
-- e.g. a wall or raised door
if robot:blockedFront() then
    robot:moveBackward()
else
    robot:moveForward()
end

]]
	},{
		name = "Spin left and right",
		text = [[
function spinLeft()
    robot:turnLeft()
    robot:turnLeft()
    robot:turnLeft()
    robot:turnLeft()
end

function spinRight()
    robot:turnRight()
    robot:turnRight()
    robot:turnRight()
    robot:turnRight()
end

spinLeft()
spinRight()
]]
	},
	{
		name = "Dance!",
		text = [[function samba(steps)
    for i = 1, steps*2, 1 do
        if i %2 == 1 then

            robot:moveForward()
            robot:moveForward()
            robot:turnLeft()
            robot:turnRight()
            robot:turnRight()
            robot:turnLeft()

        else

            robot:moveBackward()
            robot:moveBackward()
            robot:turnLeft()
            robot:turnRight()
            robot:turnRight()
            robot:turnLeft()

        end
    end
end

samba(2)]]
    },{
    name = "Basic Maze Solver",
    text = [[while true do
    if robot:blockedFront() then
        robot:turnRight()
    else
        robot:moveForward()
    end
end
]]
    }
}

return scripts
