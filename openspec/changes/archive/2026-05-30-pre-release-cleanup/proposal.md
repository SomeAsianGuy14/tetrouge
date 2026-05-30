## Why

The game is approaching initial release and has several accumulated bugs, broken tests, inconsistent terminology, and a dead voucher that need to be resolved before players see it. Fixing these now prevents shipping with known incorrect behavior and ensures the test suite is a reliable safety net going forward.

## What Changes

- **Fix test_keystones.gd**: Two tests use stale API (`flat_bonus_by_event` field removed from Technique; `pending_garbage` field / non-void `_flush_pending_garbage` return). Rewrite to use current Technique tags and `_garbage_packets`.
- **Remove sharp_eye voucher**: Effect (`sharp_eye_active`) was never wired to any gameplay logic. Remove the .tres file and all references in RunState and RunSave.
- **Fix Simple Bag (second hold slot)**: `input_hold()` in TetrisBoard contains a `pass` stub — the second slot is never filled. Rewrite hold logic as a queue: append current to back when slots are available; otherwise pop front and push back.
- **Fix starter keystones appearing post-boss**: `KeystoneSelection._draw_three_keystones()` allows starters (`is_starter = true`) in non-starter draws because `not starter_only or ks.is_starter` passes all keystones when `starter_only = false`. Fix to `ks.is_starter == starter_only`.
- **Fix midair lock when sliding**: In `TetrisBoard._move_horizontal()`, a successful slide does not re-check whether the piece is still on the ground. If the piece slides over a hole, `is_on_ground` stays `true` and the lock timer fires, locking the piece in mid-air. Fix: after a successful horizontal move, check if the cell below is still blocked; if not, clear `is_on_ground`.
- **Implement Side Strike column check**: Side Strike's description says "far-left or far-right column" but the implementation is a flat quad bonus with no column check. Add `locked_col: int` to `AttackContext`, populate it in RunManager, and add a `"side_strike"` effect type to TechniqueEvaluator that checks `locked_col == 0 or locked_col >= board_width - 4`.
- **Rename Tetris → Quad throughout**: All in-game descriptions and technique tags using "Tetris/tetris" should use "Quad/quad" for consistency with the game's terminology. Affects ~9 technique .tres files, ~6 keystone .tres files, 1 boss modifier .tres, the "Tetris Echo" display name (→ "Quad Echo"), technique tags array values, and one check in `_apply_keystone_flat_bonuses`. Also fixes the **specialist_discount** silent bug: `ks.category = "Quad"` never matched `t.tags = ["tetris"]`, so Quad-category keystones never granted the 25% discount.
- **Rename simple_bow → simple_flail**: Update id, display_name, and filename for the Simple Bow starter keystone.

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `tetris-core`: Hold logic rewritten as queue (Simple Bag fix); horizontal move now re-checks ground state (midair lock fix).
- `attack-system`: `AttackContext` gains `locked_col: int` field for Side Strike column detection.
- `technique-evaluator`: New `"side_strike"` effect type; technique tag `"tetris"` renamed `"quad"` in evaluator checks.
- `technique-pool`: Tetris→Quad in all technique .tres descriptions, display names, and tags.
- `keystones`: simple_bow→simple_flail rename; Tetris→Quad in keystone .tres descriptions; post-boss starter filter fix.
- `vouchers`: sharp_eye removed.
- `unit-tests`: test_keystones.gd updated to current API.

## Impact

- `game/scenes/tetris/tetris_board.gd` — hold logic, horizontal move grounding
- `game/resources/attack_context.gd` — new field
- `game/scenes/game/technique_evaluator.gd` — new effect type, tag rename in check
- `game/scenes/game/run_manager.gd` — populate `locked_col` in `_build_attack_context()`
- `game/resources/data/techniques/*.tres` — ~9 description updates, 6 tag renames
- `game/resources/data/keystones/*.tres` — ~6 description updates, simple_bow rename/delete
- `game/resources/data/boss_modifiers/the_purge.tres` — description update
- `game/autoloads/run_state.gd` — remove `sharp_eye_active`
- `game/scripts/run_save.gd` — remove sharp_eye save/load
- `game/scenes/keystone_selection/keystone_selection.gd` — starter filter fix
- `game/tests/unit/test_keystones.gd` — two test rewrites
