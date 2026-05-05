extends Node2D

enum MusicType {
	MAIN_MENU,
}

enum SFXType {
	CLICK,
}

@export var fade_time: float = 0.3
@export var default_music_volume_db: float = -18.0
@export var default_sfx_volume_db: float = -8.0

@export var music_config: Dictionary = {
	MusicType.MAIN_MENU: preload("res://asset/sounds/music1.ogg"),
}
@export var sfx_config: Dictionary = {
	SFXType.CLICK: preload("res://asset/sounds/button.ogg"),
}

@onready var current_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	current_player.volume_db = default_music_volume_db

# 功能：根据 MusicType 播放背景音乐；有正在播放的音乐时执行淡入淡出切换。
# 传入参数：
# - music_type: 背景音乐枚举类型，用于从 music_config 中查找资源。
# - _fade_time: 淡入淡出时长（秒），小于等于 0 时直接切换。
# 返回值：无。
func play_music(music_type: MusicType, _fade_time: float = fade_time) -> void:
	if not music_config.has(music_type):
		push_warning("MusicManager: music_config 未配置 music_type=%s" % [music_type])
		return

	var new_song := music_config[music_type] as AudioStream
	if new_song == null:
		push_warning("MusicManager: music_config[music_type] 不是 AudioStream")
		return

	if current_player.stream == null or not current_player.playing or _fade_time <= 0.0:
		current_player.stream = new_song
		current_player.volume_db = default_music_volume_db
		current_player.play()
		return

	var new_player := AudioStreamPlayer.new()
	new_player.stream = new_song
	new_player.volume_db = linear_to_db(0.1)
	add_child(new_player)
	new_player.play()
	new_player.seek(current_player.get_playback_position())

	var target_volume := current_player.volume_db
	var tween := create_tween()
	tween.tween_property(current_player, "volume_db", linear_to_db(0.0), _fade_time)
	tween.parallel().tween_property(new_player, "volume_db", target_volume, _fade_time)
	await tween.finished

	current_player.queue_free()
	current_player = new_player

# 功能：根据 SFXType 播放一次性音效，播放结束后自动释放播放器节点。
# 传入参数：
# - sfx_type: 音效枚举类型，用于从 sfx_config 中查找资源。
# 返回值：无。
func play_sfx(sfx_type: SFXType) -> void:
	if not sfx_config.has(sfx_type):
		push_warning("MusicManager: sfx_config 未配置 sfx_type=%s" % [sfx_type])
		return

	var stream := sfx_config[sfx_type] as AudioStream
	if stream == null:
		push_warning("MusicManager: sfx_config[sfx_type] 不是 AudioStream")
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.volume_db = default_sfx_volume_db
	add_child(sfx_player)
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()
