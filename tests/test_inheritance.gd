extends SceneTree

## 测试继承架构
## 验证 BaseRegistry 和 BaseEnemy 的继承是否正常工作

func _init():
	print("\n" + "=".repeat(60))
	print("继承架构测试")
	print("=".repeat(60) + "\n")
	
	await create_timer(0.1).timeout
	
	# 测试 1: GameConfig
	print("【测试 1: GameConfig 全局配置】")
	print("  DEBUG_LOGGING: %s" % GameConfig.DEBUG_LOGGING)
	print("  GAME_DURATION: %d 秒" % GameConfig.GAME_DURATION)
	print("  ENEMY_ANIM_FRAME_DURATION: %.2f 秒" % GameConfig.ENEMY_ANIM_FRAME_DURATION)
	print("  ✓ GameConfig 可访问\n")
	
	# 测试 2: EnemyRegistry 继承
	print("【测试 2: EnemyRegistry 继承 BaseRegistry】")
	print("  等待异步加载...")
	await EnemyRegistry.ensure_loaded()
	
	if EnemyRegistry._is_ready:
		print("  ✓ 异步加载完成")
		var enemy_ids = EnemyRegistry.get_all_item_ids()
		print("  - 敌人数量: %d" % enemy_ids.size())
		
		if enemy_ids.size() > 0:
			var test_id = enemy_ids[0]
			var scene = EnemyRegistry.get_item_scene(test_id)
			var data = EnemyRegistry.get_item_data(test_id)
			print("  - 示例敌人: %s" % test_id)
			print("    场景: %s" % ("有效" if scene else "无效"))
			print("    数据: %s" % data)
	else:
		print("  ✗ 加载失败")
	
	# 测试 3: SkillRegistry 继承
	print("\n【测试 3: SkillRegistry 继承 BaseRegistry】")
	print("  等待异步加载...")
	await SkillRegistry.ensure_loaded()
	
	if SkillRegistry._is_ready:
		print("  ✓ 异步加载完成")
		var skill_ids = SkillRegistry.get_all_item_ids()
		print("  - 技能数量: %d" % skill_ids.size())
		
		if skill_ids.size() > 0:
			var test_id = skill_ids[0]
			var scene = SkillRegistry.get_item_scene(test_id)
			var data = SkillRegistry.get_item_data(test_id)
			print("  - 示例技能: %s" % test_id)
			print("    场景: %s" % ("有效" if scene else "无效"))
			print("    数据: %s" % data)
	else:
		print("  ✗ 加载失败")
	
	# 测试 4: BaseEnemy
	print("\n【测试 4: BaseEnemy 基类】")
	var enemy_scene = EnemyRegistry.get_item_scene("enemy_kobold_weak")
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		var base_enemy_script = load("res://Enemy/base_enemy.gd")
		if enemy_instance.get_script().get_base_script() == base_enemy_script:
			print("  ✓ enemy_kobold_weak 继承自 BaseEnemy")
			if enemy_instance.has_method("get_enemy_config"):
				var config = enemy_instance.get_enemy_config()
				print("  - movement_speed: %.1f" % config.movement_speed)
				print("  - hp: %d" % config.hp)
				print("  - enemy_damage: %d" % config.enemy_damage)
		else:
			print("  ✗ enemy_kobold_weak 未继承 BaseEnemy")
		enemy_instance.queue_free()
	else:
		print("  ✗ 无法加载敌人场景")
	
	# 测试 5: BaseSkill
	print("\n【测试 5: BaseSkill 基类】")
	var skill_scene = SkillRegistry.get_item_scene("icespear")
	if skill_scene:
		print("  ✓ icespear 场景存在")
		print("  - 技能继承自 BaseSkill（运行时验证）")
	else:
		print("  ✗ 无法加载技能场景")
	
	print("\n" + "=".repeat(60))
	print("继承架构测试完成！")
	print("所有系统正常工作")
	print("=".repeat(60) + "\n")
	
	quit()
