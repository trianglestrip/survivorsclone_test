extends Node

## 技能纹理加载器
## 加载与管理技能动画帧；支持宗派预加载、帧/序列缓存、同步与异步加载、性能统计

const SKILL_ASSETS_PATH = "res://Textures/Skills/Animations/"
const PERF_LOG_PREFIX := "[SkillTextureLoader:perf]"

## 宗派 -> 技能动画名（与 sect_config 中 skills.*.id 一致）；max_frames 为上限，实际以磁盘连续帧为准
const SECT_ANIMATION_SPECS: Dictionary = {
	"ice": [
		{"skill": "ice_shard", "max_frames": 12},
		{"skill": "ice_field", "max_frames": 12},
		{"skill": "ice_storm", "max_frames": 12},
	],
	"thunder": [
		{"skill": "thunder_strike", "max_frames": 12},
		{"skill": "thunder_field", "max_frames": 12},
		{"skill": "thunder_god", "max_frames": 12},
	],
	"fire": [
		{"skill": "fire_ball", "max_frames": 12},
		{"skill": "fire_wall", "max_frames": 12},
		{"skill": "fire_meteor", "max_frames": 12},
	],
	"poison": [
		{"skill": "poison_dart", "max_frames": 12},
		{"skill": "poison_cloud", "max_frames": 12},
		{"skill": "poison_plague", "max_frames": 12},
	],
}

signal preload_progress(sect_id: String, loaded_steps: int, total_steps: int, progress: float)
signal preload_finished(sect_id: String, stats: Dictionary)

## 单帧纹理缓存 key: "{skill}_{frame}"
var texture_cache: Dictionary = {}

## 技能整段动画缓存 key: skill_name -> Array[Texture2D]（多实例只读复用同一数组与纹理引用）
var skill_frames_cache: Dictionary = {}

## 累计：单次 load 耗时（微秒）、次数
var total_load_time_usec: int = 0
var load_operation_count: int = 0

## 最近一次预加载统计（供测试与调试）
var last_preload_stats: Dictionary = {}


func _log_perf(message: String) -> void:
	print("%s %s" % [PERF_LOG_PREFIX, message])


func _record_load_duration_usec(start_usec: int) -> void:
	var dt = Time.get_ticks_usec() - start_usec
	total_load_time_usec += dt
	load_operation_count += 1


## 估算已缓存纹理的近似内存（RGBA8 假设，仅统计 Texture2D）
func get_estimated_cache_memory_bytes() -> int:
	var total := 0
	for tex in texture_cache.values():
		if tex is Texture2D:
			total += _estimate_texture_bytes(tex as Texture2D)
	return total


func _estimate_texture_bytes(tex: Texture2D) -> int:
	var w := tex.get_width()
	var h := tex.get_height()
	return maxi(0, w) * maxi(0, h) * 4


## 加载单帧（先查纹理缓存；无资源时使用占位路径失败则 null，由调用方使用占位图）
func load_skill_frame(skill_name: String, frame_index: int = 0) -> Texture2D:
	var cache_key = "%s_%d" % [skill_name, frame_index]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]

	var t0 := Time.get_ticks_usec()
	var texture_path = "%s%s_frame_%d.png" % [SKILL_ASSETS_PATH, skill_name, frame_index]
	var tex: Texture2D = null

	if ResourceLoader.exists(texture_path):
		tex = load(texture_path) as Texture2D
		if tex:
			texture_cache[cache_key] = tex
			_record_load_duration_usec(t0)
			return tex

	var file_path = texture_path.replace("res://", "").replace("/", "\\")
	var abs_path = ProjectSettings.globalize_path("res://") + file_path
	if FileAccess.file_exists(abs_path):
		var image = Image.new()
		if image.load(abs_path) == OK:
			tex = ImageTexture.create_from_image(image)
			texture_cache[cache_key] = tex
			_record_load_duration_usec(t0)
			return tex

	_record_load_duration_usec(t0)
	return null


