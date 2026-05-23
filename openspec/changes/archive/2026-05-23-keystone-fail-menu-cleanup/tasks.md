## 1. Keystone Selection — Off-Screen Fix

- [x] 1.1 In `keystone_selection.tscn`, change the `Panel` node's layout from fixed offsets (±450 / ±150) to a centred anchor with a capped width — set `anchors_preset = 8`, remove the fixed offsets, and set `custom_minimum_size = Vector2(700, 0)` so the panel never exceeds the viewport

## 2. Keystone Selection — Card Layout

- [x] 2.1 In `keystone_selection.gd`, update `_populate_options()` to build each card as a `Button` with a `VBoxContainer` containing two `Label` nodes: one for `display_name` (name label) and one for `description` (description label, `autowrap_mode = WORD`)
- [x] 2.2 Set a larger font size override on the name label (e.g. `add_theme_font_size_override("font_size", 16)`) and leave the description label at default size
- [x] 2.3 Set `custom_minimum_size` on each card button to `Vector2(200, 140)` so three cards fit comfortably within the 700 px panel

## 3. Run Failure Screen — Visual and Logic Fixes

- [x] 3.1 In `run_failure.tscn`, add a `StyleBoxFlat` to the `PanelContainer`'s `theme_override_styles/panel` with a solid dark background (e.g. `Color(0.1, 0.1, 0.1, 0.95)`) so the panel is opaque and readable
- [x] 3.2 In `run_failure.tscn`, rename the `RestartButton` node text from `"Try Again"` to `"New Run"`
- [x] 3.3 In `run_failure.gd`, replace `_on_restart()` body: delete the save, instantiate `run_manager.tscn`, add it to `get_tree().root`, `queue_free()` self, then call `start_run()` on the new instance — mirroring the pattern in `main_menu.gd:_on_new_run()`

## 4. Verification

- [x] 4.1 Open the keystone selection screen (complete a boss round) — confirm the panel fits entirely within the viewport at the default resolution
- [x] 4.2 Confirm each card shows the name prominently above a wrapped description
- [x] 4.3 Click a keystone card — confirm the selection closes and the keystone is added to the HUD
- [x] 4.4 Fail a run — confirm the failure panel has a solid background (not see-through)
- [x] 4.5 Confirm the failure screen shows "New Run" (not "Try Again")
- [x] 4.6 Click "New Run" on the failure screen — confirm a fresh run starts at Ante 1 Round 1 with no leftover keystones, techniques, or coins from the previous run
