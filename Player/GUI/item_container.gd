extends TextureRect


var upgrade = null
func _ready():
	if upgrade != null:
		# 安全检查：确保升级存在
		if UpgradeDb.UPGRADES.has(upgrade):
			$ItemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
		else:
			push_warning("升级不存在: %s" % upgrade)
