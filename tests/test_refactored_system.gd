extends SceneTree

## 重构后系统测试
## 测试阶段2和阶段3的所有功能

const GameConstants = preload("res://Utility/game_constants.gd")
const StatusEffect = preload("res://Utility/Effects/status_effect.gd")
const VisualEffectsHelper = preload("res://Utility/visual_effects_helper.gd")

func _init():
	print("\n" + "=".repeat(70))
	print("重构后系统测试")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed = true
	
	all_passed = _test_constants() and all_passed
	all_passed = _test_visual_helper() and all_passed
	all_passed = _test_status_effects() and all_passed
	all_passed = _test_sect_system() and all_passed
	all_passed = _test_active_skills() and all_passed
	all_passed = _test_ranged_attack() and all_passed
	all_passed = _test_assets() and all_passed
	
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 所有测试通过！")
		print("\n新功能:")
		print("  1. 宗派系统 - 4大宗派可选")
		print("  2. QER技能 - 每宗派3个主动技能")
		print("  3. 右键攻击 - 远程攻击系统")
		print("  4. 状态效果 - 减速/灼烧/中毒/冻结")
		print("  5. 工具类 - 特效/常量/状态管理")
	else:
		print("✗ 部分测试失败")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)

func _test_constants() -> bool:
	print("【测试 1: 游戏常量】")
	
	var constants_path = "res://Utility/game_constants.gd"
	if not ResourceLoader.exists(constants_path):
		print("  ✗ GameConstants不存在")
		return false
	
	var constants_script = load(constants_path)
	print("  ✓ GameConstants脚本加载成功")
	
	var test_color = GameConstants.Colors.SECT_ICE
	if test_color is Color:
		print("  ✓ 颜色常量可访问")
	else:
		print("  ✗ 颜色常量访问失败")
		return false
	
	var test_value = GameConstants.Values.SHAKE_ATTACK
	if typeof(test_value) == TYPE_FLOAT:
		print("  ✓ 数值常量可访问")
	else:
		print("  ✗ 数值常量访问失败")
		return false
	
	return true

func _test_visual_helper() -> bool:
	print("\n【测试 2: 视觉特效工具】")
	
	var helper_path = "res://Utility/visual_effects_helper.gd"
	if not ResourceLoader.exists(helper_path):
		print("  ✗ VisualEffectsHelper不存在")
		return false
	
	var helper_script = load(helper_path)
	print("  ✓ VisualEffectsHelper脚本加载成功")
	
	var required_methods = [
		"trigger_screen_shake",
		"shake_camera",
		"trigger_hit_pause",
		"trigger_flash",
		"fade_out",
		"create_placeholder_texture",
		"load_texture_or_placeholder"
	]
	
	var all_ok = true
	for method in required_methods:
		if helper_script.has_script_method(method):
			print("  ✓ 方法存在: %s" % method)
		else:
			print("  ✗ 缺少方法: %s" % method)
			all_ok = false
	
	return all_ok

func _test_status_effects() -> bool:
	print("\n【测试 3: 状态效果系统】")
	
	var status_path = "res://Utility/Effects/status_effect.gd"
	if not ResourceLoader.exists(status_path):
		print("  ✗ StatusEffect不存在")
		return false
	
	var status_script = load(status_path)
	print("  ✓ StatusEffect脚本加载成功")
	
	var slow_effect = StatusEffect.SlowEffect.new(2.0, 0.3)
	if slow_effect:
		print("  ✓ SlowEffect创建成功")
	else:
		print("  ✗ SlowEffect创建失败")
		return false
	
	var burn_effect = StatusEffect.BurnEffect.new(3.0, 5.0)
	if burn_effect:
		print("  ✓ BurnEffect创建成功")
	else:
		print("  ✗ BurnEffect创建失败")
		return false
	
	var poison_effect = StatusEffect.PoisonEffect.new(4.0, 8.0)
	if poison_effect:
		print("  ✓ PoisonEffect创建成功")
	else:
		print("  ✗ PoisonEffect创建失败")
		return false
	
	var freeze_effect = StatusEffect.FreezeEffect.new(2.0)
	if freeze_effect:
		print("  ✓ FreezeEffect创建成功")
	else:
		print("  ✗ FreezeEffect创建失败")
		return false
	
	return true

func _test_sect_system() -> bool:
	print("\n【测试 4: 宗派系统】")
	
	var sect_mgr_path = "res://Player/Components/sect_manager.gd"
	if not ResourceLoader.exists(sect_mgr_path):
		print("  ✗ SectManager不存在")
		return false
	
	var config = _load_json("res://config/sect_config.json")
	if not config or not config.has("sects"):
		print("  ✗ 宗派配置加载失败")
		return false
	
	var sects = config["sects"]
	var required_sects = ["ice", "thunder", "fire", "poison"]
	
	var all_ok = true
	for sect_id in required_sects:
		if sects.has(sect_id):
			var sect = sects[sect_id]
			if sect.has("skills") and sect["skills"].has("q") and sect["skills"].has("e") and sect["skills"].has("r"):
				print("  ✓ 宗派配置完整: %s" % sect.get("name", sect_id))
			else:
				print("  ✗ 宗派技能配置不完整: %s" % sect_id)
				all_ok = false
		else:
			print("  ✗ 缺少宗派: %s" % sect_id)
			all_ok = false
	
	return all_ok

func _test_active_skills() -> bool:
	print("\n【测试 5: 主动技能】")
	
	var skills = [
		"ice_shard",
		"thunder_strike",
		"fire_ball",
		"poison_dart"
	]
	
	var all_ok = true
	for skill_id in skills:
		var skill_path = "res://Skills/ActiveSkills/%s.gd" % skill_id
		if ResourceLoader.exists(skill_path):
			print("  ✓ 技能脚本存在: %s" % skill_id)
		else:
			print("  ✗ 技能脚本缺失: %s" % skill_id)
			all_ok = false
	
	return all_ok

func _test_ranged_attack() -> bool:
	print("\n【测试 6: 远程攻击系统】")
	
	var ranged_path = "res://Player/Components/ranged_attack.gd"
	if not ResourceLoader.exists(ranged_path):
		print("  ✗ RangedAttack不存在")
		return false
	
	var ranged_script = load(ranged_path)
	var ranged = ranged_script.new()
	
	var required_methods = [
		"try_attack",
		"can_attack",
		"spawn_attack_effect"
	]
	
	var all_ok = true
	for method in required_methods:
		if ranged.has_method(method):
			print("  ✓ 方法存在: %s" % method)
		else:
			print("  ✗ 缺少方法: %s" % method)
			all_ok = false
	
	ranged.free()
	return all_ok

func _test_assets() -> bool:
	print("\n【测试 7: 占位资源】")
	
	var required_assets = [
		"res://Assets/UI/Sects/icon_sect_ice.png",
		"res://Assets/UI/Sects/icon_sect_thunder.png",
		"res://Assets/UI/Sects/icon_sect_fire.png",
		"res://Assets/UI/Sects/icon_sect_poison.png",
		"res://Assets/Effects/Skills/ice_shard.png",
		"res://Assets/Effects/Skills/thunder_strike.png",
		"res://Assets/Effects/Skills/fire_ball.png",
		"res://Assets/Effects/Skills/poison_dart.png",
	]
	
	var all_ok = true
	for asset_path in required_assets:
		if ResourceLoader.exists(asset_path):
			print("  ✓ 资源存在: %s" % asset_path.get_file())
		else:
			print("  ✗ 资源缺失: %s" % asset_path.get_file())
			all_ok = false
	
	return all_ok

func _load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) == OK:
		return json.data
	return {}
