## Why

The current Settings screen only offers HSlider controls for DAS and ARR, which are imprecise for competitive Tetris players who want exact millisecond values. More importantly, all key bindings are hardcoded and cannot be changed without editing `project.godot` directly, making the game inaccessible to players with non-standard keyboards or different preferences.

## What Changes

- Add a `SpinBox` beside each existing DAS and ARR `HSlider` so players can type an exact millisecond value or drag the slider — both controls stay in sync.
- Add a **Keybindings section** to the Settings screen listing all eight rebindable actions (Move Left, Move Right, Soft Drop, Hard Drop, Rotate CW, Rotate CCW, Rotate 180, Hold). Each row shows the action name, its current key, and a "Rebind" button.
- Clicking "Rebind" enters listening mode: the next key pressed becomes the new binding for that action.
- Custom bindings are saved to `user://settings.cfg` and applied at game startup via `InputMap`.
- A "Reset to Defaults" button restores all bindings to the shipped defaults.
- The settings panel background is made fully opaque so items are clearly readable.

## Capabilities

### New Capabilities

- `keybind-settings`: In-game keybinding editor in the Settings screen. Supports rebinding all eight gameplay actions, saving to config, loading on startup, and resetting to defaults.

### Modified Capabilities

- `tetris-core`: DAS and ARR expose both a slider and a SpinBox for exact integer entry; the two controls stay in sync. Valid range unchanged (DAS 50–500ms, ARR 0–200ms).

## Impact

- **Modified**: `game/scenes/screens/settings.gd` — add SpinBox sync logic alongside sliders; add keybinding section logic (listen mode, save/load bindings).
- **Modified**: `game/scenes/screens/settings.tscn` — add SpinBox nodes beside HSliders; add keybinding rows; set panel background to solid.
- **Modified**: `game/autoloads/run_state.gd` (or a new autoload) — apply saved bindings from config at startup.
- **No changes** to Tetris engine, roguelike logic, or HUD.
