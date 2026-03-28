extends SceneTree

# 阶段 1 简单测试：基础架构组件

func _init():
	print("\n========================================")
	print("开始阶段 1 测试：基础架构组件")
	print("========================================\n")
	
	var all_passed = true
	
	all_passed = test_event_bus() and all_passed
	all_passed = test_config_manager() and all_passed
	all_passed = test_base_skill_class() and all_passed
	all_passed = test_effect_classes() and all_passed
	
	print("\n========================================")
	print("测试结果汇总")
	print("========================================")
	
	if all_passed:
		print("\n✓ 阶段 1 所有测试通过！")
		quit(0)
	else:
		print("\n✗ 阶段 1 有测试失败")
		quit(1)

func test_event_bus() -> bool:
	print("测试 1: EventBus 事件总线")
	
	var event_bus_script = load("res://Utility/event_bus.gd")
	if event_bus_script == null:
		print("  ✗ 无法加载 event_bus.gd")
		return false
	
	var event_bus = event_bus_script.new()
	
	# 测试信号是否存在
	var required_signals = [
		"enemy_killed",
		"player_leveled_up",
		"skill_upgraded",
		"upgrade_collected",
		"game_started"
	]
	
	for sig in required_signals:
		if not event_bus.has_signal(sig):
			print("  ✗ EventBus 缺少信号: %s" % sig)
			event_bus.free()
			return false
	
	event_bus.free()
	print("  ✓ EventBus 测试通过")
	return true

func test_config_manager() -> bool:
	print("测试 2: ConfigManager 配置管理器")
	
	var config_mgr_script = load("res://Utility/config_manager.gd")
	if config_mgr_script == null:
		print("  ✗ 无法加载 config_manager.gd")
		return false
	
	var config_mgr = config_mgr_script.new()
	
	# 测试加载现有配置文件
	var cfg = config_mgr.load_ini_config("res://config/skill_config.ini")
	if cfg == null:
		print("  ✗ ConfigManager 无法加载 skill_config.ini")
		config_mgr.free()
		return false
	
	# 测试获取节数据
	var section_data = config_mgr.get_section_data("res://config/skill_config.ini", "IceSpear")
	if section_data.size() == 0:
		print("  ✗ ConfigManager 无法获取配置节数据")
		config_mgr.free()
		return false
	
	# 验证数据正确性
	if not section_data.has("base_speed"):
		print("  ✗ ConfigManager 配置数据不完整")
		config_mgr.free()
		return false
	
	config_mgr.free()
	print("  ✓ ConfigManager 测试通过")
	return true

func test_base_skill_class() -> bool:
	print("测试 3: BaseSkill 技能基类")
	
	var base_skill_script = load("res://Utility/base_skill.gd")
	if base_skill_script == null:
		print("  ✗ 无法加载 base_skill.gd")
		return false
	
	# 验证类名是否正确定义
	if base_skill_script.get_global_name() != "BaseSkill":
		print("  ✗ BaseSkill 类名未正确定义")
		return false
	
	print("  ✓ BaseSkill 类定义正确")
	return true

func test_effect_classes() -> bool:
	print("测试 4: 效果系统类")
	
	# 测试 BaseEffect
	var base_effect_script = load("res://Utility/Effects/base_effect.gd")
	if base_effect_script == null:
		print("  ✗ 无法加载 base_effect.gd")
		return false
	
	# 测试 StatModifierEffect
	var stat_effect_script = load("res://Utility/Effects/stat_modifier_effect.gd")
	if stat_effect_script == null:
		print("  ✗ 无法加载 stat_modifier_effect.gd")
		return false
	
	var stat_effect = stat_effect_script.new("test_stat", 10.0, 0)
	if stat_effect == null:
		print("  ✗ 无法创建 StatModifierEffect 实例")
		return false
	
	# 测试 SkillUnlockEffect
	var skill_unlock_script = load("res://Utility/Effects/skill_unlock_effect.gd")
	if skill_unlock_script == null:
		print("  ✗ 无法加载 skill_unlock_effect.gd")
		return false
	
	# 测试 HealEffect
	var heal_effect_script = load("res://Utility/Effects/heal_effect.gd")
	if heal_effect_script == null:
		print("  ✗ 无法加载 heal_effect.gd")
		return false
	
	print("  ✓ 所有效果类加载成功")
	return true
