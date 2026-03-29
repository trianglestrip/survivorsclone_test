# 暖雪类游戏改造 - 实施计划

## 概述
将当前 Survivors 类游戏框架改造成暖雪类动作 Roguelike 游戏的改造方案。

---

## [ ] Task 1: 操作控制系统改造
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 从自动攻击改为玩家主动攻击
  - 添加攻击输入（鼠标点击、空格键）
  - 添加冲刺/闪避机制（Shift 键）
  - 添加面向方向控制
- **Success Criteria**:
  - 玩家可以通过输入主动攻击
  - 冲刺/闪避机制正常工作
  - 角色面向攻击方向
- **Test Requirements**:
  - `programmatic` TR-1.1: 攻击输入检测正常
  - `programmatic` TR-1.2: 冲刺冷却机制正常
  - `human-judgement` TR-1.3: 操作手感流畅
- **Notes**: 需要修改 Player 输入处理，添加 InputManager 组件

## [ ] Task 2: 关卡系统设计
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 设计关卡结构（多个房间、传送门）
  - 创建关卡管理器（LevelManager）
  - 添加房间过渡机制
  - 设计关卡进度系统
- **Success Criteria**:
  - 可以在房间之间切换
  - 关卡进度正确保存
  - 房间过渡流畅
- **Test Requirements**:
  - `programmatic` TR-2.1: 房间切换无错误
  - `programmatic` TR-2.2: 关卡数据正确加载
  - `human-judgement` TR-2.3: 关卡设计合理
- **Notes**: 需要创建 Level 配置文件，添加传送门机制

## [ ] Task 3: 敌人系统升级
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 设计更丰富的敌人类型
  - 添加敌人攻击模式
  - 实现敌人AI行为树
  - 添加精英怪和 Boss 系统
- **Success Criteria**:
  - 敌人有多样化的攻击方式
  - Boss 战具有挑战性
  - 敌人AI行为自然
- **Test Requirements**:
  - `programmatic` TR-3.1: 敌人攻击命中检测
  - `programmatic` TR-3.2: Boss 阶段转换正常
  - `human-judgement` TR-3.3: 战斗节奏良好
- **Notes**: 需要扩展 Enemy 基类，添加 Boss 专门逻辑

## [ ] Task 4: 技能/宗派系统
- **Priority**: P1
- **Depends On**: Task 1
- **Description**: 
  - 设计宗派系统（不同宗派有不同技能树）
  - 实现主动技能系统
  - 添加技能组合效果
  - 创建圣物/装备系统
- **Success Criteria**:
  - 宗派选择影响技能
  - 主动技能释放流畅
  - 圣物效果正确应用
- **Test Requirements**:
  - `programmatic` TR-4.1: 宗派数据加载正确
  - `programmatic` TR-4.2: 技能冷却管理
  - `human-judgement` TR-4.3: 技能组合有趣
- **Notes**: 需要创建 SectRegistry、RelicSystem 等新系统

## [ ] Task 5: 武器系统
- **Priority**: P1
- **Depends On**: Task 1
- **Description**: 
  - 设计多种武器类型（剑、刀、枪等）
  - 每种武器有独特攻击模式
  - 添加武器升级和进化
  - 实现武器切换
- **Success Criteria**:
  - 武器攻击手感有差异
  - 武器升级效果明显
  - 切换流畅
- **Test Requirements**:
  - `programmatic` TR-5.1: 武器数据正确加载
  - `programmatic` TR-5.2: 攻击范围检测准确
  - `human-judgement` TR-5.3: 武器打击感良好
- **Notes**: 需要重构 Skill 系统为 Weapon 系统

## [ ] Task 6: UI/UX 改进
- **Priority**: P1
- **Depends On**: None
- **Description**: 
  - 重新设计游戏界面
  - 添加宗派选择界面
  - 改进血条、技能栏显示
  - 添加暂停菜单和设置
- **Success Criteria**:
  - 界面信息清晰
  - 宗派选择直观
  - 设置功能完善
- **Test Requirements**:
  - `programmatic` TR-6.1: UI 元素正确更新
  - `programmatic` TR-6.2: 菜单导航正常
  - `human-judgement` TR-6.3: 视觉效果美观
- **Notes**: 需要创建新的 UI 场景

## [ ] Task 7: 存档和进度系统
- **Priority**: P2
- **Depends On**: Task 2
- **Description**: 
  - 实现游戏存档
  - 添加玩家永久升级
  - 设计解锁系统
  - 记录游戏统计
- **Success Criteria**:
  - 存档可以保存和加载
  - 永久升级正确应用
  - 解锁系统工作
- **Test Requirements**:
  - `programmatic` TR-7.1: 存档文件读写正常
  - `programmatic` TR-7.2: 数据持久化正确
  - `human-judgement` TR-7.3: 进度有成就感
- **Notes**: 需要创建 SaveSystem 组件

## [ ] Task 8: 音效和视觉效果
- **Priority**: P2
- **Depends On**: None
- **Description**: 
  - 添加攻击音效
  - 实现受击反馈
  - 添加屏幕震动
  - 改进粒子效果
- **Success Criteria**:
  - 音效时机准确
  - 反馈感强
  - 视觉效果炫酷
- **Test Requirements**:
  - `programmatic` TR-8.1: 音效播放无延迟
  - `programmatic` TR-8.2: 粒子效果性能良好
  - `human-judgement` TR-8.3: 打击感强烈
- **Notes**: 需要扩展 AudioManager，添加 VFX 系统

---

## 改造优先级总结

### 第一阶段（核心玩法）
1. ✅ Task 1: 操作控制 - 让玩家能玩
2. ✅ Task 2: 关卡系统 - 有地方可去
3. ✅ Task 3: 敌人系统 - 有东西可打

### 第二阶段（深度）
4. ⬜ Task 4: 宗派/技能 - 增加玩法深度
5. ⬜ Task 5: 武器系统 - 增加战斗多样性
6. ⬜ Task 6: UI/UX - 提升体验

### 第三阶段（完善）
7. ⬜ Task 7: 存档系统 - 长期游玩
8. ⬜ Task 8: 音效视觉 - 完整体验

---

## 核心系统对比

| 系统 | 当前 (Survivors) | 目标 (暖雪) |
|------|------------------|------------|
| 攻击方式 | 自动攻击 | 主动攻击 + 技能 |
| 关卡 | 单一无限地图 | 多房间关卡 + Boss |
| 敌人 | 简单追踪 | 多样AI + 攻击模式 |
| 成长 | 被动升级 | 宗派 + 圣物 + 武器进化 |
| 操作 | WASD 移动 | 移动 + 攻击 + 冲刺 |
