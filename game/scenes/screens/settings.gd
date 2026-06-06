class_name Settings
extends Control

const SETTINGS_PATH := "user://settings.cfg"

const DAS_PRESETS = [80, 90, 100, 110, 120, 130, 140, 150, 160]
const ARR_PRESETS = [20, 30, 40, 50]
const SDF_PRESETS = [5, 10, 15, 20]

const WINDOW_SIZE_LABELS := ["Small", "Medium", "Large"]
const WINDOW_SIZE_PRESETS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

const REBINDABLE_ACTIONS: Array[Dictionary] = [
	{"action": "move_left",   "label": "Move Left"},
	{"action": "move_right",  "label": "Move Right"},
	{"action": "soft_drop",   "label": "Soft Drop"},
	{"action": "hard_drop",   "label": "Hard Drop"},
	{"action": "rotate_cw",   "label": "Rotate CW"},
	{"action": "rotate_ccw",  "label": "Rotate CCW"},
	{"action": "rotate_180",  "label": "Rotate 180"},
	{"action": "hold_piece",  "label": "Hold"},
	{"action": "pause",       "label": "Pause / Settings"},
]

@onready var das_buttons: HBoxContainer = $Panel/VBox/DASRow/DASButtons
@onready var arr_buttons: HBoxContainer = $Panel/VBox/ARRRow/ARRButtons
@onready var sdf_buttons: HBoxContainer = $Panel/VBox/SDFRow/SDFButtons
@onready var bindings_container: VBoxContainer = $Panel/VBox/ScrollContainer/BindingsContainer
@onready var rebind_status: Label = $Panel/VBox/RebindStatus
@onready var reset_button: Button = $Panel/VBox/ResetButton
@onready var close_button: Button = $Panel/VBox/CloseButton
@onready var window_mode_buttons: HBoxContainer = $Panel/VBox/WindowModeRow/WindowModeButtons
@onready var window_size_row: HBoxContainer = $Panel/VBox/WindowSizeRow
@onready var window_size_buttons: HBoxContainer = $Panel/VBox/WindowSizeRow/WindowSizeButtons

var _das_value: int = 130
var _arr_value: int = 40
var _sdf_value: int = 10
var _window_mode: String = "windowed"
var _window_size: Vector2i = Vector2i(1600, 900)
var _rebinding_action: String = ""
var _rebind_rows: Array[Dictionary] = []

func _ready() -> void:
	_build_preset_buttons(das_buttons, DAS_PRESETS, "%dms", _on_das_preset)
	_build_preset_buttons(arr_buttons, ARR_PRESETS, "%dms", _on_arr_preset)
	_build_preset_buttons(sdf_buttons, SDF_PRESETS, "%dx", _on_sdf_preset)
	_build_window_mode_buttons()
	_build_window_size_buttons()
	_load_settings()
	reset_button.connect("pressed", _on_reset_pressed)
	close_button.connect("pressed", _on_close)
	_load_bindings()
	_build_binding_rows()
	set_process_unhandled_input(false)

# ── Preset helpers ────────────────────────────────────────────────────────

static func snap_to_nearest(value: int, presets: Array) -> int:
	var best: int = presets[0]
	var best_dist: int = abs(value - best)
	for p in presets:
		var d: int = abs(value - int(p))
		if d < best_dist:
			best_dist = d
			best = int(p)
	return best

func _build_preset_buttons(container: HBoxContainer, presets: Array, fmt: String, callback: Callable) -> void:
	var group := ButtonGroup.new()
	for p in presets:
		var btn := Button.new()
		btn.text = fmt % p
		btn.toggle_mode = true
		btn.button_group = group
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", callback.bind(p))
		container.add_child(btn)

func _select_preset(container: HBoxContainer, presets: Array, value: int) -> void:
	var snapped := snap_to_nearest(value, presets)
	for i in container.get_child_count():
		var btn := container.get_child(i) as Button
		btn.set_pressed_no_signal(presets[i] == snapped)

func _on_das_preset(value: int) -> void:
	_das_value = value
	_save_settings()

func _on_arr_preset(value: int) -> void:
	_arr_value = value
	_save_settings()

func _on_sdf_preset(value: int) -> void:
	_sdf_value = value
	_save_settings()

# ── Window mode / size ────────────────────────────────────────────────────

func _build_window_mode_buttons() -> void:
	var group := ButtonGroup.new()
	for mode in ["windowed", "fullscreen"]:
		var btn := Button.new()
		btn.text = mode.capitalize()
		btn.toggle_mode = true
		btn.button_group = group
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", _on_window_mode_changed.bind(mode))
		window_mode_buttons.add_child(btn)

