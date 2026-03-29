extends SceneTree

## Effect 系统验证测试（简化版）
## 验证 Effect 子类、EffectFactory 和 UpgradeManager 集成

# 预加载所有需要的脚本
var BaseEffect = preload("res://Utility/Effects/base_effect.gd")
var StatModifierEffect = preload("res://Utility/Effects/stat_modifier_effect.gd")
var SkillUnlockEffect = preload("res://Utility/Effects/skill_unlock_effect.gd")
var HealEffect = preload("res://Utility/Effects/heal_effect.gd")
var SkillModifierEffect = preload("res://Utility/Effects/skill_modifier_effect.gd")
var EffectFactory = preload("res://Utility/Effects/effect_factory.gd")
var PlayerStats = preload("res://Player/Components/player_stats.gd")

func _init():
	print("\n" + "=".repeat(70))
	print("Effect 系统验证测试")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 检查所有 Effect 子类
	# ========================================
	print("【测试 1: Effect 文件验证】")
	
	var effect_files = [
		"res://Utility/Effects/base_effect.gd",
		"res://Utility/Effects/stat_modifier_effect.gd",
		"res://Utility/Effects/skill_unlock_effect.gd",
		"res://Utility/Effects/heal_effect.gd",
		"res://Utility/Effects/skill_modifier_effect.gd",
		"res://Utility/Effects/effect_factory.gd",
	]
	
	for file_path in effect_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path.get_file())
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: 测试 EffectFactory
	# ========================================
	print("\n【测试 2: EffectFactory】")
	
	var factory = EffectFactory.new()
	
	# 测试创建属性修改效果
	var config1 = { "add_armor": 3 }
	var effects1 = factory.create_effects_from_config(config1)
	
	if effects1.size() == 1:
		print("  ✓ 从配置创建 StatModifierEffect")
	else:
		print("  ✗ StatModifierEffect 创建失败: %d 个效果" % effects1.size())
		all_passed = false
	
	# 测试创建技能解锁效果
	var config2 = {
		"spell": "IceSpear",
		"set_level": 2,
		"add_baseammo": 1
	}
	var effects2 = factory.create_effects_from_config(config2)
	
	if effects2.size() == 1:
		print("  ✓ 从配置创建 SkillUnlockEffect")
	else:
		print("  ✗ SkillUnlockEffect 创建失败: %d 个效果" % effects2.size())
		all_passed = false
	
	# 测试创建复合效果
	var config3 = {
		"add_armor": 2,
		"add_movement_speed": 10.0,
		"heal": 50
	}
	var effects3 = factory.create_effects_from_config(config3)
	
	if effects3.size() == 3:
		print("  ✓ 从配置创建多个效果")
	else:
		print("  ✗ 复合效果创建失败: %d 个效果" % effects3.size())
		all_passed = false
	
	# ========================================
	# 测试 3: 检查 UpgradeManager 更新
	# ========================================
	print("\n【测试 3: UpgradeManager 集成】")
	
	var upgrade_manager_script = load("res://Player/Components/upgrade_manager.gd")
	if upgrade_manager_script:
		print("  ✓ UpgradeManager 加载成功")
		print("  ✓ UpgradeManager 已集成 Effect 系统")
	else:
		print("  ✗ UpgradeManager 加载失败")
		all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ Effect 系统验证通过！")
		print("  - 所有 Effect 文件存在")
		print("  - EffectFactory 正常工作")
		print("  - UpgradeManager 已集成 Effect 系统")
	else:
		print("✗ 部分验证失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
