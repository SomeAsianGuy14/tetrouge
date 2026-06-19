## 1. Mastery Data on RunState

- [x] 1.1 Add mastery constants to `run_state.gd`: `MASTERY_TRACKS` array of 7 track names, `MASTERY_BASE_XP` Dictionary mapping track name to base threshold, `MASTERY_XP_INCREMENT` Dictionary mapping track name to per-level increment (singles/doubles/tspin_singles/tspin_doubles: base=10, inc=2; triples/quads/tspin_triples: base=5, inc=1). Add `get_mastery_threshold(track: String) -> int` that returns `base + increment * current_level`
- [x] 1.2 Add `mastery: Dictionary` field to RunState — keys are track names, values are `{xp: int, level: int}`. Initialize all tracks to `{xp: 0, level: 0}` in `reset()`
- [x] 1.3 Add `grant_mastery_xp(track: String) -> int` method: increments XP, checks threshold, levels up if met (returns new level or 0 if no level-up)
- [x] 1.4 Add `get_mastery_level(track: String) -> int` helper that returns the level for a track (0 if not found)
- [x] 1.5 Add `get_highest_mastery_for(category: String) -> int` helper that maps broad categories to max level: `"all_clear"` → max of all 7, `"tspin"` → max of tspin tracks, `"multiline"` → max of double/triple/quad

## 2. Grant XP in RunManager

- [x] 2.1 In `_on_attack_generated()`, after the run_stats tracking block, add mastery XP grant: if not `is_bonus_event` and `event_type != "perfect_clear"` and event_type is in `MASTERY_TRACKS`, call `RunState.grant_mastery_xp(event_type)`
- [x] 2.2 If `grant_mastery_xp` returns a level > 0 (level-up occurred), spawn a mastery level-up popup

## 3. Apply Mastery Flat Bonus to Attack

- [x] 3.1 In `_on_attack_generated()`, after computing `technique_atk`, add mastery bonus: `mastery_atk = RunState.get_mastery_level(event_type)` (0 for non-tracked types). Add `mastery_atk` to `modified` alongside `technique_atk`

## 4. Technique Amplification

- [x] 4.1 In `TechniqueEvaluator._eval_flat()`, after computing `bonus`, add mastery amplification: if `on` is a specific tracked type and not `require_b2b` and not `"perfect_clear"`, add `floor(RunState.get_mastery_level(on) / 2)` to bonus
- [x] 4.2 For broad `on` values (`"all_clear"`, `"tspin"`, `"multiline"`), add `floor(RunState.get_highest_mastery_for(on) / 2)` to bonus
- [x] 4.3 Ensure `require_b2b` techniques and `on="perfect_clear"` techniques skip amplification

## 5. RunSave Persistence

- [x] 5.1 In `RunSave.save()`, serialize `RunState.mastery` under a `"mastery"` section
- [x] 5.2 In `RunSave.load_into_state()`, deserialize mastery data with default of all tracks at `{xp: 0, level: 0}` when section is missing

## 6. Mastery HUD Panel

- [x] 6.1 Add a `MasteryPanel` VBoxContainer above the InventoryPanel in `run_manager.tscn` with a clickable header label and 7 track labels
- [x] 6.2 In `hud.gd`, add `@onready` references for the mastery panel and track labels
- [x] 6.3 Add `_toggle_mastery_panel()` method wired to the header button press — toggles visibility of track labels
- [x] 6.4 Add `_refresh_mastery_panel()` method that updates all 7 track labels with level and XP progress (e.g., "Quads  Lv 3 (2/7)") from `RunState.mastery`
- [x] 6.5 Call `_refresh_mastery_panel()` from `refresh_inventory()` and `setup()`
- [x] 6.6 Include the mastery panel in `hide_inventory()` and `show_inventory()` so it follows the InventoryPanel visibility pattern (hidden during shop)
- [x] 6.7 Default the mastery panel to collapsed state on ready

## 7. Level-Up Popup

- [x] 7.1 Add `_spawn_mastery_popup(track_name: String, level: int)` method to RunManager that spawns a popup label (e.g., "Quads Lv 3!") in light green, using the same float-and-fade animation as `_spawn_event_popup`
- [x] 7.2 Wire the popup spawn to the level-up check in task 2.2

## 8. Testing

- [x] 8.1 Add test: `grant_mastery_xp` increments XP by 1
- [x] 8.2 Add test: quad track levels up at 5 XP (level 0→1), then at 6 XP (level 1→2), then at 7 XP (level 2→3)
- [x] 8.3 Add test: singles track levels up at 10 XP (level 0→1), then at 12 XP (level 1→2)
- [x] 8.4 Add test: `get_mastery_level` returns 0 for untracked type
- [x] 8.5 Add test: `get_highest_mastery_for("all_clear")` returns max across all tracks
- [x] 8.6 Add test: `get_highest_mastery_for("tspin")` returns max of tspin tracks only
- [x] 8.7 Add test: `get_highest_mastery_for("multiline")` returns max of double/triple/quad
- [x] 8.8 Add test: mastery amplification adds floor(level/2) to specific technique bonus
- [x] 8.9 Add test: mastery amplification uses highest track for broad technique
- [x] 8.10 Add test: `require_b2b` technique not amplified by mastery
- [x] 8.11 Add test: `on="perfect_clear"` technique not amplified by mastery
- [x] 8.12 Add test: mastery resets to zero on `RunState.reset()`
- [x] 8.13 Run full GUT test suite and fix any failures
