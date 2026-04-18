# MusicManager 使用文档（枚举版）

本项目的 `MusicManager` 负责：
- 背景音乐（BGM）播放与淡入淡出切换
- 音效（SFX）统一播放与自动回收

## 1. 设计目标

- 对外仅暴露枚举：`MusicType`、`SFXType`
- 业务侧不再传字符串 key，避免拼写错误
- 保留可扩展性：后续可接音量设置、Bus、池化

## 2. 枚举定义

建议在 `music_manager.gd` 中定义：

```gdscript
enum MusicType {
	MAIN_MENU,
	BATTLE,
	SHOP,
}

enum SFXType {
	CLICK,
	HOVER,
	DEAL_CARD,
	CHIP_GAIN,
}
```

## 3. 资源配置形式

资源仍使用配置字典，但 key 从 `StringName` 改为枚举值：

```gdscript
@export var music_config: Dictionary = {
	MusicType.MAIN_MENU: preload("res://assets/sounds/music1.ogg"),
	MusicType.BATTLE: preload("res://assets/sounds/music2.ogg"),
}

@export var sfx_config: Dictionary = {
	SFXType.CLICK: preload("res://assets/sounds/click.ogg"),
	SFXType.DEAL_CARD: preload("res://assets/sounds/deal_card.ogg"),
}
```

## 4. 对外 API（枚举）

- `play_music(music_type: MusicType, _fade_time: float = fade_time) -> void`
  - 通过 `MusicType` 查表播放 BGM
  - 自动执行淡入淡出切换
- `play_sfx(sfx_type: SFXType, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void`
  - 通过 `SFXType` 查表播放 SFX
  - 单次音效播放后自动释放节点

## 5. 调用示例

```gdscript
func _ready() -> void:
	MusicManager.play_music(MusicManager.MusicType.MAIN_MENU)

func _on_button_pressed() -> void:
	MusicManager.play_sfx(MusicManager.SFXType.CLICK)
```

## 6. 迁移建议

- 旧调用 `play_music(&"main_menu")` 迁移为 `play_music(MusicType.MAIN_MENU)`
- 旧调用 `play_sfx(&"click")` 迁移为 `play_sfx(SFXType.CLICK)`
- 过渡期可保留字符串接口，内部转发到枚举接口

## 7. 注意事项

- 若枚举未配置对应 `AudioStream`，应输出 warning 并安全返回
- 建议使用统一命名：枚举成员 `UPPER_SNAKE_CASE`
- `music_config` / `sfx_config` 的 value 必须为 `AudioStream`