extends TextureRect


var upgrade = null
func _ready():
	if upgrade != null:
		var upgrade_db = get_node_or_null("/root/UpgradeDb")
		if upgrade_db and upgrade_db.UPGRADES.has(upgrade):
			$ItemTexture.texture = load(upgrade_db.UPGRADES[upgrade]["icon"])
		else:
			push_warning("升级不存在: %s" % upgrade)
