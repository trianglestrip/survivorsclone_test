extends Node

# 配置管理器 - 统一管理所有游戏配置文件的加载和缓存

var _config_cache = {}

# 加载 INI 配置文件
func load_ini_config(config_path: String, force_reload: bool = false) -> ConfigFile:
	if not force_reload and _config_cache.has(config_path):
		return _config_cache[config_path]
	
	var cfg = ConfigFile.new()
	var err = cfg.load(config_path)
	
	if err != OK:
		push_error("Failed to load config: %s (Error: %d)" % [config_path, err])
		return null
	
	_config_cache[config_path] = cfg
	return cfg

# 加载 JSON 配置文件
func load_json_config(config_path: String, force_reload: bool = false) -> Dictionary:
	if not force_reload and _config_cache.has(config_path):
		return _config_cache[config_path]
	
	var file = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open config: %s" % config_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse JSON config: %s" % config_path)
		return {}
	
	var data = json.data
	_config_cache[config_path] = data
	return data

# 获取 INI 配置的某个节的所有数据
func get_section_data(config_path: String, section: String) -> Dictionary:
	var cfg = load_ini_config(config_path)
	if cfg == null or not cfg.has_section(section):
		return {}
	
	var data = {}
	for key in cfg.get_section_keys(section):
		data[key] = cfg.get_value(section, key)
	
	return data

# 获取 INI 配置的所有节数据
func get_all_sections(config_path: String) -> Dictionary:
	var cfg = load_ini_config(config_path)
	if cfg == null:
		return {}
	
	var all_data = {}
	for section in cfg.get_sections():
		all_data[section] = get_section_data(config_path, section)
	
	return all_data

# 清除缓存
func clear_cache():
	_config_cache.clear()

# 重新加载指定配置
func reload_config(config_path: String):
	if _config_cache.has(config_path):
		_config_cache.erase(config_path)
	
	if config_path.ends_with(".ini"):
		return load_ini_config(config_path, true)
	elif config_path.ends_with(".json"):
		return load_json_config(config_path, true)
	
	return null

# 检查配置文件是否存在
func config_exists(config_path: String) -> bool:
	return FileAccess.file_exists(config_path)
