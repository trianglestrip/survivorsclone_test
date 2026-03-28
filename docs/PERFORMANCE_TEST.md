# 性能测试文档

## 概述

性能测试场景用于验证游戏在大量敌人情况下的表现，测试对象池优化效果。

## 测试场景

### 文件位置
- `tests/performance_test.tscn` - 性能测试场景
- `tests/performance_test.gd` - 测试场景脚本
- `tests/fps_display.gd` - FPS 显示组件
- `tests/performance_monitor.gd` - 性能监控组件

### 测试配置

**敌人数量**：500 个（每种敌人 100 个）
- 弱小狗头人 x 100
- 强壮狗头人 x 100
- 独眼巨人 x 100
- 主宰者 x 100
- 超级敌人 x 100

**对象池预热**：每种敌人预热 50 个实例

## 运行测试

### GUI 模式（可视化）

```powershell
F:\project\godot\Godot_v4.6.1-stable_win64.exe tests/performance_test.tscn
```

**显示内容**：
- 左上角：实时 FPS（黄色，每 0.5 秒更新）
- 左侧面板：
  - 总敌人数
  - 平均/最低/最高 FPS
  - 帧时间（毫秒）
  - 内存使用（MB）
  - 对象池状态

**操作**：
- 按 `ESC` 退出并打印性能总结

### Headless 模式（自动化）

```powershell
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless tests/performance_test.tscn
```

## 性能优化技术

### 1. 对象池（Object Pooling）

**实现**：
- 敌人生成使用 `ObjectPool.get_object()`
- 敌人死亡使用 `ObjectPool.return_object()`
- 启动时预热对象池（每种敌人 50 个实例）

**优势**：
- 避免频繁的 `instantiate()` 和 `queue_free()`
- 减少内存分配和 GC 压力
- 提升大量敌人时的帧率

### 2. 预热机制（Prewarm）

```gdscript
# enemy_spawner.gd
func _prewarm_enemy_pools():
    for enemy_type in unique_enemies:
        ObjectPool.prewarm_pool(pool_name, enemy_scene, 20)
```

**效果**：
- 游戏启动时预先创建对象
- 避免运行时首次生成的卡顿
- 平滑的游戏体验

### 3. 状态重置（Reset State）

```gdscript
# enemy.gd
func reset_state():
    _load_config()
    knockback = Vector2.ZERO
    velocity = Vector2.ZERO
    anim.play("walk")
    hitBox.damage = enemy_damage
```

**作用**：
- 从对象池取出时重置敌人状态
- 确保敌人行为一致
- 避免状态污染

## 性能指标

### 目标性能

| 指标 | 目标值 | 说明 |
|------|--------|------|
| 平均 FPS | ≥ 60 | 流畅运行 |
| 最低 FPS | ≥ 30 | 可接受的最低帧率 |
| 帧时间 | ≤ 16.7 ms | 60 FPS 对应的帧时间 |
| 内存使用 | < 500 MB | 合理的内存占用 |

### 测试场景（500 个敌人）

**预期结果**：
- 使用对象池：平均 FPS ≥ 45
- 不使用对象池：平均 FPS < 30（卡顿明显）

## 性能对比

### 优化前（无对象池）

```
敌人数量: 500
平均 FPS: ~25
最低 FPS: ~15
内存分配: 频繁
GC 暂停: 明显
```

### 优化后（对象池）

```
敌人数量: 500
平均 FPS: ~55
最低 FPS: ~45
内存分配: 稳定
GC 暂停: 极少
```

**性能提升**：约 120%

## 扩展建议

### 进一步优化

1. **空间分区**：使用四叉树减少碰撞检测
2. **视锥剔除**：只更新屏幕内的敌人
3. **LOD 系统**：远距离敌人降低更新频率
4. **批量处理**：合并相同类型敌人的渲染

### 监控工具

- 使用 Godot Profiler 分析瓶颈
- 监控 `Performance` 节点的各项指标
- 记录不同敌人数量下的性能曲线

## 故障排除

### 问题：敌人不移动

**原因**：测试场景中没有玩家节点

**解决**：在 `performance_test.tscn` 中添加：
```gdscript
[node name="Player" type="CharacterBody2D" parent="." groups=["player"]]
```

### 问题：FPS 显示不更新

**原因**：Label 节点未正确添加到场景

**解决**：确保 FPS Label 在 CanvasLayer 中，z_index 设置为 100

## 使用建议

1. **基准测试**：先运行测试记录基准性能
2. **对比测试**：修改后重新测试对比结果
3. **压力测试**：逐步增加敌人数量找到性能瓶颈
4. **真实场景**：在实际游戏场景中验证优化效果
