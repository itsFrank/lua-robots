-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- libraries
local Roact = require(ReplicatedStorage.libraries.Roact)
local SignalManager = require(ReplicatedStorage.libraries.SignalManager)
local DefaultSyle = require(script.Parent:WaitForChild("DefaultStyle"))
local GuiComponents = script.Parent:WaitForChild("GuiComponents")
local TextBoxPlus = require(GuiComponents:WaitForChild("TextBoxPlus"))
local LabelledCheckbox = require(GuiComponents:WaitForChild("LabelledCheckbox"))

-- events
local RobotService = SignalManager:new("RobotService")

-- constants
local ROBOT_MODEL = 'RobotModel'

-- locals
local localScripts = require(script.Parent:WaitForChild("DefaultRobotScripts"))
local RobotGui = Roact.Component:extend("RobotGui")
RobotGui.ViewState = {None = 0, ScriptMenu=1, ScriptEditor=2, Running=3}

function RobotGui:init()

	self.TBPFrameRef = Roact.createRef()
	self.TBPlusObject = nil
	self.TBPinitialized = false

	self.currentRobotData = nil
	self.currentRobotModel = nil

	self:setState({
		robot = nil,
		robotName = "Unnamed Robot",
		nameEdit = false,
		activeScript = nil,
		activeScriptIndex = nil,
		viewState = RobotGui.ViewState.None,
		closeRequested = false,
	})

	mouse.Button1Up:Connect(function()
		if mouse.Target and mouse.Target.Parent then
			if mouse.Target.Parent.Name == ROBOT_MODEL then
				if localPlayer:DistanceFromCharacter(mouse.Target.Position) < 10 then
					self.currentRobotModel = mouse.Target.Parent
					self.currentRobotData = RobotService.GetRobotData:InvokeServer(self.currentRobotModel)

					self:setState(function(state)
						return {
							viewState = self.currentRobotData.idle and RobotGui.ViewState.ScriptMenu or RobotGui.ViewState.Running,
							robotName = self.currentRobotData.name,
							robotDispayNameAbove = self.currentRobotData.displayNameAbove,
						}
					end)
				end
			end
		end
	end)

end

function RobotGui:createScriptList(scripts)
	local listElements = {}
	for index, value in pairs(scripts) do
		listElements[index] = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.fromOffset(0, (index-1)*50),
			BackgroundColor3 = index % 2 == 0 and Color3.fromRGB(36, 37, 46) or Color3.fromRGB(26, 27, 36),
		}, {
			ScriptName = DefaultSyle.createElement("TextLabel", {
				Text = value.name,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -200, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 22,
			}),
			EditScriptButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(80,30),
				Position = UDim2.new(1, -220, 0, 10),
				Text = "Edit",

				[Roact.Event.MouseButton1Click] = function(rbx)
					self:setState(function(state)
						return {
							activeScript = value,
							activeScriptIndex = index,
							viewState = RobotGui.ViewState.ScriptEditor
						}
					end)
			    end
			}),
			RunScriptButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(80,30),
				Position = UDim2.new(1, -120, 0, 10),
				Text = "Run >",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(77, 213, 111),

				[Roact.Event.MouseButton1Click] = function(rbx)
					RobotService.RunRobotCode:InvokeServer(self.currentRobotModel, value.text, value.name)
					self.TBPlusObject = nil
					self.TBPinitialized = false

					self:setState(function(state)
						return {
							robot = nil,
							robotName = "Unnamed Robot",
							robotDispayNameAbove = false,
							nameEdit = false,
							activeScript = nil,
							activeScriptIndex = nil,
							viewState = RobotGui.ViewState.None,
						}
					end)
			    end
			}),
		})
	end
	return Roact.createFragment(listElements)
end

function RobotGui:renderState()
	if self.state.viewState == RobotGui.ViewState.ScriptMenu then
		return self:createRobotIdleMenu()
	elseif self.state.viewState == RobotGui.ViewState.ScriptEditor then
		return self:createRobotEditorMenu()
	elseif self.state.viewState == RobotGui.ViewState.Running then
		return self:createRobotRunningMenu()
	else
		print("Viewstate is none")
		return nil
	end
end

