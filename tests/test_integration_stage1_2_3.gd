extends SceneTree

## 阶段1-2-3集成测试
## 模拟完整游戏流程，测试所有功能

const GameConstants = preload("res://Utility/game_constants.gd")
const StatusEffect = preload("res://Utility/Effects/status_effect.gd")

var test_passed = 0
var test_failed = 0
var test_world_scene = null
var test_player = null

func _init():
	print("\n" + "=".repeat(70))
	print("阶段1-2-3集成测试")
	print("=".repeat(70) + "\n")
	
	_test_stage1_operations()
	_test_stage2_sect_system()
	_test_stage3_weapon_system()
	_test_game_flow()
	
	print("\n" + "=".repeat(70))
	if test_failed == 0:
		print("✓ 所有测试通过！(%d/%d)" % [test_passed, test_passed])
	else:
		print("✗ 部分测试失败")
		print("通过: %d, 失败: %d" % [test_passed, test_failed])
	print("=".repeat(70) + "\n")
	
	quit()

# ========================================
# 阶段1：操作控制系统测试
# ========================================

func _test_stage1_operations():
	print("【阶段1：操作控制系统】")
	
	# 测试1：输入映射
	_assert(InputMap.has_action("up"), "输入映射: up")
	_assert(InputMap.has_action("down"), "输入映射: down")
	_assert(InputMap.has_action("left"), "输入映射: left")
	_assert(InputMap.has_action("right"), "输入映射: right")
	_assert(InputMap.has_action("attack"), "输入映射: attack (左键/空格)")
	_assert(InputMap.has_action("right_click"), "输入映射: right_click")
	_assert(InputMap.has_action("shift"), "输入映射: shift (冲刺)")
	_assert(InputMap.has_action("skill_q"), "输入映射: skill_q")
	_assert(InputMap.has_action("skill_e"), "输入映射: skill_e")
	_assert(InputMap.has_action("skill_r"), "输入映射: skill_r")
	
	# 测试2：配置文件加载
	var config = _load_json("res://config/stage1_controls.json")
	_assert(not config.is_empty(), "配置文件加载")
	_assert(config.has("primary_attack"), "主攻击配置")
	_assert(config.has("secondary_attack"), "副攻击配置")
	_assert(config.has("dash"), "冲刺配置")
	_assert(config.has("skills"), "技能配置")
	
	# 测试3：组件脚本存在
	_assert(ResourceLoader.exists("res://Player/Components/input_manager.gd"), "InputManager脚本")
	_assert(ResourceLoader.exists("res://Player/Components/attack_manager.gd"), "AttackManager脚本")
	_assert(ResourceLoader.exists("res://Player/Components/dash_manager.gd"), "DashManager脚本")
	_assert(ResourceLoader.exists("res://Player/Components/melee_attack.gd"), "MeleeAttack脚本")
	_assert(ResourceLoader.exists("res://Player/Components/ranged_attack.gd"), "RangedAttack脚本")
	
	print("")

# ========================================
# 阶段2：宗派系统测试
# ========================================

func _test_stage2_sect_system():
	print("【阶段2：宗派系统】")
	
	# 测试1：宗派配置
	var sect_config = _load_json("res://config/sect_config.json")
	_assert(not sect_config.is_empty(), "宗派配置加载")
	_assert(sect_config.has("sects"), "宗派配置结构")
	
	var sects = sect_config.get("sects", {})
	_assert(sects.has("ice"), "冰心宗配置")
	_assert(sects.has("thunder"), "雷鸣宗配置")
	_assert(sects.has("fire"), "烈焰宗配置")
	_assert(sects.has("poison"), "毒瘴宗配置")
	
	# 测试2：宗派技能配置
	for sect_id in ["ice", "thunder", "fire", "poison"]:
		var sect = sects[sect_id]
		_assert(sect.has("skills"), "%s技能配置" % sect["name"])
		var skills = sect["skills"]
		_assert(skills.has("q"), "%s Q技能" % sect["name"])
		_assert(skills.has("e"), "%s E技能" % sect["name"])
		_assert(skills.has("r"), "%s R技能" % sect["name"])
	
	# 测试3：主动技能脚本
	_assert(ResourceLoader.exists("res://Skills/ActiveSkills/base_active_skill.gd"), "BaseActiveSkill基类")
	_assert(ResourceLoader.exists("res://Skills/ActiveSkills/ice_shard.gd"), "冰霜碎片脚本")
	_assert(ResourceLoader.exists("res://Skills/ActiveSkills/thunder_strike.gd"), "雷霆一击脚本")
	_assert(ResourceLoader.exists("res://Skills/ActiveSkills/fire_ball.gd"), "火球术脚本")
	_assert(ResourceLoader.exists("res://Skills/ActiveSkills/poison_dart.gd"), "毒镖脚本")
	
	# 测试4：宗派管理器
	_assert(ResourceLoader.exists("res://Player/Components/sect_manager.gd"), "SectManager脚本")
	_assert(ResourceLoader.exists("res://Player/Components/active_skill_manager.gd"), "ActiveSkillManager脚本")
	
	# 测试5：状态效果系统
	var slow_effect = StatusEffect.SlowEffect.new(2.0, 0.3)
	_assert(slow_effect != null, "SlowEffect创建")
	_assert(slow_effect.effect_type == GameConstants.StatusEffectType.SLOW, "SlowEffect类型")
	
	var burn_effect = StatusEffect.BurnEffect.new(3.0, 5.0)
	_assert(burn_effect != null, "BurnEffect创建")
	_assert(burn_effect.effect_type == GameConstants.StatusEffectType.BURN, "BurnEffect类型")
	
	print("")

