extends CharacterBody2D

## 注意：此脚本仅用于场景定义和编辑器显示
## GPU 实例化模式下不会实例化敌人节点，因此此脚本不会执行
## 所有敌人逻辑由 Enemy/enemy_instance_manager.gd 管理

@export var movement_speed = 20.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)


func _ready():
	# GPU 模式下此代码不会执行
	# 保留用于非 GPU 模式或调试
	_load_config()
	anim.play("walk")
	hitBox.damage = enemy_damage

func _load_config():
	var cfg = ConfigFile.new()
	if cfg.load("res://config/enemy_config.ini") != OK:
		return
	var section = get_name()
	if not cfg.has_section(section):
		return
	movement_speed = cfg.get_value(section, "movement_speed", movement_speed)
	hp = cfg.get_value(section, "hp", hp)
	knockback_recovery = cfg.get_value(section, "knockback_recovery", knockback_recovery)
	experience = cfg.get_value(section, "experience", experience)
	enemy_damage = cfg.get_value(section, "enemy_damage", enemy_damage)

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
	# 检查玩家是否存在
	if player == null or not is_instance_valid(player):
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func death():
	emit_signal("remove_from_array",self)
	
	# 使用对象池获取爆炸效果
	var enemy_death = ObjectPool.get_object("explosion", death_anim)
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child",enemy_death)
	
	# 使用对象池获取经验宝石
	var new_gem = ObjectPool.get_object("experience_gem", exp_gem)
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child",new_gem)
	
	# 归还敌人到对象池
	var pool_name = "enemy_" + get_name()
	ObjectPool.return_object(pool_name, self)

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()

# 对象池支持：重置敌人状态
func reset_state():
	_load_config()
	knockback = Vector2.ZERO
	velocity = Vector2.ZERO
	if anim:
		anim.play("walk")
	if hitBox:
		hitBox.damage = enemy_damage
