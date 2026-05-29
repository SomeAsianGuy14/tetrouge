## 1. Settings Logic

- [x] 1.1 Add `SDF_PRESETS` constant array `[5, 10, 15, 20]` and `snap_to_nearest(value, presets)` helper to `settings.gd`
- [x] 1.2 Update `Settings.load_das()` to snap the loaded value to the nearest preset in `[80, 90, 100, 110, 120, 130, 140, 150, 160]` (default 130)
- [x] 1.3 Update `Settings.load_arr()` to snap the loaded value to the nearest preset in `[20, 30, 40, 50]` (default 40)
- [x] 1.4 Add `Settings.load_sdf()` static method: reads `sdf_x` from `settings.cfg`, snaps to nearest preset in `[5, 10, 15, 20]`, returns int (default 10)
- [x] 1.5 Update `_save_settings()` to write `sdf_x` to `settings.cfg` under `[timing]`
- [x] 1.6 Update `_load_settings()` to read `sdf_x` and select the matching SDF preset button

## 2. Settings UI — Scene

- [x] 2.1 In `settings.tscn`, remove `DASSlider` (HSlider), `DASSpinBox` (SpinBox) nodes; replace the DAS row with an `HBoxContainer` of 9 `Button` nodes labelled 80–160 ms
- [x] 2.2 Remove `ARRSlider` (HSlider), `ARRSpinBox` (SpinBox) nodes; replace the ARR row with an `HBoxContainer` of 4 `Button` nodes labelled 20–50 ms
- [x] 2.3 Add a new SDF row with an `HBoxContainer` of 4 `Button` nodes labelled 5×, 10×, 15×, 20×
- [x] 2.4 Assign `button_group` (exclusive toggle) to all buttons within each row so only one can be active at a time

## 3. Settings UI — Code

- [x] 3.1 Remove `das_slider`, `das_spinbox`, `arr_slider`, `arr_spinbox` `@onready` refs and all slider sync functions (`_on_das_changed`, `_on_das_spinbox_changed`, `_on_arr_changed`, `_on_arr_spinbox_changed`) from `settings.gd`
- [x] 3.2 Add `@onready` refs for DAS, ARR, and SDF button group containers; wire `pressed` signal of each button to a shared handler that reads the button's value and marks it selected
- [x] 3.3 Update `_load_settings()` to highlight the correct preset button for DAS, ARR, and SDF on open
- [x] 3.4 Update `_save_settings()` to read the selected button value for DAS, ARR, and SDF and write to config

## 4. Board — SDF Wiring

- [x] 4.1 Add `var sdf_multiplier: int = 10` to `TetrisBoard`
- [x] 4.2 In `TetrisBoard._handle_gravity()`, replace hardcoded `20.0` with `float(sdf_multiplier)`; keep `1000.0` for `config.instant_soft_drop` branch unchanged
- [x] 4.3 In `RunManager._start_round()`, add `current_board.sdf_multiplier = Settings.load_sdf()` alongside the existing DAS/ARR assignments
- [x] 4.4 In `RunManager._on_round_restarted()` (or equivalent restart path), apply `sdf_multiplier` the same way as 4.3

## 5. Testing

- [x] 5.1 Add `test_snap_to_nearest_returns_exact_match` — `snap_to_nearest(130, DAS_PRESETS)` returns 130
- [x] 5.2 Add `test_snap_to_nearest_rounds_to_closest` — `snap_to_nearest(167, DAS_PRESETS)` returns 160
- [x] 5.3 Add `test_snap_to_nearest_clamps_below_min` — `snap_to_nearest(0, ARR_PRESETS)` returns 20
- [x] 5.4 Add `test_load_das_default_when_no_config` — `Settings.load_das()` returns 0.130 when no config file exists
- [x] 5.5 Add `test_load_arr_default_when_no_config` — `Settings.load_arr()` returns 0.040 when no config file exists
- [x] 5.6 Add `test_load_sdf_default_when_no_config` — `Settings.load_sdf()` returns 10 when no config file exists
- [x] 5.7 Add `test_load_sdf_snaps_legacy_value` — `Settings.load_sdf()` with a saved value of 20 (old hardcoded default) returns 20 (valid preset, no snap needed)
- [x] 5.8 Add `test_board_uses_sdf_multiplier_for_soft_drop` — board with `sdf_multiplier = 5` accumulates gravity at 5× speed when `soft_dropping = true`
- [x] 5.9 Run all tests via `game/tests/run_tests.tscn` and confirm no failures