# ========================================
# 阶段3：武器系统测试
# ========================================

func _test_stage3_weapon_system():
	print("【阶段3：武器系统】")
	
	# 测试1：双攻击配置
	var config = _load_json("res://config/stage1_controls.json")
	var primary = config.get("primary_attack", {})
	var secondary = config.get("secondary_attack", {})
	
	_assert(primary.get("type") == "melee", "主攻击类型: melee")
	_assert(secondary.get("type") == "ranged", "副攻击类型: ranged")
	_assert(primary.has("base_damage"), "主攻击伤害配置")
	_assert(secondary.has("base_damage"), "副攻击伤害配置")
	_assert(secondary.has("projectile_speed"), "副攻击弹速配置")
	
	# 测试2：攻击脚本
	var base_attack = load("res://Player/Components/base_attack.gd")
	_assert(base_attack != null, "BaseAttack基类加载")
	
	var melee_attack = load("res://Player/Components/melee_attack.gd")
	_assert(melee_attack != null, "MeleeAttack脚本加载")
	
	var ranged_attack = load("res://Player/Components/ranged_attack.gd")
	_assert(ranged_attack != null, "RangedAttack脚本加载")
	
	print("")

# ========================================
# 游戏流程测试
# ========================================

func _test_game_flow():
	print("【游戏流程测试】")
	
	# 测试1：场景加载
	var world_scene = load("res://World/world.tscn")
	_assert(world_scene != null, "World场景加载")
	
	# 实例化场景
	test_world_scene = world_scene.instantiate()
	_assert(test_world_scene != null, "World场景实例化")
	
	root.add_child(test_world_scene)
	await root.process_frame
	
	# 测试2：Player初始化
	test_player = test_world_scene.get_node_or_null("Player")
	_assert(test_player != null, "Player节点存在")
	
	if test_player:
		# 等待Player完全初始化
		await root.create_timer(0.5).timeout
		
		# 测试3：Player组件
		var stats = test_player.get("stats")
		_assert(stats != null, "PlayerStats组件")
		
		var attack_mgr = test_player.get("attack_mgr")
		_assert(attack_mgr != null, "AttackManager组件")
		
		var dash_mgr = test_player.get("dash_mgr")
		_assert(dash_mgr != null, "DashManager组件")
		
		var active_skill_mgr = test_player.get("active_skill_mgr")
		_assert(active_skill_mgr != null, "ActiveSkillManager组件")
		
		var sect_mgr = test_player.get("sect_mgr")
		_assert(sect_mgr != null, "SectManager组件")
		
		# 测试4：宗派选择
		if sect_mgr:
			_assert(sect_mgr.has_selected_sect(), "宗派已选择")
			var current_sect = sect_mgr.get_current_sect_id()
			_assert(current_sect == "ice", "当前宗派: 冰心宗")
		
		# 测试5：技能解锁状态
		if active_skill_mgr:
			_assert(active_skill_mgr.is_skill_unlocked("q"), "Q技能已解锁")
			_assert(active_skill_mgr.is_skill_unlocked("e"), "E技能已解锁")
			_assert(active_skill_mgr.is_skill_unlocked("r"), "R技能已解锁")
		
		# 测试6：模拟Q技能释放
		if active_skill_mgr and sect_mgr:
			print("  → 模拟释放Q技能...")
			var can_cast = active_skill_mgr.try_cast_skill("q")
			_assert(can_cast, "Q技能可以释放")
			
			# 等待技能执行
			await root.create_timer(0.5).timeout
			
			# 检查冷却
			var is_on_cd = active_skill_mgr.is_skill_on_cooldown("q")
			_assert(is_on_cd, "Q技能进入冷却")
		
		# 测试7：模拟近战攻击
		if attack_mgr:
			print("  → 模拟近战攻击...")
			var primary = attack_mgr.get_primary_attack()
			_assert(primary != null, "主攻击存在")
			
			if primary:
				var can_attack = primary.can_attack()
				_assert(can_attack, "可以执行主攻击")
		
		# 测试8：模拟冲刺
		if dash_mgr:
			print("  → 模拟冲刺...")
			_assert(dash_mgr.has_method("can_dash"), "DashManager有can_dash方法")
			_assert(dash_mgr.has_method("start_dash"), "DashManager有start_dash方法")
	
	print("")

# ========================================
# 工具函数
# ========================================

func _assert(condition: bool, test_name: String):
	if condition:
		print("  ✓ %s" % test_name)
		test_passed += 1
	else:
		print("  ✗ %s" % test_name)
		test_failed += 1

func _load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		return json.data
	else:
		return {}
