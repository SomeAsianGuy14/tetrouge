## 1. Keystone Selection — Card Layout

- [ ] 1.1 In `keystone_selection.tscn`, replace the `Options` node type from `HBoxContainer` to one that holds card `PanelContainer` nodes — keep the `HBoxContainer` but ensure each card can be added dynamically
- [ ] 1.2 In `keystone_selection.gd`, update `_populate_options()` to build each card as a `Button` with a `VBoxContainer` containing two `Label` nodes: one for `display_name` (name label) and one for `description` (description label, `autowrap_mode = WORD`)
- [ ] 1.3 Set a larger font size override on the name label (e.g. `add_theme_font_size_override("font_size", 16)`) and leave the description label at default size
- [ ] 1.4 Set `custom_minimum_size` on each card button to ensure description text has room to wrap (e.g. `Vector2(220, 140)`)

## 2. Run Failure Screen — Bug Fix and Copy

- [ ] 2.1 In `run_failure.tscn`, rename the `RestartButton` node text from `"Try Again"` to `"New Run"`
- [ ] 2.2 In `run_failure.gd`, replace `_on_restart()` body: delete the save, instantiate `run_manager.tscn`, add it to `get_tree().root`, `queue_free()` self, then call `start_run()` on the new instance — mirroring the pattern in `main_menu.gd:_on_new_run()`

## 3. Verification

- [ ] 3.1 Open the keystone selection screen (complete a boss round) — confirm each card shows the name prominently above a wrapped description
- [ ] 3.2 Click a keystone card — confirm the selection closes and the keystone is added to the HUD
- [ ] 3.3 Fail a run — confirm the failure screen shows "New Run" (not "Try Again")
- [ ] 3.4 Click "New Run" on the failure screen — confirm a fresh run starts at Ante 1 Round 1 with no leftover keystones, techniques, or coins from the previous run
