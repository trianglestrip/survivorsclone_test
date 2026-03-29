class_name BaseActiveSkill
extends Node2D

## 主动技能基类
## 所有QER技能的基类
## 
## 设计原则：
## 1. 所有数值从配置加载，无硬编码
## 2. 使用工具类处理通用逻辑（特效、范围检测等）
## 3. 子类只实现特定的技能行为
## 4. 通过配置对象和回调机制最大化代码复用

## 技能节点类型枚举
enum SkillNodeType {
	PROJECTILE,    # 弹射物（Q技能）
	AREA_CIRCLE,   # 圆形区域（E/R技能）
	AREA_RECT,     # 矩形区域（火墙等）
}

## 状态效果类型
enum StatusEffect {
	SLOW,
	FREEZE,
	BURN,
	POISON,
	STUN,
}

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

## 周期性伤害
var tick_damage_enabled: bool = false
var tick_interval: float = 0.5
var tick_timer: float = 0.0
var tick_callback: Callable

## 状态效果列表
var status_effects: Array = []

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
	
	await _on_skill_cast(cast_position, cast_direction)
	
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
	if not is_active:
		return
	
	elapsed_time += delta
	
	# 处理周期性伤害
	if tick_damage_enabled and tick_callback:
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer = 0.0
			tick_callback.call()
	
	# 持续时间结束
	if duration > 0 and elapsed_time >= duration:
		is_active = false
	
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
	if player and player.is_inside_tree():
		VisualEffectsHelper.trigger_screen_shake(player, intensity)

## 仅调整 modulate（自定义 Sprite / 非 animated_skill_sprite）
func apply_standard_modulate_to_item(item: CanvasItem, skill_type: String, sect_override: String = "") -> void:
	if item == null:
		return
	var sect := sect_override if not sect_override.is_empty() else VisualEffectsStandard.infer_sect_from_skill_id(skill_id)
	VisualEffectsStandard.apply_standard_modulate(item, skill_type, sect)

## 对技能视觉节点应用标准（缩放、帧率、modulate）；用于非 create_skill_node 的弹射物等
func apply_standard_to_skill_visual(node: Node, skill_type: String, sect_override: String = "") -> void:
	if node == null:
		return
	var sect := sect_override if not sect_override.is_empty() else VisualEffectsStandard.infer_sect_from_skill_id(skill_id)
	VisualEffectsStandard.apply_standard_visual_node(node, skill_type, sect)

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
		player.get_parent().add_child(effect)
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

## ========================================
## 通用技能节点创建系统
## ========================================

## 技能节点配置类
class SkillNodeConfig:
	var node_name: String = "SkillNode"
	var node_type: int = SkillNodeType.AREA_CIRCLE
	var position: Vector2 = Vector2.ZERO
	var rotation: float = 0.0
	var z_index: int = 2
	
	# 动画配置
	var skill_animation_name: String = ""
	var animation_scale: Vector2 = Vector2.ONE
	var animation_modulate: Color = Color.WHITE
	var animation_fps: float = 10.0
	var animation_loop: bool = true
	var fallback_color: Color = Color.WHITE
	
	# 碰撞配置
	var collision_radius: float = 0.0  # 圆形
	var collision_size: Vector2 = Vector2.ZERO  # 矩形
	
	# 生命周期
	var lifetime: float = 0.0
	var fade_duration: float = 0.5
	
	# 弹射物特定
	var projectile_direction: Vector2 = Vector2.RIGHT
	var projectile_speed: float = 400.0
	var projectile_range: float = 300.0
	# 视觉标准（见 config/visual_effects_standard.json）
	var visual_category: String = ""
	var visual_sect: String = ""
	var skip_visual_standard: bool = false

## 创建技能节点（通用方法）
func create_skill_node(cfg: SkillNodeConfig) -> Node2D:
	if not cfg.skip_visual_standard:
		VisualEffectsStandard.apply_to_skill_node_config(cfg, skill_id)
	var skill_node = Node2D.new()
	skill_node.name = cfg.node_name
	skill_node.global_position = cfg.position
	skill_node.rotation = cfg.rotation
	skill_node.z_index = cfg.z_index
	
	# 创建动画精灵
	_add_animated_sprite(skill_node, cfg)
	
	# 创建碰撞区域
	_add_damage_area(skill_node, cfg)
	
	# 添加生命周期管理
	if cfg.lifetime > 0:
		_add_auto_cleanup(skill_node, cfg.lifetime, cfg.fade_duration)
	
	# 弹射物特定逻辑
	if cfg.node_type == SkillNodeType.PROJECTILE:
		_add_projectile_behavior(skill_node, cfg)
	
	# 添加到场景
	if player and player.get_parent():
		player.get_parent().add_child(skill_node)
		if skill_node.is_inside_tree():
			await skill_node.get_tree().process_frame
	
	return skill_node

