extends CharacterBody2D

## GPU 实例化模式专用空壳脚本
## 
## 此脚本不包含任何逻辑，仅用于 .tscn 文件的脚本引用
## 所有敌人逻辑（移动、动画、碰撞、伤害）由 Enemy/enemy_instance_manager.gd 管理
## 
## 为何保留此文件：
## - 敌人 .tscn 文件必须有脚本引用才能在编辑器中打开
## - 编辑器需要此脚本来显示场景预览和导出变量
## - 删除会导致所有敌人场景报错

@export var movement_speed = 20.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1
