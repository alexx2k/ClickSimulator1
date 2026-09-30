local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local clickRemote = remotes:WaitForChild("Click")
local buyRemote = remotes:WaitForChild("BuyClickPower")
local rebirthRemote = remotes:WaitForChild("Rebirth")
local feedbackRemote = remotes:WaitForChild("Feedback")

local leaderstats = player:WaitForChild("leaderstats")
local clicks = leaderstats:WaitForChild("Clicks")
local rebirths = leaderstats:WaitForChild("Rebirths")
local clickPower = player:WaitForChild("Upgrades"):WaitForChild("ClickPower")

local function round(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function formatNumber(value)
	if value >= 1e12 then
		return string.format("%.2fT", value / 1e12)
	elseif value >= 1e9 then
		return string.format("%.2fB", value / 1e9)
	elseif value >= 1e6 then
		return string.format("%.2fM", value / 1e6)
	elseif value >= 1e3 then
		return string.format("%.1fK", value / 1e3)
	end

	return tostring(value)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ClickSimulatorUI"
gui.ResetOnSpawn = false
gui.Parent = guiParent

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

local statsPill = Instance.new("TextLabel")
statsPill.AnchorPoint = Vector2.new(0.5, 0)
statsPill.Position = UDim2.new(0.5, 0, 0, 22)
statsPill.Size = UDim2.new(0.5, 0, 0, 48)
statsPill.BackgroundColor3 = Color3.fromRGB(29, 32, 44)
statsPill.BackgroundTransparency = 0.08
statsPill.TextColor3 = Color3.new(1, 1, 1)
statsPill.Font = Enum.Font.GothamBold
statsPill.TextScaled = true
statsPill.Parent = gui
round(statsPill, 16)

local statsConstraint = Instance.new("UISizeConstraint")
statsConstraint.MinSize = Vector2.new(260, 44)
statsConstraint.MaxSize = Vector2.new(520, 52)
statsConstraint.Parent = statsPill

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

local rebirthButton = Instance.new("TextButton")
rebirthButton.AnchorPoint = Vector2.new(1, 1)
rebirthButton.Position = UDim2.new(1, -24, 1, -24)
rebirthButton.Size = UDim2.fromOffset(180, 56)
rebirthButton.BackgroundColor3 = Color3.fromRGB(172, 92, 255)
rebirthButton.TextColor3 = Color3.new(1, 1, 1)
rebirthButton.Font = Enum.Font.GothamBold
rebirthButton.Text = "REBIRTH"
rebirthButton.TextScaled = true
rebirthButton.Parent = gui
round(rebirthButton, 14)

local function makeMenu(titleText)
	local menu = Instance.new("Frame")
	menu.AnchorPoint = Vector2.new(0.5, 0.5)
	menu.Position = UDim2.fromScale(0.5, 0.5)
	menu.Size = UDim2.new(0.88, 0, 0.62, 0)
	menu.BackgroundColor3 = Color3.fromRGB(29, 32, 44)
	menu.Visible = false
	menu.ClipsDescendants = true
	menu.Parent = gui
	round(menu, 22)

	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(330, 290)
	constraint.MaxSize = Vector2.new(560, 400)
	constraint.Parent = menu

	local scale = Instance.new("UIScale")
	scale.Parent = menu

	local title = Instance.new("TextLabel")
	title.Position = UDim2.fromOffset(22, 16)
	title.Size = UDim2.new(1, -92, 0, 48)
	title.BackgroundTransparency = 1
	title.Text = titleText
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

	close.Activated:Connect(function()
		menu.Visible = false
	end)

	return menu, scale
end

local upgradesMenu, upgradesScale = makeMenu("UPGRADES")
local upgradeCard = Instance.new("Frame")
upgradeCard.Position = UDim2.fromOffset(22, 84)
upgradeCard.Size = UDim2.new(1, -44, 1, -106)
upgradeCard.BackgroundColor3 = Color3.fromRGB(40, 44, 59)
upgradeCard.Parent = upgradesMenu
round(upgradeCard, 16)

local upgradeName = Instance.new("TextLabel")
upgradeName.Position = UDim2.fromOffset(18, 14)
upgradeName.Size = UDim2.new(1, -36, 0, 34)
upgradeName.BackgroundTransparency = 1
upgradeName.Text = "CLICK POWER"
upgradeName.TextColor3 = Color3.new(1, 1, 1)
upgradeName.TextXAlignment = Enum.TextXAlignment.Left
upgradeName.Font = Enum.Font.GothamBold
upgradeName.TextScaled = true
upgradeName.Parent = upgradeCard

local level = Instance.new("TextLabel")
level.Position = UDim2.fromOffset(18, 56)
level.Size = UDim2.new(1, -36, 0, 28)
level.BackgroundTransparency = 1
level.TextColor3 = Color3.fromRGB(190, 194, 215)
level.TextXAlignment = Enum.TextXAlignment.Left
level.Font = Enum.Font.Gotham
level.TextScaled = true
level.Parent = upgradeCard

local buy = Instance.new("TextButton")
buy.AnchorPoint = Vector2.new(0.5, 1)
buy.Position = UDim2.new(0.5, 0, 1, -16)
buy.Size = UDim2.new(1, -36, 0, 58)
buy.TextColor3 = Color3.new(1, 1, 1)
buy.Font = Enum.Font.GothamBold
buy.TextScaled = true
buy.Parent = upgradeCard
round(buy, 14)

local rebirthMenu, rebirthScale = makeMenu("REBIRTH")
local rebirthCard = Instance.new("Frame")
rebirthCard.Position = UDim2.fromOffset(22, 84)
rebirthCard.Size = UDim2.new(1, -44, 1, -106)
rebirthCard.BackgroundColor3 = Color3.fromRGB(40, 44, 59)
rebirthCard.Parent = rebirthMenu
round(rebirthCard, 16)

local rebirthInfo = Instance.new("TextLabel")
rebirthInfo.Position = UDim2.fromOffset(18, 16)
rebirthInfo.Size = UDim2.new(1, -36, 0, 90)
rebirthInfo.BackgroundTransparency = 1
rebirthInfo.TextColor3 = Color3.new(1, 1, 1)
rebirthInfo.TextWrapped = true
rebirthInfo.Font = Enum.Font.GothamBold
rebirthInfo.TextScaled = true
rebirthInfo.Parent = rebirthCard

local rebirthCost = Instance.new("TextLabel")
rebirthCost.Position = UDim2.fromOffset(18, 112)
rebirthCost.Size = UDim2.new(1, -36, 0, 34)
rebirthCost.BackgroundTransparency = 1
rebirthCost.TextColor3 = Color3.fromRGB(205, 208, 225)
rebirthCost.Font = Enum.Font.Gotham
rebirthCost.TextScaled = true
rebirthCost.Parent = rebirthCard

local rebirthConfirm = Instance.new("TextButton")
rebirthConfirm.AnchorPoint = Vector2.new(0.5, 1)
rebirthConfirm.Position = UDim2.new(0.5, 0, 1, -16)
rebirthConfirm.Size = UDim2.new(1, -36, 0, 58)
rebirthConfirm.TextColor3 = Color3.new(1, 1, 1)
rebirthConfirm.Font = Enum.Font.GothamBold
rebirthConfirm.TextScaled = true
rebirthConfirm.Parent = rebirthCard
round(rebirthConfirm, 14)

local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 82)
toast.Size = UDim2.new(0.6, 0, 0, 44)
toast.BackgroundColor3 = Color3.fromRGB(40, 44, 59)
toast.BackgroundTransparency = 1
toast.TextTransparency = 1
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Font = Enum.Font.GothamBold
toast.TextScaled = true
toast.Visible = false
toast.Parent = gui
round(toast, 14)

