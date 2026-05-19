class_name Settings
extends Control

const SETTINGS_PATH := "user://settings.cfg"

const REBINDABLE_ACTIONS: Array[Dictionary] = [
	{"action": "move_left",   "label": "Move Left"},
	{"action": "move_right",  "label": "Move Right"},
	{"action": "soft_drop",   "label": "Soft Drop"},
	{"action": "hard_drop",   "label": "Hard Drop"},
	{"action": "rotate_cw",   "label": "Rotate CW"},
	{"action": "rotate_ccw",  "label": "Rotate CCW"},
	{"action": "rotate_180",  "label": "Rotate 180"},
	{"action": "hold_piece",  "label": "Hold"},
]

@onready var das_slider: HSlider = $Panel/VBox/DASRow/DASSlider
@onready var das_label: Label = $Panel/VBox/DASRow/DASLabel
@onready var das_spinbox: SpinBox = $Panel/VBox/DASRow/DASSpinBox
@onready var arr_slider: HSlider = $Panel/VBox/ARRRow/ARRSlider
@onready var arr_label: Label = $Panel/VBox/ARRRow/ARRLabel
@onready var arr_spinbox: SpinBox = $Panel/VBox/ARRRow/ARRSpinBox
@onready var bindings_container: VBoxContainer = $Panel/VBox/ScrollContainer/BindingsContainer
@onready var rebind_status: Label = $Panel/VBox/RebindStatus
@onready var reset_button: Button = $Panel/VBox/ResetButton
@onready var close_button: Button = $Panel/VBox/CloseButton

var _syncing: bool = false
var _rebinding_action: String = ""
var _rebind_rows: Array[Dictionary] = []  # [{action, key_label, button}]

func _ready() -> void:
	_load_settings()
	das_slider.connect("value_changed", _on_das_changed)
	das_spinbox.connect("value_changed", _on_das_spinbox_changed)
	arr_slider.connect("value_changed", _on_arr_changed)
	arr_spinbox.connect("value_changed", _on_arr_spinbox_changed)
	reset_button.connect("pressed", _on_reset_pressed)
	close_button.connect("pressed", _on_close)
	_load_bindings()
	_build_binding_rows()
	_update_labels()
	set_process_unhandled_input(false)

# ── DAS / ARR sync ────────────────────────────────────────────────────────

func _on_das_changed(_val: float) -> void:
	if not _syncing:
		_syncing = true
		das_spinbox.value = das_slider.value
		_syncing = false
	_update_labels()
	_save_settings()

func _on_das_spinbox_changed(_val: float) -> void:
	if not _syncing:
		_syncing = true
		das_slider.value = das_spinbox.value
		_syncing = false
	_update_labels()
	_save_settings()

func _on_arr_changed(_val: float) -> void:
	if not _syncing:
		_syncing = true
		arr_spinbox.value = arr_slider.value
		_syncing = false
	_update_labels()
	_save_settings()

func _on_arr_spinbox_changed(_val: float) -> void:
	if not _syncing:
		_syncing = true
		arr_slider.value = arr_spinbox.value
		_syncing = false
	_update_labels()
	_save_settings()

func _update_labels() -> void:
	das_label.text = "DAS: %dms" % int(das_slider.value)
	arr_label.text = "ARR: Instant" if arr_slider.value == 0 else "ARR: %dms" % int(arr_slider.value)

# ── Keybinding rows ───────────────────────────────────────────────────────

func _build_binding_rows() -> void:
	for child in bindings_container.get_children():
		child.queue_free()
	_rebind_rows.clear()

	for entry in REBINDABLE_ACTIONS:
		var action: String = entry["action"]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var name_lbl := Label.new()
		name_lbl.text = entry["label"]
		name_lbl.custom_minimum_size = Vector2(120, 0)
		row.add_child(name_lbl)

		var key_lbl := Label.new()
		key_lbl.text = _get_key_name(action)
		key_lbl.custom_minimum_size = Vector2(110, 0)
		key_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(key_lbl)

		var btn := Button.new()
		btn.text = "Rebind"
		btn.connect("pressed", _on_rebind_pressed.bind(action))
		row.add_child(btn)

		bindings_container.add_child(row)
		_rebind_rows.append({"action": action, "key_label": key_lbl, "button": btn})

func _get_key_name(action: String) -> String:
	var events := InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return "Unbound"

func _refresh_all_key_labels() -> void:
	for row in _rebind_rows:
		row["key_label"].text = _get_key_name(row["action"])

# ── Rebind listen mode ────────────────────────────────────────────────────

func _on_rebind_pressed(action: String) -> void:
	_rebinding_action = action
	for row in _rebind_rows:
		row["button"].disabled = true
	rebind_status.text = "Press any key… (Escape to cancel)"
	rebind_status.visible = true
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if _rebinding_action.is_empty():
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	get_viewport().set_input_as_handled()
	var key_event := event as InputEventKey
	if key_event.physical_keycode == KEY_ESCAPE:
		_exit_listen_mode()
		return
	InputMap.action_erase_events(_rebinding_action)
	var new_event := InputEventKey.new()
	new_event.physical_keycode = key_event.physical_keycode
	InputMap.action_add_event(_rebinding_action, new_event)
	_save_bindings()
	_refresh_all_key_labels()
	_exit_listen_mode()

func _exit_listen_mode() -> void:
	_rebinding_action = ""
	rebind_status.visible = false
	set_process_unhandled_input(false)
	for row in _rebind_rows:
		row["button"].disabled = false

# ── Reset to defaults ─────────────────────────────────────────────────────

func _on_reset_pressed() -> void:
	InputMap.load_from_project_settings()
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.erase_section_key("bindings", "")  # erase all entries under [bindings]
	for entry in REBINDABLE_ACTIONS:
		cfg.erase_section_key("bindings", entry["action"])
	cfg.save(SETTINGS_PATH)
	_refresh_all_key_labels()

# ── Settings load / save ──────────────────────────────────────────────────

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		var das: float = cfg.get_value("timing", "das_ms", 167)
		var arr: float = cfg.get_value("timing", "arr_ms", 33)
		das_slider.value = das
		das_spinbox.value = das
		arr_slider.value = arr
		arr_spinbox.value = arr
	else:
		das_slider.value = 167
		das_spinbox.value = 167
		arr_slider.value = 33
		arr_spinbox.value = 33

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("timing", "das_ms", das_slider.value)
	cfg.set_value("timing", "arr_ms", arr_slider.value)
	cfg.save(SETTINGS_PATH)

# ── Bindings load / save ──────────────────────────────────────────────────

func _load_bindings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	for entry in REBINDABLE_ACTIONS:
		var action: String = entry["action"]
		if not cfg.has_section_key("bindings", action):
			continue
		var keycode: int = cfg.get_value("bindings", action, -1)
		if keycode < 0:
			continue
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

func _save_bindings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	for entry in REBINDABLE_ACTIONS:
		var action: String = entry["action"]
		var events := InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				cfg.set_value("bindings", action, (event as InputEventKey).physical_keycode)
				break
	cfg.save(SETTINGS_PATH)

# ── Close ─────────────────────────────────────────────────────────────────

func _on_close() -> void:
	queue_free()

# ── Static startup helpers ────────────────────────────────────────────────

static func apply_saved_bindings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	var actions := [
		"move_left", "move_right", "soft_drop", "hard_drop",
		"rotate_cw", "rotate_ccw", "rotate_180", "hold_piece",
	]
	for action in actions:
		if not cfg.has_section_key("bindings", action):
			continue
		var keycode: int = cfg.get_value("bindings", action, -1)
		if keycode < 0:
			continue
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

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
