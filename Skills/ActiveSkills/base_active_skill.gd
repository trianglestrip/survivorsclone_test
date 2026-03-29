class_name BaseActiveSkill
extends Node2D

## 主动技能基类
## 所有QER技能的基类
## 
## 设计原则：
## 1. 所有数值从配置加载，无硬编码
## 2. 使用工具类处理通用逻辑（特效、范围检测等）
## 3. 子类只实现特定的技能行为

## 技能配置（从配置文件加载）
var config: Dictionary = {}
var skill_id: String = ""
var skill_name: String = ""
var damage: float = 0.0
var cooldown: float = 0.0
var duration: float = 0.0

## 技能状态
var is_active: bool = false
var elapsed_time: float = 0.0

## 引用
var player: Node = null
var sect_manager: Node = null

func _ready():
	pass

## 初始化技能
func initialize(skill_config: Dictionary, p: Node, sm: Node):
	player = p
	sect_manager = sm
	config = skill_config
	
	skill_id = config.get("id", "")
	skill_name = config.get("name", "")
	damage = config.get("damage", 0.0)
	cooldown = config.get("cooldown", 3.0)
	duration = config.get("duration", 0.0)
	
	_load_skill_config(config)

## 子类重写：加载特定配置
func _load_skill_config(_config: Dictionary):
	pass

## 释放技能
func cast(cast_position: Vector2, cast_direction: Vector2) -> bool:
	if is_active:
		return false
	
	is_active = true
	elapsed_time = 0.0
	
	_on_skill_cast(cast_position, cast_direction)
	
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		_on_skill_end()
	else:
		_on_skill_end()
	
	return true

## 子类重写：技能释放时
func _on_skill_cast(_cast_position: Vector2, _cast_direction: Vector2):
	pass

## 子类重写：技能结束时
func _on_skill_end():
	is_active = false
	queue_free()

func _process(delta: float):
	if is_active:
		elapsed_time += delta
		_on_skill_update(delta)

## 子类重写：技能更新
func _on_skill_update(_delta: float):
	pass

## 工具函数：获取鼠标方向
func get_mouse_direction() -> Vector2:
	if not player:
		return Vector2.RIGHT
	
	var mouse_pos = player.get_global_mouse_position()
	var player_pos = player.global_position
	return (mouse_pos - player_pos).normalized()

## 工具函数：触发屏幕震动
func trigger_screen_shake(intensity: float = 0.3):
	VisualEffectsHelper.trigger_screen_shake(self, intensity)

## 工具函数：创建特效
func create_effect(texture_path: String, pos: Vector2, scale_val: float = 1.0) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.position = pos
	sprite.scale = Vector2(scale_val, scale_val)
	sprite.texture = VisualEffectsHelper.load_texture_or_placeholder(texture_path, Vector2(64, 64))
	sprite.z_index = 10
	return sprite

## 工具函数：创建并添加特效到世界
func spawn_effect(texture_path: String, pos: Vector2, scale_val: float = 1.0) -> Sprite2D:
	var effect = create_effect(texture_path, pos, scale_val)
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", effect)
	return effect

## 工具函数：获取范围内的敌人
func get_enemies_in_range(center: Vector2, radius: float) -> Array:
	var enemies = []
	var world = player.get_parent() if player else null
	if not world:
		return enemies
	
	var enemies_group = world.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies_group:
		if enemy and is_instance_valid(enemy):
			var distance = enemy.global_position.distance_to(center)
			if distance <= radius:
				enemies.append(enemy)
	
	return enemies

## 工具函数：对敌人造成伤害
func damage_enemy(enemy: Node, dmg: float, knockback_dir: Vector2 = Vector2.ZERO):
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(dmg, knockback_dir)
