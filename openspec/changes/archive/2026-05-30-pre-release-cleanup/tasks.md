## 1. Remove sharp_eye voucher

- [x] 1.1 Delete `game/resources/data/vouchers/sharp_eye.tres`
- [x] 1.2 Remove `var sharp_eye_active: bool = false` from `game/autoloads/run_state.gd`
- [x] 1.3 Remove `sharp_eye_active = false` from `reset_run()` in `run_state.gd`
- [x] 1.4 Remove the `"sharp_eye": sharp_eye_active = true` case from `_apply_voucher_effects()` in `run_state.gd`
- [x] 1.5 Remove `cfg.set_value("run", "sharp_eye_active", ...)` and `cfg.get_value("run", "sharp_eye_active", ...)` from `game/scripts/run_save.gd`

## 2. Rename simple_bow → simple_flail

- [x] 2.1 Rename `game/resources/data/keystones/simple_bow.tres` to `simple_flail.tres`
- [x] 2.2 Update `id = "simple_bow"` → `id = "simple_flail"` and `display_name = "Simple Bow"` → `display_name = "Simple Flail"` inside the renamed file

## 3. Fix starter keystones appearing post-boss

- [x] 3.1 In `game/scenes/keystone_selection/keystone_selection.gd`, change line `if not starter_only or ks.is_starter:` to `if ks.is_starter == starter_only:`

## 4. Fix midair lock when sliding

- [x] 4.1 In `game/scenes/tetris/tetris_board.gd`, update `_move_horizontal()`: after `_try_move()` succeeds and `is_on_ground` is true, check `_cells_valid(current_type, current_rotation, current_pivot + Vector2i(0, 1))`; if that returns `true` (cell below is empty), set `is_on_ground = false` and `lock_timer = 0.0`; otherwise call `_reset_lock()` as before

## 5. Fix Simple Bag second hold slot

- [x] 5.1 Rewrite `input_hold()` in `game/scenes/tetris/tetris_board.gd` to use queue logic: if `held_pieces.size() < config.hold_slots`, append current piece and spawn from `piece_queue`; otherwise pop front of `held_pieces` as new current and push current to back — remove the `pass` stub entirely

## 6. Add locked_col to AttackContext

- [x] 6.1 Add `@export var locked_col: int = -1` to `game/resources/attack_context.gd`
- [x] 6.2 In `game/scenes/game/run_manager.gd`, populate `ctx.locked_col` in `_build_attack_context()` using the locked pivot x-coordinate (store `locked_pivot.x` from the `piece_locked` signal handler into a member variable, then assign it here)

## 7. Implement Side Strike column check

- [x] 7.1 In `game/scenes/game/technique_evaluator.gd`, replace the `"flat"` effect type on Side Strike by adding a `"side_strike"` match case: return `p.get("bonus", 1)` when `ctx.lines_cleared == 4 and (ctx.locked_col == 0 or ctx.locked_col >= 6)`, else return 0
- [x] 7.2 Update `game/resources/data/techniques/side_strike.tres`: change `effect_type = "flat"` → `effect_type = "side_strike"`, update params to `{"bonus": 1}`, update description to `"If a Quad clear uses the far-left or far-right column, send +1 extra attack."`

## 8. Tetris → Quad: technique tags and descriptions

- [x] 8.1 In `game/scenes/game/run_manager.gd`, update `_apply_keystone_flat_bonuses()`: change `"tetris" in t.tags` → `"quad" in t.tags`
- [x] 8.2 Update `back_to_back_pressure.tres`: tags `["tetris"]` → `["quad"]`; description: "Back-to-back Quads send +2 attack."
- [x] 8.3 Update `delayed_cannon.tres`: tags `["tetris"]` → `["quad"]`; description: "Every second Quad sends +5 attack instead of the usual bonus."
- [x] 8.4 Update `four_disciplines.tres`: tags `["tetris", "risk"]` → `["quad", "risk"]`; description: "Other line clears send -1 attack, but Quads send +5 attack."
- [x] 8.5 Update `reckless_assault.tres`: tags `["tetris", "risk"]` → `["quad", "risk"]`; description: "If your board is above 60% height, Quads send +4 attack."
- [x] 8.6 Update `tetris_echo.tres`: tags `["tetris", "general"]` → `["quad", "general"]`; `display_name = "Quad Echo"`; description: "After a Quad, your next single/double/triple sends +1 attack."
- [x] 8.7 Update `sharpen.tres` (technique): tags `["general", "tetris"]` → `["general", "quad"]`

## 9. Tetris → Quad: keystone and boss modifier descriptions

- [x] 9.1 Update `dual_wielding.tres`: description: "Consecutive Quads deal 2× damage."
- [x] 9.2 Update `daze.tres`: description: "Quads delay the next garbage drop by 2 seconds."
- [x] 9.3 Update `sharpen.tres` (keystone): description: "Each Quad-applicable technique adds +2 damage to Quads."
- [x] 9.4 Update `great_sword.tres`: description: "Quads deal +8 damage. Requires: Slightly Magical Coin."
- [x] 9.5 Update `simplicity.tres`: description: "Quads deal 2× damage. T-Spins deal no damage."
- [x] 9.6 Update `simple_sword.tres`: description: "Quads deal +2 damage."
- [x] 9.7 Update `game/resources/data/boss_modifiers/the_purge.tres`: description: "Only Quads and T-spins count toward the quota."

## 10. Fix test_keystones.gd

- [x] 10.1 Rewrite `_make_technique()` helper: instead of setting `t.flat_bonus_by_event`, set `t.tags = [event]` (so `_make_technique("quad", 1)` creates a technique with `tags = ["quad"]`) — remove the second parameter `bonus` since it is unused by the current API
- [x] 10.2 Rewrite `test_garbage_flush_reduction_reduces_flush_amount`: remove `_rm.pending_garbage = 5`; instead push a `GarbagePacket`-equivalent object to `_rm._garbage_packets` with `lines = 5` (or use a larger packet to verify partial flush); assert on `_rm._garbage_packets` state after calling `_flush_pending_garbage()` (which returns void — do not capture its return value)
- [x] 10.3 Run the full GUT test suite and confirm all tests in `test_keystones.gd` pass

## 11. Testing

- [x] 11.1 Add test in `test_technique_system.gd`: Side Strike fires when `locked_col = 0` and `lines_cleared = 4`
- [x] 11.2 Add test: Side Strike fires when `locked_col = 6` and `lines_cleared = 4`
- [x] 11.3 Add test: Side Strike does not fire when `locked_col = 3` (centre placement)
- [x] 11.4 Add test: Side Strike does not fire when `lines_cleared = 2` even if `locked_col = 0`
- [x] 11.5 Add test: hold queue with 2-slot capacity fills second slot on second hold (single-slot behavior unchanged)
- [x] 11.6 Run full GUT suite and confirm all tests pass
