## 1. Resource Schema Changes

- [x] 1.1 Add `unlock_condition_id: String = ""` export field to `game/resources/keystone.gd`
- [x] 1.2 Add `unlock_condition_id: String = ""` export field to `game/resources/technique.gd`
- [x] 1.3 Create `game/resources/unlock_condition.gd` — `class_name UnlockCondition extends Resource` with fields: `target_id: String`, `condition_type: String`, `params: Dictionary`

## 2. ProfileSave

- [x] 2.1 Create `game/scripts/profile_save.gd` — static `RefCounted` class wrapping `user://profile.cfg` with `ConfigFile`
- [x] 2.2 Implement `ProfileSave.load() -> void` — reads `highest_beaten` (default -1), `unlocked_ids` (default []), and cumulative stats (default 0 each)
- [x] 2.3 Implement `ProfileSave.save() -> void` — writes all fields to disk
- [x] 2.4 Implement `ProfileSave.record_victory(level: int) -> void` — updates `highest_beaten` to `max(highest_beaten, level)` then saves
- [x] 2.5 Implement `ProfileSave.accumulate_stats(run_stats) -> void` — adds additive fields (`total_damage`, `quad_damage`, `tspin_damage`, `runs_completed`) to stored totals; updates lifetime maximums (`highest_combo_chain`, `highest_b2b`) with `max(stored, run_value)`; then saves
- [x] 2.6 Call `ProfileSave.load()` at game startup (in `main_menu.gd _ready()` or a dedicated autoload init)

## 3. RunStats

- [x] 3.1 Create `game/scripts/run_stats.gd` — `class_name RunStats extends RefCounted` with fields: `total_damage: int`, `quad_damage: int`, `tspin_damage: int`, `highest_combo_chain: int`, `highest_b2b: int`, all defaulting to 0
- [x] 3.2 In `RunManager`, instantiate `RunStats` at run start; populate `total_damage` from `quota_accumulated` at victory; populate `quad_damage` and `tspin_damage` by accumulating per attack event type; update `highest_combo_chain` and `highest_b2b` each time a combo/b2b count is recorded

## 4. UnlockChecker

- [x] 4.1 Create `game/scripts/unlock_checker.gd` — static class with `check_all(run_stats: RunStats) -> void` that iterates registered `UnlockCondition` entries (empty array for now) and adds met condition ids to `ProfileSave.unlocked_ids`

## 5. AscensionManager Autoload

- [x] 5.1 Create `game/autoloads/ascension_manager.gd` — `extends Node` with `var current_level: int = 0`
- [x] 5.2 Define `const LEVEL_MODIFIERS: Array` — array of 7 Dictionaries (indices 0–6), where index 0 is empty and each subsequent entry adds its new modifier key to those of the previous level. Keys: `faster_attacks: bool`, `extra_lines: int`, `consumable_capacity_delta: int`, `quota_mult: float`, `skip_starter_keystone: bool`, `technique_capacity_delta: int`
- [x] 5.3 Implement `get_modifiers(level: int) -> Dictionary` — returns the merged modifier dictionary for the given level (all keys from levels 1 through `level` combined)
- [x] 5.4 Register `AscensionManager` as an autoload in `game/project.godot`
- [x] 5.5 Reset `AscensionManager.current_level = 0` at the start of each new run (call from `RunManager.start_run()`)

## 6. ResourceRegistry Filtering

- [x] 6.1 Add `get_available_keystones() -> Array` to `game/autoloads/resource_registry.gd` — returns `all_keystones` filtered to items where `unlock_condition_id == ""` or `unlock_condition_id in ProfileSave.unlocked_ids`
- [x] 6.2 Add `get_available_techniques() -> Array` — same pattern for `all_techniques`
- [x] 6.3 Update `game/scenes/keystone_selection/keystone_selection.gd` to call `ResourceRegistry.get_available_keystones()` instead of `ResourceRegistry.all_keystones`
- [x] 6.4 Update `game/scenes/shop/shop.gd` `_load_item_pools()` to call `get_available_techniques()` and `get_available_keystones()` (for shop keystone display, if any)

