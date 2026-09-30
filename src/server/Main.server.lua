local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local dataStore = DataStoreService:GetDataStore("ClickSimulatorPlayerData_v1")

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function getRemote(name)
	local remote = remotes:FindFirstChild(name)
	if remote then
		return remote
	end

	remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	return remote
end

local clickEvent = getRemote("Click")
local buyClickPower = getRemote("BuyClickPower")
local rebirthEvent = getRemote("Rebirth")
local feedbackEvent = getRemote("Feedback")

local lastClicks = {}

local function getValues(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local upgrades = player:FindFirstChild("Upgrades")
	if not leaderstats or not upgrades then
		return
	end

	local clicks = leaderstats:FindFirstChild("Clicks")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	local clickPower = upgrades:FindFirstChild("ClickPower")

	return clicks, rebirths, clickPower
end

local function savePlayer(player)
	local clicks, rebirths, clickPower = getValues(player)
	if not clicks or not rebirths or not clickPower then
		return
	end

	local data = {
		Clicks = clicks.Value,
		Rebirths = rebirths.Value,
		ClickPower = clickPower.Value,
	}

	local success, err = pcall(function()
		dataStore:SetAsync("player_" .. player.UserId, data)
	end)

	if not success then
		warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

local function loadPlayer(player)
	local data
	local success, err = pcall(function()
		data = dataStore:GetAsync("player_" .. player.UserId)
	end)

	if not success then
		warn("Failed to load data for " .. player.Name .. ": " .. tostring(err))
	end

	return data
end

local function setupPlayer(player)
	if player:FindFirstChild("leaderstats") then
		return
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local clicks = Instance.new("IntValue")
	clicks.Name = "Clicks"
	clicks.Value = 0
	clicks.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local upgrades = Instance.new("Folder")
	upgrades.Name = "Upgrades"
	upgrades.Parent = player

	local clickPower = Instance.new("IntValue")
	clickPower.Name = "ClickPower"
	clickPower.Value = 1
	clickPower.Parent = upgrades

	local data = loadPlayer(player)
	if type(data) == "table" then
		clicks.Value = math.max(0, tonumber(data.Clicks) or 0)
		rebirths.Value = math.max(0, tonumber(data.Rebirths) or 0)
		clickPower.Value = math.max(1, tonumber(data.ClickPower) or 1)
	end
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	lastClicks[player] = nil
end)

clickEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	local minimumDelay = 1 / Config.MaxClicksPerSecond

	if lastClicks[player] and now - lastClicks[player] < minimumDelay then
		return
	end
	lastClicks[player] = now

	local clicks, rebirths, clickPower = getValues(player)
	if not clicks or not rebirths or not clickPower then
		return
	end

	local multiplier = Config.GetRebirthMultiplier(rebirths.Value)
	clicks.Value += clickPower.Value * multiplier
end)

buyClickPower.OnServerEvent:Connect(function(player)
	local clicks, _, clickPower = getValues(player)
	if not clicks or not clickPower then
		return
	end

	local cost = Config.GetClickPowerCost(clickPower.Value)
	if clicks.Value < cost then
		feedbackEvent:FireClient(player, "Not enough Clicks!", false)
		return
	end

	clicks.Value -= cost
	clickPower.Value += 1
	feedbackEvent:FireClient(player, "Click Power upgraded!", true)
end)

rebirthEvent.OnServerEvent:Connect(function(player)
	local clicks, rebirths, clickPower = getValues(player)
	if not clicks or not rebirths or not clickPower then
		return
	end

	local cost = Config.GetRebirthCost(rebirths.Value)
	if clicks.Value < cost then
		feedbackEvent:FireClient(player, "You need more Clicks to rebirth!", false)
		return
	end

	clicks.Value = 0
	clickPower.Value = 1
	rebirths.Value += 1

	feedbackEvent:FireClient(
		player,
		"Rebirth complete! Permanent x" .. Config.GetRebirthMultiplier(rebirths.Value) .. " multiplier.",
		true
	)
end)

task.spawn(function()
	while true do
		task.wait(Config.AutoSaveSeconds)
		for _, player in Players:GetPlayers() do
			task.spawn(savePlayer, player)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		savePlayer(player)
	end
end)
