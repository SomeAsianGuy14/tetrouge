## Context

DAS and ARR are currently stored as arbitrary millisecond floats via `HSlider`+`SpinBox` pairs and persisted in `settings.cfg` under `[timing]`. `RunManager` reads them with `Settings.load_das()` / `Settings.load_arr()` and assigns them directly to `TetrisBoard.das_delay` / `TetrisBoard.arr_rate`. Soft drop speed is hardcoded to `20.0×` inside `TetrisBoard._handle_gravity()`, with a binary override (`RoundConfig.instant_soft_drop`) used exclusively by the Full Potential keystone.

## Goals / Non-Goals

**Goals:**
- Constrain DAS to 9 presets (80–160 ms, 10 ms steps; default 130 ms)
- Constrain ARR to 4 presets (20–50 ms, 10 ms steps; default 40 ms)
- Add SDF as a 4-preset player setting (5×/10×/15×/20×; default 10×)
- Maintain Full Potential keystone override: `instant_arr` → 0 ms, `instant_soft_drop` → 1000×

**Non-Goals:**
- No 0 ms ARR or infinite SDF as player settings
- No changes to Full Potential keystone logic or `RoundConfig` fields
- No preset migration for players with existing saved arbitrary values (snap to nearest)

## Decisions

**Preset button groups instead of sliders**
Godot `Button` nodes in a horizontal `HBoxContainer` with toggle/exclusive behaviour. Each button stores its value as metadata or maps to a const array by index. This is simpler than a custom control and fits the existing settings panel layout.

*Alternative considered*: Keep sliders but add min/max clamping. Rejected — sliders still allow arbitrary values between steps and do not communicate the discrete nature of the options.

**Snap-to-nearest on load for existing saves**
`Settings.load_das()` / `load_arr()` / `load_sdf()` each take the raw config value and return the nearest valid preset. This silently corrects any out-of-range saves (e.g. from the old 167 ms default) without requiring a migration pass.

*Alternative considered*: Hard-fail / reset to default if value is not a valid preset. Rejected — too disruptive for existing players.

**SDF stored as integer multiplier (`sdf_x`) in settings.cfg**
Storing `5`, `10`, `15`, or `20` directly is unambiguous and maps cleanly to `TetrisBoard.sdf_multiplier`. No unit conversion needed at read time.

**`TetrisBoard.sdf_multiplier` var, set by RunManager**
Mirrors the existing pattern for `das_delay` / `arr_rate`. `RunManager` reads `Settings.load_sdf()` and sets `board.sdf_multiplier` before each round. `_handle_gravity()` uses `sdf_multiplier` unless `config.instant_soft_drop` is true (Full Potential path).

## Risks / Trade-offs

`HSlider`/`SpinBox` node removal will break the `.tscn` scene if node paths are referenced anywhere other than `settings.gd` → check `@onready` paths are the only references before deleting.

Existing saves with 0 ms ARR (from old "instant" slider position) will snap to 20 ms — a meaningful gameplay change for any player who had that saved. Acceptable given the design intent, but worth noting.

Nine DAS buttons in a row may feel cramped at the current settings panel width → lay them out in the scene and verify visually before shipping.
