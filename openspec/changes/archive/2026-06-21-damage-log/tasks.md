## 1. DamageLog autoload

- [x] 1.1 Create `game/autoloads/damage_log.gd` with `class_name DamageLog extends Node`. Add `_enabled: bool`, `_file: FileAccess`, and round accumulator variables (`_round_sum_base`, `_round_sum_technique`, `_round_sum_mastery`, `_round_sum_honed`, `_round_sum_keystone_flat`, `_round_sum_consumable_flat`, `_round_sum_tag_bonus`, `_round_sum_final`, `_run_total_damage`)
- [x] 1.2 Implement `_ready()`: set `_enabled = OS.is_debug_build()`
- [x] 1.3 Implement `start_run(seed: int, ascension: int)`: if not enabled, return. Create `user://damage_logs/` directory if missing. Open CSV file at `user://damage_logs/run_<YYYYMMDD_HHmmss>.csv`. Write CSV header row. Write `RUN_START` row with seed, ascension, timestamp. Reset all accumulators
- [x] 1.4 Implement `log_build()`: if not enabled or no file, return. Write `BUILD` row listing all `RunState.keystones`, `RunState.techniques`, and `RunState.consumables` by ID, semicolon-separated within each field
- [x] 1.5 Implement `log_attack(floor, room_tier, event_type, base, technique, mastery, honed, keystone_flat, consumable_flat, surge_mult, keystone_mult, amplified_mult, tag_bonus, final)`: if not enabled, return. Write `ATTACK` row. Accumulate additive values into round sums
- [x] 1.6 Implement `log_round_end(floor, room_tier, quota, time_elapsed, pieces_placed)`: if not enabled, return. Write `ROUND_END` row with accumulated round sums. Add round total to `_run_total_damage`. Reset round accumulators
- [x] 1.7 Implement `log_run_end(result: String)`: if not enabled, return. Write `RUN_END` row with result and `_run_total_damage`. Close file handle
- [x] 1.8 Register `DamageLog` as an autoload in `project.godot`

## 2. RunState build_changed signal

- [x] 2.1 Add `signal build_changed` to `RunState`
- [x] 2.2 Emit `build_changed` at the end of `add_keystone()`, `add_technique()`, `add_consumable()`, `remove_technique()`, `remove_consumable()`
- [x] 2.3 In `DamageLog._ready()`, connect to `RunState.build_changed` → `log_build`

## 3. Instrument RunManager damage pipeline

- [x] 3.1 In `_on_attack_generated()`, after the suppression check, capture per-source values by snapshotting `modified` before and after each pipeline stage: `keystone_flat_delta = modified - pre_keystone_flat`, `consumable_flat_delta`, `surge_mult` (2.0 if surge fired, else 1.0), `keystone_mult` (ratio of post/pre), `amplified_mult`, and `tag_bonus` delta
- [x] 3.2 Call `DamageLog.log_attack()` with all captured values after the tag bonus stage, before `_drain_attack()`
- [x] 3.3 Call `DamageLog.log_build()` and `DamageLog.start_run()` from `RunManager._start_run()` after `RunState.reset()` and ascension modifiers are applied
- [x] 3.4 Call `DamageLog.log_round_end()` from `RunManager._end_round()` with floor, tier, quota, elapsed time, and pieces placed
- [x] 3.5 Call `DamageLog.log_run_end("victory")` from `_show_victory()` and `DamageLog.log_run_end("failure")` from `_show_failure()`

## 4. Testing

- [x] 4.1 Add test: `DamageLog` disabled state — calling `log_attack()` when `_enabled = false` does not create files or write data
- [x] 4.2 Add test: `log_attack()` accumulates round sums correctly — call multiple times and verify `_round_sum_base`, `_round_sum_technique`, etc. match expected totals
- [x] 4.3 Add test: `log_round_end()` resets round accumulators to zero and adds to `_run_total_damage`
- [x] 4.4 Add test: `log_run_end()` records correct `_run_total_damage` across multiple rounds
- [x] 4.5 Add test: `build_changed` signal emitted from `RunState.add_technique()`, `add_keystone()`, `remove_technique()`, `add_consumable()`, `remove_consumable()`
