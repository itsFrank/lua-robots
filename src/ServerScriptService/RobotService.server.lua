-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local RobotRegistry = require(script.Parent.RobotRegistry)
local SignalManager = require(ReplicatedStorage.libraries.SignalManager)

-- locals
local robotServiceSignalManager = SignalManager:new("RobotService", SignalManager.Enum.SignalType.RemoteFunction)

-- Temporirly register the dev robot models
local robotModels = workspace:WaitForChild("Robots")

for index, model in pairs(robotModels:GetChildren()) do
	RobotRegistry.registerNewRobot(model)
end

-- Run code on some robot
robotServiceSignalManager.RunRobotCode = function(player, model, scriptText, scriptName)
	local robot = RobotRegistry.getRobot(model)

	local f, err = loadstring(scriptText)

	if f then
		robot:executeScript(f, scriptName)
		return nil
	else
		return err
	end
end

-- Kill active script on some robot
robotServiceSignalManager.KillRobotCode = function(player, model)
	local robot = RobotRegistry.getRobot(model)
	robot:killActiveScript()
	return true
end

-- Get data relevant to robot GUI from model reference
robotServiceSignalManager.GetRobotData = function(player, model)
	local robot = RobotRegistry.getRobot(model)
	if robot then
		return {
			name = robot.name,
			idle = robot.activeCoroutine == nil,
			activeScript = robot.activeScriptName,
			displayNameAbove = robot.displayNameAbove,
		}
	else
		return nil
	end
end

-- Set a robot's name from it's model
robotServiceSignalManager.SetRobotName = function(player, model, newName)
	local robot = RobotRegistry.getRobot(model)
	if robot then
		robot:setName(newName)
	end

	return newName
end

-- Change is a robot's name is displaye above from it's model
robotServiceSignalManager.SetRobotDisplayNameAbove = function(player, model, newValue)
	local robot = RobotRegistry.getRobot(model)
	if robot then
		robot:setDisplayNameAbove(newValue)
	end

	return newValue
end

-----------------
-- UNUSED EVENTS
-----------------
-- Get a robot's name from it's model
local getRobotName = Instance.new("RemoteFunction")
getRobotName.Parent = ReplicatedStorage
getRobotName.Name = "GetRobotName"

local function onGetRobotNameRequested(player, model)
	local robot = RobotRegistry.getRobot(model)
	if robot then
		return robot.name
	else
		return nil
	end
end

getRobotName.OnServerInvoke = onGetRobotNameRequested

-- Check if robot idle from model
local isRobotIdle = Instance.new("RemoteFunction")
isRobotIdle.Parent = ReplicatedStorage
isRobotIdle.Name = "IsRobotIdle"

local function onIsRobotIdleRequested(player, model)
	local robot = RobotRegistry.getRobot(model)
	if robot then
		return robot.activeCoroutine == nil
	else
		return true
	end
end

isRobotIdle.OnServerInvoke = onIsRobotIdleRequested

