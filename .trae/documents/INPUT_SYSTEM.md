# 输入系统说明

## 📋 操作布局

### 当前操作方案（暖雪风格）

| 按键 | 功能 | 类型 | 状态 |
|------|------|------|------|
| **WASD** | 移动 | 基础 | ✅ 已实现 |
| **左键** | 近战攻击 | 主攻击 | ✅ 已实现 |
| **空格** | 近战攻击 | 主攻击 | ✅ 已实现 |
| **右键** | 远程攻击/副武器 | 副攻击 | 🔴 待实现 |
| **Shift** | 冲刺闪避 | 机动 | ✅ 已实现 |
| **Q** | 宗派技能1 | 主动技能 | ✅ 输入已支持 |
| **E** | 宗派技能2 | 主动技能 | ✅ 输入已支持 |
| **R** | 必杀技 | 主动技能 | ✅ 输入已支持 |

---

## 🎮 操作说明

### 基础操作
- **WASD** - 八方向移动
- **左键/空格** - 近战攻击（当前是斩击）
  - 冷却：0.3秒
  - 范围：90
  - 伤害：12
  - 特效：蓝色斩击 + 屏幕震动

### 机动操作
- **Shift** - 冲刺闪避
  - 冷却：0.8秒
  - 距离：160
  - 持续：0.12秒
  - 特效：蓝色残影 + 屏幕震动
  - 效果：0.3秒无敌时间

### 主动技能（需要解锁）
- **Q** - 宗派技能1
  - 冷却：3.0秒
  - 状态：输入已支持，技能待实现
  - 示例：冰霜冲击、雷霆一击等

- **E** - 宗派技能2
  - 冷却：5.0秒
  - 状态：输入已支持，技能待实现
  - 示例：冰封领域、雷阵等

- **R** - 必杀技
  - 冷却：10.0秒
  - 状态：输入已支持，技能待实现
  - 示例：极寒风暴、天罚雷劫等

### 副攻击（待实现）
- **右键** - 远程攻击/副武器
  - 冷却：0.5秒
  - 范围：300
  - 伤害：8
  - 状态：输入已支持，攻击待实现
  - 用途：远程牵制、副武器切换等

---

## 🔧 技术实现

### 输入管理器（InputManager）

**信号列表**：
```gdscript
signal move_input(direction: Vector2)
signal attack_pressed()              # 左键/空格
signal secondary_attack_pressed()    # 右键
signal dash_pressed()                # Shift
signal skill_q_pressed()             # Q
signal skill_e_pressed()             # E
signal skill_r_pressed()             # R
```

**状态查询**：
```gdscript
input_manager.get_move_direction() -> Vector2
input_manager.is_attacking() -> bool
input_manager.is_secondary_attacking() -> bool
input_manager.is_dashing() -> bool
```

### 主动技能管理器（ActiveSkillManager）

**核心功能**：
- 管理QER三个技能的冷却
- 处理技能解锁状态
- 触发技能释放
- 更新UI显示

**API**：
```gdscript
# 尝试释放技能
active_skill_mgr.try_cast_skill("q") -> bool

# 解锁技能
active_skill_mgr.unlock_skill("q")

# 查询状态
active_skill_mgr.is_skill_unlocked("q") -> bool
active_skill_mgr.is_skill_on_cooldown("q") -> bool
active_skill_mgr.get_skill_cooldown_progress("q") -> float

# 减少冷却（特殊效果）
active_skill_mgr.reduce_cooldown("q", 1.0)
```

---

## 📝 配置文件

### stage1_controls.json

```json
{
  "input": {
    "bindings": {
      "primary_attack": "click",      // 左键/空格
      "secondary_attack": "right_click", // 右键
      "dash": "shift",                // Shift
      "skill_q": "skill_q",           // Q
      "skill_e": "skill_e",           // E
      "skill_r": "skill_r"            // R
    },
    "description": {
      "primary_attack": "近战攻击（左键/空格）",
      "secondary_attack": "远程攻击/副武器（右键）",
      "dash": "冲刺闪避（Shift）",
      "skill_q": "宗派技能1（Q）",
      "skill_e": "宗派技能2（E）",
      "skill_r": "必杀技（R）"
    }
  },
  "primary_attack": {
    "type": "melee",
    "base_cooldown": 0.3,
    "base_range": 90,
    "base_damage": 12,
    "base_knockback": 180
  },
  "secondary_attack": {
    "type": "ranged",
    "base_cooldown": 0.5,
    "base_range": 300,
    "base_damage": 8,
    "base_knockback": 50,
    "projectile_speed": 400
  },
  "skills": {
    "q": {
      "name": "宗派技能1",
      "cooldown": 3.0
    },
    "e": {
      "name": "宗派技能2",
      "cooldown": 5.0
    },
    "r": {
      "name": "必杀技",
      "cooldown": 10.0
    }
  }
}
```

---

## 🎯 当前状态

### ✅ 已实现
1. **基础移动**：WASD八方向移动
2. **近战攻击**：左键/空格触发近战攻击
   - 带斩击特效
   - 带屏幕震动
   - 带打击停顿
3. **冲刺闪避**：Shift触发冲刺
   - 带残影效果
   - 带无敌时间
   - 带屏幕震动
4. **输入支持**：QER技能和右键输入已支持

### 🔴 待实现
1. **右键攻击**：远程攻击或副武器系统
2. **Q技能**：宗派技能1（需要宗派系统）
3. **E技能**：宗派技能2（需要宗派系统）
4. **R技能**：必杀技（需要宗派系统）

---

## 🚀 下一步开发

### 阶段2：宗派系统
实现QER技能需要先完成宗派系统：

1. **创建宗派数据结构**
   - 4大宗派配置
   - 每个宗派3个技能

2. **实现宗派选择**
   - 选择界面UI
   - 宗派属性应用

3. **实现宗派技能**
   - Q技能：快速技能（3秒CD）
   - E技能：强力技能（5秒CD）
   - R技能：必杀技（10秒CD）

### 右键攻击系统
可以在阶段3武器系统中实现：

1. **远程武器**
   - 弓箭、法杖等
   - 右键触发

2. **副武器切换**
   - 左键主武器
   - 右键副武器

---

## 🔍 调试技巧

### 测试输入
在Godot控制台中执行：
```gdscript
# 查看输入映射
InputMap.get_actions()

# 测试特定按键
Input.is_action_pressed("skill_q")

# 查看技能状态
active_skill_mgr.is_skill_unlocked("q")
```

### 解锁技能（测试用）
在Player的_initial_setup()中添加：
```gdscript
if active_skill_mgr:
    active_skill_mgr.unlock_skill("q")
    active_skill_mgr.unlock_skill("e")
    active_skill_mgr.unlock_skill("r")
```

---

## 📊 输入响应时间

| 输入 | 响应延迟 | 冷却时间 |
|------|----------|----------|
| 移动 | <16ms | 无 |
| 左键攻击 | <50ms | 0.3s |
| 右键攻击 | <50ms | 0.5s |
| Shift冲刺 | <50ms | 0.8s |
| Q技能 | <50ms | 3.0s |
| E技能 | <50ms | 5.0s |
| R技能 | <50ms | 10.0s |

---

## ✅ 测试结果

```
【测试 1: 输入映射】 ✓
【测试 2: 输入管理器】 ✓
【测试 3: 主动技能管理器】 ✓
【测试 4: 配置文件】 ✓

总计：4/4 通过
```

---

**状态**：✅ 输入系统完成  
**日期**：2026-03-29
