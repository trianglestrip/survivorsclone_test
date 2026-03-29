extends Node2D

## 测试升级卡牌UI
## 模拟升级时的3选1卡牌选择

const UpgradeCardUI = preload("res://UI/upgrade_card_ui.tscn")

var upgrade_ui: Control = null
var test_upgrades = []

func _ready():
	_load_test_upgrades()
	_setup_ui()
	
	# 添加说明
	var label = Label.new()
	label.position = Vector2(20, 20)
	label.text = """升级卡牌系统测试

按键说明:
  SPACE - 显示升级选择
  1/2/3 - 快捷选择对应卡牌
  ESC - 退出

当前已选择: 无
"""
	label.add_theme_font_size_override("font_size", 16)
	label.name = "InfoLabel"
	add_child(label)
	
	print("\n========================================")
	print("升级卡牌UI测试")
	print("========================================")
	print("按SPACE键显示升级选择")
	print("按1/2/3快捷选择卡牌")
	print("========================================\n")

func _load_test_upgrades():
	# 加载扩展的升级配置
	var config_path = "res://config/upgrade_config_extended.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		push_error("无法加载升级配置: " + config_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("JSON解析失败: " + json.get_error_message())
		return
	
	var data = json.data
	if data and data.has("upgrades"):
		for upgrade_id in data["upgrades"]:
			test_upgrades.append(data["upgrades"][upgrade_id])
	
	print("加载了 %d 个升级配置" % test_upgrades.size())

func _setup_ui():
	# 创建升级UI
	upgrade_ui = UpgradeCardUI.instantiate()
	upgrade_ui.card_selected.connect(_on_upgrade_selected)
	add_child(upgrade_ui)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_select"):  # SPACE
		_show_random_upgrades()

func _show_random_upgrades():
	if test_upgrades.size() < 3:
		print("升级配置不足3个")
		return
	
	# 随机选择3个不同的升级
	var selected = []
	var available = test_upgrades.duplicate()
	
	for i in range(3):
		if available.size() == 0:
			break
		var index = randi() % available.size()
		selected.append(available[index])
		available.remove_at(index)
	
	print("\n显示升级选项:")
	for i in range(selected.size()):
		print("  %d. %s (%s)" % [i + 1, selected[i].get("displayname", ""), selected[i].get("rarity", "")])
	
	upgrade_ui.show_upgrade_options(selected)

func _on_upgrade_selected(upgrade_id: String):
	print("\n✓ 选择了升级: %s" % upgrade_id)
	
	# 更新信息标签
	var label = get_node_or_null("InfoLabel")
	if label:
		var upgrade_data = null
		for upgrade in test_upgrades:
			if upgrade.get("id", "") == upgrade_id:
				upgrade_data = upgrade
				break
		
		if upgrade_data:
			label.text = """升级卡牌系统测试

按键说明:
  SPACE - 显示升级选择
  1/2/3 - 快捷选择对应卡牌
  ESC - 退出

当前已选择: %s
稀有度: %s
效果: %s
""" % [
				upgrade_data.get("displayname", ""),
				upgrade_data.get("rarity", ""),
				_format_effects(upgrade_data.get("effects", {}))
			]
	
	# 1秒后可以再次选择
	await get_tree().create_timer(1.0).timeout
	print("\n按SPACE键显示下一组升级选项")

func _format_effects(effects: Dictionary) -> String:
	var lines = []
	for key in effects:
		var value = effects[key]
		if value is float:
			lines.append("%s %+.1f%%" % [key, value * 100] if abs(value) < 1.0 else "%s %+.0f" % [key, value])
		else:
			lines.append("%s %+d" % [key, value])
	return ", ".join(lines)
