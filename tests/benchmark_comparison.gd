extends Node

# 性能对比测试 - 对比普通实例化 vs GPU 实例化

func _ready():
	print("\n" + "="*60)
	print("性能对比测试")
	print("="*60)
	
	print("\n测试配置:")
	print("  敌人数量: 500 (每种 100 个)")
	print("  测试时长: 10 秒")
	print("  采样频率: 每帧")
	
	print("\n[测试 1] 普通对象池实例化")
	print("  场景: tests/performance_test.tscn")
	print("  方法: CharacterBody2D + ObjectPool")
	print("  说明: 每个敌人是独立的节点")
	
	print("\n[测试 2] GPU 实例化 (MultiMesh)")
	print("  场景: tests/performance_test_gpu.tscn")
	print("  方法: MultiMesh + 数据驱动")
	print("  说明: 使用 GPU 批量渲染")
	
	print("\n" + "="*60)
	print("请手动运行以下命令进行测试:")
	print("="*60)
	
	print("\n# 测试 1 - 普通对象池")
	print("F:\\project\\godot\\Godot_v4.6.1-stable_win64.exe tests/performance_test.tscn")
	print("# 观察 FPS，运行 10 秒后按 ESC 查看统计")
	
	print("\n# 测试 2 - GPU 实例化")
	print("F:\\project\\godot\\Godot_v4.6.1-stable_win64.exe tests/performance_test_gpu.tscn")
	print("# 观察 FPS，运行 10 秒后按 ESC 查看统计")
	
	print("\n预期结果:")
	print("  普通对象池: 平均 FPS ~10-30")
	print("  GPU 实例化: 平均 FPS ~100-300")
	print("  性能提升: 10-30 倍")
	
	print("\n" + "="*60)
	
	get_tree().quit()
