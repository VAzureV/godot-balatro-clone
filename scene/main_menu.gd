extends Control

# 音乐设置面板场景。
const MUSIC_SETTING_SCENE : PackedScene = preload("res://panel/music_setting.tscn")

var music_setting: Control = null

# 功能：初始化主菜单背景音乐，并创建默认隐藏的音乐设置面板。
func _ready() -> void:
	MusicManager.play_music(MusicManager.MusicType.MAIN_MENU)
	music_setting = MUSIC_SETTING_SCENE.instantiate()
	music_setting.visible = false
	add_child(music_setting)

# 功能：处理“开始游戏”按钮点击，当前仅播放点击音效。
func _on_start_button_button_down() -> void:
	MusicManager.play_sfx(MusicManager.SFXType.CLICK)

# 功能：处理“选项”按钮点击，弹出或隐藏音乐设置面板。
func _on_option_button_button_down() -> void:
	MusicManager.play_sfx(MusicManager.SFXType.CLICK)
	if music_setting == null:
		return
	music_setting.visible = not music_setting.visible

# 功能：处理“退出”按钮点击，退出当前游戏。
func _on_exit_button_button_down() -> void:
	get_tree().quit()
