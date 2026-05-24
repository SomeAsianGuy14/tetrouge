## 1. Keystone Resource — Data Model Overhaul

- [x] 1.1 Remove old effect fields from `keystone.gd` (`preview_count_override`, `hold_slots_override`, `lock_delay_ms_override`, `lock_max_resets_override`, `disable_hold_lockout`, `bag_reset_interval_override`, `deep_sight`, `second_wind`)
- [x] 1.2 Add `category: String` and `requires_keystone_id: String` to `keystone.gd`
- [x] 1.3 Add flat-bonus fields: `single_bonus`, `double_bonus`, `triple_bonus`, `quad_bonus`, `tspin_mini_bonus`, `tspin_single_bonus`, `tspin_double_bonus`, `tspin_triple_bonus`, `tspin_any_bonus`, `b2b_bonus` (all `int`, default 0)
- [x] 1.4 Add per-technique bonus fields: `per_technique_quad_bonus: int`, `per_technique_tspin_bonus: int`
- [x] 1.5 Add multiplier fields: `quad_multiplier`, `tspin_double_multiplier`, `tspin_triple_multiplier`, `single_multiplier`, `combo_multiplier`, `pc_first_multiplier`, `pc_after_first_multiplier`, `consecutive_quad_multiplier` (all `float`, default 1.0 where multiplicative; note 0.0 = no multiplier to distinguish from explicit x1)
- [x] 1.6 Add combo threshold: `combo_multiplier_threshold: int` (default 0)
- [x] 1.7 Add suppression flags: `suppress_spins`, `suppress_tspin_single`, `suppress_tspin_double`, `suppress_tspin_triple`, `suppress_non_singles` (all `bool`, default false)
- [x] 1.8 Add mechanic flags: `daze_stun_seconds: float`, `dizzy: bool`, `safety_net: bool`, `final_blow: bool`, `flexible_b2b: bool`
- [x] 1.9 Add economy fields: `end_round_coins: int`, `overkill_coins: bool`, `time_coins: bool`
- [x] 1.10 Add utility fields: `hold_slots_bonus: int`, `preview_count_bonus: int`, `instant_arr: bool`, `instant_soft_drop: bool`, `garbage_flush_reduction: int`
- [x] 1.11 Rewrite `apply_to_config(config: RoundConfig)` to write the new RoundConfig fields (hold_slots_bonus, preview_count_bonus, instant_arr, instant_soft_drop, garbage_flush_reduction, b2b_shield_count, flexible_b2b, safety_net)

## 2. RoundConfig Extensions

- [x] 2.1 Add `b2b_shield_count: int` (default 0) to `round_config.gd`
- [x] 2.2 Add `flexible_b2b: bool` (default false) to `round_config.gd`
- [x] 2.3 Add `instant_arr: bool` and `instant_soft_drop: bool` (default false) to `round_config.gd`
- [x] 2.4 Add `garbage_flush_reduction: int` (default 0) to `round_config.gd`

## 3. TetrisBoard Signal Additions

- [x] 3.1 Add `signal piece_rotated(piece_type: String)` to `tetris_board.gd` and emit it inside the rotation handler each time the active piece is rotated
- [x] 3.2 Add `signal lines_cleared(row_indices: Array[int])` to `tetris_board.gd` and emit it (with the indices of cleared rows, 0 = topmost visible row) immediately before the corresponding `attack_generated` in `_emit_attack_events`
- [x] 3.3 Add `signal b2b_broken(streak: int)` to `tetris_board.gd` and emit it when B2B breaks, carrying the streak count at break
- [x] 3.4 Apply `b2b_shield_count` in the B2B break logic: consume one shield (decrement) instead of breaking B2B when `config.b2b_shield_count > 0`
- [x] 3.5 Apply `flexible_b2b` in the B2B maintenance logic: treat any spin-lock as a B2B-preserving move when `config.flexible_b2b` is true
- [x] 3.6 Apply `instant_arr` and `instant_soft_drop` in `TetrisBoard`: when the respective RoundConfig flag is true, set the input handler's auto-repeat rate or soft-drop interval to 0

## 4. RunManager — Keystone Effect Pipeline

