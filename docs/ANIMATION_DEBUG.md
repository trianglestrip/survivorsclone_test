# 敌人动画调试指南

## 问题：某些敌人动画不播放

### 检查清单

#### 1. 检查场景文件中的 hframes

```bash
# 查看敌人场景的 Sprite2D 配置
grep -A 2 "Sprite2D" Enemy/enemy_kobold_weak.tscn
```

**应该看到**：
```
[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ...
hframes = 2  ← 必须 > 1
```

#### 2. 检查初始化日志

运行游戏时，查看控制台输出：

```
=== GPU 实例化敌人管理器初始化 ===
  开始初始化 5 种敌人类型...
    📽 敌人 enemy_kobold_weak 有 2 帧动画  ← 应该显示
    📽 敌人 enemy_cyclops 有 2 帧动画
```

**如果没有显示 📽**：
- 说明 SceneState 没有正确解析 hframes
- 检查场景文件格式

#### 3. 检查运行时动画

在游戏中观察敌人：
- **有动画**：敌人行走时腿部有移动
- **无动画**：敌人静止滑行

### 常见问题

#### 问题 A：场景有 hframes，但初始化时没有识别

**原因**：SceneState 解析失败

**解决方案**：
```gdscript
# 在 enemy_instance_manager.gd 的 _parse_enemy_scene_from_state 中添加调试
if node_type == &"Sprite2D":
    print("DEBUG: 找到 Sprite2D，节点索引 ", i)
    for j in state.get_node_property_count(i):
        var pname := state.get_node_property_name(i, j)
        var pval := state.get_node_property_value(i, j)
        print("  属性: ", pname, " = ", pval)
```

#### 问题 B：初始化识别了，但运行时不播放

**原因**：Shader 或帧计算问题

**检查**：
1. 查看 `_update_enemy_type` 中的帧计算
2. 确认 `type_data.hframes > 1`
3. 检查 COLOR 是否正确设置

**调试代码**：
```gdscript
if type_data.hframes > 1:
    var total_time = inst.anim_time + inst.anim_offset
    var current_frame = int(total_time / 0.3) % type_data.hframes
    var frame_normalized = (float(current_frame) + 0.5) / float(type_data.hframes)
    print("敌人 %s: frame=%d, normalized=%.3f" % [enemy_type, current_frame, frame_normalized])
```

#### 问题 C：只有某些敌人不播放

**可能原因**：
1. 场景文件格式不同
2. Sprite2D 节点路径不同
3. hframes 属性位置不同

**解决方案**：
对比正常的和异常的场景文件：

```bash
# 正常的（cyclops）
diff Enemy/enemy_cyclops.tscn Enemy/enemy_kobold_weak.tscn
```

查找差异：
- Sprite2D 节点定义
- hframes 属性位置
- 是否有 unique_id

### 测试方法

#### 方法 1：控制台日志

运行游戏，查看：
```
📽 敌人 enemy_kobold_weak 有 2 帧动画
```

#### 方法 2：性能测试场景

使用 `tests/performance_test_gpu.tscn`：
- 生成 100 个 kobold_weak
- 观察是否有行走动画

#### 方法 3：手动测试

在 `_initialize_enemy_types` 中添加：
```gdscript
print("\n=== 敌人动画配置 ===")
for enemy_id in enemy_types:
    var type_data = enemy_types[enemy_id]
    print("%s: hframes=%d, 有纹理=%s" % [
        enemy_id, 
        type_data.hframes,
        "是" if type_data.texture else "否"
    ])
```

### 当前状态

**已知工作的敌人**：
- ✓ enemy_cyclops (2 帧)
- ✓ enemy_kobold_strong (2 帧)
- ✓ enemy_juggernaut (2 帧)

**需要验证的敌人**：
- ? enemy_kobold_weak (应该 2 帧)
- ? enemy_super (需要检查)

### 快速修复

如果某个敌人动画不工作，临时解决方案：

1. **在编辑器中打开场景**
2. **选择 Sprite2D 节点**
3. **确认 HFrames = 2**
4. **保存场景**
5. **重新运行游戏**

### 建议

**在编辑器中运行主场景**，实际观察：
1. kobold_weak 是否有行走动画
2. 击杀敌人是否有爆炸效果
3. 经验宝石是否正常掉落

如果 kobold_weak 仍然没有动画，请提供：
- 控制台完整输出
- 是否看到 "📽 敌人 enemy_kobold_weak 有 2 帧动画"
- 其他敌人的动画是否正常