local function openMenu(menu, scale)
	upgradesMenu.Visible = false
	rebirthMenu.Visible = false

	menu.Visible = true
	scale.Scale = 0.88
	TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function updateUI()
	local multiplier = Config.GetRebirthMultiplier(rebirths.Value)
	local gain = clickPower.Value * multiplier
	local upgradeCost = Config.GetClickPowerCost(clickPower.Value)
	local nextRebirthCost = Config.GetRebirthCost(rebirths.Value)

	statsPill.Text = string.format(
		"%s Clicks   •   %d Rebirths   •   x%d",
		formatNumber(clicks.Value),
		rebirths.Value,
		multiplier
	)

	level.Text = string.format("Level %d  •  +%s per click", clickPower.Value - 1, formatNumber(gain))
	buy.Text = "UPGRADE - " .. formatNumber(upgradeCost) .. " CLICKS"

	if clicks.Value >= upgradeCost then
		buy.BackgroundColor3 = Color3.fromRGB(63, 190, 112)
	else
		buy.BackgroundColor3 = Color3.fromRGB(95, 99, 116)
	end

	rebirthInfo.Text = string.format(
		"Rebirth #%d\nCurrent multiplier: x%d\nNext multiplier: x%d",
		rebirths.Value + 1,
		multiplier,
		Config.GetRebirthMultiplier(rebirths.Value + 1)
	)

	rebirthCost.Text = "Requires " .. formatNumber(nextRebirthCost) .. " Clicks"
	rebirthConfirm.Text = "REBIRTH"

	if clicks.Value >= nextRebirthCost then
		rebirthConfirm.BackgroundColor3 = Color3.fromRGB(172, 92, 255)
	else
		rebirthConfirm.BackgroundColor3 = Color3.fromRGB(95, 99, 116)
	end