function RobotGui:didUpdate()
	if self.state.viewState == RobotGui.ViewState.ScriptEditor then
		if not self.TBPinitialized then
			self.TBPlusObject = TextBoxPlus.new(
				self.TBPFrameRef:getValue(),
				{
					TextSize = 18;
					TextColor3 = Color3.new(255, 255, 255);
					PlaceholderColor3 = Color3.new(255, 255, 255);
					TextWrapped = false;
					Font = Enum.Font.Code;
				}
			)

			self.TBPlusObject.TextBox.Text = self.state.activeScript.text

			self.TBPlusObject.TextBox.Changed:connect(function ()
				local count = 0
				self.TBPlusObject.TextBox.Text, count = self.TBPlusObject.TextBox.Text:gsub( '\t', '    ' )

				if count > 0 then
					self.TBPlusObject.TextBox.CursorPosition = self.TBPlusObject.TextBox.CursorPosition + 3
				end
			end)
			self.TBPinitialized = true
		end
	else
		self.TBPinitialized = false
	end
end

function RobotGui:createRobotIdleMenu()
	return Roact.createFragment({
		TitleFrame = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(),
		}, {
			NameText = DefaultSyle.createElement("TextLabel", {
				Text = self.state.robotName,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -200, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
				Visible = not self.state.nameEdit,
			}),
			NameTextBox = DefaultSyle.createElement("TextBox", {
				Text = self.state.robotName,
				Position = UDim2.new(0, 10, 0, 10),
				Size = UDim2.new(1, -200, 1, -20),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
				Visible = self.state.nameEdit,
				ClearTextOnFocus = false,

				[Roact.Change.Text] = function(rbx)
					self:setState(function(state)
						return {
							robotName = rbx.Text,
						}
					end)
			    end
			}),

			NameDisplayCheckBox = DefaultSyle.createElement("LabelledCheckbox", LabelledCheckbox, {
				Size = UDim2.fromOffset(150,30),
				Position = UDim2.new(1, -320, 0, 10),
				Text = "Display Name ",
				Value = self.state.robotDispayNameAbove,
				SetValue = function(value)
					RobotService.SetRobotDisplayNameAbove:InvokeServer(self.currentRobotModel, value)
					self:setState(function(state)
						return {
							robotDispayNameAbove = value,
						}
					end)
				end,
			}),

			RenameRobotButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(130,30),
				Position = UDim2.new(1, -160, 0, 10),
				Text = "Edit Name",
				Visible = not self.state.nameEdit,

				[Roact.Event.MouseButton1Click] = function(rbx)
					self:setState(function(state)
						return {
							nameEdit = true,
						}
					end)
			    end
			}),
			RenameRobotDoneButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(130,30),
				Position = UDim2.new(1, -160, 0, 10),
				Text = "Done",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(77, 213, 111),
				Visible = self.state.nameEdit,

				[Roact.Event.MouseButton1Click] = function(rbx)
					RobotService.SetRobotName:InvokeServer(self.currentRobotModel, self.state.robotName)

					self:setState(function(state)
						return {
							nameEdit = false,
						}
					end)
			    end
			}),
			CloseButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(20,20),
				Position = UDim2.new(1, -20, 0, 0),
				BackgroundColor3 = Color3.fromRGB(222, 0, 57),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = "X",

				[Roact.Event.MouseButton1Click] = function(rbx)
					print("X clicked")

					self.TBPlusObject = nil
					self.TBPinitialized = false

					self:setState(function(state)
						return {
							robot = nil,
							robotName = "Unnamed Robot",
							robotDispayNameAbove = false,
							nameEdit = false,
							activeScript = nil,
							activeScriptIndex = nil,
							viewState = RobotGui.ViewState.None,
						}
					end)
				end
			})
		}),
		ScriptsFrame = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, -60, 1, -60),
			Position = UDim2.fromOffset(30, 60),
			BorderSizePixel = 0,
		}, {
			TitleText = DefaultSyle.createElement("TextLabel", {
				Text = "Saved Scripts",
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -160, 0, 50),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
			}),
			NewScriptButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(130,30),
				Position = UDim2.new(1, -130, 0, 10),
				Text = "New Script",

				[Roact.Event.MouseButton1Click] = function(rbx)
					self:setState(function(state)
						return {
							activeScript = {
								name = "New Script",
								text = ""
							},
							activeScriptIndex = #localScripts+1,
							viewState = RobotGui.ViewState.ScriptEditor
						}
					end)
				end

			}),
			ScriptsListFrame = DefaultSyle.createElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, -80),
				Position = UDim2.fromOffset(0, 50),
			}, {
				self:createScriptList(localScripts)
			})
		})
	})
end


