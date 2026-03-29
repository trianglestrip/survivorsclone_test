extends Node

## 资源热重载管理器
## 用于开发时避免Godot资源缓存问题
## 确保UI和特效资源正确刷新

## 配置
@export var enable_hot_reload: bool = true
@export var check_interval: float = 1.0

## 监控的资源路径
var _monitored_paths: Array[String] = [
	"res://Textures/UI/",
	"res://Textures/Placeholder/Effects/",
	"res://config/"
]

## 资源缓存
var _resource_cache: Dictionary = {}
var _last_check_time: float = 0.0

func _ready():
	if enable_hot_reload:
		print("[ResourceHotReload] 热重载已启用")
		_scan_resources()

func _process(delta: float):
	if not enable_hot_reload:
		return
	
	_last_check_time += delta
	if _last_check_time >= check_interval:
		_last_check_time = 0.0
		_check_for_changes()

func _scan_resources():
	for path in _monitored_paths:
		_scan_directory(path)

func _scan_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = dir_path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_scan_directory(full_path + "/")
		else:
			if file_name.ends_with(".png") or file_name.ends_with(".json"):
				_cache_resource(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _cache_resource(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var modified_time = FileAccess.get_modified_time(path)
		_resource_cache[path] = modified_time
		file.close()

func _check_for_changes():
	var changed_resources: Array[String] = []
	
	for path in _resource_cache.keys():
		var cached_time = _resource_cache[path]
		var current_time = FileAccess.get_modified_time(path)
		
		if current_time > cached_time:
			changed_resources.append(path)
			_resource_cache[path] = current_time
	
	if changed_resources.size() > 0:
		_reload_changed_resources(changed_resources)

func _reload_changed_resources(paths: Array[String]):
	print("[ResourceHotReload] 检测到资源变化，重新加载:")
	for path in paths:
		print("  - %s" % path)
		
		if path.ends_with(".json"):
			_reload_json_config(path)
		elif path.ends_with(".png"):
			_reload_texture(path)

func _reload_json_config(path: String):
	ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	print("  ✓ 配置已重载: %s" % path.get_file())

func _reload_texture(path: String):
	var texture = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if texture:
		print("  ✓ 纹理已重载: %s" % path.get_file())

## 公共API - 强制重载特定资源
func force_reload(path: String):
	if path.ends_with(".json"):
		_reload_json_config(path)
	elif path.ends_with(".png"):
		_reload_texture(path)
	else:
		push_warning("不支持的资源类型: %s" % path)

## 公共API - 强制重载所有监控资源
func force_reload_all():
	print("[ResourceHotReload] 强制重载所有资源...")
	var all_paths = _resource_cache.keys()
	_reload_changed_resources(all_paths)
	print("[ResourceHotReload] 重载完成")

## 公共API - 清除Godot资源缓存
func clear_godot_cache():
	print("[ResourceHotReload] 清除Godot资源缓存...")
	
	for path in _resource_cache.keys():
		ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	print("[ResourceHotReload] 缓存已清除")