## 获取整段动画（优先序列缓存，避免重复 ResourceLoader/磁盘扫描）
func load_skill_frames(skill_name: String, max_frames: int = 12) -> Array:
	if skill_frames_cache.has(skill_name):
		return skill_frames_cache[skill_name]

	var frames: Array = []
	for i in range(max_frames):
		var texture = load_skill_frame(skill_name, i)
		if texture:
			frames.append(texture)
		else:
			break

	skill_frames_cache[skill_name] = frames
	return frames


## 只读复用：与 load_skill_frames 相同，语义上强调“从缓存取”
func get_skill_frames(skill_name: String, max_frames: int = 12) -> Array:
	return load_skill_frames(skill_name, max_frames)


func _emit_progress(sect_id: String, loaded: int, total: int, progress: float, progress_callback: Callable) -> void:
	preload_progress.emit(sect_id, loaded, total, progress)
	if progress_callback.is_valid():
		progress_callback.call(sect_id, loaded, total, progress)


## 预加载某宗派全部技能动画
## progress_callback(sect_id, loaded_steps, total_steps, progress01)；async_mode=true 时调用方需 await
func preload_sect_animations(sect_id: String, progress_callback: Callable = Callable(), async_mode: bool = false) -> Dictionary:
	if async_mode:
		return await preload_sect_animations_async(sect_id, progress_callback)
	return _preload_sect_animations_sync(sect_id, progress_callback)


func _preload_sect_animations_sync(sect_id: String, progress_callback: Callable) -> Dictionary:
	var specs: Array = SECT_ANIMATION_SPECS.get(sect_id, [])
	var total_steps: int = specs.size()
	var t0 := Time.get_ticks_usec()
	var textures_before: int = texture_cache.size()

	if specs.is_empty():
		_log_perf("preload_sect_animations sync sect='%s' — 无配置，跳过" % sect_id)
		var empty_stats = _build_stats(sect_id, 0, total_steps, textures_before, t0)
		last_preload_stats = empty_stats
		preload_finished.emit(sect_id, empty_stats)
		return empty_stats

	for i in range(total_steps):
		var spec: Dictionary = specs[i]
		var sn: String = spec.get("skill", "")
		var mf: int = int(spec.get("max_frames", 12))
		load_skill_frames(sn, mf)
		var progress: float = float(i + 1) / float(total_steps)
		_emit_progress(sect_id, i + 1, total_steps, progress, progress_callback)

	var stats = _build_stats(sect_id, total_steps, total_steps, textures_before, t0)
	last_preload_stats = stats
	_log_perf(
		"sync sect=%s duration_ms=%.2f steps=%d tex_delta=%d cache_entries=%d est_mem_mb=%.2f load_ops=%d total_load_ms=%.2f"
		% [
			sect_id,
			stats["duration_ms"],
			total_steps,
			stats["textures_loaded_delta"],
			texture_cache.size(),
			stats["estimated_cache_memory_mb"],
			load_operation_count,
			stats["total_accumulated_load_ms"],
		]
	)
	preload_finished.emit(sect_id, stats)
	return stats


## 异步预加载：能走资源系统的路径用线程加载，其余回退到同步 load_skill_frame；每步之间 await 一帧以摊平主线程
func preload_sect_animations_async(sect_id: String, progress_callback: Callable = Callable()) -> Dictionary:
	var specs: Array = SECT_ANIMATION_SPECS.get(sect_id, [])
	var total_steps: int = specs.size()
	var t0 := Time.get_ticks_usec()
	var textures_before: int = texture_cache.size()

	if specs.is_empty():
		var empty_stats = _build_stats(sect_id, 0, total_steps, textures_before, t0)
		last_preload_stats = empty_stats
		preload_finished.emit(sect_id, empty_stats)
		return empty_stats

	for i in range(total_steps):
		var spec: Dictionary = specs[i]
		var sn: String = spec.get("skill", "")
		var mf: int = int(spec.get("max_frames", 12))
		await _load_one_skill_frames_async(sn, mf)
		var progress: float = float(i + 1) / float(total_steps)
		_emit_progress(sect_id, i + 1, total_steps, progress, progress_callback)
		await Engine.get_main_loop().process_frame

	var stats = _build_stats(sect_id, total_steps, total_steps, textures_before, t0)
	last_preload_stats = stats
	_log_perf(
		"async sect=%s duration_ms=%.2f steps=%d tex_delta=%d cache_entries=%d est_mem_mb=%.2f"
		% [
			sect_id,
			stats["duration_ms"],
			total_steps,
			stats["textures_loaded_delta"],
			texture_cache.size(),
			stats["estimated_cache_memory_mb"],
		]
	)
	preload_finished.emit(sect_id, stats)
	return stats


