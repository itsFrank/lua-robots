-- sevices
local TweenService = game:GetService("TweenService")

-- modules
local ActiveLevel = require(game.ReplicatedStorage.Levels.ActiveLevel)
local BlockManager = require(game.ReplicatedStorage.Blocks.BlockManager)

local Robot = {}
Robot.__index = Robot

local MOVE_DISTANCE = 4
local MOVE_TIME = 0.75
local THINK_TIME = 0.5

local MOVE_TIME_PER_STUD = MOVE_TIME / MOVE_DISTANCE
local BLOCKED_MOVE_DISTANCE = MOVE_DISTANCE / 8
local BLOCKED_MOVE_TIME = MOVE_TIME_PER_STUD * BLOCKED_MOVE_DISTANCE
local BLOCKED_JUMP_HEIGHT = 1
local BLOCKED_JUMP_TIME = 0.25

function Robot.new(model)
	local defaultName = "Robot"

	local newRobot = {
		model = model,
		facing = Vector3.new(0, 0, -1),
		activeCoroutine = nil,
		activeScriptName = "none",
		name = defaultName,
		displayNameAbove = true,
	}

	model.nameGui.nameLabel.Text = defaultName
  	return setmetatable(newRobot, Robot)
end

-- limit access to robot class members for user scripts
function Robot:_createUserAPI()
	local robot = self
	local userAPI = {
		blockedFront = function() return robot:blockedFront() end,
		senseFront = function() return robot:senseFront() end,
		moveForward = function() robot:moveForward() end,
		moveBackward = function() robot:moveBackward() end,
		turnLeft = function() robot:turnLeft() end,
		turnRight = function() robot:turnRight() end,
	}
	return userAPI
end

function Robot:_positionFront()
	return self.model.PrimaryPart.Position + (self.facing * MOVE_DISTANCE)
end

function Robot:_positionBack()
	return self.model.PrimaryPart.Position + (self.facing * (-1 * MOVE_DISTANCE))
end

