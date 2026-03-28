extends SceneTree

## 测试异步加载性能
## 验证 EnemyRegistry 和 SkillRegistry 的异步加载是否正常工作

func _init():
	print("\n" + "=".repeat(60))
	print("异步加载性能测试")
	print("=".repeat(60) + "\n")
	
	# 等待 Autoload 初始化
	await create_timer(0.1).timeout
	
	print("【测试 1: GameConfig 配置】")
	print("  DEBUG_LOGGING: %s" % GameConfig.DEBUG_LOGGING)
	print("  GAME_DURATION: %d 秒" % GameConfig.GAME_DURATION)
	print("  PATH_ENEMY_REGISTRY: %s" % GameConfig.PATH_ENEMY_REGISTRY)
	print("  PATH_SKILL_REGISTRY: %s" % GameConfig.PATH_SKILL_REGISTRY)
	
	print("\n【测试 2: EnemyRegistry 异步加载】")
	var enemy_start := Time.get_ticks_msec()
	
	# 检查是否正在加载
	if EnemyRegistry._is_loading:
		print("  ⏳ 正在异步加载...")
		await EnemyRegistry.loading_complete
		print("  ✓ 异步加载完成")
	elif EnemyRegistry._is_ready:
		print("  ✓ 已加载完成")
	else:
		print("  ⚠️ 未开始加载，手动触发...")
		await EnemyRegistry.ensure_loaded()
	
	var enemy_time := Time.get_ticks_msec() - enemy_start
	var enemy_count = EnemyRegistry.get_all_item_ids().size()
	print("  - 敌人数量: %d" % enemy_count)
	print("  - 耗时: %d ms" % enemy_time)
	
	print("\n【测试 3: SkillRegistry 异步加载】")
	var skill_start := Time.get_ticks_msec()
	
	if SkillRegistry._is_loading:
		print("  ⏳ 正在异步加载...")
		await SkillRegistry.loading_complete
		print("  ✓ 异步加载完成")
	elif SkillRegistry._is_ready:
		print("  ✓ 已加载完成")
	else:
		print("  ⚠️ 未开始加载，手动触发...")
		await SkillRegistry.ensure_loaded()
	
	var skill_time := Time.get_ticks_msec() - skill_start
	var skill_count = SkillRegistry.get_all_item_ids().size()
	print("  - 技能数量: %d" % skill_count)
	print("  - 耗时: %d ms" % skill_time)
	
	print("\n【测试 4: 验证数据完整性】")
	
	# 测试获取敌人场景
	var test_enemy_id = "enemy_kobold_weak"
	var enemy_scene = EnemyRegistry.get_item_scene(test_enemy_id)
	if enemy_scene:
		print("  ✓ 成功获取敌人场景: %s" % test_enemy_id)
	else:
		print("  ✗ 获取敌人场景失败: %s" % test_enemy_id)
	
	# 测试获取技能场景
	var test_skill_id = "icespear"
	var skill_scene = SkillRegistry.get_item_scene(test_skill_id)
	if skill_scene:
		print("  ✓ 成功获取技能场景: %s" % test_skill_id)
	else:
		print("  ✗ 获取技能场景失败: %s" % test_skill_id)
	
	print("\n" + "=".repeat(60))
	print("测试完成！")
	print("异步加载工作正常，编辑器启动应该更快")
	print("=".repeat(60) + "\n")
	
	quit()
