local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local clickRemote = remotes:WaitForChild("Click")
local buyRemote = remotes:WaitForChild("BuyClickPower")

local clicks = player:WaitForChild("leaderstats"):WaitForChild("Clicks")
local clickPower = player:WaitForChild("Upgrades"):WaitForChild("ClickPower")

local function round(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local gui = Instance.new("ScreenGui")
gui.Name = "ClickSimulatorUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = guiParent

local counter = Instance.new("TextLabel")
counter.AnchorPoint = Vector2.new(0.5, 0.5)
counter.Position = UDim2.fromScale(0.5, 0.58)
counter.Size = UDim2.new(0.7, 0, 0, 64)
counter.BackgroundTransparency = 1
counter.Font = Enum.Font.GothamBold
counter.TextColor3 = Color3.new(1, 1, 1)
counter.TextScaled = true
counter.Parent = gui

local counterConstraint = Instance.new("UITextSizeConstraint")
counterConstraint.MaxTextSize = 42
counterConstraint.MinTextSize = 18
counterConstraint.Parent = counter

local clickButton = Instance.new("TextButton")
clickButton.AnchorPoint = Vector2.new(0.5, 0.5)
clickButton.Position = UDim2.fromScale(0.5, 0.76)
clickButton.Size = UDim2.new(0.32, 0, 0, 96)
clickButton.BackgroundColor3 = Color3.fromRGB(78, 118, 255)
clickButton.TextColor3 = Color3.new(1, 1, 1)
clickButton.Font = Enum.Font.GothamBlack
clickButton.Text = "CLICK!"
clickButton.TextScaled = true
clickButton.AutoButtonColor = false
clickButton.Parent = gui
round(clickButton, 22)

local clickSizeConstraint = Instance.new("UISizeConstraint")
clickSizeConstraint.MinSize = Vector2.new(180, 80)
clickSizeConstraint.MaxSize = Vector2.new(320, 110)
clickSizeConstraint.Parent = clickButton

local upgradesButton = Instance.new("TextButton")
upgradesButton.AnchorPoint = Vector2.new(0, 1)
upgradesButton.Position = UDim2.new(0, 24, 1, -24)
upgradesButton.Size = UDim2.fromOffset(180, 56)
upgradesButton.BackgroundColor3 = Color3.fromRGB(44, 48, 65)
upgradesButton.TextColor3 = Color3.new(1, 1, 1)
upgradesButton.Font = Enum.Font.GothamBold
upgradesButton.Text = "UPGRADES"
upgradesButton.TextScaled = true
upgradesButton.Parent = gui
round(upgradesButton, 14)

local menu = Instance.new("Frame")
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.fromScale(0.5, 0.5)
menu.Size = UDim2.new(0.88, 0, 0.62, 0)
menu.BackgroundColor3 = Color3.fromRGB(29, 32, 44)
menu.Visible = false
menu.ClipsDescendants = true
menu.Parent = gui
round(menu, 22)

local menuConstraint = Instance.new("UISizeConstraint")
menuConstraint.MinSize = Vector2.new(330, 290)
menuConstraint.MaxSize = Vector2.new(560, 400)
menuConstraint.Parent = menu

local menuScale = Instance.new("UIScale")
menuScale.Scale = 1
menuScale.Parent = menu

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(22, 16)
title.Size = UDim2.new(1, -92, 0, 48)
title.BackgroundTransparency = 1
title.Text = "UPGRADES"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = menu

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -16, 0, 16)
close.Size = UDim2.fromOffset(46, 46)
close.BackgroundColor3 = Color3.fromRGB(55, 59, 78)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = menu
round(close, 12)

local card = Instance.new("Frame")
card.Position = UDim2.fromOffset(22, 84)
card.Size = UDim2.new(1, -44, 1, -106)
card.BackgroundColor3 = Color3.fromRGB(40, 44, 59)
card.Parent = menu
round(card, 16)

local upgradeName = Instance.new("TextLabel")
upgradeName.Position = UDim2.fromOffset(18, 14)
upgradeName.Size = UDim2.new(1, -36, 0, 34)
upgradeName.BackgroundTransparency = 1
upgradeName.Text = "CLICK POWER"
upgradeName.TextColor3 = Color3.new(1, 1, 1)
upgradeName.TextXAlignment = Enum.TextXAlignment.Left
upgradeName.Font = Enum.Font.GothamBold
upgradeName.TextScaled = true
upgradeName.Parent = card

local level = Instance.new("TextLabel")
level.Position = UDim2.fromOffset(18, 56)
level.Size = UDim2.new(1, -36, 0, 28)
level.BackgroundTransparency = 1
level.TextColor3 = Color3.fromRGB(190, 194, 215)
level.TextXAlignment = Enum.TextXAlignment.Left
level.Font = Enum.Font.Gotham
level.TextScaled = true
level.Parent = card

local buy = Instance.new("TextButton")
buy.AnchorPoint = Vector2.new(0.5, 1)
buy.Position = UDim2.new(0.5, 0, 1, -16)
buy.Size = UDim2.new(1, -36, 0, 58)
buy.BackgroundColor3 = Color3.fromRGB(63, 190, 112)
buy.TextColor3 = Color3.new(1, 1, 1)
buy.Font = Enum.Font.GothamBold
buy.TextScaled = true
buy.Parent = card
round(buy, 14)

local function updateUI()
	counter.Text = tostring(clicks.Value) .. " Clicks"
	level.Text = string.format("Level %d  •  +%d per click", clickPower.Value - 1, clickPower.Value)
	buy.Text = string.format("UPGRADE - %d CLICKS", Config.GetClickPowerCost(clickPower.Value))
end

local function floatingGain(amount)
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.66, 0)
	label.Size = UDim2.fromOffset(110, 42)
	label.BackgroundTransparency = 1
	label.Text = "+" .. tostring(amount)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui

	local target = label.Position - UDim2.fromOffset(0, 80)
	local tween = TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = target,
		TextTransparency = 1,
	})
	tween:Play()
	tween.Completed:Once(function()
		label:Destroy()
	end)
end

clickButton.Activated:Connect(function()
	clickRemote:FireServer()
	floatingGain(clickPower.Value)

	local original = clickButton.Size
	TweenService:Create(clickButton, TweenInfo.new(0.05), {Size = UDim2.new(original.X.Scale * 0.94, 0, original.Y.Scale, math.max(72, original.Y.Offset - 8))}):Play()
	task.delay(0.06, function()
		TweenService:Create(clickButton, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = original}):Play()
	end)
end)

upgradesButton.Activated:Connect(function()
	menu.Visible = true
	menuScale.Scale = 0.88
	TweenService:Create(menuScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)

close.Activated:Connect(function()
	menu.Visible = false
end)

buy.Activated:Connect(function()
	buyRemote:FireServer()
end)

clicks:GetPropertyChangedSignal("Value"):Connect(updateUI)
clickPower:GetPropertyChangedSignal("Value"):Connect(updateUI)
updateUI()