function Robot:_tweenTranslate(forward)
	local goal = {}
	if forward then
		goal.Position = self:_positionFront()
	else
		goal.Position = self:_positionBack()
	end

	local tweenInfo = TweenInfo.new(MOVE_TIME, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(self.model.PrimaryPart, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
end

function Robot:_tweenRotate(right)
	local goal = {}
	if right then
		goal.Orientation = self.model.PrimaryPart.Orientation + Vector3.new(0, -90, 0)
	else
		goal.Orientation = self.model.PrimaryPart.Orientation + Vector3.new(0, 90, 0)
	end

	local tweenInfo = TweenInfo.new(MOVE_TIME, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(self.model.PrimaryPart, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
end
function Robot:_tweenBlockedAnimation(forward)
	local originalPosition = self.model.PrimaryPart.Position

	local goal = {}
	if forward then
		goal.Position = self.model.PrimaryPart.Position + (self.facing * BLOCKED_MOVE_DISTANCE)
	else
		goal.Position = self.model.PrimaryPart.Position + (self.facing * (-1 * BLOCKED_MOVE_DISTANCE))
	end

	-- forward
	local tweenInfo = TweenInfo.new(BLOCKED_MOVE_TIME, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(self.model.PrimaryPart, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	-- jump
	goal.Position = self.model.PrimaryPart.Position + Vector3.new(0, BLOCKED_JUMP_HEIGHT, 0)
	local jumpTweenInfo = TweenInfo.new(BLOCKED_JUMP_TIME, Enum.EasingStyle.Linear)
	tween = TweenService:Create(self.model.PrimaryPart, jumpTweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	goal.Position = self.model.PrimaryPart.Position + Vector3.new(0, -BLOCKED_JUMP_HEIGHT, 0)
	jumpTweenInfo = TweenInfo.new(BLOCKED_JUMP_TIME, Enum.EasingStyle.Linear)
	tween = TweenService:Create(self.model.PrimaryPart, jumpTweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	-- backward
	goal.Position = originalPosition
	tweenInfo = TweenInfo.new(BLOCKED_MOVE_TIME, Enum.EasingStyle.Linear)
	tween = TweenService:Create(self.model.PrimaryPart, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
end

-- Without this function check at the start of every robot API call
-- Multiple scripts could be giving the robot conflicting instructions
-- This ensures only one script is controling the robot at a time
-- It also yields any errant disconnected scripts so they stop using resources
function Robot:_checkCoroutineKill()
	if coroutine.running() ~= self.activeCoroutine then
		print("Robot yielded disconnected coroutine")
		coroutine.yield()
	end
end

function Robot:_canMoveTo(target: Vector3)
	if not(ActiveLevel.isOpened()) or not(ActiveLevel.get():worldPosInBounds(target.X, target.Z)) then
		return true
	end
	return not(ActiveLevel.get():getBlockWorldPos(target.X, target.Z):canCollide())
end

function Robot:_notifyEnterBlock(worldPos)
	if ActiveLevel.isOpened() and ActiveLevel.get():worldPosInBounds(worldPos.X, worldPos.Z) then
		ActiveLevel.get():getBlockWorldPos(worldPos.X, worldPos.Z):blockEntered(self)
	end
end

function Robot:killActiveScript()
	self.activeCoroutine = nil
	self.activeScriptName = "none"
end

function Robot:setName(newName)
	self.name = newName
	self.model.nameGui.nameLabel.Text = newName
end

function Robot:setDisplayNameAbove(value)
	self.displayNameAbove = value
	self.model.nameGui.Enabled = value
end

function Robot:executeScript(f, scriptName)
	setfenv(f, {robot = self:_createUserAPI(), print = print, Blocks = BlockManager.cloneTypeTable()})

	self.activeCoroutine = coroutine.create(function()
		local success, message = pcall(f)
		if not(success) then
			print("Script Error: " .. message)
		end
		-- without this the robot will be treated as running rather than idle even after the script has ended
		if coroutine.running() == self.activeCoroutine then
			self.activeCoroutine = nil
			self.activeScriptName = "none"
		end
	end)

	self.activeScriptName = scriptName
	coroutine.resume(self.activeCoroutine)
end

function Robot:isRobotClass()
	return true
end

--------------------
---- PUBLIC API ----
--------------------

function Robot:blockedFront()
	self:_checkCoroutineKill()
	return not(self:_canMoveTo(self:_positionFront()))
end

function Robot:senseFront()
	self:_checkCoroutineKill()

	local posFront = self:_positionFront()

	if not(ActiveLevel.isOpened() and ActiveLevel.get():worldPosInBounds(posFront.X, posFront.Z)) then
		return BlockManager.Types.AIR
	end

	return ActiveLevel.get():getBlockWorldPos(posFront.X, posFront.Z).type:clone()
end

function Robot:moveForward()
	self:_checkCoroutineKill()
	if (self:_canMoveTo(self:_positionFront())) then
		self:_tweenTranslate(true)
	else
		self:_tweenBlockedAnimation(true)
	end

	self:_notifyEnterBlock(self.model.PrimaryPart.Position)

	wait(THINK_TIME)
end

function Robot:moveBackward()
	self:_checkCoroutineKill()
	if (self:_canMoveTo(self:_positionBack())) then
		self:_tweenTranslate(false)
	else
		self:_tweenBlockedAnimation(false)
	end

	self:_notifyEnterBlock(self.model.PrimaryPart.Position)

	wait(THINK_TIME)
end

function Robot:turnRight()
	self:_checkCoroutineKill()

	self:_tweenRotate(true)

	self.facing = Vector3.new(-1 * self.facing.Z, 0, self.facing.X)

	wait(THINK_TIME)
end

function Robot:turnLeft()
	self:_checkCoroutineKill()

	self:_tweenRotate(false)

	self.facing = Vector3.new(self.facing.Z, 0, -1 * self.facing.X)

	wait(THINK_TIME)
end

return Robot
