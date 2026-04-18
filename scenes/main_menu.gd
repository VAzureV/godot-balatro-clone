extends Control

func _ready() -> void:
	MusicManager.play_music(MusicManager.MusicType.MAIN_MENU)

func _on_start_button_button_down() -> void:
	MusicManager.play_sfx(MusicManager.SFXType.CLICK)