## 7. Apply Ascension Modifiers in RunManager

- [x] 7.1 Increase base garbage interval constants by 25%: `SMALL_INTERVAL_MIN/MAX`, `BIG_INTERVAL_MIN/MAX`, `ELITE_INTERVAL_MIN/MAX`, `BOSS_INTERVAL_MIN/MAX`
- [x] 7.2 In `_build_round_config()`, after setting base interval values: if `AscensionManager.get_modifiers(level).get("faster_attacks", false)` is true, divide intervals by 1.25 (restoring pre-rebalance speed)
- [x] 7.3 In `_build_round_config()`, add `get_modifiers(level).get("extra_lines", 0)` to both `garbage_lines_min` and `garbage_lines_max`
- [x] 7.4 In `_build_round_config()`, multiply `cfg.quota` by `get_modifiers(level).get("quota_mult", 1.0)` and apply `ceili()`
- [x] 7.5 In `RunManager.start_run()`, apply `consumable_capacity_delta` to `RunState.consumable_capacity` after reset
- [x] 7.6 In `RunManager.start_run()`, apply `technique_capacity_delta` to the base technique capacity (4 + delta, minimum 1) before stage scaling
- [x] 7.7 In `RunManager._show_starter_keystone_selection()` (or its caller), skip the call entirely if `AscensionManager.get_modifiers(level).get("skip_starter_keystone", false)` is true

## 8. Victory Flow Update

- [x] 8.1 In `RunManager._show_victory()` (or `_end_round(true)` on run completion), call `ProfileSave.record_victory(AscensionManager.current_level)` before instantiating the victory scene
- [x] 8.2 Call `ProfileSave.accumulate_stats(run_stats)` at the same point
- [x] 8.3 Call `UnlockChecker.check_all(run_stats)` at the same point
- [x] 8.4 Update `game/scenes/screens/run_victory.gd` to display the newly unlocked ascension level (e.g. "Ascension [N+1] unlocked!")

## 9. Ascension Selector Scene

- [x] 9.1 Create `game/scenes/screens/ascension_selector.tscn` — full-screen `CanvasLayer` containing a solid `ColorRect` background (fully covers the viewport), a title label, a `VBoxContainer` for level buttons, and a Back button
- [x] 9.2 Create `game/scenes/screens/ascension_selector.gd` — populates level buttons 0 through `ProfileSave.highest_beaten + 1`; each button shows the level number and cumulative modifier summary; emits `level_selected(level: int)` signal on confirmation
- [x] 9.3 In `MainMenu._on_new_run()`: if `ProfileSave.highest_beaten >= 0`, instantiate and show the ascension selector instead of starting the run immediately; connect `level_selected` to a handler that sets `AscensionManager.current_level` and starts the run

## 10. Run Tests

- [x] 10.1 Run the full GUT test suite via `game/tests/run_tests.tscn` and confirm all tests pass

## 11. Testing

- [x] 11.1 Add test: `ProfileSave.record_victory(0)` sets `highest_beaten` to 0 when previously -1
- [x] 11.2 Add test: `ProfileSave.record_victory(N)` does not downgrade `highest_beaten` when N < current value
- [x] 11.3 Add test: `ProfileSave.accumulate_stats()` adds run values to existing totals
- [x] 11.4 Add test: `AscensionManager.get_modifiers(0)` returns no active modifiers
- [x] 11.5 Add test: `AscensionManager.get_modifiers(3)` includes `faster_attacks`, `extra_lines`, and `consumable_capacity_delta` but not higher-level keys
- [x] 11.6 Add test: `AscensionManager.get_modifiers(6)` includes all six modifier keys
- [x] 11.7 Add test: `ResourceRegistry.get_available_keystones()` excludes items with non-empty `unlock_condition_id` not in `unlocked_ids`
- [x] 11.8 Add test: `ResourceRegistry.get_available_keystones()` includes all items when none are locked
- [x] 11.9 Add test: `UnlockChecker.check_all()` is a no-op when no conditions are defined
- [x] 11.10 Add test: ascension level 4 quota modifier — `ceili(50 * 1.2)` equals 60
