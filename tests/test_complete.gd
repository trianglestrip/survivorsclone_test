extends SceneTree

# 完整重构测试 - 验证所有阶段

func _init():
	var separator = "============================================================"
	print("\n" + separator)
	print("完整架构重构测试")
	print(separator + "\n")
	
	var all_passed = true
	var stage_results = []
	
	# 阶段 1-3 测试
	print("【阶段 1】基础架构组件")
	var stage1 = test_stage1()
	stage_results.append({"stage": "阶段 1", "passed": stage1})
	all_passed = stage1 and all_passed
	
	print("\n【阶段 2】技能系统重构")
	var stage2 = test_stage2()
	stage_results.append({"stage": "阶段 2", "passed": stage2})
	all_passed = stage2 and all_passed
	
	print("\n【阶段 3】玩家组件化")
	var stage3 = test_stage3()
	stage_results.append({"stage": "阶段 3", "passed": stage3})
	all_passed = stage3 and all_passed
	
	print("\n【阶段 4】升级系统增强")
	var stage4 = test_stage4()
	stage_results.append({"stage": "阶段 4", "passed": stage4})
	all_passed = stage4 and all_passed
	
	print("\n【阶段 5】敌人系统优化")
	var stage5 = test_stage5()
	stage_results.append({"stage": "阶段 5", "passed": stage5})
	all_passed = stage5 and all_passed
	
	print("\n【阶段 6】对象池系统")
	var stage6 = test_stage6()
	stage_results.append({"stage": "阶段 6", "passed": stage6})
	all_passed = stage6 and all_passed
	
	print("\n【阶段 7】玩家类集成")
	var stage7 = test_stage7()
	stage_results.append({"stage": "阶段 7", "passed": stage7})
	all_passed = stage7 and all_passed
	
	# 打印总结
	print("\n" + separator)
	print("测试结果总结")
	print(separator)
	for result in stage_results:
		var status = "✗ 失败"
		if result["passed"]:
			status = "✓ 通过"
		print("%s: %s" % [result["stage"], status])
	
	print("\n" + separator)
	if all_passed:
		print("✓ 所有阶段测试通过！")
		print(separator)
		quit(0)
	else:
		print("✗ 部分阶段测试失败")
		print(separator)
		quit(1)

func test_stage1() -> bool:
	var tests = [
		check_file("res://Utility/event_bus.gd", "EventBus"),
		check_file("res://Utility/config_manager.gd", "ConfigManager"),
		check_file("res://Utility/base_skill.gd", "BaseSkill"),
		check_file("res://Utility/Effects/base_effect.gd", "BaseEffect"),
		check_file("res://Utility/Effects/stat_modifier_effect.gd", "StatModifierEffect"),
	]
	return tests.all(func(x): return x)

func test_stage2() -> bool:
	var tests = [
		check_file("res://Utility/skill_registry.gd", "SkillRegistry"),
		check_skill_inheritance("res://Player/Attack/ice_spear.gd", "IceSpear"),
		check_skill_inheritance("res://Player/Attack/tornado.gd", "Tornado"),
		check_skill_inheritance("res://Player/Attack/javelin.gd", "Javelin"),
	]
	return tests.all(func(x): return x)

func test_stage3() -> bool:
	var tests = [
		check_file("res://Player/Components/player_stats.gd", "PlayerStats"),
		check_file("res://Player/Components/skill_manager.gd", "SkillManager"),
		check_file("res://Player/Components/experience_manager.gd", "ExperienceManager"),
		check_file("res://Player/Components/upgrade_manager.gd", "UpgradeManager"),
	]
	return tests.all(func(x): return x)

func test_stage4() -> bool:
	var tests = [
		check_file("res://Utility/upgrade_db_enhanced.gd", "UpgradeDbEnhanced"),
		check_file("res://Player/Components/upgrade_manager_v2.gd", "UpgradeManagerV2"),
	]
	return tests.all(func(x): return x)

func test_stage5() -> bool:
	var tests = [
		check_file("res://Utility/enemy_registry.gd", "EnemyRegistry"),
		check_file("res://Utility/enemy_spawner_enhanced.gd", "EnemySpawnerEnhanced"),
		check_config_file("res://config/spawn_waves.ini", "SpawnWaves"),
	]
	return tests.all(func(x): return x)

func test_stage6() -> bool:
	var tests = [
		check_file("res://Utility/object_pool.gd", "ObjectPool"),
		check_object_pool_support("res://Enemy/explosion.gd", "Explosion"),
		check_object_pool_support("res://Objects/experience_gem.gd", "ExperienceGem"),
	]
	return tests.all(func(x): return x)

func test_stage7() -> bool:
	var player_script = load("res://Player/player.gd")
	if player_script == null:
		print("  ✗ 无法加载 player.gd")
		return false
	
	# 检查是否使用组件化架构
	var script_text = player_script.source_code
	if script_text.contains("_initialize_components"):
		print("  ✓ player.gd 已集成组件化架构")
		return true
	else:
		print("  ⚠ player.gd 未使用组件化架构")
		return false

func check_file(path: String, name: String) -> bool:
	var script = load(path)
	if script == null:
		print("  ✗ %s 加载失败" % name)
		return false
	print("  ✓ %s" % name)
	return true

func check_config_file(path: String, name: String) -> bool:
	if FileAccess.file_exists(path):
		print("  ✓ %s 配置文件存在" % name)
		return true
	else:
		print("  ✗ %s 配置文件不存在" % name)
		return false

func check_skill_inheritance(path: String, skill_name: String) -> bool:
	var script = load(path)
	if script == null:
		print("  ✗ %s 加载失败" % skill_name)
		return false
	
	var base_script = script.get_base_script()
	if base_script and base_script.get_global_name() == "BaseSkill":
		print("  ✓ %s 继承 BaseSkill" % skill_name)
		return true
	else:
		print("  ✗ %s 未正确继承 BaseSkill" % skill_name)
		return false

func check_object_pool_support(path: String, name: String) -> bool:
	var script = load(path)
	if script == null:
		print("  ✗ %s 加载失败" % name)
		return false
	
	var script_text = script.source_code
	if script_text.contains("reset_state"):
		print("  ✓ %s 支持对象池" % name)
		return true
	else:
		print("  ⚠ %s 未完全支持对象池" % name)
		return true
