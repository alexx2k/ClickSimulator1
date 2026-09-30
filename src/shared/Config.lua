local Config = {}

Config.BaseUpgradeCost = 25
Config.UpgradeGrowth = 1.65
Config.MaxClicksPerSecond = 15

Config.BaseRebirthCost = 500
Config.RebirthGrowth = 3
Config.RebirthMultiplierPerRebirth = 1

Config.AutoSaveSeconds = 60

function Config.GetClickPowerCost(clickPower)
	return math.floor(Config.BaseUpgradeCost * (Config.UpgradeGrowth ^ (clickPower - 1)))
end

function Config.GetRebirthCost(rebirths)
	return math.floor(Config.BaseRebirthCost * (Config.RebirthGrowth ^ rebirths))
end

function Config.GetRebirthMultiplier(rebirths)
	return 1 + (rebirths * Config.RebirthMultiplierPerRebirth)
end

return Config
