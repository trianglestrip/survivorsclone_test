extends CharacterBody2D
class_name BaseEnemy

## 敌人基类
## 所有敌人类型都应该继承此类
## 
## 注意：GPU 实例化模式下，此脚本仅用于：
## 1. 场景定义（.tscn 文件必须有脚本引用）
## 2. 编辑器预览（显示属性面板）
## 3. 导出变量（供配置系统读取）
## 
## 实际游戏逻辑由 Enemy/enemy_instance_manager.gd 管理

# ========================================
# 敌人属性（从配置文件加载）
# ========================================

@export_group("基础属性")
@export var movement_speed := 20.0
@export var hp := 10
@export var knockback_recovery := 3.5
@export var experience := 1
@export var enemy_damage := 1

@export_group("视觉效果")
@export var sprite_scale := Vector2(0.75, 0.75)
@export var animation_speed := 1.0

# ========================================
# 状态效果管理
# ========================================

var status_manager: EnemyStatusManager = null

func _ready():
	_initialize_status_manager()

func _initialize_status_manager():
	status_manager = EnemyStatusManager.new()
	status_manager.set_enemy(self)
	add_child(status_manager)

# ========================================
# 获取敌人配置（用于 GPU 系统读取）
# ========================================

func get_enemy_config() -> Dictionary:
	return {
		"movement_speed": movement_speed,
		"hp": hp,
		"knockback_recovery": knockback_recovery,
		"experience": experience,
		"enemy_damage": enemy_damage,
		"sprite_scale": sprite_scale,
		"animation_speed": animation_speed,
	}

# ========================================
# 状态效果API
# ========================================

func apply_slow(percent: float, duration: float):
	if status_manager:
		status_manager.apply_slow(percent, duration)

func apply_burn(damage_per_sec: float, duration: float):
	if status_manager:
		status_manager.apply_burn(damage_per_sec, duration)

func apply_poison(damage_per_sec: float, duration: float):
	if status_manager:
		status_manager.apply_poison(damage_per_sec, duration)

func apply_freeze(duration: float):
	if status_manager:
		status_manager.apply_freeze(duration)

func has_status(type: GameConstants.StatusEffectType) -> bool:
	return status_manager and status_manager.has_effect(type)

# ========================================
# 子类可重写的方法
# ========================================

## 敌人特殊行为（如 Boss 技能）
func special_behavior(_delta: float):
	pass

## 死亡时的特殊效果
func on_death():
	pass

## 受到伤害（子类可重写添加特殊逻辑）
func take_damage(dmg: float, _knockback_dir: Vector2 = Vector2.ZERO):
	hp -= dmg
	if hp <= 0:
		on_death()