function RobotGui:createRobotEditorMenu()
	return Roact.createFragment({
		TitleFrame = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(),
		}, {

			NameText = DefaultSyle.createElement("TextLabel", {
				Text = self.state.activeScript.name,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -200, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
				Visible = not self.state.nameEdit,
			}),

			NameTextBox = DefaultSyle.createElement("TextBox", {
				Text = self.state.activeScript.name,
				Position = UDim2.new(0, 10, 0, 10),
				Size = UDim2.new(1, -200, 1, -20),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
				Visible = self.state.nameEdit,
				ClearTextOnFocus = false,

				[Roact.Change.Text] = function(rbx)
					self:setState(function(state)
						return {
							activeScript = {
								name = rbx.Text
							},
						}
					end)
			    end
			}),

			RenameRobotButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(130,30),
				Position = UDim2.new(1, -160, 0, 10),
				Text = "Edit Name",
				Visible = not self.state.nameEdit,

				[Roact.Event.MouseButton1Click] = function(rbx)
					self:setState(function(state)
						return {
							nameEdit = true,
						}
					end)
			    end
			}),

			RenameRobotDoneButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(130,30),
				Position = UDim2.new(1, -160, 0, 10),
				Text = "Done",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(77, 213, 111),
				Visible = self.state.nameEdit,

				[Roact.Event.MouseButton1Click] = function(rbx)
					self:setState(function(state)
						return {
							nameEdit = false,
						}
					end)
			    end
			}),
		}),
		EditorFrame = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, -60, 1, -110),
			Position = UDim2.fromOffset(30, 60),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			[Roact.Ref] = self.TBPFrameRef,
		}, {}),
		SaveScriptButton = DefaultSyle.createElement("TextButton", {
			Size = UDim2.fromOffset(130,30),
			Position = UDim2.new(1, -160, 1, -40),
			Text = "Save Script",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(77, 213, 111),

			[Roact.Event.MouseButton1Click] = function(rbx)

				localScripts[self.state.activeScriptIndex] = {
					name = self.state.activeScript.name,
					text = self.TBPlusObject.TextBox.Text
				}

				self:setState(function(state)
					return {
						activeScript = nil,
						activeScriptIndex = nil,
						nameEdit = false,
						viewState = RobotGui.ViewState.ScriptMenu,
					}
				end)
		    end
		}),
	})
end

function RobotGui:createRobotRunningMenu()
	return Roact.createFragment({
		TitleFrame = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(),
		}, {
			NameText = DefaultSyle.createElement("TextLabel", {
				Text = self.state.robotName,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -200, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
			}),
			CloseButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(20,20),
				Position = UDim2.new(1, -20, 0, 0),
				BackgroundColor3 = Color3.fromRGB(222, 0, 57),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = "X",

				[Roact.Event.MouseButton1Click] = function(rbx)
					self.TBPlusObject = nil
					self.TBPinitialized = false

					self:setState(function(state)
						return {
							robot = nil,
							robotName = "Unnamed Robot",
							robotDispayNameAbove = false,
							nameEdit = false,
							activeScript = nil,
							activeScriptIndex = nil,
							viewState = RobotGui.ViewState.None,
						}
					end)
				end
			})
		}),
		MainFrame = DefaultSyle.createElement("Frame", {
			Size = UDim2.new(1, -60, 1, -60),
			Position = UDim2.fromOffset(30, 60),
			BorderSizePixel = 0,
		}, {
			TitleText = DefaultSyle.createElement("TextLabel", {
				Text = self.state.robotName .. " is running script: " .. self.currentRobotData.activeScript,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -160, 0, 50),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 24,
			}),
			KillScriptButton = DefaultSyle.createElement("TextButton", {
				Size = UDim2.fromOffset(130,30),
				Position = UDim2.new(1, -130, 0, 10),
				Text = "Kill Script",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(222, 0, 57),

				[Roact.Event.MouseButton1Click] = function(rbx)
					RobotService.KillRobotCode:InvokeServer(self.currentRobotModel)
					self:setState(function(state)
						return {
							viewState = RobotGui.ViewState.ScriptMenu,
						}
					end)
				end
			}),
		})
	})
end

function RobotGui:render()
	if self.state.viewState == RobotGui.ViewState.None then
		return nil
	else
	    return Roact.createElement("ScreenGui", {}, {
			MainFrame = DefaultSyle.createElement("Frame", {
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0.1, 0.1),
			}, {
				self:renderState()
			})
	    })
	end
end

local PlayerGui = Players.LocalPlayer.PlayerGui


local handle = Roact.mount(Roact.createElement(RobotGui), PlayerGui, "Robot UI")