## 添加动画精灵
func _add_animated_sprite(skill_node: Node2D, cfg: SkillNodeConfig):
	if cfg.skill_animation_name.is_empty():
		return
	
	var animated_sprite = preload("res://Utility/animated_skill_sprite.gd").new()
	animated_sprite.scale = cfg.animation_scale
	animated_sprite.modulate = cfg.animation_modulate
	animated_sprite.fps = cfg.animation_fps
	animated_sprite.loop = cfg.animation_loop
	animated_sprite.name = "AnimatedLayer"
	
	# 尝试加载动画帧
	if animated_sprite.load_from_skill(cfg.skill_animation_name):
		skill_node.add_child(animated_sprite)
	else:
		# 回退到占位纹理
		var fallback_sprite = Sprite2D.new()
		var size = cfg.collision_radius * 2 if cfg.collision_radius > 0 else cfg.collision_size
		fallback_sprite.texture = VisualEffectsHelper.create_glow_background(
			Vector2(size.x if size is Vector2 else size, size.y if size is Vector2 else size),
			cfg.fallback_color
		)
		fallback_sprite.modulate = cfg.fallback_color
		fallback_sprite.modulate.a = cfg.animation_modulate.a
		fallback_sprite.name = "FallbackLayer"
		skill_node.add_child(fallback_sprite)

## 添加伤害区域
func _add_damage_area(skill_node: Node2D, cfg: SkillNodeConfig):
	var damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	damage_area.collision_layer = 0
	damage_area.collision_mask = 2  # 检测敌人
	
	var shape = CollisionShape2D.new()
	
	if cfg.node_type == SkillNodeType.AREA_CIRCLE and cfg.collision_radius > 0:
		var circle = CircleShape2D.new()
		circle.radius = cfg.collision_radius
		shape.shape = circle
	elif cfg.node_type == SkillNodeType.AREA_RECT and cfg.collision_size != Vector2.ZERO:
		var rect = RectangleShape2D.new()
		rect.size = cfg.collision_size
		shape.shape = rect
	elif cfg.node_type == SkillNodeType.PROJECTILE and cfg.collision_radius > 0:
		var circle = CircleShape2D.new()
		circle.radius = cfg.collision_radius
		shape.shape = circle
	
	if shape.shape:
		damage_area.add_child(shape)
		skill_node.add_child(damage_area)

## 添加自动清理脚本
func _add_auto_cleanup(skill_node: Node2D, lifetime: float, fade_duration: float):
	var cleanup_script = load("res://Utility/auto_cleanup_node.gd")
	skill_node.set_script(cleanup_script)
	skill_node.set("lifetime", lifetime)
	skill_node.set("fade_duration", fade_duration)

## 添加弹射物行为
func _add_projectile_behavior(skill_node: Node2D, cfg: SkillNodeConfig):
	var projectile_script = load("res://Utility/auto_projectile.gd")
	skill_node.set_script(projectile_script)
	skill_node.set("direction", cfg.projectile_direction)
	skill_node.set("speed", cfg.projectile_speed)
	skill_node.set("max_range", cfg.projectile_range)
	skill_node.set("skill_instance", self)

## ========================================
## 周期性伤害系统
## ========================================

## 启用周期性伤害
func enable_tick_damage(interval: float, callback: Callable):
	tick_damage_enabled = true
	tick_interval = interval
	tick_callback = callback
	tick_timer = 0.0
	set_process(true)

## ========================================
## 状态效果系统
## ========================================

## 状态效果配置类
class StatusEffectConfig:
	var effect_type: int
	var value: float
	var duration: float

## 添加状态效果
func add_status_effect(effect_type: int, value: float, effect_duration: float):
	var effect = StatusEffectConfig.new()
	effect.effect_type = effect_type
	effect.value = value
	effect.duration = effect_duration
	status_effects.append(effect)

## 应用所有状态效果到敌人
func apply_status_effects(enemy: Node):
	if not enemy:
		return
	
	for effect in status_effects:
		match effect.effect_type:
			StatusEffect.SLOW:
				if enemy.has_method("apply_slow"):
					enemy.apply_slow(effect.value, effect.duration)
			StatusEffect.FREEZE:
				if enemy.has_method("apply_freeze"):
					enemy.apply_freeze(effect.duration)
				elif enemy.has_method("apply_slow"):
					enemy.apply_slow(0.9, effect.duration)  # 90%减速模拟冻结
			StatusEffect.BURN:
				if enemy.has_method("apply_burn"):
					enemy.apply_burn(effect.value, effect.duration)
			StatusEffect.POISON:
				if enemy.has_method("apply_poison"):
					enemy.apply_poison(effect.value, effect.duration)
			StatusEffect.STUN:
				if enemy.has_method("apply_stun"):
					enemy.apply_stun(effect.duration)
