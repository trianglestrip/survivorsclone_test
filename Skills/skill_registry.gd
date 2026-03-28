extends "res://Utility/base_registry.gd"

## 技能注册系统
## 继承自 BaseRegistry，管理所有技能的注册和加载

func _get_config_path() -> String:
	return GameConfig.PATH_SKILL_REGISTRY

func _get_registry_type_name() -> String:
	return "技能"

func _create_item_data(item_id: String, config: Dictionary) -> Dictionary:
	return {
		"name": config.get("name", item_id),
		"description": config.get("description", ""),
		"type": config.get("type", "projectile")
	}
