extends Node

signal volumes_changed

const SAVE_PATH := "user://local_data.cfg"
const DEFAULT_MASTER_VOLUME_FACTOR := 0.5
const DEFAULT_MUSIC_VOLUME := 0.5
const DEFAULT_SFX_VOLUME := 0.5

var master_volume_factor: float = DEFAULT_MASTER_VOLUME_FACTOR
var music_volume: float = DEFAULT_MUSIC_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME

# 功能：初始化本地数据管理器，并从本地加载已保存的数据。
func _ready() -> void:
	load_data()

# 功能：从本地文件读取数据；若文件不存在则写入默认值。
func load_data() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		save_data()
		volumes_changed.emit()
		return

	master_volume_factor = clampf(float(config.get_value("audio", "master_volume_factor", DEFAULT_MASTER_VOLUME_FACTOR)), 0.0, 1.0)
	music_volume = clampf(float(config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)
	volumes_changed.emit()

# 功能：将当前本地数据写入文件。
func save_data() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume_factor", master_volume_factor)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save(SAVE_PATH)

# 功能：设置总音量因子并保存到本地。
# 传入参数：
# - value: 0.0 到 1.0 的线性因子值，会同时作用于音乐和音效。
func set_master_volume_factor(value: float) -> void:
	master_volume_factor = clampf(value, 0.0, 1.0)
	save_data()
	volumes_changed.emit()

# 功能：设置音乐音量并保存到本地。
# 传入参数：
# - value: 0.0 到 1.0 的线性音量值。
func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	save_data()
	volumes_changed.emit()

# 功能：设置音效音量并保存到本地。
# 传入参数：
# - value: 0.0 到 1.0 的线性音量值。
func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	save_data()
	volumes_changed.emit()

# 功能：清除指定 section 下的某个本地数据项，用于测试缺省值回退逻辑。
# 传入参数：
# - section: 配置分区名，例如 `audio`。
# - key: 配置字段名，例如 `music_volume`。
func clear_data_item(section: String, key: String) -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return

	if not config.has_section_key(section, key):
		return

	config.erase_section_key(section, key)
	config.save(SAVE_PATH)
	load_data()

# 功能：清除整个本地数据文件，用于测试首次启动或无存档场景。
func clear_all_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	load_data()