func _build_window_size_buttons() -> void:
	var group := ButtonGroup.new()
	for i in WINDOW_SIZE_PRESETS.size():
		var btn := Button.new()
		btn.text = WINDOW_SIZE_LABELS[i]
		btn.toggle_mode = true
		btn.button_group = group
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", _on_window_size_preset.bind(WINDOW_SIZE_PRESETS[i]))
		window_size_buttons.add_child(btn)

func _on_window_mode_changed(mode: String) -> void:
	_window_mode = mode
	if not OS.has_feature("editor"):
		if mode == "fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(_window_size)
	window_size_row.visible = (mode == "windowed")
	_save_settings()

func _on_window_size_preset(size: Vector2i) -> void:
	_window_size = size
	if not OS.has_feature("editor"):
		DisplayServer.window_set_size(size)
	_save_settings()

func _select_window_mode(mode: String) -> void:
	var modes := ["windowed", "fullscreen"]
	for i in window_mode_buttons.get_child_count():
		var btn := window_mode_buttons.get_child(i) as Button
		btn.set_pressed_no_signal(modes[i] == mode)

func _select_window_preset(size: Vector2i) -> void:
	for i in window_size_buttons.get_child_count():
		var btn := window_size_buttons.get_child(i) as Button
		btn.set_pressed_no_signal(WINDOW_SIZE_PRESETS[i] == size)

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
	cfg.erase_section_key("bindings", "")
	for entry in REBINDABLE_ACTIONS:
		cfg.erase_section_key("bindings", entry["action"])
	cfg.save(SETTINGS_PATH)
	_refresh_all_key_labels()

# ── Settings load / save ──────────────────────────────────────────────────

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var das := 130
	var arr := 40
	var sdf := 10
	if cfg.load(SETTINGS_PATH) == OK:
		das = snap_to_nearest(int(cfg.get_value("timing", "das_ms", 130)), DAS_PRESETS)
		arr = snap_to_nearest(int(cfg.get_value("timing", "arr_ms", 40)), ARR_PRESETS)
		sdf = snap_to_nearest(int(cfg.get_value("timing", "sdf_x", 10)), SDF_PRESETS)
		_window_mode = cfg.get_value("display", "window_mode", "windowed")
		var w: int = cfg.get_value("display", "window_width", 1600)
		var h: int = cfg.get_value("display", "window_height", 900)
		_window_size = Vector2i(w, h)
	_das_value = das
	_arr_value = arr
	_sdf_value = sdf
	_select_preset(das_buttons, DAS_PRESETS, das)
	_select_preset(arr_buttons, ARR_PRESETS, arr)
	_select_preset(sdf_buttons, SDF_PRESETS, sdf)
	_select_window_mode(_window_mode)
	_select_window_preset(_window_size)
	window_size_row.visible = (_window_mode == "windowed")

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("timing", "das_ms", _das_value)
	cfg.set_value("timing", "arr_ms", _arr_value)
	cfg.set_value("timing", "sdf_x", _sdf_value)
	cfg.set_value("display", "window_mode", _window_mode)
	cfg.set_value("display", "window_width", _window_size.x)
	cfg.set_value("display", "window_height", _window_size.y)
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

static func apply_saved_display() -> void:
	if OS.has_feature("editor"):
		return
	var cfg := ConfigFile.new()
	var mode := "windowed"
	var size := Vector2i(1600, 900)
	if cfg.load("user://settings.cfg") == OK:
		mode = cfg.get_value("display", "window_mode", "windowed")
		var w: int = cfg.get_value("display", "window_width", 1600)
		var h: int = cfg.get_value("display", "window_height", 900)
		size = Vector2i(w, h)
	if mode == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(size)

static func apply_saved_bindings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	var actions := [
		"move_left", "move_right", "soft_drop", "hard_drop",
		"rotate_cw", "rotate_ccw", "rotate_180", "hold_piece", "pause",
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
		var raw := int(cfg.get_value("timing", "das_ms", 130))
		return snap_to_nearest(raw, DAS_PRESETS) / 1000.0
	return 0.130

static func load_arr() -> float:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var raw := int(cfg.get_value("timing", "arr_ms", 40))
		return snap_to_nearest(raw, ARR_PRESETS) / 1000.0
	return 0.040

static func load_sdf() -> int:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var raw := int(cfg.get_value("timing", "sdf_x", 10))
		return snap_to_nearest(raw, SDF_PRESETS)
	return 10
