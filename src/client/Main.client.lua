local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local clickEvent = remotes:WaitForChild("Click")
local buyClickPower = remotes:WaitForChild("BuyClickPower")

local clicks = player:WaitForChild("leaderstats"):WaitForChild("Clicks")
local clickPower = player:WaitForChild("Upgrades"):WaitForChild("ClickPower")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local gui = Instance.new("ScreenGui")
gui.Name = "ClickSimulatorUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local counter = Instance.new("TextLabel")
counter.AnchorPoint = Vector2.new(0.5, 0.5)
counter.Position = UDim2.fromScale(0.5, 0.35)
counter.Size = UDim2.fromOffset(420, 80)
counter.BackgroundTransparency = 1
counter.Font = Enum.Font.GothamBold
counter.TextColor3 = Color3.new(1, 1, 1)
counter.TextScaled = true
counter.Parent = gui

local clickButton = Instance.new("TextButton")
clickButton.AnchorPoint = Vector2.new(0.5, 0.5)
clickButton.Position = UDim2.fromScale(0.5, 0.55)
clickButton.Size = UDim2.fromOffset(280, 110)
clickButton.BackgroundColor3 = Color3.fromRGB(78, 118, 255)
clickButton.TextColor3 = Color3.new(1, 1, 1)
clickButton.Font = Enum.Font.GothamBlack
clickButton.Text = "CLICK!"
clickButton.TextScaled = true
clickButton.AutoButtonColor = false
clickButton.Parent = gui
corner(clickButton, 22)

local upgradesButton = Instance.new("TextButton")
upgradesButton.AnchorPoint = Vector2.new(0, 1)
upgradesButton.Position = UDim2.new(0, 30, 1, -30)
upgradesButton.Size = UDim2.fromOffset(190, 60)
upgradesButton.BackgroundColor3 = Color3.fromRGB(44, 48, 65)
upgradesButton.TextColor3 = Color3.new(1, 1, 1)
upgradesButton.Font = Enum.Font.GothamBold
upgradesButton.Text = "UPGRADES"
upgradesButton.TextScaled = true
upgradesButton.Parent = gui
corner(upgradesButton, 14)

local menu = Instance.new("Frame")
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.fromScale(0.5, 0.5)
menu.Size = UDim2.fromOffset(520, 350)
menu.BackgroundColor3 = Color3.fromRGB(29, 32, 44)
menu.Visible = false
menu.Parent = gui
corner(menu, 22)

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(24, 18)
title.Size = UDim2.new(1, -100, 0, 52)
title.BackgroundTransparency = 1
title.Text = "UPGRADES"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = menu

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -18, 0, 18)
close.Size = UDim2.fromOffset(50, 50)
close.BackgroundColor3 = Color3.fromRGB(55, 59, 78)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = menu
corner(close, 12)

local card = Instance.new("Frame")
card.Position = UDim2.fromOffset(24, 95)
card.Size = UDim2.new(1, -48, 0, 150)
card.BackgroundColor3 = Color3.fromRGB(40, 44, 59)
card.Parent = menu
corner(card, 16)

local upgradeName = Instance.new("TextLabel")
upgradeName.Position = UDim2.fromOffset(18, 16)
upgradeName.Size = UDim2.new(0.5, 0, 0, 38)
upgradeName.BackgroundTransparency = 1
upgradeName.Text = "CLICK POWER"
upgradeName.TextColor3 = Color3.new(1, 1, 1)
upgradeName.TextXAlignment = Enum.TextXAlignment.Left
upgradeName.Font = Enum.Font.GothamBold
upgradeName.TextScaled = true
upgradeName.Parent = card

local level = Instance.new("TextLabel")
level.Position = UDim2.fromOffset(18, 61)
level.Size = UDim2.new(0.42, 0, 0, 28)
level.BackgroundTransparency = 1
level.TextColor3 = Color3.fromRGB(190, 194, 215)
level.TextXAlignment = Enum.TextXAlignment.Left
level.Font = Enum.Font.Gotham
level.TextScaled = true
level.Parent = card

local buy = Instance.new("TextButton")
buy.AnchorPoint = Vector2.new(1, 0.5)
buy.Position = UDim2.new(1, -18, 0.5, 0)
buy.Size = UDim2.fromOffset(235, 70)
buy.BackgroundColor3 = Color3.fromRGB(63, 190, 112)
buy.TextColor3 = Color3.new(1, 1, 1)
buy.Font = Enum.Font.GothamBold
buy.TextScaled = true
buy.Parent = card
corner(buy, 14)

local function updateUI()
	counter.Text = string.format("%d Clicks", clicks.Value)
	level.Text = string.format("Level %d  •  +%d/click", clickPower.Value - 1, clickPower.Value)
	buy.Text = string.format("UPGRADE\n%d CLICKS", Config.GetClickPowerCost(clickPower.Value))
end

local function floatingGain(amount)
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, math.random(-80, 80), 0.46, 0)
	label.Size = UDim2.fromOffset(120, 50)
	label.BackgroundTransparency = 1
	label.Text = "+" .. amount
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui

	local tween = TweenService:Create(label, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = label.Position - UDim2.fromOffset(0, 90),
		TextTransparency = 1,
	})
	tween:Play()
	tween.Completed:Once(function() label:Destroy() end)
end

local buttonSize = clickButton.Size
clickButton.Activated:Connect(function()
	clickEvent:FireServer()
	floatingGain(clickPower.Value)
	TweenService:Create(clickButton, TweenInfo.new(0.05), {Size = UDim2.fromOffset(255, 96)}):Play()
	task.delay(0.05, function()
		TweenService:Create(clickButton, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = buttonSize}):Play()
	end)
end)

upgradesButton.Activated:Connect(function()
	menu.Visible = true
	menu.Size = UDim2.fromOffset(450, 300)
	TweenService:Create(menu, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(520, 350)}):Play()
end)

close.Activated:Connect(function()
	menu.Visible = false
end)

buy.Activated:Connect(function()
	buyClickPower:FireServer()
end)

clicks:GetPropertyChangedSignal("Value"):Connect(updateUI)
clickPower:GetPropertyChangedSignal("Value"):Connect(updateUI)
updateUI()
