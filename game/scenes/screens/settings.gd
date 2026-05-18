class_name Settings
extends Control

@onready var das_slider: HSlider = $Panel/VBox/DASRow/DASSlider
@onready var das_label: Label = $Panel/VBox/DASRow/DASLabel
@onready var arr_slider: HSlider = $Panel/VBox/ARRRow/ARRSlider
@onready var arr_label: Label = $Panel/VBox/ARRRow/ARRLabel
@onready var close_button: Button = $Panel/VBox/CloseButton

const SETTINGS_PATH := "user://settings.cfg"

func _ready() -> void:
	_load_settings()
	das_slider.min_value = 50
	das_slider.max_value = 300
	arr_slider.min_value = 0
	arr_slider.max_value = 100
	das_slider.connect("value_changed", _on_das_changed)
	arr_slider.connect("value_changed", _on_arr_changed)
	close_button.connect("pressed", _on_close)
	_update_labels()

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		das_slider.value = cfg.get_value("timing", "das_ms", 167)
		arr_slider.value = cfg.get_value("timing", "arr_ms", 33)
	else:
		das_slider.value = 167
		arr_slider.value = 33

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("timing", "das_ms", das_slider.value)
	cfg.set_value("timing", "arr_ms", arr_slider.value)
	cfg.save(SETTINGS_PATH)

func _on_das_changed(_val: float) -> void:
	_update_labels()
	_save_settings()

func _on_arr_changed(_val: float) -> void:
	_update_labels()
	_save_settings()

func _update_labels() -> void:
	das_label.text = "DAS: %dms" % int(das_slider.value)
	arr_label.text = "ARR: %dms" % int(arr_slider.value)

func _on_close() -> void:
	queue_free()

static func load_das() -> float:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		return cfg.get_value("timing", "das_ms", 167) / 1000.0
	return 0.167

static func load_arr() -> float:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		return cfg.get_value("timing", "arr_ms", 33) / 1000.0
	return 0.033
