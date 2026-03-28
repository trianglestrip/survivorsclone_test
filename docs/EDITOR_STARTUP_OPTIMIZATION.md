# 编辑器启动优化指南

## 当前问题

编辑器启动需要几分钟，主要原因：

### 1. Autoload 同步初始化

7 个 Autoload 单例在启动时同步执行：
- `EventBus` - 事件总线
- `ConfigManager` - 配置管理
- `SkillRegistry` - 技能注册（加载配置 + 场景）
- `EnemyRegistry` - 敌人注册（加载配置 + 场景）
- `ObjectPool` - 对象池
- `UpgradeDb` - 升级数据库（加载配置）
- `AudioManager` - 音频管理

每个都会：
- 读取 INI 配置文件
- 加载 PackedScene 资源
- 打印调试日志

### 2. 资源导入

Godot 启动时需要：
- 扫描所有资源文件（42 个 .import 文件）
- 检查是否需要重新导入
- 编译所有 GDScript

## 优化方案

### 方案 1: 延迟加载（推荐）

将 Autoload 改为延迟初始化：

```gdscript
# enemy_registry.gd
var _initialized := false

func _ready():
    # 不在这里加载，等待首次使用时加载
    pass

func ensure_initialized():
    if not _initialized:
        _load_enemies_from_config()
        _initialized = true

func get_enemy_scene(enemy_id: String) -> PackedScene:
    ensure_initialized()  # 首次调用时才加载
    return registered_enemies.get(enemy_id, {}).get("scene")
```

**优势**：
- 编辑器启动快（不加载配置）
- 游戏运行时才加载（首次使用时）
- 代码改动最小

### 方案 2: 禁用调试日志

在 Autoload 中添加调试开关：

```gdscript
# enemy_registry.gd
const DEBUG_LOGGING := false  # 编辑器模式下关闭日志

func _load_enemies_from_config():
    if DEBUG_LOGGING:
        print("\n=== 加载敌人注册配置 ===")
```

**优势**：
- 减少控制台输出
- 保持同步加载
- 简单快速

### 方案 3: 异步加载

使用 `ResourceLoader.load_threaded_request()` 异步加载资源：

```gdscript
func _load_enemies_async():
    for enemy_id in enemy_configs:
        var path = enemy_configs[enemy_id]["scene_path"]
        ResourceLoader.load_threaded_request(path)
    
    # 等待加载完成
    for enemy_id in enemy_configs:
        var path = enemy_configs[enemy_id]["scene_path"]
        while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            await get_tree().process_frame
        var scene = ResourceLoader.load_threaded_get(path)
```

**优势**：
- 真正的异步加载
- 不阻塞主线程
- 适合大量资源

### 方案 4: 缓存资源

使用 `.tres` 资源文件预先缓存配置：

```gdscript
# 创建 enemy_registry.tres
@tool
extends Resource
class_name EnemyRegistryData

@export var enemies: Dictionary = {}
```

**优势**：
- 最快的加载速度
- 二进制格式
- 编辑器友好

## 推荐实施顺序

### 第一步：禁用调试日志（立即见效）

修改所有 Autoload 的 `_ready()` 函数：

```gdscript
const DEBUG_LOGGING := OS.has_feature("editor") == false

func _load_config():
    if DEBUG_LOGGING:
        print("=== 加载配置 ===")
```

**预期效果**：编辑器启动时间减少 30-50%

### 第二步：延迟加载非关键 Autoload

将 `ObjectPool` 和 `AudioManager` 改为延迟初始化：

```gdscript
# object_pool.gd
var _pools := {}
var _initialized := false

func _ready():
    # 不做任何事
    pass

func get_object(pool_name: String, scene: PackedScene):
    if not _initialized:
        _initialized = true
    # ... 正常逻辑
```

**预期效果**：再减少 10-20%

### 第三步：异步加载场景（可选）

如果还是慢，将 `EnemyRegistry` 和 `SkillRegistry` 改为异步加载。

## 快速修复（立即实施）

只需修改 3 个文件，添加调试开关：

1. `Utility/enemy_registry.gd` - 第 49 行
2. `Utility/skill_registry.gd` - 第 46 行  
3. `Utility/upgrade_db.gd` - 第 11 行

将所有 `print()` 包裹在 `if DEBUG_LOGGING:` 中。

## 测量启动时间

使用 Godot 的性能监视器：
```
调试 -> 性能监视器 -> Time -> Process
```

或在控制台查看：
```
Godot Engine v4.6.1 启动
... (各种初始化日志)
编辑器就绪 <- 查看这个时间戳
```

## 其他优化

### 减少 Autoload 数量

考虑合并相关的 Autoload：
- `SkillRegistry` + `EnemyRegistry` -> `GameRegistry`
- `ConfigManager` 可能不需要（直接用 `ConfigFile`）

### 使用 EditorPlugin

如果某些功能只在编辑器中使用，改为 EditorPlugin 而不是 Autoload。

### .godot 缓存

定期清理 `.godot/` 文件夹可以解决一些缓存导致的慢启动：
```bash
# 关闭编辑器后
rm -rf .godot/
# 重新打开编辑器
```

## 预期结果

实施快速修复后：
- 编辑器启动时间：从 2-3 分钟 -> 30-60 秒
- 控制台输出：从 100+ 行 -> 10 行以内
- 游戏运行：无影响（首次使用时才加载）
