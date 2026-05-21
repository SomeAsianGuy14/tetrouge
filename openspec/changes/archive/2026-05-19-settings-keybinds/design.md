## Context

The Settings screen (`settings.gd` / `settings.tscn`) currently has two HSlider controls for DAS and ARR, a label per slider, and a Close button. All key bindings live only in `project.godot` and are immutable at runtime.

Godot 4's `InputMap` singleton supports runtime modification: `InputMap.action_erase_events(action)` clears existing events, `InputMap.action_add_event(action, event)` adds a new one. Changes survive until the process ends; they must be reapplied each launch from saved config.

## Goals / Non-Goals

**Goals:**
- SpinBox for DAS (50–500ms) and ARR (0–200ms) replacing sliders
- In-screen keybinding rows for all 8 gameplay actions
- Rebind flow: click button → listen for next key → save and apply
- Persistent storage in `user://settings.cfg` under a `[bindings]` section
- Apply saved bindings at startup (in `RunState._ready()` or a dedicated loader)
- Reset-to-defaults button

**Non-Goals:**
- Mouse button or gamepad bindings (keyboard only)
- Multiple bindings per action (one key per action)
- Rebinding debug tools (F1/F2 for console/overlay)

## Decisions

### D1: SpinBox added alongside HSlider for DAS/ARR (two-way sync)

Each DAS and ARR row gains a `SpinBox` next to the existing `HSlider`. Both controls share the same value — changing one updates the other. The slider's `value_changed` signal sets `spinbox.value`; the SpinBox's `value_changed` signal sets `slider.value`. A guard flag (`_syncing`) prevents recursive signal loops.

`SpinBox` validates range automatically via `min_value`/`max_value`. DAS: 50–500ms, step 1. ARR: 0–200ms, step 1. ARR=0 still shows "Instant" in the existing label. The HSlider is kept so players can drag for coarse adjustment and use the SpinBox for fine-tuning.

### D1b: Solid settings panel background

The settings `PanelContainer` currently inherits the default theme which may render with transparency. Adding a `theme_override_styles/panel` `StyleBoxFlat` with a fully opaque dark background colour (`Color(0.12, 0.12, 0.14, 1.0)`) on the PanelContainer in `settings.tscn` makes all content clearly readable.

### D2: Keybinding rows built procedurally in _ready()

Rather than hardcoding 8 rows in the .tscn, the Settings script iterates a constant list of `{action, label}` pairs and creates each row (`HBoxContainer` → `Label` + current-key `Label` + `Button`) dynamically. This keeps the scene file minimal and makes adding/removing actions a one-line change.

### D3: Rebind listen mode via _input() override

When the player clicks a "Rebind" button:
1. `_rebinding_action` is set to the action name.
2. `set_process_input(true)` is enabled (disabled at other times).
3. `_input(event)` waits for the first `InputEventKey` with `pressed = true`.
4. It calls `InputMap.action_erase_events(action)`, `InputMap.action_add_event(action, event)`, saves to config, updates the UI label, clears `_rebinding_action`.

Pressing Escape during listen mode cancels without saving.

### D4: Save bindings as physical keycode integers in [bindings] section

`user://settings.cfg` gets a `[bindings]` section: `{action_name: physical_keycode_int}`. On load, reconstruct `InputEventKey` with `physical_keycode = saved_int` and apply to `InputMap`. Default is -1 (not set — use project defaults).

### D5: Apply bindings at startup in Settings static method

`Settings.apply_saved_bindings()` is a static method called once from `RunState._ready()`. It reads `[bindings]` from config and applies any non-default entries to `InputMap`. This keeps the binding application close to the Settings module.

### D6: Reset restores project.godot defaults

"Reset to Defaults" calls `ProjectSettings.load_resource_pack("")` is not needed — instead, iterate all actions, call `InputMap.action_erase_events(action)`, then `InputMap.load_from_project_settings()` to restore the shipped defaults. Clear the `[bindings]` section from config and save.

## Risks / Trade-offs

**Simultaneous key conflicts** → Not enforced. If the player binds the same key to two actions, both fire. Documenting this in the UI ("press Escape to cancel") is sufficient for an indie title.

**SpinBox "Instant" label** → The ARR SpinBox at value 0 won't automatically say "Instant" — the label alongside it will. The current `_update_labels()` logic handles this already.

**_input() eating key presses during rebind** → While in listen mode, all key events are consumed by the settings screen. Since the settings screen sits above the game, this is correct behaviour.
