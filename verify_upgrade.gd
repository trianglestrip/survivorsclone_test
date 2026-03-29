extends SceneTree

## 验证暖雪风格升级
## 快速检查所有改进是否正确应用

func _init():
	print("\n" + "=".repeat(70))
	print("阶段1暖雪风格升级验证")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_ok = true
	
	all_ok = _verify_config() and all_ok
	all_ok = _verify_components() and all_ok
	all_ok = _verify_ui() and all_ok
	all_ok = _verify_tools() and all_ok
	all_ok = _verify_docs() and all_ok
	
	print("\n" + "=".repeat(70))
	if all_ok:
		print("✓ 所有验证通过！升级已正确应用")
		print("\n可以开始测试游戏了：")
		print("  1. 打开 Godot 编辑器")
		print("  2. 运行 World/world.tscn 场景")
		print("  3. 体验暖雪风格的操作手感")
	else:
		print("✗ 部分验证失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_ok else 1)

func _verify_config() -> bool:
	print("【验证配置文件】")
	
	var config_path = "res://config/stage1_controls.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	if not file:
		print("  ✗ 配置文件不存在")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("  ✗ 配置文件解析失败")
		return false
	
	var config = json.data
	
	var checks = [
		["attack.base_cooldown", 0.3],
		["attack.base_range", 90],
		["attack.animation_speed", 1.5],
		["dash.cooldown", 0.8],
		["dash.distance", 160],
		["dash.trail_effect", true]
	]
	
	var all_ok = true
	for check in checks:
		var path_parts = check[0].split(".")
		var value = config
		for part in path_parts:
			if value.has(part):
				value = value[part]
			else:
				print("  ✗ 缺少配置: %s" % check[0])
				all_ok = false
				break
		
		if typeof(value) != TYPE_DICTIONARY:
			var expected = check[1]
			if typeof(expected) == TYPE_BOOL:
				if value == expected:
					print("  ✓ %s = %s" % [check[0], value])
				else:
					print("  ✗ %s: 期望 %s, 实际 %s" % [check[0], expected, value])
					all_ok = false
			else:
				if abs(value - expected) < 0.01:
					print("  ✓ %s = %.2f" % [check[0], value])
				else:
					print("  ✗ %s: 期望 %.2f, 实际 %.2f" % [check[0], expected, value])
					all_ok = false
	
	return all_ok

func _verify_components() -> bool:
	print("\n【验证组件文件】")
	
	var components = [
		"res://Player/Components/melee_attack.gd",
		"res://Player/Components/dash_manager.gd",
		"res://Player/Components/base_attack.gd",
		"res://Player/player.gd"
	]
	
	var all_ok = true
	for path in components:
		if ResourceLoader.exists(path):
			var script = load(path)
			if script:
				print("  ✓ %s" % path.get_file())
			else:
				print("  ✗ %s 加载失败" % path.get_file())
				all_ok = false
		else:
			print("  ✗ %s 不存在" % path.get_file())
			all_ok = false
	
	return all_ok

func _verify_ui() -> bool:
	print("\n【验证UI文件】")
	
	var ui_files = [
		"res://Player/GUI/skill_bar_ui.gd",
		"res://Player/GUI/enhanced_health_bar.gd"
	]
	
	var all_ok = true
	for path in ui_files:
		if ResourceLoader.exists(path):
			var script = load(path)
			if script:
				print("  ✓ %s" % path.get_file())
			else:
				print("  ✗ %s 加载失败" % path.get_file())
				all_ok = false
		else:
			print("  ✗ %s 不存在" % path.get_file())
			all_ok = false
	
	return all_ok

func _verify_tools() -> bool:
	print("\n【验证工具文件】")
	
	var tools = [
		"res://Utility/resource_hot_reload.gd",
		"res://tests/test_stage1_warmsnow_upgrade.gd",
		"res://clear_cache.gd"
	]
	
	var all_ok = true
	for path in tools:
		if ResourceLoader.exists(path):
			print("  ✓ %s" % path.get_file())
		else:
			print("  ✗ %s 不存在" % path.get_file())
			all_ok = false
	
	return all_ok

func _verify_docs() -> bool:
	print("\n【验证文档文件】")
	
	var docs = [
		"res://.trae/documents/stage1_warmsnow_upgrade.md",
		"res://.trae/documents/stage1_improvements_summary.md",
		"res://tests/warmsnow_demo_instructions.md",
		"res://WARMSNOW_UPGRADE_README.md"
	]
	
	var all_ok = true
	for path in docs:
		if FileAccess.file_exists(path):
			print("  ✓ %s" % path.get_file())
		else:
			print("  ✗ %s 不存在" % path.get_file())
			all_ok = false
	
	return all_ok
