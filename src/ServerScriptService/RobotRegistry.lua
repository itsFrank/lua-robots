local RobotClass = require(script.Parent.Robot)

local RobotRegistry = {}

local robots = {}

function RobotRegistry.registerNewRobot(model)
	assert(robots[model] == nil, "Robot already registered with model: " .. model.Name)

	robots[model] = RobotClass.new(model)
end

function RobotRegistry.getRobot(model)
	local robot = robots[model]

	assert(robot ~= nil, "No robot registered with model: " .. model.Name)

	return robot
end

-- Can accept a robot instance or a model key
function RobotRegistry.unRegisterRobot(object)
	local model = object
	if object:isRobotClass() then
		model = object.model
	end

	assert(robots[model] ~= nil, "No robot registered with model: " .. model.Name)

	robots[model] = nil
end

return RobotRegistry
