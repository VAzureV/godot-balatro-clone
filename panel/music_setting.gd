extends Control

@onready var total_vol_hslider: HSlider = $PanelContainer/VBoxContainer/MarginContainer/GridContainer/TotalVolHSlider
@onready var music_vol_hslider: HSlider = $PanelContainer/VBoxContainer/MarginContainer/GridContainer/MusicVolHSlider
@onready var sfxvol_hslider: HSlider = $PanelContainer/VBoxContainer/MarginContainer/GridContainer/SFXVolHSlider

# 功能：初始化音乐设置界面的滑条数值，界面范围与本地存储统一使用 0.0 到 1.0。
func _ready() -> void:
	total_vol_hslider.set_value_no_signal(float(LocalDataManager.get_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MASTER_VOLUME_FACTOR, 0.5)))
	music_vol_hslider.set_value_no_signal(float(LocalDataManager.get_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MUSIC_VOLUME, 0.5)))
	sfxvol_hslider.set_value_no_signal(float(LocalDataManager.get_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_SFX_VOLUME, 0.5)))

# 功能：当音效音量滑条变化时，保存音效音量。
# 传入参数：
# - value: 0.0 到 1.0 的线性音量值。
func _on_sfx_vol_h_slider_value_changed(value: float) -> void:
	LocalDataManager.set_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_SFX_VOLUME, value)

# 功能：当音乐音量滑条变化时，保存音乐音量。
# 传入参数：
# - value: 0.0 到 1.0 的线性音量值。
func _on_music_vol_h_slider_value_changed(value: float) -> void:
	LocalDataManager.set_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MUSIC_VOLUME, value)
	MusicManager.refresh_music_volume()

# 功能：当总音量滑条变化时，保存总音量因子。
# 传入参数：
# - value: 0.0 到 1.0 的线性音量值。
func _on_total_vol_h_slider_value_changed(value: float) -> void:
	LocalDataManager.set_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MASTER_VOLUME_FACTOR, value)
	MusicManager.refresh_music_volume()

# 功能：点击关闭按钮后隐藏当前音乐设置界面。
func _on_close_button_pressed() -> void:
	visible = false
