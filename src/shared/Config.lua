local Config = {}

Config.BaseUpgradeCost = 25
Config.UpgradeGrowth = 1.65
Config.MaxClicksPerSecond = 15

function Config.GetClickPowerCost(clickPower)
	return math.floor(Config.BaseUpgradeCost * (Config.UpgradeGrowth ^ (clickPower - 1)))
end

return Config
