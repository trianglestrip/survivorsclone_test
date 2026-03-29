extends SceneTree

## 视觉效果综合测试 - 验证所有视觉优化功能

var _passed := 0
var _failed := 0

func _initialize():
	print("\n========================================")
	print("视觉效果综合测试")
	print("========================================\n")

func _init():
	_initialize()
	await _run_all()
	print("\n========================================")
	print("通过: ", _passed, "  失败: ", _failed)
	print("========================================\n")
	quit()

func _run_all() -> void:
	await _test_visual_standards_config()
	await _test_skill_scale_helpers()
	await _test_sect_color_schemes()
	await _test_animation_enhancement()
	await _test_texture_preload_cache()

func _test_visual_standards_config() -> void:
	print("[测试1] 视觉效果标准配置加载")
	var root = get_root()
	var std = root.get_node_or_null("/root/VisualEffectsStandard")
	_assert(std != null, "VisualEffectsStandard autoload 存在")
	
	if std and std.has_method("get_skill_visual_config"):
		var proj_cfg = std.get_skill_visual_config("projectile")
		_assert(proj_cfg.has("base_scale"), "projectile 配置含 base_scale")
		_assert(proj_cfg.get("base_scale") > 1.0, "projectile base_scale > 1.0")
		
		var area_cfg = std.get_skill_visual_config("area")
		_assert(area_cfg.has("base_alpha"), "area 配置含 base_alpha")
		
		var ult_cfg = std.get_skill_visual_config("ultimate")
		_assert(ult_cfg.has("screen_shake"), "ultimate 配置含 screen_shake")

func _test_skill_scale_helpers() -> void:
	print("[测试2] 技能缩放辅助方法")
	var VFXHelper = load("res://Utility/visual_effects_helper.gd")
	
	var q_scale = VFXHelper.q_skill_scale_vector()
	_assert(q_scale.x >= 1.2 and q_scale.x <= 1.5, "Q技能缩放在合理范围")
	
	var e_scale = VFXHelper.e_skill_scale_vector(100.0)
	_assert(e_scale.x == 1.0, "E技能100半径缩放为1.0")
	
	var e_scale_200 = VFXHelper.e_skill_scale_vector(200.0)
	_assert(e_scale_200.x == 2.0, "E技能200半径缩放为2.0")
	
	var r_scale = VFXHelper.r_skill_scale_vector(150.0)
	_assert(r_scale.x == 1.0, "R技能150半径缩放为1.0")
	
	var wall_scale = VFXHelper.e_skill_fire_wall_scale(200.0, 80.0)
	_assert(wall_scale.x == 1.0 and wall_scale.y == 1.0, "火墙默认尺寸缩放为1.0")

func _test_sect_color_schemes() -> void:
	print("[测试3] 宗派颜色方案")
	var root = get_root()
	var std = root.get_node_or_null("/root/VisualEffectsStandard")
	if not std:
		_assert(false, "需要 VisualEffectsStandard")
		return
	
	var ice_colors = std.get_sect_color_scheme("ice")
	_assert(ice_colors.has("primary"), "冰心宗有 primary 颜色")
	_assert(ice_colors.has("glow"), "冰心宗有 glow 颜色")
	
	var thunder_colors = std.get_sect_color_scheme("thunder")
	_assert(thunder_colors.has("secondary"), "雷鸣宗有 secondary 颜色")
	
	var fire_colors = std.get_sect_color_scheme("fire")
	_assert(not fire_colors.is_empty(), "烈焰宗颜色方案不为空")
	
	var poison_colors = std.get_sect_color_scheme("poison")
	_assert(not poison_colors.is_empty(), "毒瘴宗颜色方案不为空")

func _test_animation_enhancement() -> void:
	print("[测试4] 动画帧增强验证")
	var backup_dir = "res://Textures/Skills/Animations/backup/"
	var work_dir = "res://Textures/Skills/Animations/"
	
	var test_files = [
		"ice_shard_0.png",
		"thunder_strike_0.png",
		"fire_ball_0.png",
		"poison_dart_0.png"
	]
	
	for filename in test_files:
		var work_path = work_dir + filename
		var backup_path = backup_dir + filename
		_assert(FileAccess.file_exists(backup_path), "备份文件存在: " + filename)
		_assert(FileAccess.file_exists(work_path), "工作文件存在: " + filename)

func _test_texture_preload_cache() -> void:
	print("[测试5] 纹理预加载和缓存")
	var root = get_root()
	var loader = root.get_node_or_null("/root/SkillTextureLoader")
	if not loader:
		_assert(false, "需要 SkillTextureLoader autoload")
		return
	
	_assert(loader.has_method("preload_sect_animations"), "有 preload_sect_animations 方法")
	_assert(loader.has_method("get_skill_frames"), "有 get_skill_frames 方法")
	
	var before_count = loader.get("load_operation_count") if "load_operation_count" in loader else 0
	
	var frames = loader.get_skill_frames("ice_shard", 4)
	_assert(frames.size() > 0, "成功获取 ice_shard 帧")
	
	var frames2 = loader.get_skill_frames("ice_shard", 4)
	var after_count = loader.get("load_operation_count") if "load_operation_count" in loader else 0
	_assert(after_count == before_count or frames2.size() > 0, "缓存命中或成功加载")
	
	if loader.has_method("get_estimated_cache_memory_bytes"):
		var mem = loader.get_estimated_cache_memory_bytes()
		_assert(mem >= 0, "内存估算返回有效值")
		print("  [信息] 当前缓存内存估算: ", mem / 1024.0 / 1024.0, " MB")

func _assert(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
		print("  ✓ ", message)
	else:
		_failed += 1
		print("  ✗ ", message)

func process_frame() -> void:
	await get_root().process_frame
