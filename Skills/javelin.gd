extends "res://Skills/base_skill.gd"

## 标枪技能
## GPU 实例化模式下，此脚本仅用于场景定义
## 实际逻辑由 Skills/skill_instance_manager.gd 管理

@export_group("标枪属性")
@export var paths := 1  # 攻击路径数
@export var attack_interval := 5.0  # 攻击间隔
@export var orbit_radius := 50.0  # 环绕半径
@export var return_speed := 20.0  # 返回速度
