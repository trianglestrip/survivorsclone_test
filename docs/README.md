# 文档索引

本目录包含项目的所有技术文档。

---

## 核心文档

### [ARCHITECTURE.md](ARCHITECTURE.md)
系统架构和设计模式详解
- 组件化设计
- 事件驱动架构
- 配置驱动理念
- 核心系统说明

### [CONFIG_SYSTEM.md](CONFIG_SYSTEM.md)
配置系统完整说明
- 配置文件格式
- 加载和验证流程
- 数据分离原则
- 扩展指南

### [REGISTRY_SYSTEM.md](REGISTRY_SYSTEM.md)
技能和敌人注册系统
- 动态注册实现
- 配置文件格式
- 扩展指南
- 从硬编码到配置驱动的演进

### [AUDIO_SYSTEM.md](AUDIO_SYSTEM.md)
音频系统说明
- AudioManager 使用方法
- 声音开关实现
- 未来扩展建议

### [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
快速参考指南
- Godot 可执行文件路径
- 常用命令
- 配置文件格式
- 项目结构概览
- 核心系统速查表

---

## 开发文档

### [TESTING_GUIDE.md](TESTING_GUIDE.md)
测试指南
- 自动化测试方法
- 手动测试清单
- 故障排除步骤

### [PERFORMANCE_TEST.md](PERFORMANCE_TEST.md)
性能测试文档
- 性能测试场景（500 个敌人）
- 对象池优化效果
- 性能指标和对比
- FPS 监控和分析

### [WARNING_FIXES.md](WARNING_FIXES.md)
警告修复记录
- 修复的警告类型
- 修复前后对比
- GDScript 最佳实践
- 代码质量建议

### [BUGFIX_SUMMARY.md](BUGFIX_SUMMARY.md)
Bug 修复总结
- 已修复的 Bug 列表
- 根本原因分析
- 修复方案说明
- 验证结果

---

## 历史文档

### [REFACTORING_PLAN.md](REFACTORING_PLAN.md)
架构重构详细计划
- 7 个重构阶段
- 每个阶段的目标和任务
- 测试验证方法

### [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md)
重构完成总结
- 重构成果
- 架构改进
- 性能提升

### [CONFIG_REFACTORING_SUMMARY.md](CONFIG_REFACTORING_SUMMARY.md)
配置系统重构总结
- 从硬编码到配置驱动
- 代码简化 63%
- 设计理念演进

### [TASKS.md](TASKS.md)
重构任务清单
- 详细的任务分解
- 完成状态追踪

---

## 文档使用建议

### 新手入门
1. 先阅读 [../README.md](../README.md) 了解项目概况
2. 查看 [QUICK_REFERENCE.md](QUICK_REFERENCE.md) 学习基本操作
3. 阅读 [ARCHITECTURE.md](ARCHITECTURE.md) 理解架构设计

### 开发者
1. 参考 [CONFIG_SYSTEM.md](CONFIG_SYSTEM.md) 了解如何修改游戏数据
2. 查看 [TESTING_GUIDE.md](TESTING_GUIDE.md) 学习测试方法
3. 遵循 [WARNING_FIXES.md](WARNING_FIXES.md) 中的最佳实践

### 维护者
1. 查看 [BUGFIX_SUMMARY.md](BUGFIX_SUMMARY.md) 了解已知问题
2. 参考历史文档了解项目演进
3. 更新相关文档记录新的改动

---

**文档总数**: 14 个  
**最后更新**: 2026-03-28
