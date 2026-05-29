## Why

The DAS/ARR settings use continuous sliders that expose arbitrary values, including ranges that trivialise the game's skill curve. Soft drop speed (SDF) has no player setting at all — it is hardcoded at 20×. Capping these values at meaningful presets and adding SDF control gives players tuning flexibility while preserving the design intent that instant ARR and infinite SDF remain locked behind the Full Potential keystone.

## What Changes

- Replace DAS `HSlider`+`SpinBox` UI with a preset button group: 80 / 90 / 100 / 110 / 120 / 130 / 140 / 150 / 160 ms (default 130 ms)
- Replace ARR `HSlider`+`SpinBox` UI with a preset button group: 20 / 30 / 40 / 50 ms (default 40 ms); 0 ms instant is not available as a player setting
- Add SDF preset button group: 5× / 10× / 15× / 20× (default 10×); infinite SDF is not available as a player setting
- Add `Settings.load_sdf()` static helper, persist `sdf_x` to `settings.cfg`
- Wire SDF from settings into `TetrisBoard` via `RunManager`, with `RoundConfig.instant_soft_drop` override taking priority (Full Potential keystone path unchanged)

## Capabilities

### New Capabilities

- `sdf-setting`: Player-configurable soft drop factor (5×–20×), stored in settings and applied to the board each round, overridden by `RoundConfig.instant_soft_drop`

### Modified Capabilities

- `das-arr-setting`: DAS and ARR are now preset-only (no arbitrary slider values); ARR ceiling is 50 ms, eliminating the instant-ARR player path

## Impact

- `game/scenes/screens/settings.gd` — replace slider/spinbox nodes and sync logic with preset button logic; add SDF load/save
- `game/scenes/screens/settings.tscn` — remove `HSlider`/`SpinBox` nodes, add button group containers for DAS, ARR, SDF
- `game/scenes/game/run_manager.gd` — read and apply `sdf_multiplier` from `Settings.load_sdf()`
- `game/scenes/tetris/tetris_board.gd` — replace hardcoded `20.0` soft mult with `sdf_multiplier` var
- `game/tests/unit/` — new test file covering preset persistence and SDF wiring
