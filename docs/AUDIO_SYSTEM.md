# 音频系统说明

**日期**: 2026-03-28  
**提交**: ae1a0dd  
**状态**: ✅ 已实现

---

## 功能概述

游戏现在支持声音开关控制，默认声音关闭，玩家可以在开始菜单中手动开启。

---

## 实现细节

### AudioManager (Autoload)

**路径**: `Utility/audio_manager.gd`

```gdscript
extends Node

var sound_enabled = false  # 默认关闭

func toggle_sound() -> bool:
    sound_enabled = !sound_enabled
    _apply_sound_settings()
    return sound_enabled

func set_sound_enabled(enabled: bool):
    sound_enabled = enabled
    _apply_sound_settings()

func _apply_sound_settings():
    var master_bus_idx = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_mute(master_bus_idx, !sound_enabled)
```

**核心功能**:
- 管理全局声音状态
- 控制 Master 音频总线的静音
- 提供切换和设置方法

### 菜单集成

**路径**: `TitleScreen/menu.gd`

```gdscript
@onready var btn_sound = $btn_sound

func _ready():
    _update_sound_button()

func _on_btn_sound_click_end():
    AudioManager.toggle_sound()
    _update_sound_button()

func _update_sound_button():
    if AudioManager.is_sound_enabled():
        btn_sound.text = "声音：开"
    else:
        btn_sound.text = "声音：关"
```

**UI 布局**:
```
┌─────────────────┐
│   剑客无敌      │
│                 │
│   [ 开始 ]      │  ← 250px
│   [ 声音：关 ]  │  ← 290px (新增)
│   [ 退出 ]      │  ← 330px (下移)
└─────────────────┘
```

---

## 使用方式

### 玩家视角

1. 启动游戏，进入开始菜单
2. 默认显示 "声音：关"
3. 点击按钮切换为 "声音：开"
4. 再次点击切换回 "声音：关"
5. 设置会在游戏运行期间保持

### 开发者视角

```gdscript
# 在任何脚本中使用
AudioManager.toggle_sound()  # 切换
AudioManager.set_sound_enabled(true)  # 开启
AudioManager.set_sound_enabled(false)  # 关闭
var is_on = AudioManager.is_sound_enabled()  # 查询
```

---

## 技术实现

### 音频总线控制

Godot 的音频系统使用总线（Bus）架构：

```
Master (主总线)
├── Music (音乐)
├── SFX (音效)
└── Voice (语音)
```

通过静音 Master 总线，可以一次性关闭所有声音：

```gdscript
var master_bus_idx = AudioServer.get_bus_index("Master")
AudioServer.set_bus_mute(master_bus_idx, true)  # 静音
AudioServer.set_bus_mute(master_bus_idx, false)  # 取消静音
```

### 状态管理

- **全局单例**: AudioManager 作为 Autoload，在整个游戏中可访问
- **持久状态**: `sound_enabled` 变量在游戏运行期间保持
- **即时生效**: 调用 `AudioServer.set_bus_mute()` 立即生效

---

## 默认关闭的原因

1. **用户体验** - 避免突然的声音惊扰用户
2. **可访问性** - 让用户主动选择是否开启声音
3. **测试友好** - 开发和测试时默认静音更方便
4. **最佳实践** - 现代游戏通常让用户控制音频

---

## 未来扩展

### 可以添加的功能

1. **音量控制**
```gdscript
func set_master_volume(volume: float):  # 0.0 - 1.0
    var master_bus_idx = AudioServer.get_bus_index("Master")
    var db = linear_to_db(volume)
    AudioServer.set_bus_volume_db(master_bus_idx, db)
```

2. **分离音乐和音效**
```gdscript
var music_enabled = true
var sfx_enabled = true

func toggle_music():
    music_enabled = !music_enabled
    var music_bus_idx = AudioServer.get_bus_index("Music")
    AudioServer.set_bus_mute(music_bus_idx, !music_enabled)

func toggle_sfx():
    sfx_enabled = !sfx_enabled
    var sfx_bus_idx = AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_mute(sfx_bus_idx, !sfx_enabled)
```

3. **保存设置**
```gdscript
func save_settings():
    var config = ConfigFile.new()
    config.set_value("audio", "sound_enabled", sound_enabled)
    config.save("user://audio_settings.cfg")

func load_settings():
    var config = ConfigFile.new()
    if config.load("user://audio_settings.cfg") == OK:
        sound_enabled = config.get_value("audio", "sound_enabled", false)
        _apply_sound_settings()
```

4. **设置菜单**
```
音频设置
├── 主音量: [======----] 60%
├── 音乐音量: [========--] 80%
├── 音效音量: [=====-----] 50%
└── 静音: [ ] 开启
```

---

## 测试

### 手动测试清单

- [x] 游戏启动，菜单显示 "声音：关"
- [x] 点击按钮，切换为 "声音：开"
- [x] 再次点击，切换回 "声音：关"
- [ ] 开启声音后进入游戏，验证音效播放
- [ ] 关闭声音后进入游戏，验证音效静音

### 测试命令

```powershell
# 运行游戏测试声音功能
F:\project\godot\Godot_v4.6.1-stable_win64.exe --path .
```

---

## 相关文件

| 文件 | 用途 |
|------|------|
| `Utility/audio_manager.gd` | 音频管理器单例 |
| `TitleScreen/menu.gd` | 菜单逻辑（声音按钮） |
| `TitleScreen/menu.tscn` | 菜单场景（UI 布局） |
| `project.godot` | Autoload 注册 |

---

## API 参考

### AudioManager

#### 属性
- `sound_enabled: bool` - 当前声音状态（只读，使用方法修改）

#### 方法
- `toggle_sound() -> bool` - 切换声音状态，返回新状态
- `set_sound_enabled(enabled: bool)` - 设置声音状态
- `is_sound_enabled() -> bool` - 查询当前声音状态

#### 示例

```gdscript
# 切换声音
if AudioManager.toggle_sound():
    print("声音已开启")
else:
    print("声音已关闭")

# 强制开启
AudioManager.set_sound_enabled(true)

# 查询状态
if AudioManager.is_sound_enabled():
    play_sound_effect()
```

---

## 总结

✅ **声音默认关闭**  
✅ **菜单中可切换**  
✅ **状态清晰显示**  
✅ **全局生效**  
✅ **易于扩展**

这是一个简单但完整的音频控制系统，为未来的音频功能（音量控制、分离音乐/音效等）奠定了基础。
