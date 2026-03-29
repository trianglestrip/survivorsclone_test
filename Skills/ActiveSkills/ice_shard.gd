class_name IceShardSkill
extends BaseActiveSkill

## 冰霜碎片技能
## 发射3枚冰霜碎片，造成伤害并减速敌人
## 
## 设计：完全配置驱动，无硬编码数值

var projectile_count: int = 0
var skill_range: float = 0.0
var slow_duration: float = 0.0
var slow_percent: float = 0.0
var projectile_speed: float = 400.0
var angle_spread: float = 20.0

func _load_skill_config(cfg: Dictionary):
	projectile_count = cfg.get("projectile_count", 3)
	skill_range = cfg.get("range", 250.0)
	slow_duration = cfg.get("slow_duration", 2.0)
	slow_percent = cfg.get("slow_percent", 0.3)
	projectile_speed = cfg.get("projectile_speed", 400.0)
	angle_spread = cfg.get("angle_spread", 20.0)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK)
	
	for i in range(projectile_count):
		var offset_angle = (i - projectile_count / 2.0) * angle_spread
		var projectile_dir = direction.rotated(deg_to_rad(offset_angle))
		await _spawn_projectile(cast_position, projectile_dir)

func _spawn_projectile(pos: Vector2, dir: Vector2):
	var projectile = Node2D.new()
	projectile.name = "IceShard"
	projectile.position = pos
	projectile.z_index = 5
	
	# 使用动画精灵
	var sprite = preload("res://Utility/animated_skill_sprite.gd").new()
	sprite.rotation = dir.angle()
	sprite.scale = Vector2(2.0, 2.0)
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)  # 不再需要着色，纹理已有颜色
	sprite.fps = 15.0
	sprite.loop = true
	
	# 尝试加载动画帧
	if not sprite.load_from_skill("ice_shard"):
		# 回退到占位纹理
		sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(16, 8))
		sprite.modulate = GameConstants.Colors.SECT_ICE
	
	projectile.add_child(sprite)
	
	# 添加自动清理脚本
	var projectile_script = load("res://Utility/auto_projectile.gd")
	projectile.set_script(projectile_script)
	projectile.set("direction", dir)
	projectile.set("speed", projectile_speed)
	projectile.set("max_range", skill_range)
	projectile.set("skill_instance", self)
	
	if player and player.get_parent():
		player.get_parent().add_child(projectile)
		await get_tree().process_frame
	else:
		projectile.queue_free()

func _check_projectile_hit(projectile: Node2D):
	var enemies = get_enemies_in_range(projectile.position, 20.0)
	
	if enemies.size() > 0:
		for enemy in enemies:
			damage_enemy(enemy, damage)
			_apply_slow(enemy)
		
		_create_hit_effect(projectile.position)
		projectile.queue_free()

func _apply_slow(enemy: Node):
	if enemy and enemy.has_method("apply_slow"):
		enemy.apply_slow(slow_percent, slow_duration)

func _create_hit_effect(pos: Vector2):
	# 创建爆炸效果容器
	var effect_container = Node2D.new()
	effect_container.global_position = pos
	effect_container.z_index = 10
	
	# 中心爆炸光晕
	var center_glow = Sprite2D.new()
	center_glow.texture = VisualEffectsHelper.create_glow_background(
		Vector2(80, 80),
		GameConstants.Colors.SECT_ICE
	)
	center_glow.modulate = GameConstants.Colors.SECT_ICE
	center_glow.modulate.a = 0.9
	center_glow.scale = Vector2(0.5, 0.5)
	effect_container.add_child(center_glow)
	
	# 外围冰晶碎片（4个方向）
	for i in range(4):
		var shard = Sprite2D.new()
		shard.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(12, 12))
		shard.modulate = GameConstants.Colors.SECT_ICE
		shard.modulate.a = 0.8
		var angle = i * PI / 2
		shard.position = Vector2(cos(angle), sin(angle)) * 20
		shard.rotation = angle
		effect_container.add_child(shard)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect_container)
		_animate_hit_effect(effect_container, center_glow)

func _animate_hit_effect(container: Node2D, glow: Sprite2D):
	if not is_instance_valid(container):
		return
	
	# 爆炸扩散动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(glow, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(glow, "modulate:a", 0.0, 0.3)
	
	# 碎片飞散
	for i in range(4):
		var shard = container.get_child(i + 1) if i + 1 < container.get_child_count() else null
		if shard:
			var angle = i * PI / 2
			var target_pos = Vector2(cos(angle), sin(angle)) * 40
			var shard_tween = create_tween()
			shard_tween.set_parallel(true)
			shard_tween.tween_property(shard, "position", target_pos, 0.3)
			shard_tween.tween_property(shard, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	if is_instance_valid(container):
		container.queue_free()
