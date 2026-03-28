# GPU 实例化优化文档

## 问题分析

### 性能瓶颈

**测试场景**：500 个敌人（每种 100 个）

**普通对象池方案**：
- FPS: **7.6**（严重卡顿）
- 帧时间: ~130 ms
- 内存: 203.8 MB

**问题根源**：
1. 每个敌人是独立的 `CharacterBody2D` 节点
2. 包含完整的子节点树：Sprite2D、CollisionShape2D、AnimationPlayer、AudioStreamPlayer2D、HurtBox、HitBox
3. 每帧需要处理 500 个节点的物理、渲染、动画
4. CPU 成为瓶颈（单线程处理所有节点）

## 解决方案：GPU 实例化

### 架构设计

#### 1. 数据驱动的敌人系统

**逻辑层**（CPU）：
```gdscript
class EnemyInstance:
    var position: Vector2
    var velocity: Vector2
    var hp: float
    var knockback: Vector2
    var active: bool
```

**渲染层**（GPU）：
```gdscript
MultiMeshInstance2D + MultiMesh
- 一个 MultiMesh 渲染同类型的所有敌人
- GPU 并行处理渲染
```

#### 2. 系统组件

**EnemyInstanceManager** (`Utility/enemy_instance_manager.gd`):
- 管理所有敌人实例的逻辑数据
- 为每种敌人类型创建 MultiMesh
- 每帧更新敌人位置和状态
- 批量更新 MultiMesh Transform

### 实现细节

#### MultiMesh 创建

```gdscript
var multimesh_instance = MultiMeshInstance2D.new()
var multimesh = MultiMesh.new()

# 使用 QuadMesh 作为基础网格
var quad = QuadMesh.new()
quad.size = texture.get_size() * 0.75

multimesh.mesh = quad
multimesh.transform_format = MultiMesh.TRANSFORM_2D
multimesh.instance_count = 100  # 动态调整

multimesh_instance.multimesh = multimesh
multimesh_instance.texture = enemy_texture
```

#### 敌人生成

```gdscript
func spawn_enemy(enemy_type: String, pos: Vector2):
    var instance = EnemyInstance.new(pos, enemy_type, hp)
    type_data.instances.append(instance)
    
    # 更新 MultiMesh 实例数量
    multimesh.instance_count = active_enemies.size()
```

#### 每帧更新

```gdscript
func _physics_process(delta):
    for enemy_type in enemy_types:
        var active_index = 0
        
        for inst in type_data.instances:
            if not inst.active:
                continue
            
            # 更新逻辑（CPU）
            inst.position += inst.velocity * delta
            
            # 更新渲染（GPU）
            var transform = Transform2D().translated(inst.position)
            multimesh.set_instance_transform_2d(active_index, transform)
            
            active_index += 1
```

## 性能对比

### 测试结果

| 方案 | FPS | 帧时间 | 内存 | CPU 使用 | GPU 使用 |
|------|-----|--------|------|----------|----------|
| 普通对象池 | 7.6 | 130 ms | 203 MB | 95% | 5% |
| GPU 实例化 | 预期 150+ | <7 ms | 预期 100 MB | 预期 20% | 预期 30% |

**性能提升**：预期 **20-40 倍**

### 优势

1. **批量渲染**：GPU 并行处理，不受敌人数量线性影响
2. **内存优化**：共享网格和纹理，减少内存占用
3. **CPU 释放**：减少节点树遍历和更新
4. **可扩展性**：支持数千个敌人同时存在

### 局限性

1. **动画限制**：MultiMesh 不支持独立动画（可用 Sprite Sheet + UV 偏移模拟）
2. **碰撞简化**：需要自定义碰撞检测（空间分区）
3. **音效处理**：需要音效池化和距离衰减
4. **调试困难**：无法在编辑器中直接查看单个实例

## 运行测试

### 普通对象池测试

```powershell
F:\project\godot\Godot_v4.6.1-stable_win64.exe tests/performance_test.tscn
```

**观察**：
- 左上角 FPS（预期 7-15）
- 敌人移动是否流畅
- 按 ESC 查看统计

### GPU 实例化测试

```powershell
F:\project\godot\Godot_v4.6.1-stable_win64.exe tests/performance_test_gpu.tscn
```

**观察**：
- 左上角 FPS（预期 100-300）
- 渲染是否流畅
- 按 ESC 查看统计

### 对比测试说明

```powershell
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --script tests/benchmark_comparison.gd
```

## 实现路线图

### 阶段 1: 基础 MultiMesh 渲染 ✅
- [x] 创建 EnemyInstanceManager
- [x] 实现基础 MultiMesh 渲染
- [x] 创建 GPU 测试场景

### 阶段 2: 完整功能集成（待实现）
- [ ] 自定义碰撞检测（空间哈希）
- [ ] Sprite Sheet 动画支持
- [ ] 音效池化和距离衰减
- [ ] 伤害数字显示优化

### 阶段 3: 游戏集成（待实现）
- [ ] 将 GPU 实例化集成到主游戏
- [ ] 配置开关（GPU vs 普通模式）
- [ ] 性能自适应调整

## 技术细节

### MultiMesh 优势

1. **单次绘制调用**：所有同类型敌人一次 Draw Call
2. **GPU 并行**：Transform 计算在 GPU 并行执行
3. **内存共享**：所有实例共享同一个 Mesh 和 Texture

### 数据局部性

```gdscript
# 紧凑的数据结构
class EnemyInstance:
    var position: Vector2      # 8 bytes
    var velocity: Vector2      # 8 bytes
    var hp: float              # 4 bytes
    var knockback: Vector2     # 8 bytes
    # 总计: 28 bytes/敌人
```

vs

```gdscript
# 完整节点
CharacterBody2D
├─ Sprite2D
├─ CollisionShape2D
├─ AnimationPlayer
├─ HurtBox (Area2D + CollisionShape2D)
├─ HitBox (Area2D + CollisionShape2D)
└─ AudioStreamPlayer2D
# 总计: ~2-5 KB/敌人
```

**内存节省**：约 **100 倍**

## 未来优化

### 1. 动画支持

使用 Sprite Sheet + UV 动画：
```gdscript
# 在 shader 中实现帧动画
var frame_offset = Vector2(frame_x, frame_y) / atlas_size
multimesh.set_instance_custom_data(i, Color(frame_offset.x, frame_offset.y, 0, 0))
```

### 2. 空间分区

使用四叉树或空间哈希：
```gdscript
var spatial_hash = {}
for enemy in enemies:
    var cell = get_cell(enemy.position)
    spatial_hash[cell].append(enemy)
```

### 3. 计算着色器

使用 Compute Shader 在 GPU 上计算敌人移动：
```glsl
// 在 GPU 上并行计算所有敌人的位置
void compute() {
    vec2 direction = normalize(player_pos - enemy_pos);
    enemy_pos += direction * speed * delta;
}
```

## 参考资料

- [Godot MultiMesh 文档](https://docs.godotengine.org/en/stable/classes/class_multimesh.html)
- [GPU 实例化最佳实践](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html)
- [大规模实体优化](https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html)
