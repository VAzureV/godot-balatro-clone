# MusicManager 使用文档

`MusicManager` 负责统一管理项目中的背景音乐和音效播放。当前版本采用枚举 + 配置字典的形式管理音频资源，并与 `LocalDataManager` 联动处理本地音量设置。

## 1. 模块职责

- 播放背景音乐
- 播放一次性音效
- 处理背景音乐淡入淡出切换
- 根据本地音量配置实时计算播放音量

## 2. 当前枚举定义

当前版本的枚举如下：

```gdscript
enum MusicType {
	MAIN_MENU,
}

enum SFXType {
	CLICK,
}
```

后续新增音乐或音效时，建议先补充对应枚举，再补配置表。

## 3. 资源配置形式

当前使用字典将枚举映射到音频资源：

```gdscript
@export var music_config: Dictionary = {
	MusicType.MAIN_MENU: preload("res://asset/sounds/music1.ogg"),
}

@export var sfx_config: Dictionary = {
	SFXType.CLICK: preload("res://asset/sounds/button.ogg"),
}
```

说明：

- key 为枚举值
- value 必须为 `AudioStream`
- 若未配置对应资源，播放时会输出 warning 并安全返回

## 4. 音量计算方式

`MusicManager` 不直接持久化音量数据，而是从 `LocalDataManager` 读取当前配置。

当前计算方式：

- 背景音乐音量 = `LocalDataManager.master_volume_factor * LocalDataManager.music_volume`
- 音效音量 = `LocalDataManager.master_volume_factor * LocalDataManager.sfx_volume`

再通过 `linear_to_db()` 转换为 Godot 实际播放使用的 dB 值。

## 5. 对外接口

### 播放背景音乐

- `play_music(music_type: MusicType, _fade_time: float = fade_time) -> void`

作用：

- 按 `MusicType` 查找背景音乐资源
- 若当前没有播放中的音乐，直接播放
- 若已有背景音乐，执行淡出旧音乐、淡入新音乐

### 播放音效

- `play_sfx(sfx_type: SFXType) -> void`

作用：

- 按 `SFXType` 查找音效资源
- 创建临时 `AudioStreamPlayer`
- 播放结束后自动释放节点

## 6. 调用示例

播放主菜单背景音乐：

```gdscript
func _ready() -> void:
	MusicManager.play_music(MusicManager.MusicType.MAIN_MENU)
```

播放按钮点击音效：

```gdscript
func _on_button_down() -> void:
	MusicManager.play_sfx(MusicManager.SFXType.CLICK)
```

## 7. 与 LocalDataManager 的关系

- `MusicManager` 在 `_ready()` 中连接 `LocalDataManager.volumes_changed`
- 当本地音量设置变化时，会刷新当前背景音乐音量
- 后续新播放的音效，也会按最新音量配置计算

因此：

- `MusicManager` 负责播放逻辑
- `LocalDataManager` 负责本地存储
- `music_setting` 负责界面输入

## 8. 扩展建议

后续如果需要扩展音频系统，建议按下面顺序进行：

- 新增枚举成员
- 在 `music_config` / `sfx_config` 中补资源映射
- 在对应界面或逻辑中调用 `play_music()` / `play_sfx()`
- 同步更新本说明文档
