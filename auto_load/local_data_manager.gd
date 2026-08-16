extends Node

const SAVE_PATH := "user://local_data.cfg"
const DEFAULT_MASTER_VOLUME_FACTOR := 0.5
const DEFAULT_MUSIC_VOLUME := 0.5
const DEFAULT_SFX_VOLUME := 0.5

# 功能：初始化本地数据管理器，并从本地加载已保存的数据。
func _ready() -> void:
	load_data()

# 功能：从本地文件中读取指定 section 和 key 对应的数据。
# 传入参数：
# - section: 配置分区名。
# - key: 配置字段名。
# - default_value: 配置缺失时使用的默认值。
# 返回值：
# - 对应的本地配置值；若不存在则返回默认值。
func get_local_data(section: String, key: String, default_value: Variant = null) -> Variant:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return default_value

	return config.get_value(section, key, default_value)

# 功能：将指定 section 和 key 对应的数据写入本地文件，不影响其他字段。
# 传入参数：
# - section: 配置分区名。
# - key: 配置字段名。
# - value: 需要写入的本地配置值。
func set_local_data(section: String, key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	config.set_value(section, key, value)
	config.save(SAVE_PATH)

# 功能：从本地文件读取数据；若文件不存在则写入默认值。
func load_data() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		save_data()

# 功能：将默认本地数据整批写入文件，主要用于初始化默认配置。
func save_data() -> void:
	var config := ConfigFile.new()
	config.set_value(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MASTER_VOLUME_FACTOR, DEFAULT_MASTER_VOLUME_FACTOR)
	config.set_value(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MUSIC_VOLUME, DEFAULT_MUSIC_VOLUME)
	config.set_value(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_SFX_VOLUME, DEFAULT_SFX_VOLUME)
	config.save(SAVE_PATH)

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

# 功能：清除整个本地数据文件，用于测试首次启动或无存档场景。
func clear_all_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