end

local function floatingGain(amount)
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, math.random(-55, 55), 0.66, 0)
	label.Size = UDim2.fromOffset(110, 42)
	label.BackgroundTransparency = 1
	label.Text = "+" .. formatNumber(amount)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui

	local tween = TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = label.Position - UDim2.fromOffset(0, 80),
		TextTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		label:Destroy()
	end)
end

local function performClick()
	local multiplier = Config.GetRebirthMultiplier(rebirths.Value)
	local gain = clickPower.Value * multiplier

	clickRemote:FireServer()
	floatingGain(gain)

	local original = clickButton.Size
	TweenService:Create(clickButton, TweenInfo.new(0.05), {
		Size = UDim2.new(original.X.Scale * 0.94, 0, original.Y.Scale, math.max(72, original.Y.Offset - 8))
	}):Play()

	task.delay(0.06, function()
		TweenService:Create(clickButton, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = original
		}):Play()
	end)
end

clickButton.Activated:Connect(performClick)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space then
		performClick()
	end
end)

upgradesButton.Activated:Connect(function()
	openMenu(upgradesMenu, upgradesScale)
end)

rebirthButton.Activated:Connect(function()
	openMenu(rebirthMenu, rebirthScale)
end)

buy.Activated:Connect(function()
	buyRemote:FireServer()
end)

rebirthConfirm.Activated:Connect(function()
	rebirthRemote:FireServer()
end)

feedbackRemote.OnClientEvent:Connect(function(message, success)
	toast.Text = message
	toast.BackgroundColor3 = success and Color3.fromRGB(44, 135, 79) or Color3.fromRGB(150, 61, 70)
	toast.Visible = true
	toast.BackgroundTransparency = 0.08
	toast.TextTransparency = 0

	task.delay(1.6, function()
		local tween = TweenService:Create(toast, TweenInfo.new(0.25), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		})
		tween:Play()
		tween.Completed:Once(function()
			toast.Visible = false
		end)
	end)
end)

clicks:GetPropertyChangedSignal("Value"):Connect(updateUI)
rebirths:GetPropertyChangedSignal("Value"):Connect(updateUI)
clickPower:GetPropertyChangedSignal("Value"):Connect(updateUI)

updateUI()
