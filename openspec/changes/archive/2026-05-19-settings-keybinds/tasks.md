## 1. DAS / ARR SpinBox Addition and Panel Background

- [x] 1.1 In `game/scenes/screens/settings.tscn`, add a `SpinBox` node named `DASSpinBox` to the right of the existing `DASSlider` inside `DASRow`; set `min_value=50`, `max_value=500`, `step=1`, `suffix=" ms"`
- [x] 1.2 Add a `SpinBox` node named `ARRSpinBox` to the right of the existing `ARRSlider` inside `ARRRow`; set `min_value=0`, `max_value=200`, `step=1`, `suffix=" ms"`
- [x] 1.3 In `game/scenes/screens/settings.gd`, add `@onready var das_spinbox: SpinBox = $Panel/VBox/DASRow/DASSpinBox` and `@onready var arr_spinbox: SpinBox = $Panel/VBox/ARRRow/ARRSpinBox`
- [x] 1.4 Add `var _syncing: bool = false` to prevent signal loops; in `_on_das_changed`, when not syncing set `das_spinbox.value = das_slider.value`; add `_on_das_spinbox_changed` that sets `das_slider.value = das_spinbox.value` when not syncing; connect the SpinBox `value_changed` signal in `_ready()`
- [x] 1.5 Repeat the same sync pattern for ARR: `_on_arr_spinbox_changed` ↔ `arr_slider`
- [x] 1.6 Update `_load_settings()` to also set `das_spinbox.value` and `arr_spinbox.value` after loading; `_save_settings()` can continue reading from the slider (values are kept in sync)
- [x] 1.7 In `settings.tscn`, select the root `Panel` (`PanelContainer`) and add a `theme_override_styles/panel` override using a `StyleBoxFlat` with `bg_color = Color(0.12, 0.12, 0.14, 1.0)` to make the background fully opaque

## 2. Keybinding Section — UI

- [x] 2.1 Add a `ScrollContainer` + inner `VBoxContainer` (named `BindingsContainer`) to `settings.tscn` below the ARR row, before the Close button; set a `custom_minimum_size` height of 240px on the ScrollContainer
- [x] 2.2 Add a `Label` above `BindingsContainer` with text "Key Bindings"
- [x] 2.3 Add a `Button` named `ResetButton` below `BindingsContainer` with text "Reset to Defaults"
- [x] 2.4 Update `settings.gd`: add `@onready var bindings_container: VBoxContainer = $Panel/VBox/ScrollContainer/BindingsContainer` and `@onready var reset_button: Button = $Panel/VBox/ResetButton`

## 3. Keybinding Section — Logic

- [x] 3.1 In `settings.gd`, define a constant `REBINDABLE_ACTIONS` as an ordered Array of Dictionaries, each with `"action"` (GDScript action name) and `"label"` (display name)
- [x] 3.2 Add `var _rebinding_action: String = ""` and `var _rebind_buttons: Array = []` instance variables
- [x] 3.3 In `_ready()`, call `_build_binding_rows()` to procedurally create each row in `BindingsContainer`: an `HBoxContainer` containing a `Label` (action display name, min_size 120px), a `Label` (current key name, min_size 100px), and a `Button` ("Rebind")
- [x] 3.4 Store a reference to each key `Label` and `Button` in `_rebind_buttons` for easy updates; connect each `Button.pressed` to `_on_rebind_pressed(action_name)`
- [x] 3.5 Implement `_get_key_name(action: String) -> String`: return the display name of the first `InputEventKey` in `InputMap.action_get_events(action)`, or "Unbound" if none
- [x] 3.6 Implement `_on_rebind_pressed(action: String)`: set `_rebinding_action = action`; disable all rebind buttons; show a "Press any key…" status label; `set_process_unhandled_input(true)`
- [x] 3.7 Implement `_unhandled_input(event: InputEvent)`: if `_rebinding_action` is non-empty and `event` is `InputEventKey` with `pressed = true`: if Escape cancel, otherwise apply binding
- [x] 3.8 Connect `reset_button.pressed` to `_on_reset_pressed()`: call `InputMap.load_from_project_settings()`, clear `[bindings]` section from config and save, call `_refresh_all_key_labels()`

## 4. Persistence — Save / Load / Apply

- [x] 4.1 Implement `_save_bindings()` in `settings.gd`: iterate `REBINDABLE_ACTIONS`; for each action, get the first `InputEventKey` event; write physical_keycode to `[bindings]` section and save
- [x] 4.2 Implement `_load_bindings()` in `settings.gd` (called from `_ready()`): read `[bindings]` section from config; for each saved entry, construct an `InputEventKey` with `physical_keycode = saved_int` and apply via `InputMap`
- [x] 4.3 Add a static method `Settings.apply_saved_bindings()` that performs the same load-and-apply logic without opening the Settings UI (used at startup)
- [x] 4.4 In `game/autoloads/run_state.gd`, call `Settings.apply_saved_bindings()` at the top of `_ready()` so custom bindings are active from the first round
