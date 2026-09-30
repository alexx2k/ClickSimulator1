local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local clickEvent = remotes:FindFirstChild("Click") or Instance.new("RemoteEvent")
clickEvent.Name = "Click"
clickEvent.Parent = remotes

local buyClickPower = remotes:FindFirstChild("BuyClickPower") or Instance.new("RemoteEvent")
buyClickPower.Name = "BuyClickPower"
buyClickPower.Parent = remotes

local lastClicks = {}

local function setupPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local clicks = Instance.new("IntValue")
	clicks.Name = "Clicks"
	clicks.Value = 0
	clicks.Parent = leaderstats

	local upgrades = Instance.new("Folder")
	upgrades.Name = "Upgrades"
	upgrades.Parent = player

	local clickPower = Instance.new("IntValue")
	clickPower.Name = "ClickPower"
	clickPower.Value = 1
	clickPower.Parent = upgrades
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	lastClicks[player] = nil
end)

clickEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	local minimumDelay = 1 / Config.MaxClicksPerSecond
	if lastClicks[player] and now - lastClicks[player] < minimumDelay then return end
	lastClicks[player] = now

	local leaderstats = player:FindFirstChild("leaderstats")
	local upgrades = player:FindFirstChild("Upgrades")
	if not leaderstats or not upgrades then return end

	local clicks = leaderstats:FindFirstChild("Clicks")
	local clickPower = upgrades:FindFirstChild("ClickPower")
	if clicks and clickPower then
		clicks.Value += clickPower.Value
	end
end)

buyClickPower.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local upgrades = player:FindFirstChild("Upgrades")
	if not leaderstats or not upgrades then return end

	local clicks = leaderstats:FindFirstChild("Clicks")
	local clickPower = upgrades:FindFirstChild("ClickPower")
	if not clicks or not clickPower then return end

	local cost = Config.GetClickPowerCost(clickPower.Value)
	if clicks.Value < cost then return end

	clicks.Value -= cost
	clickPower.Value += 1
end)