- [x] 4.1 Add per-round state fields to `RunManager`: `_last_attack_was_quad: bool`, `_t_spin_rotations: int`, `_pc_count_this_round: int`; reset all to zero/false at round start
- [x] 4.2 Connect `current_board.piece_rotated` to a new `_on_piece_rotated(piece_type: String)` handler in `_setup_round()` (increment `_t_spin_rotations` when piece_type is "T", reset on non-T); disconnect in `_end_round()`
- [x] 4.3 Connect `current_board.lines_cleared` to `_on_lines_cleared(row_indices: Array[int])` in `_setup_round()`; store as `_last_cleared_rows`; disconnect in `_end_round()`
- [x] 4.4 Connect `current_board.b2b_broken` to `_on_b2b_broken(streak: int)` in `_setup_round()`; disconnect in `_end_round()`
- [x] 4.5 Implement `_on_b2b_broken(streak: int)`: if any owned keystone has `final_blow`, add `streak × 2` to `quota_accumulated` and set `current_config.b2b_disabled = true`
- [x] 4.6 Implement `_apply_keystone_suppressions(attack: int, event_type: String) -> int`: return 0 if any owned keystone's suppression flag matches the event type; otherwise return attack unchanged
- [x] 4.7 Implement `_apply_keystone_flat_bonuses(attack: int, event_type: String) -> int`: sum all applicable flat bonuses (per-clear-type and per-technique) across owned keystones and add to attack
- [x] 4.8 Implement `_apply_keystone_multipliers(attack: int, event_type: String) -> int`: apply all applicable multipliers (consecutive quad, single, tspin_double, tspin_triple, combo, pc_first, pc_after_first, risky_business) by multiplying into a running float; also apply Daze timer extension when event is "tetris"
- [x] 4.9 Insert the three keystone methods into `_on_attack_generated` after `_apply_techniques` and before `_drain_attack`: suppressions → flat bonuses → multipliers
- [x] 4.10 After the keystone multiplier phase, update `_last_attack_was_quad` (true if event_type == "tetris", else false) and increment `_pc_count_this_round` when event_type == "perfect_clear"
- [x] 4.11 In `_flush_pending_garbage()`, apply `current_config.garbage_flush_reduction`: `flush = max(0, mini(pending_garbage, 8) - current_config.garbage_flush_reduction)`
- [x] 4.12 Remove dead `second_wind_triggered` logic from RunManager and `second_wind_used_this_round` from RunState (no longer used)

## 5. RunManager — End-of-Round Economy

- [x] 5.1 At round end (win), sum `end_round_coins` from all owned keystones and credit to `Economy.coins`
- [x] 5.2 At round end (win), if any owned keystone has `overkill_coins`, add `surplus_attack` to `Economy.coins`
- [x] 5.3 At round end (win), if any owned keystone has `time_coins`, add `int(round_timer / 5.0)` to `Economy.coins`

## 6. Keystone Selection Screen — Starter Mode & Conditional Filtering

- [x] 6.1 Add `var starter_only: bool = false` property to `keystone_selection.gd`
- [x] 6.2 In `keystone_selection.gd`'s `_draw_three_keystones()`, when `starter_only` is true, filter the pool to keystones with `is_starter = true` before drawing
- [x] 6.3 In `keystone_selection.gd`'s draw-pool logic, filter out any keystone whose `requires_keystone_id` is non-empty and not present in `RunState.used_keystone_ids`

## 7. Run-Start Starter Selection in RunManager

- [x] 7.1 In `RunManager.start_run()`, replace the direct call to `start_round()` with a call to `_show_starter_keystone_selection()`
- [x] 7.2 Implement `_show_starter_keystone_selection()`: instantiate the keystone selection scene, set `starter_only = true`, add to tree, connect `keystone_chosen` to `_on_starter_keystone_chosen`
- [x] 7.3 Implement `_on_starter_keystone_chosen(_keystone: Keystone)`: call `start_round()` (no shop between starter pick and round 1)

## 8. Keystone Resource Files

