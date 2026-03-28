extends Node
class_name BaseRegistry

## 通用注册系统基类
## 用于管理可扩展的资源注册（敌人、技能、道具等）
## 
## 特性：
## - 异步加载资源，不阻塞启动
## - 统一的配置文件解析
## - 线程安全的加载状态管理
## - 可扩展的验证逻辑

# ========================================
# 状态管理
# ========================================

var _registered_items := {}
var _is_loading := false
var _is_ready := false

signal loading_complete

# ========================================
# 核心 API（子类必须实现）
# ========================================

## 获取配置文件路径（子类必须重写）
func _get_config_path() -> String:
	push_error("BaseRegistry._get_config_path() 必须在子类中重写")
	return ""

## 获取注册类型名称（用于日志）
func _get_registry_type_name() -> String:
	push_error("BaseRegistry._get_registry_type_name() 必须在子类中重写")
	return "Item"

## 解析配置行（子类可选重写）
func _parse_config_value(key: String, value: String) -> Variant:
	# 默认实现：智能类型转换
	if value.is_valid_int():
		return int(value)
	elif value.is_valid_float():
		return float(value)
	elif value.to_lower() == "true":
		return true
	elif value.to_lower() == "false":
		return false
	else:
		return value

## 验证单个配置项（子类可选重写）
func _validate_config(item_id: String, config: Dictionary) -> bool:
	if not config.has("scene_path"):
		push_error("❌ %s '%s' 缺少 scene_path" % [_get_registry_type_name(), item_id])
		return false
	return true

## 创建数据字典（子类可选重写）
func _create_item_data(item_id: String, config: Dictionary) -> Dictionary:
	return {
		"name": config.get("name", item_id),
	}

# ========================================
# 注册 API
# ========================================

## 注册项目
func register_item(item_id: String, item_scene: PackedScene, item_data: Dictionary = {}):
	_registered_items[item_id] = {
		"scene": item_scene,
		"data": item_data
	}

## 获取场景
func get_item_scene(item_id: String) -> PackedScene:
	if _registered_items.has(item_id):
		return _registered_items[item_id]["scene"]
	return null

## 获取数据
func get_item_data(item_id: String) -> Dictionary:
	if _registered_items.has(item_id):
		return _registered_items[item_id]["data"]
	return {}

## 检查是否已注册
func has_item(item_id: String) -> bool:
	return _registered_items.has(item_id)

## 获取所有 ID
func get_all_item_ids() -> Array:
	return _registered_items.keys()

## 实例化项目
func instantiate_item(item_id: String) -> Node:
	var scene = get_item_scene(item_id)
	if scene:
		var instance = scene.instantiate()
		instance.name = item_id
		return instance
	return null

# ========================================
# 加载系统
# ========================================

func _ready():
	# 异步加载，不阻塞启动
	_load_from_config_async()

## 确保已加载（外部调用）
func ensure_loaded():
	if _is_ready:
		return
	if _is_loading:
		await loading_complete
		return
	await _load_from_config_async()

## 异步加载配置和资源
func _load_from_config_async():
	_is_loading = true
	var start_time := Time.get_ticks_msec()
	var type_name = _get_registry_type_name()
	var config_path = _get_config_path()
	
	if GameConfig.DEBUG_LOGGING:
		print("\n=== 异步加载%s注册配置 ===" % type_name)
		print("配置文件: %s" % config_path)
	
	# 读取配置文件
	var configs = _read_config_file(config_path)
	if configs.size() == 0:
		push_error("❌ %s配置为空！" % type_name)
		_finalize_loading()
		return
	
	# 异步加载场景资源
	var loaded_count := 0
	for item_id in configs:
		var config = configs[item_id]
		
		# 验证配置
		if not _validate_config(item_id, config):
			continue
		
		var scene_path = config["scene_path"]
		
		# 异步加载场景
		var scene = await _load_scene_async(scene_path)
		if scene == null:
			continue
		
		# 创建数据并注册
		var item_data = _create_item_data(item_id, config)
		register_item(item_id, scene, item_data)
		loaded_count += 1
		
		if GameConfig.DEBUG_LOGGING:
			print("  ✓ 注册%s: %s" % [type_name, item_id])
	
	var total_time := Time.get_ticks_msec() - start_time
	if GameConfig.DEBUG_LOGGING:
		print("✓ 异步注册 %d 个%s完成 (耗时 %d ms)\n" % [loaded_count, type_name, total_time])
	
	_finalize_loading()

## 读取 INI 配置文件
func _read_config_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("❌ 无法打开配置文件: %s" % file_path)
		return {}
	
	var current_section := ""
	var configs := {}
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# 跳过空行和注释
		if line == "" or line.begins_with("#") or line.begins_with(";"):
			continue
		
		# 节标题
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			configs[current_section] = {}
			continue
		
		# 键值对
		if current_section != "" and line.contains("="):
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				configs[current_section][key] = _parse_config_value(key, value)
	
	file.close()
	return configs

## 异步加载单个场景
func _load_scene_async(scene_path: String) -> PackedScene:
	# 请求异步加载
	var err = ResourceLoader.load_threaded_request(scene_path)
	if err != OK:
		push_error("❌ 无法请求加载场景: %s" % scene_path)
		return null
	
	# 等待加载完成
	var status = ResourceLoader.load_threaded_get_status(scene_path)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(scene_path)
	
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("❌ 加载场景失败: %s (状态: %d)" % [scene_path, status])
		return null
	
	var scene = ResourceLoader.load_threaded_get(scene_path)
	if scene == null:
		push_error("❌ 获取场景失败: %s" % scene_path)
		return null
	
	return scene

## 完成加载
func _finalize_loading():
	_is_loading = false
	_is_ready = true
	emit_signal("loading_complete")
