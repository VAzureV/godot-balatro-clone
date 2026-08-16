# LocalDataManager 使用文档

`LocalDataManager` 用于管理项目中需要本地持久化的数据。当前已接入的内容只有音量设置，但后续可以继续扩展到分辨率、语言、按键配置等本地数据。

## 1. 模块职责

- 负责读取本地存档配置
- 负责保存本地配置到磁盘
- 对外提供统一的数据读写接口
- 不负责运行时状态同步，只处理本地数据存取

## 2. 当前管理的数据

当前版本管理以下 3 个音量字段：

- `master_volume_factor`
  - 总音量因子
  - 取值范围 `0.0 ~ 1.0`
  - 会同时乘在音乐和音效音量上
- `music_volume`
  - 音乐音量
  - 取值范围 `0.0 ~ 1.0`
- `sfx_volume`
  - 音效音量
  - 取值范围 `0.0 ~ 1.0`

实际播放时的音量计算方式：

- 音乐实际音量 = `master_volume_factor * music_volume`
- 音效实际音量 = `master_volume_factor * sfx_volume`

## 3. 存储位置

- 本地文件路径：`user://local_data.cfg`
- 当前使用 `ConfigFile` 存储
- `section` 与 `key` 常量统一定义在 `auto_load/local_data_keys.gd`

示例内容：

```ini
[audio]
master_volume_factor=1.0
music_volume=1.0
sfx_volume=1.0
```

## 4. 对外接口

### 初始化与存取

- `load_data()`
  - 从本地文件读取配置
  - 文件不存在时自动写入默认值
- `get_local_data(section: String, key: String, default_value: Variant = null)`
  - 读取指定 section 和 key 对应的本地数据
- `set_local_data(section: String, key: String, value: Variant)`
  - 写入指定 section 和 key 对应的本地数据
- `save_data()`
  - 将默认本地配置整批写入文件
  - 主要用于首次创建默认配置或需要整份重建本地文件的场景
- `clear_data_item(section: String, key: String)`
  - 清除指定 section 下的某个配置项
  - 常用于测试字段缺失时的默认值回退逻辑
- `clear_all_data()`
  - 清除整个本地数据文件
  - 常用于测试首次启动或无本地存档场景

### 常量表

- `LocalDataKeys`
  - 统一管理本地存储中用到的 `section` 与 `key`
  - 用于避免在 `LocalDataManager` 中散落硬编码字符串
  - 当前已定义：
    - `SECTION_AUDIO`
    - `KEY_MASTER_VOLUME_FACTOR`
    - `KEY_MUSIC_VOLUME`
    - `KEY_SFX_VOLUME`

### 公共存取方法

- `get_local_data(section, key, default_value)`
  - 通用读取入口
- `set_local_data(section, key, value)`
  - 通用写入入口

## 5. 当前接入关系

### 与 `MusicManager` 的关系

- `MusicManager` 通过 `LocalDataManager` 读取当前音量配置
- 当界面修改本地音量配置后，`MusicManager` 再主动刷新当前背景音乐音量
- 播放新的音效时，也会按最新配置计算音量

### 与 `music_setting` 面板的关系

- `music_setting.gd` 在 `_ready()` 时读取 `LocalDataManager` 中的数据初始化滑条
- 用户拖动滑条后，通过 `LocalDataManager` 保存配置
- 当前界面滑条范围与本地存储统一使用 `0.0 ~ 1.0`，不再做百分比换算

## 6. 使用示例

设置音乐音量：

```gdscript
LocalDataManager.set_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MUSIC_VOLUME, 0.8)
```

设置总音量因子：

```gdscript
LocalDataManager.set_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MASTER_VOLUME_FACTOR, 0.6)
```

读取当前音效音量：

```gdscript
var current_sfx_volume := LocalDataManager.get_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_SFX_VOLUME, 0.5)
```

直接读取本地配置：

```gdscript
var music_volume := LocalDataManager.get_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MUSIC_VOLUME, 0.5)
```

直接写入本地配置：

```gdscript
LocalDataManager.set_local_data(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MASTER_VOLUME_FACTOR, 0.6)
```

清除指定字段：

```gdscript
LocalDataManager.clear_data_item(LocalDataKeys.SECTION_AUDIO, LocalDataKeys.KEY_MUSIC_VOLUME)
```

清除全部本地数据：

```gdscript
LocalDataManager.clear_all_data()
```

## 7. 后续扩展建议

后续如果需要扩展本地数据，建议继续放在 `LocalDataManager` 中统一管理，例如：

- 显示设置：分辨率、窗口模式、垂直同步
- 语言设置：当前语言、字体方案
- 输入设置：按键映射、手柄映射
- 游戏设置：动画速度、震动开关、辅助选项

建议按分类写入不同 section，例如：

- `[audio]`
- `[display]`
- `[input]`
- `[gameplay]`
