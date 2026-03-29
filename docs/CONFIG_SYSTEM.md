# 配置系统

## 概述

所有游戏数据通过配置文件管理，实现数据与逻辑完全分离。

## 配置文件

### skill_registry.ini - 技能注册

```ini
[IceSpear]
name=冰矛
description=向随机敌人投掷冰矛
type=projectile
scene_path=res://Skills/ice_spear.tscn
```

### skill_config.ini - 技能属性

```ini
[IceSpear]
behavior_type=tracking
base_speed=200
base_damage=5
base_knockback_amount=100
base_attack_size=1.0
base_lifetime=5.0
base_pierce=1
rotation_offset=135
tracking_enabled=true
level1_damage=5
level2_damage=5
level3_damage=8
level4_damage=8
```

### enemy_registry.ini - 敌人注册

```ini
[enemy_kobold_weak]
name=弱小狗头人
tier=1
is_boss=false
scene_path=res://Enemy/enemy_kobold_weak.tscn
```

### enemy_config.ini - 敌人属性

```ini
[enemy_kobold_weak]
movement_speed=20.0
hp=10
knockback_recovery=3.5
experience=1
enemy_damage=1
```

### upgrade_config.ini - 升级配置

```ini
[icespear1]
displayname=冰矛
details=解锁冰矛技能
level=等级：1
prerequisite=
type=weapon
icon=res://Textures/Items/Weapons/ice_spear.png
spell=IceSpear
set_level=1
add_baseammo=1
```

### spawn_waves.ini - 波次配置

定义敌人的生成规则和时间。

---

## 配置加载流程

1. 启动时，ConfigManager 加载所有配置
2. SkillRegistry 和 EnemyRegistry 从配置文件动态注册
3. UpgradeDb 解析升级配置
4. 验证配置完整性，失败则退出

---

## 修改游戏平衡

只需编辑配置文件，无需修改代码：

- 调整伤害 → 修改 `skill_config.ini`
- 调整敌人血量 → 修改 `enemy_config.ini`
- 添加新升级 → 编辑 `upgrade_config.ini`
- 调整生成节奏 → 修改 `spawn_waves.ini`
