extends SceneTree

## 测试技能 GPU 实例化系统

func _init():
	print("\n" + "=".repeat(60))
	print("技能 GPU 实例化测试")
	print("=".repeat(60) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# 测试 1: SkillInstanceManager 加载
	print("【测试 1: SkillInstanceManager 初始化】")
	var skill_mgr_script = load("res://Skills/skill_instance_manager.gd")
	if not skill_mgr_script:
		print("  ✗ 无法加载 skill_instance_manager.gd")
		quit(1)
		return
	
	var skill_mgr = skill_mgr_script.new()
	var root = Node2D.new()
	root.add_child(skill_mgr)
	skill_mgr.set_container(root)
	print("  ✓ SkillInstanceManager 创建成功")
	
	# 等待初始化
	if not skill_mgr.is_initialized:
		await skill_mgr.initialization_complete
	
	if skill_mgr.is_initialized:
		print("  ✓ 技能类型初始化完成")
		print("  - 技能类型数: %d" % skill_mgr.skill_types.size())
	else:
		print("  ✗ 初始化失败")
		all_passed = false
	
	# 测试 2: 生成冰矛
	print("\n【测试 2: 生成冰矛技能】")
	if skill_mgr.skill_types.has("icespear"):
		var pos = Vector2(100, 100)
		var vel = Vector2(200, 0)
		var id = skill_mgr.spawn_skill("icespear", pos, vel, 0.0, Vector2(500, 100))
		
		if id >= 0:
			print("  ✓ 冰矛生成成功 (ID: %d)" % id)
			var type_data = skill_mgr.skill_types["icespear"]
			print("  - 实例数: %d" % type_data.instances.size())
			print("  - MultiMesh 实例数: %d" % type_data.multimesh_instance.multimesh.instance_count)
			
			if type_data.instances[id].hit_box:
				print("  ✓ 碰撞体已创建")
			else:
				print("  ✗ 碰撞体未创建")
				all_passed = false
		else:
			print("  ✗ 冰矛生成失败")
			all_passed = false
	else:
		print("  ✗ icespear 类型未注册")
		all_passed = false
	
	# 测试 3: 生成龙卷风
	print("\n【测试 3: 生成龙卷风技能】")
	if skill_mgr.skill_types.has("tornado"):
		var pos = Vector2(200, 200)
		var vel = Vector2(50, 50)
		var id = skill_mgr.spawn_skill("tornado", pos, vel, 0.0)
		
		if id >= 0:
			print("  ✓ 龙卷风生成成功 (ID: %d)" % id)
			var active_count = skill_mgr.get_active_skill_count("tornado")
			print("  - 活跃龙卷风数: %d" % active_count)
		else:
			print("  ✗ 龙卷风生成失败")
			all_passed = false
	else:
		print("  ✗ tornado 类型未注册")
		all_passed = false
	
	# 测试 4: 更新和移动
	print("\n【测试 4: 技能更新和移动】")
	var initial_pos = skill_mgr.skill_types["icespear"].instances[0].position
	
	# 模拟几帧更新
	for i in range(5):
		skill_mgr._physics_process(0.016)  # 60 FPS
		await create_timer(0.016).timeout
	
	var new_pos = skill_mgr.skill_types["icespear"].instances[0].position
	if new_pos != initial_pos:
		print("  ✓ 技能位置更新正常")
		print("  - 初始位置: %s" % initial_pos)
		print("  - 新位置: %s" % new_pos)
	else:
		print("  ✗ 技能位置未更新")
		all_passed = false
	
	# 测试 5: 生命周期
	print("\n【测试 5: 技能生命周期】")
	var short_lifetime_id = skill_mgr.spawn_skill("icespear", Vector2(300, 300), Vector2.ZERO, 0.0)
	if short_lifetime_id >= 0:
		var inst = skill_mgr.skill_types["icespear"].instances[short_lifetime_id]
		inst.max_lifetime = 0.1  # 设置很短的生命周期
		
		await create_timer(0.2).timeout
		skill_mgr._physics_process(0.2)
		
		if not inst.active:
			print("  ✓ 技能生命周期正常（已销毁）")
		else:
			print("  ✗ 技能未按预期销毁")
			all_passed = false
	
	# 测试 6: 清理
	print("\n【测试 6: 清理所有技能】")
	var total_before = skill_mgr.get_active_skill_count()
	skill_mgr.clear_all_skills()
	var total_after = skill_mgr.get_active_skill_count()
	
	if total_after == 0:
		print("  ✓ 所有技能已清理")
		print("  - 清理前: %d" % total_before)
		print("  - 清理后: %d" % total_after)
	else:
		print("  ✗ 技能清理失败")
		all_passed = false
	
	# 总结
	print("\n" + "=".repeat(60))
	if all_passed:
		print("✓ 所有测试通过！技能 GPU 实例化系统正常工作")
	else:
		print("✗ 部分测试失败")
	print("=".repeat(60) + "\n")
	
	quit(0 if all_passed else 1)