- [x] 8.1 Delete all 8 existing `.tres` files from `game/resources/data/keystones/`
- [x] 8.2 Create `simple_bow.tres` (Starter, single_bonus=1, double_bonus=1)
- [x] 8.3 Create `simple_shield.tres` (Starter, garbage_flush_reduction=2)
- [x] 8.4 Create `simple_sword.tres` (Starter, quad_bonus=2)
- [x] 8.5 Create `simple_wand.tres` (Starter, tspin_single_bonus=2, tspin_double_bonus=2, tspin_triple_bonus=2)
- [x] 8.6 Create `simple_bag.tres` (Starter, hold_slots_bonus=1)
- [x] 8.7 Create `slightly_magical_coin.tres` (Starter, end_round_coins=1)
- [x] 8.8 Create `dual_wielding.tres` (Tetris, consecutive_quad_multiplier=2.0)
- [x] 8.9 Create `sharpen.tres` (Tetris, per_technique_quad_bonus=2)
- [x] 8.10 Create `daze.tres` (Tetris, daze_stun_seconds=2.0)
- [x] 8.11 Create `simplicity.tres` (Tetris, quad_multiplier=2.0, suppress_spins=true)
- [x] 8.12 Create `great_sword.tres` (Tetris, quad_bonus=8, requires_keystone_id="slightly_magical_coin")
- [x] 8.13 Create `dizzy.tres` (T-Spin, dizzy=true)
- [x] 8.14 Create `double_trouble.tres` (T-Spin, tspin_double_multiplier=2.0, suppress_tspin_single=true, suppress_tspin_triple=true)
- [x] 8.15 Create `triple_threat.tres` (T-Spin, tspin_triple_multiplier=3.0, suppress_tspin_single=true, suppress_tspin_double=true)
- [x] 8.16 Create `enchant.tres` (T-Spin, per_technique_tspin_bonus=2)
- [x] 8.17 Create `consistency.tres` (B2B, b2b_bonus=1)
- [x] 8.18 Create `safety_net.tres` (B2B, safety_net=true)
- [x] 8.19 Create `final_blow.tres` (B2B, final_blow=true)
- [x] 8.20 Create `flexible.tres` (B2B, flexible_b2b=true)
- [x] 8.21 Create `flurry.tres` (Combo, combo_multiplier=2.0, combo_multiplier_threshold=5)
- [x] 8.22 Create `holy_cheese.tres` (Combo, single_multiplier=2.0, suppress_non_singles=true)
- [x] 8.23 Create `beginners_luck.tres` (PC, pc_first_multiplier=3.0)
- [x] 8.24 Create `veterans_luck.tres` (PC, pc_after_first_multiplier=2.0)
- [x] 8.25 Create `midas_touch.tres` (Economic, overkill_coins=true)
- [x] 8.26 Create `golden_watch.tres` (Economic, time_coins=true)
- [x] 8.27 Create `magical_coin.tres` (Economic, end_round_coins=2, requires_keystone_id="slightly_magical_coin")
- [x] 8.28 Create `full_potential.tres` (Utility, instant_arr=true, instant_soft_drop=true)
- [x] 8.29 Create `foresight.tres` (Utility, preview_count_bonus=2)
- [x] 8.30 Create `risky_business.tres` (Utility, risky_business=true)

## 9. Testing

- [x] 9.1 Create `game/tests/unit/test_keystones.gd` extending `GutTest`; save/restore `RunState.techniques` and `RunState.keystones` in before/after each
- [x] 9.2 Add test: suppression zeroes tspin attack when `suppress_spins` is true
- [x] 9.3 Add test: suppression does not affect quad when only spin suppression is set
- [x] 9.4 Add test: flat bonus added to matching event type (e.g., `quad_bonus = 2` on `"tetris"`)
- [x] 9.5 Add test: per-technique quad bonus counts only quad-applicable techniques (e.g., 2 techniques → +4 with `per_technique_quad_bonus = 2`)
- [x] 9.6 Add test: multiplier applied after flat bonus (technique 4 + quad_bonus 2, multiplier 2.0 = 12)
- [x] 9.7 Add test: `quad_multiplier` does not affect tspin events
- [x] 9.8 Add test: `combo_multiplier` applies only when combo count exceeds `combo_multiplier_threshold`
- [x] 9.9 Add test: Dual Wielding consecutive quad multiplier fires on second quad, not first
- [x] 9.10 Add test: Dual Wielding resets after a non-quad clear
- [x] 9.11 Add test: Dizzy adds 4 when rotation count exceeds 4; does not fire at exactly 4
- [x] 9.12 Add test: `pc_first_multiplier` applies on first PC, `pc_after_first_multiplier` on second
- [x] 9.13 Add test: `garbage_flush_reduction = 2` reduces flush from 5 to 3 (via `_flush_pending_garbage`)
- [x] 9.14 Add test: `end_round_coins` from two keystones (1 + 2) credits 3 coins at round end
- [x] 9.15 Add test: `overkill_coins` grants coins equal to surplus attack
- [x] 9.16 Add test: `time_coins` grants floor(time / 5) coins (e.g., 17s → 3 coins)
- [x] 9.17 Add test: conditional availability — keystone with `requires_keystone_id` excluded from pool when prerequisite not owned
- [x] 9.18 Add test: conditional availability — keystone appears in pool when prerequisite is in `used_keystone_ids`
- [x] 9.19 Run full GUT test suite (`game/tests/run_tests.tscn`) and fix any failures in implementation code (do not modify test code)
