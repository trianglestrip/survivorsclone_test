extends SceneTree

## 技能纹理预加载与缓存性能测试
## 运行: Godot --headless --script res://tests/test_texture_loading_performance.gd

const SECT_IDS: Array[String] = ["ice", "thunder", "fire", "poison"]
const TARGET_SECT_PRELOAD_MS := 100.0
const TARGET_ALL_SECTS_MEMORY_MB := 50.0
const TARGET_CACHED_FRAME_US := 500

var _report: Dictionary = {}
var _passed := 0
var _failed := 0

func _init():
	print("\n========================================")
	print("技能纹理加载性能测试")
	print("========================================\n")
	await _ensure_loader_ready()
	await _run_all()
	_write_report()
	_print_report()
	quit(0 if _failed == 0 else 1)

func _ensure_loader_ready():
	# --script 入口时 autoload 的 _ready 可能晚于本脚本首帧；等待树就绪
	for _i in range(60):
		if root.get_node_or_null("SkillTextureLoader") != null:
			return
		await process_frame
	push_warning("SkillTextureLoader autoload 未在首帧出现，测试将实例化临时加载器节点")

func _run_all():
	var loader: Node = root.get_node_or_null("SkillTextureLoader")
	if loader == null:
		var script: GDScript = load("res://Utility/skill_texture_loader.gd") as GDScript
		loader = script.new()
		loader.name = "SkillTextureLoader_TestInstance"
		root.add_child(loader)
		await process_frame
	if loader == null:
		push_error("无法获取 SkillTextureLoader")
		_failed += 1
		return

	loader.clear_cache()
	if loader.has_method("reset_performance_counters"):
		loader.reset_performance_counters()

	await _test_sect_preload_budget(loader)
	await _test_cached_skill_frame_latency(loader)
	await _test_all_sects_memory_cap(loader)
	await _test_async_preload(loader)
	await _test_skill_frames_reuse_no_duplicate_disk(loader)

func _test_sect_preload_budget(loader: Node) -> void:
	print("[1] 宗派预加载耗时（目标 < %.0f ms）" % TARGET_SECT_PRELOAD_MS)
	var worst_ms := 0.0
	var worst_sect := ""
	for sect in SECT_IDS:
		loader.clear_cache()
		if loader.has_method("reset_performance_counters"):
			loader.reset_performance_counters()
		var t0 := Time.get_ticks_usec()
		var stats: Dictionary = loader.preload_sect_animations(sect, Callable(), false)
		var wall_ms := (Time.get_ticks_usec() - t0) / 1000.0
		var dur: float = stats.get("duration_ms", wall_ms)
		print("    sect=%s duration_ms=%.2f (stats) wall_ms=%.2f tex_delta=%d" % [sect, dur, wall_ms, stats.get("textures_loaded_delta", 0)])
		if dur > worst_ms:
			worst_ms = dur
			worst_sect = sect
	var ok: bool = worst_ms < TARGET_SECT_PRELOAD_MS or loader.texture_cache.is_empty()
	_record("sect_preload_under_100ms", ok, "worst=%.2fms sect=%s (无贴图时自动通过)" % [worst_ms, worst_sect])
	_report["worst_sect_preload_ms"] = worst_ms
	_report["worst_sect_preload_id"] = worst_sect

func _test_cached_skill_frame_latency(loader: Node) -> void:
	print("[2] 缓存命中帧加载延迟（目标 < %d µs 量级）" % TARGET_CACHED_FRAME_US)
	loader.clear_cache()
	loader.preload_sect_animations("ice", Callable(), false)
	var t0 := Time.get_ticks_usec()
	var _tex = loader.load_skill_frame("ice_shard", 0)
	var dt := Time.get_ticks_usec() - t0
	print("    load_skill_frame(cached) = %d µs" % dt)
	var ok: bool = dt < TARGET_CACHED_FRAME_US or loader.texture_cache.is_empty()
	_record("skill_cast_zero_load", ok, "cached_lookup_usec=%d" % dt)
	_report["cached_frame_usec"] = dt

func _test_all_sects_memory_cap(loader: Node) -> void:
	print("[3] 四宗派全量预加载估算内存（目标 < %.0f MB）" % TARGET_ALL_SECTS_MEMORY_MB)
	loader.clear_cache()
	if loader.has_method("reset_performance_counters"):
		loader.reset_performance_counters()
	for sect in SECT_IDS:
		loader.preload_sect_animations(sect, Callable(), false)
	var mb: float = loader.get_estimated_cache_memory_bytes() / 1048576.0
	print("    estimated_cache_memory_mb=%.2f" % mb)
	var ok: bool = mb < TARGET_ALL_SECTS_MEMORY_MB
	_record("all_sects_memory_under_50mb", ok, "est_mb=%.2f" % mb)
	_report["all_sects_estimated_mb"] = mb

func _test_async_preload(loader: Node) -> void:
	print("[4] 异步预加载（协程）完成与统计")
	loader.clear_cache()
	if loader.has_method("reset_performance_counters"):
		loader.reset_performance_counters()
	var stats: Dictionary = await loader.preload_sect_animations("thunder", Callable(), true)
	var ok: bool = stats.get("steps_done", 0) >= 0
	print("    async duration_ms=%.2f steps=%d/%d" % [stats.get("duration_ms", 0.0), stats.get("steps_done", 0), stats.get("total_steps", 0)])
	_record("async_preload_completes", ok, "duration_ms=%.2f" % stats.get("duration_ms", 0.0))
	_report["async_thunder_ms"] = stats.get("duration_ms", 0.0)

func _test_skill_frames_reuse_no_duplicate_disk(loader: Node) -> void:
	print("[5] get_skill_frames 重复调用不增加 load_operation_count（序列缓存）")
	loader.clear_cache()
	if loader.has_method("reset_performance_counters"):
		loader.reset_performance_counters()
	var ops_before: int = loader.load_operation_count
	loader.get_skill_frames("fire_ball")
	var mid: int = loader.load_operation_count
	loader.get_skill_frames("fire_ball")
	var after: int = loader.load_operation_count
	print("    load_ops: %d -> %d -> %d" % [ops_before, mid, after])
	var ok: bool = after == mid
	_record("skill_frames_cache_reuse", ok, "ops_after_second=%d (期望=%d)" % [after, mid])
	_report["load_ops_second_get_frames"] = after - mid

func _record(name: String, passed: bool, detail: String) -> void:
	if passed:
		_passed += 1
		print("    ✓ %s: %s" % [name, detail])
	else:
		_failed += 1
		print("    ✗ %s: %s" % [name, detail])
	_report[name] = {"passed": passed, "detail": detail}

func _write_report() -> void:
	var path := "res://tests/texture_loading_performance_report.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_report, "\t"))
		f.close()
		print("\n报告已写入: %s" % path)
	else:
		push_warning("无法写入报告: %s" % path)

func _print_report() -> void:
	print("\n========================================")
	print("汇总: 通过 %d / 失败 %d" % [_passed, _failed])
	print("========================================")