func _load_one_skill_frames_async(skill_name: String, max_frames: int) -> void:
	if skill_frames_cache.has(skill_name):
		return

	var frames: Array = []
	for i in range(max_frames):
		var cache_key = "%s_%d" % [skill_name, i]
		if texture_cache.has(cache_key):
			frames.append(texture_cache[cache_key])
			await Engine.get_main_loop().process_frame
			continue

		var texture_path = "%s%s_frame_%d.png" % [SKILL_ASSETS_PATH, skill_name, i]
		var tex: Texture2D = null

		if ResourceLoader.exists(texture_path):
			var t_io := Time.get_ticks_usec()
			ResourceLoader.load_threaded_request(texture_path, "", ResourceLoader.CACHE_MODE_REUSE)
			while true:
				var st = ResourceLoader.load_threaded_get_status(texture_path)
				if st == ResourceLoader.THREAD_LOAD_LOADED:
					tex = ResourceLoader.load_threaded_get(texture_path) as Texture2D
					break
				if st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
					break
				await Engine.get_main_loop().process_frame
			if tex:
				texture_cache[cache_key] = tex
				frames.append(tex)
				_record_load_duration_usec(t_io)
			else:
				break
		else:
			tex = load_skill_frame(skill_name, i)
			if tex:
				frames.append(tex)
			else:
				break

		await Engine.get_main_loop().process_frame

	skill_frames_cache[skill_name] = frames


func _build_stats(sect_id: String, steps_done: int, total_steps: int, textures_before: int, start_usec: int) -> Dictionary:
	var duration_ms: float = (Time.get_ticks_usec() - start_usec) / 1000.0
	var tex_delta: int = texture_cache.size() - textures_before
	var est_bytes: int = get_estimated_cache_memory_bytes()
	var total_load_ms: float = total_load_time_usec / 1000.0
	return {
		"sect_id": sect_id,
		"duration_ms": duration_ms,
		"steps_done": steps_done,
		"total_steps": total_steps,
		"textures_loaded_delta": tex_delta,
		"texture_cache_size": texture_cache.size(),
		"skill_frames_cached": skill_frames_cache.size(),
		"estimated_cache_memory_bytes": est_bytes,
		"estimated_cache_memory_mb": est_bytes / 1048576.0,
		"load_operation_count": load_operation_count,
		"total_accumulated_load_ms": total_load_ms,
	}


## 预加载所有宗派（可选，调试用）
func preload_all_skills() -> void:
	var t0 := Time.get_ticks_usec()
	for sect_id in SECT_ANIMATION_SPECS.keys():
		_preload_sect_animations_sync(sect_id, Callable())
	var ms = (Time.get_ticks_usec() - t0) / 1000.0
	_log_perf("preload_all_skills duration_ms=%.2f cache_entries=%d est_mem_mb=%.2f" % [ms, texture_cache.size(), get_estimated_cache_memory_bytes() / 1048576.0])
	print("[SkillTextureLoader] Preloaded %d textures (all sects)" % texture_cache.size())


func clear_cache() -> void:
	texture_cache.clear()
	skill_frames_cache.clear()
	_log_perf("clear_cache — 已清空帧缓存与序列缓存")


func reset_performance_counters() -> void:
	total_load_time_usec = 0
	load_operation_count = 0
	_log_perf("reset_performance_counters")
