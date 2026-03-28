extends Node
class_name BaseSkill

## 技能基类 - 定义技能行为接口
## 
## 职责：
## - 定义技能的**行为逻辑**（如何移动、如何追踪）
## - 子类实现具体行为（冰矛追踪、龙卷风之字形、标枪环绕）
## - 不负责渲染和碰撞（由 SkillInstanceManager 管理）

# ========================================
# 引用
# ========================================

var player: Node = null
var skill_instance_mgr: Node = null

# ========================================
# 初始化
# ========================================

func setup(p_player: Node, p_skill_mgr: Node):
	player = p_player
	skill_instance_mgr = p_skill_mgr
	on_skill_initialized()

# ========================================
# 子类必须重写的方法
# ========================================

## 技能初始化完成后调用（可选）
func on_skill_initialized():
	pass

## 获取技能发射参数
## 返回: { "position": Vector2, "velocity": Vector2, "rotation": float, "target": Vector2 }
func get_spawn_params() -> Dictionary:
	push_error("子类必须实现 get_spawn_params()")
	return {
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"rotation": 0.0,
		"target": Vector2.ZERO
	}

## 每帧更新技能实例的行为
## inst: SkillInstance 的数据字典
## 返回: 更新后的数据字典
func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
	# 默认行为：直线移动
	inst.position += inst.velocity * delta
	return inst
