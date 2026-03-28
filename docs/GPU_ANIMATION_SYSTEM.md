# GPU 实例化动画系统

## 概述

本项目完全使用 GPU 实例化渲染敌人，**不使用传统的 AnimationPlayer**。
所有动画通过 **Shader + MultiMesh Color 通道**实现。

## 动画实现原理

### 1. 精灵表（Sprite Sheet）

每个敌人纹理包含多帧动画，例如：
- `kolbold_weak.png`: 4 帧（hframes = 4）
- `cyclops.png`: 2 帧（hframes = 2）

### 2. Shader 动画

使用自定义 Shader 根据 `COLOR.r` 值选择当前帧：

```glsl
shader_type canvas_item;

uniform int hframes = 1;

void fragment() {
    vec2 uv = UV;
    
    // 从 COLOR.r 读取帧索引（范围 0.0 - 1.0）
    float frame_index = COLOR.r;
    int frame = int(frame_index * float(hframes));
    frame = clamp(frame, 0, hframes - 1);
    
    // 计算帧的 UV 偏移
    float frame_width = 1.0 / float(hframes);
    uv.x = (uv.x * frame_width) + (float(frame) * frame_width);
    
    COLOR = texture(TEXTURE, uv);
}
```

### 3. CPU 端动画控制

在 `enemy_instance_manager.gd` 的 `_update_enemy_type()` 中：

```gdscript
# 更新动画时间
inst.anim_time += delta

# 计算当前帧（0.3 秒/帧）
var total_time = inst.anim_time + inst.anim_offset
var current_frame = int(total_time / 0.3) % type_data.hframes

# 归一化到 [0, 1) 范围传给 Shader
var frame_normalized = (float(current_frame) + 0.5) / float(type_data.hframes)

# 设置 MultiMesh 实例颜色
colors.append(Color(frame_normalized, 0, 0, 1))
```

### 4. 动画偏移

每个敌人实例有随机的 `anim_offset`（0-0.6 秒），避免所有敌人同步播放动画。

## 与旧系统对比

| 特性 | 旧系统（实例化） | GPU 系统 |
|------|-----------------|----------|
| 动画方式 | AnimationPlayer | Shader |
| 帧控制 | 节点动画 | MultiMesh Color |
| 性能 | 低（每个敌人一个节点） | 高（批量渲染） |
| 同步 | 自动同步 | 手动偏移 |

## 配置要求

### 敌人场景 (.tscn)

1. **Sprite2D 节点**：
   - `texture`: 精灵表纹理
   - `hframes`: 帧数（必须正确设置）
   - `scale`: 缩放比例

2. **AnimationPlayer 节点**（可选）：
   - GPU 模式下不使用
   - 保留用于编辑器预览

### 配置文件 (enemy_config.ini)

不需要动画相关配置，动画完全由精灵表的 `hframes` 控制。

## 调试

### 检查动画是否播放

1. 运行游戏，观察敌人是否有帧切换
2. 检查控制台输出：
   ```
   📽 敌人 enemy_kobold_weak 有 4 帧动画
   ```
3. 确认 `hframes` 值正确：
   ```gdscript
   print(type_data.hframes)  # 应该 > 1
   ```

### 常见问题

**问题**: 敌人只显示第一帧
**原因**: 
- `hframes` 未正确读取（检查场景文件）
- Shader 未正确应用（检查 Material）

**解决**: 
- 确保 `Sprite2D.hframes` 在场景中正确设置
- 确认 `_get_sprite_sheet_material()` 被调用

## 性能

- **批量渲染**: 所有同类型敌人一次 Draw Call
- **无节点开销**: 不创建 AnimationPlayer 节点
- **帧计算**: CPU 端简单算术，开销极小

## 总结

GPU 实例化动画系统完全替代了传统的 AnimationPlayer，实现了：
- ✓ 多帧动画播放
- ✓ 随机偏移避免同步
- ✓ 极高性能（500+ 敌人流畅）
- ✓ 简洁的代码结构
