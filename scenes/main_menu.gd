extends Control

@export var background_music: AudioStream = null

func _ready() -> void:
	MusicManger.playBackgroundMusic(background_music)