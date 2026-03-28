extends SceneTree

## 初始化性能分析测试
## 测量所有 Autoload 和 EnemyInstanceManager 的初始化时间

var results := {}

func _init():
	print("\n" + "=".repeat(60))
	print("初始化性能分析测试")
	print("=".repeat(60) + "\n")
	
	# 等待 Autoload 初始化完成
	await create_timer(0.5).timeout
	
	print_autoload_results()
	print("\n" + "-".repeat(60) + "\n")
	
	await test_enemy_manager_init()
	
	print("\n" + "=".repeat(60))
	print_summary()
	print("=".repeat(60) + "\n")
	
	quit()

func print_autoload_results():
	print("【Autoload 初始化时间】")
	print("(从控制台输出中提取)\n")
	
	var autoloads := [
		"SkillRegistry",
		"EnemyRegistry", 
		"UpgradeDb"
	]
	
	for name in autoloads:
		print("  %s: 查看控制台输出" % name)

func test_enemy_manager_init():
	print("【EnemyInstanceManager 初始化测试】\n")
	
	var total_start := Time.get_ticks_msec()
	
	# 创建最小场景
	var root := Node2D.new()
	root.name = "TestRoot"
	get_root().add_child(root)
	
	var player := Node2D.new()
	player.name = "TestPlayer"
	player.add_to_group("player")
	root.add_child(player)
	
	var container := Node2D.new()
	container.name = "EnemyContainer"
	root.add_child(container)
	
	print("1. 创建管理器...")
	var create_start := Time.get_ticks_msec()
	var manager_script := load("res://Enemy/enemy_instance_manager.gd")
	var manager = manager_script.new()
	manager.set_container(container)
	manager.set_player(player)
	root.add_child(manager)
	var create_time := Time.get_ticks_msec() - create_start
	print("   ✓ 耗时: %d ms\n" % create_time)
	
	print("2. 等待初始化完成...")
	var init_start := Time.get_ticks_msec()
	await manager.initialization_complete
	var init_time := Time.get_ticks_msec() - init_start
	print("   ✓ 初始化耗时: %d ms\n" % init_time)
	
	var total_time := Time.get_ticks_msec() - total_start
	
	# 分析结果
	print("3. 初始化结果:")
	print("   - 敌人类型数: %d" % manager.enemy_types.size())
	
	var has_texture := 0
	var has_collision := 0
	var has_animation := 0
	
	for enemy_id in manager.enemy_types:
		var type_data = manager.enemy_types[enemy_id]
		if type_data.texture:
			has_texture += 1
		if type_data.collision_shape:
			has_collision += 1
		if type_data.hframes > 1:
			has_animation += 1
			print("   - %s: %d 帧动画" % [enemy_id, type_data.hframes])
	
	print("   - 有纹理: %d/%d" % [has_texture, manager.enemy_types.size()])
	print("   - 有碰撞: %d/%d" % [has_collision, manager.enemy_types.size()])
	print("   - 有动画: %d/%d\n" % [has_animation, manager.enemy_types.size()])
	
	# 存储结果
	results["manager_create"] = create_time
	results["manager_init"] = init_time
	results["manager_total"] = total_time
	results["enemy_types"] = manager.enemy_types.size()

func print_summary():
	print("【性能总结】\n")
	
	if results.has("manager_total"):
		print("EnemyInstanceManager:")
		print("  - 创建: %d ms" % results.manager_create)
		print("  - 初始化: %d ms" % results.manager_init)
		print("  - 总计: %d ms" % results.manager_total)
		print("  - 平均每类型: %.1f ms" % (float(results.manager_init) / results.enemy_types))
	
	print("\n【优化建议】\n")
	
	if results.get("manager_init", 0) > 100:
		print("⚠️ 初始化时间较长 (>100ms)，建议优化：")
		print("  1. 减少 instantiate() 调用（目前每类型一次）")
		print("  2. 预编译 ShaderMaterial（已实现缓存）")
		print("  3. 异步加载纹理资源")
		print("  4. 延迟创建 MultiMesh（按需创建）")
	elif results.get("manager_init", 0) > 50:
		print("✓ 初始化时间适中 (50-100ms)")
		print("  可选优化：")
		print("  - 考虑异步初始化（分帧处理）")
		print("  - 预加载常用敌人类型")
	else:
		print("✓✓ 初始化速度优秀 (<50ms)")
		print("  当前性能已经很好，无需优化")
	
	print("\n【瓶颈分析】\n")
	print("主要耗时操作（按优先级）：")
	print("  1. PackedScene.instantiate() - 获取碰撞形状")
	print("  2. FileAccess.open() - 读取 enemy_config.ini")
	print("  3. MultiMesh 创建和 add_child()")
	print("  4. Shader 编译（首次）")
	
	print("\n【进一步优化方案】\n")
	print("1. 预缓存方案：")
	print("   - 在主菜单时预加载敌人数据")
	print("   - 使用 ResourcePreloader 预加载场景")
	print("")
	print("2. 延迟初始化：")
	print("   - 只初始化前 3 波会出现的敌人")
	print("   - 后续敌人在首次生成前初始化")
	print("")
	print("3. 数据缓存：")
	print("   - 将碰撞形状数据序列化到 .tres 文件")
	print("   - 避免每次启动都 instantiate")
