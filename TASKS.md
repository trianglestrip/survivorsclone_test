# 重构任务清单

## 阶段 1：创建基础架构组件 ✅

### 任务 1.1：事件总线系统
- [x] 创建 `Utility/event_bus.gd`
- [x] 定义核心游戏事件信号
- [x] 在 `project.godot` 中注册为 Autoload
- [x] 编写测试脚本验证事件系统

### 任务 1.2：配置管理器
- [x] 创建 `Utility/config_manager.gd`
- [x] 实现统一的配置加载接口
- [x] 支持 INI 和 JSON 格式
- [x] 添加配置缓存机制

### 任务 1.3：技能基类
- [x] 创建 `Utility/base_skill.gd`
- [x] 定义通用属性和方法
- [x] 实现统一的配置加载逻辑
- [x] 实现玩家修正器应用逻辑

### 任务 1.4：效果系统基类
- [x] 创建 `Utility/Effects/` 目录
- [x] 创建 `base_effect.gd` 基类
- [x] 创建 `stat_modifier_effect.gd`
- [x] 创建 `skill_unlock_effect.gd`
- [x] 创建 `heal_effect.gd`
- [x] 创建 `skill_modifier_effect.gd`

### 测试脚本
- [x] `tests/test_stage1_simple.gd` ✅ 通过

---

## 阶段 2：重构技能系统 ✅

### 任务 2.1：技能注册系统
- [x] 创建 `Utility/skill_registry.gd`
- [x] 实现技能注册和查询接口
- [x] 在 `project.godot` 中注册为 Autoload

### 任务 2.2：重构 IceSpear
- [x] 修改 `ice_spear.gd` 继承 `BaseSkill`
- [x] 移除重复的配置加载代码
- [x] 保持原有功能不变

### 任务 2.3：重构 Tornado
- [x] 修改 `tornado.gd` 继承 `BaseSkill`
- [x] 移除重复的配置加载代码
- [x] 保持原有功能不变

### 任务 2.4：重构 Javelin
- [x] 修改 `javelin.gd` 继承 `BaseSkill`
- [x] 移除重复的配置加载代码
- [x] 保持原有功能不变

### 测试脚本
- [x] `tests/test_stage2.gd` ✅ 通过

---

## 阶段 3：拆分玩家类 ✅

### 任务 3.1：PlayerStats 组件
- [x] 创建 `Player/Components/player_stats.gd`
- [x] 迁移属性变量（hp, armor, speed 等）
- [x] 提供属性修改接口

### 任务 3.2：SkillManager 组件
- [x] 创建 `Player/Components/skill_manager.gd`
- [x] 迁移技能相关变量和逻辑
- [x] 实现技能激活和管理接口

### 任务 3.3：UpgradeManager 组件
- [x] 创建 `Player/Components/upgrade_manager.gd`
- [x] 迁移升级相关逻辑
- [x] 实现升级应用接口

### 任务 3.4：ExperienceManager 组件
- [x] 创建 `Player/Components/experience_manager.gd`
- [x] 迁移经验值计算逻辑
- [x] 实现升级触发接口

### 任务 3.5：重构 player.gd
- [x] 创建 `player_refactored.gd` 使用组件
- [⏸️] 集成到主游戏（待后续完成）

### 测试脚本
- [x] `tests/test_stage3.gd` - 组件独立测试
- [⏸️] 完整集成测试（待完成）

---

## 阶段 4：重构升级系统 ⏳

### 任务 4.1：效果类实现
- [ ] 实现 `StatModifierEffect`
- [ ] 实现 `SkillUnlockEffect`
- [ ] 实现 `HealEffect`
- [ ] 实现 `SkillModifierEffect`

### 任务 4.2：更新配置格式
- [ ] 设计新的升级配置格式
- [ ] 迁移现有配置数据
- [ ] 更新 `upgrade_db.gd` 解析逻辑

### 任务 4.3：重构升级应用
- [ ] 重构 `_apply_upgrade_effect()` 使用效果系统
- [ ] 移除硬编码的 match 语句
- [ ] 测试所有升级

### 测试脚本
- [ ] `tests/test_upgrade_system.gd`

---

## 阶段 5：优化敌人系统 ⏳

### 任务 5.1：敌人注册系统
- [ ] 创建 `Utility/enemy_registry.gd`
- [ ] 实现敌人注册接口

### 任务 5.2：波次配置系统
- [ ] 创建 `config/spawn_waves.ini`
- [ ] 重构 `enemy_spawner.gd` 使用配置文件
- [ ] 添加事件和 Boss 支持

### 测试脚本
- [ ] `tests/test_enemy_spawner.gd`

---

## 阶段 6：性能优化 ⏸️

### 任务 6.1：对象池系统
- [x] 创建 `Utility/object_pool.gd`
- [x] 注册为 Autoload

### 任务 6.2：应用对象池
- [ ] 技能使用对象池
- [ ] 经验宝石使用对象池
- [ ] 敌人死亡特效使用对象池

### 测试脚本
- [ ] `tests/test_object_pool.gd`
- [ ] `tests/test_performance.gd`

---

## 阶段 7：最终整合和测试 ⏳

### 任务 7.1：集成测试
- [ ] 完整游戏流程测试
- [ ] 所有技能组合测试
- [ ] 所有升级组合测试

### 任务 7.2：文档更新
- [ ] 更新 `README.md`
- [ ] 创建 `ARCHITECTURE.md` 架构文档
- [ ] 添加代码注释

### 任务 7.3：代码清理
- [ ] 移除未使用的代码
- [ ] 统一代码风格
- [ ] 优化性能瓶颈

---

## 测试策略

### 自动化测试
使用 Godot 的 GUT (Godot Unit Test) 框架或自定义测试脚本。

### 测试命令
```bash
# 无界面模式运行测试
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/run_all_tests.gd
```

### 测试覆盖
- 单元测试：每个组件独立测试
- 集成测试：组件协同工作测试
- 功能测试：完整游戏流程测试

---

## 回滚策略
每个阶段完成后创建 Git 提交：
- `refactor: stage1 - add base infrastructure`
- `refactor: stage2 - refactor skill system`
- `refactor: stage3 - split player class`
- `refactor: stage4 - refactor upgrade system`
- `refactor: stage5 - optimize enemy system`
- `refactor: stage6 - add object pooling`
- `refactor: stage7 - final integration`

---

## 风险评估

### 高风险
- 玩家类拆分可能导致信号连接问题
- 技能系统重构可能影响游戏平衡

### 缓解措施
- 每个阶段充分测试
- 保持 Git 提交粒度细化
- 出现问题立即回滚

---

## 预期成果

### 代码质量
- 代码行数减少 30-40%
- 圈复杂度降低 50%
- 代码重复率降低 60%

### 扩展性
- 添加新技能：只需配置 + 1 个脚本文件（约 20 行）
- 添加新敌人：只需配置文件
- 添加新升级：只需配置文件

### 性能
- 对象创建/销毁减少 70%
- 内存占用降低 20-30%
- 帧率提升 10-15%
