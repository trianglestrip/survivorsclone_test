extends SceneTree

## 最终架构验证测试
## 验证继承体系、GPU 实例化、文件结构

func _init():
	print("\n" + "=".repeat(70))
	print("最终架构验证测试")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 文件结构
	# ========================================
	print("【测试 1: 文件结构验证】")
	var required_files = [
		"res://Utility/base_registry.gd",
		"res://Utility/game_config.gd",
		"res://Enemy/base_enemy.gd",
		"res://Enemy/enemy.gd",
		"res://Enemy/enemy_registry.gd",
		"res://Enemy/enemy_instance_manager.gd",
		"res://Skills/base_skill.gd",
		"res://Skills/skill_registry.gd",
		"res://Skills/skill_instance_manager.gd",
		"res://Skills/ice_spear.gd",
		"res://Skills/tornado.gd",
		"res://Skills/javelin.gd",
	]
	
	for file_path in required_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path)
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: GameConfig
	# ========================================
	print("\n【测试 2: GameConfig 全局配置】")
	print("  DEBUG_LOGGING: %s" % GameConfig.DEBUG_LOGGING)
	print("  GAME_DURATION: %d 秒" % GameConfig.GAME_DURATION)
	print("  MAX_ENEMIES: %d" % GameConfig.MAX_ENEMIES)
	print("  ✓ GameConfig 可访问")
	
	# ========================================
	# 测试 3: 注册系统继承
	# ========================================
	print("\n【测试 3: 注册系统继承 BaseRegistry】")
	
	await EnemyRegistry.ensure_loaded()
	await SkillRegistry.ensure_loaded()
	
	var enemy_count = EnemyRegistry.get_all_item_ids().size()
	var skill_count = SkillRegistry.get_all_item_ids().size()
	
	print("  ✓ EnemyRegistry 加载完成 (敌人数: %d)" % enemy_count)
	print("  ✓ SkillRegistry 加载完成 (技能数: %d)" % skill_count)
	
	if enemy_count == 0:
		print("  ✗ 敌人注册为空")
		all_passed = false
	
	if skill_count == 0:
		print("  ✗ 技能注册为空")
		all_passed = false
	
	# ========================================
	# 测试 4: 敌人继承 BaseEnemy
	# ========================================
	print("\n【测试 4: 敌人继承 BaseEnemy】")
	var base_enemy_script = load("res://Enemy/base_enemy.gd")
	var enemy_scene = EnemyRegistry.get_item_scene("enemy_kobold_weak")
	
	if enemy_scene:
		var enemy_inst = enemy_scene.instantiate()
		var enemy_script = enemy_inst.get_script()
		
		if enemy_script and enemy_script.get_base_script() == base_enemy_script:
			print("  ✓ enemy_kobold_weak 继承 BaseEnemy")
			
			if enemy_inst.has_method("get_enemy_config"):
				var config = enemy_inst.get_enemy_config()
				print("    - HP: %d" % config.hp)
				print("    - 速度: %.1f" % config.movement_speed)
				print("    - 伤害: %d" % config.enemy_damage)
			else:
				print("  ✗ 缺少 get_enemy_config() 方法")
				all_passed = false
		else:
			print("  ✗ enemy_kobold_weak 未正确继承")
			all_passed = false
		
		enemy_inst.queue_free()
	else:
		print("  ✗ 无法加载敌人场景")
		all_passed = false
	
	# ========================================
	# 测试 5: 技能继承 BaseSkill
	# ========================================
	print("\n【测试 5: 技能继承 BaseSkill】")
	var base_skill_script = load("res://Skills/base_skill.gd")
	var skill_scene = SkillRegistry.get_item_scene("icespear")
	
	if skill_scene:
		var skill_inst = skill_scene.instantiate()
		var skill_script = skill_inst.get_script()
		
		if skill_script and skill_script.get_base_script() == base_skill_script:
			print("  ✓ icespear 继承 BaseSkill")
			
			if skill_inst.has_method("get_spawn_params"):
				print("    ✓ 实现 get_spawn_params()")
			else:
				print("    ✗ 缺少 get_spawn_params()")
				all_passed = false
			
			if skill_inst.has_method("update_skill_instance"):
				print("    ✓ 实现 update_skill_instance()")
			else:
				print("    ✗ 缺少 update_skill_instance()")
				all_passed = false
		else:
			print("  ✗ icespear 未正确继承")
			all_passed = false
		
		skill_inst.queue_free()
	else:
		print("  ✗ 无法加载技能场景")
		all_passed = false
	
	# ========================================
	# 测试 6: GPU 管理器
	# ========================================
	print("\n【测试 6: GPU 实例管理器】")
	
	var enemy_mgr_script = load("res://Enemy/enemy_instance_manager.gd")
	var skill_mgr_script = load("res://Skills/skill_instance_manager.gd")
	
	if enemy_mgr_script:
		print("  ✓ EnemyInstanceManager 存在")
	else:
		print("  ✗ EnemyInstanceManager 缺失")
		all_passed = false
	
	if skill_mgr_script:
		print("  ✓ SkillInstanceManager 存在")
	else:
		print("  ✗ SkillInstanceManager 缺失")
		all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 所有架构验证通过！")
		print("  - 继承体系正确")
		print("  - GPU 系统完整")
		print("  - 文件结构规范")
	else:
		print("✗ 部分验证失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
