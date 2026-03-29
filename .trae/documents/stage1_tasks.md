# 暖雪改造 - 第一阶段任务清单

## 阶段目标：操作控制系统改造

---

## [x] Task 1.1: 输入管理器组件 (InputManager)
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 创建独立的 InputManager 组件
  - 统一管理所有玩家输入
  - 支持输入绑定配置
  - 事件驱动的输入通知
- **Success Criteria**:
  - InputManager 可以检测所有按键输入
  - 输入事件正确发出
  - 代码解耦，Player 不直接处理输入
- **Test Requirements**:
  - `programmatic` TR-1.1.1: InputManager 类存在且可加载
  - `programmatic` TR-1.1.2: 输入信号正确定义
  - `programmatic` TR-1.1.3: 输入状态查询方法可用
- **Notes**: 参考当前 Player 输入处理，解耦到独立组件
- **Status**: 已完成 ✅
- **Completion Date**: 2026-03-29

## [x] Task 1.2: 玩家主动攻击系统
- **Priority**: P0
- **Depends On**: Task 1.1
- **Description**: 
  - 重构 AttackManager 支持主动攻击
  - 创建攻击基类 (BaseAttack)
  - 实现武器攻击模式
  - 添加攻击冷却管理
  - 攻击方向基于玩家面向
- **Success Criteria**:
  - 点击鼠标/按空格可以攻击
  - 攻击有冷却时间
  - 攻击方向正确
  - 数值与逻辑分离
- **Test Requirements**:
  - `programmatic` TR-1.2.1: BaseAttack 基类存在
  - `programmatic` TR-1.2.2: 攻击冷却工作正常
  - `programmatic` TR-1.2.3: 攻击方向计算正确
- **Notes**: 使用继承架构，BaseAttack 定义接口
- **Status**: 已完成 ✅
- **Completion Date**: 2026-03-29

## [x] Task 1.3: 冲刺/闪避机制
- **Priority**: P0
- **Depends On**: Task 1.1
- **Description**: 
  - 创建 DashManager 组件
  - 实现冲刺逻辑
  - 添加冲刺冷却
  - 无敌帧/闪避效果
  - 冲刺消耗管理
- **Success Criteria**:
  - 按 Shift 可以冲刺
  - 冲刺有冷却时间
  - 冲刺距离和速度可配置
  - 冲刺期间有特殊状态
- **Test Requirements**:
  - `programmatic` TR-1.3.1: DashManager 组件存在
  - `programmatic` TR-1.3.2: 冲刺冷却管理正常
  - `programmatic` TR-1.3.3: 冲刺位移计算正确
- **Notes**: 冲刺参数可配置，从配置文件加载
- **Status**: 已完成 ✅
- **Completion Date**: 2026-03-29

## [x] Task 1.4: 第一阶段自动化测试
- **Priority**: P0
- **Depends On**: Tasks 1.1, 1.2, 1.3
- **Description**: 
  - 创建 InputManager 测试
  - 创建攻击系统测试
  - 创建冲刺系统测试
  - 集成测试场景
- **Success Criteria**:
  - 所有单元测试通过
  - 集成测试运行正常
  - 测试覆盖核心功能
- **Test Requirements**:
  - `programmatic` TR-1.4.1: 测试文件存在
  - `programmatic` TR-1.4.2: 测试可以运行
  - `programmatic` TR-1.4.3: 所有测试通过
- **Notes**: 创建 test_stage1_input.gd, test_stage1_attack.gd, test_stage1_dash.gd
- **Status**: 已完成 ✅
- **Completion Date**: 2026-03-29

## [x] 额外完成的工作
- 删除了旧的 INI 配置文件，迁移到 JSON 格式
- 更新了 base_registry.gd 和 upgrade_db.gd 支持 JSON 配置
- 创建了占位资源生成器 generate_placeholders.py
- 生成了 18 个占位资源（纹理、动画、UI）
- 修复了游戏启动问题（添加了 fps_display.gd）
- 修复了 player.gd 异步初始化问题
- 在 project.godot 中添加了缺失的输入动作（attack、shift）
- 集成 InputManager 和 DashManager 到 player.gd

---

## 设计原则

### 解耦原则
- **InputManager** - 只处理输入，不处理游戏逻辑
- **AttackManager** - 只管理攻击，不处理输入
- **DashManager** - 只管理冲刺，独立组件
- **Player** - 协调各组件，不包含具体逻辑

### 数值与逻辑分离
- 所有数值在 `config/` 目录
- 攻击参数、冲刺参数从配置加载
- 硬编码数值 → 配置驱动

### 继承与复用
- **BaseAttack** - 攻击基类，定义抽象方法
- **BaseWeapon** - 武器基类（后续扩展）
- 使用抽象函数强制子类实现

### 事件驱动
- InputManager 发出输入事件
- 各组件监听事件，不直接依赖
- EventBus 扩展支持新事件类型
