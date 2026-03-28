extends "res://Utility/base_registry.gd"

## 敌人注册系统
## 继承自 BaseRegistry，管理所有敌人类型的注册和加载

func _get_config_path() -> String:
	return GameConfig.PATH_ENEMY_REGISTRY

func _get_registry_type_name() -> String:
	return "敌人"

func _parse_config_value(key: String, value: String) -> Variant:
	match key:
		"tier":
			return int(value) if value.is_valid_int() else 1
		"is_boss":
			return value.to_lower() == "true"
		_:
			return super._parse_config_value(key, value)

func _create_item_data(item_id: String, config: Dictionary) -> Dictionary:
	return {
		"name": config.get("name", item_id),
		"tier": config.get("tier", 1),
		"is_boss": config.get("is_boss", false)
	}
