## Context

Eight discrete issues accumulated across multiple feature branches: two broken unit tests referencing removed Technique API, a dead voucher with no effect, a TetrisBoard hold stub that was never implemented, a keystone selection filter bug, a ground-check gap in horizontal movement, an unimplemented Side Strike column check, widespread Tetris/tetris terminology (the game uses "Quad" throughout), and a stale keystone filename. These are independent fixes with no shared runtime dependency, but they share the same release gate.

## Goals / Non-Goals

**Goals:**
- All GUT tests pass before release
- simple_bag's second hold slot works as a queue-based hold
- Starter keystones never appear in post-boss selection
- Pieces do not lock in mid-air after a horizontal slide over a hole
- Side Strike correctly requires the I-piece to touch the left or right wall column
- In-game text uses "Quad" everywhere; technique tags are `"quad"` not `"tetris"`; specialist_discount now correctly matches Quad-category keystones
- sharp_eye is removed cleanly with no dead state
- simple_bow renamed to simple_flail

**Non-Goals:**
- Adding a full tag system to keystones (deferred; `category` field is sufficient for now)
- Fixing consumable_expert being a no-op (separate issue, not user-reported)
- Fixing technique_capacity not persisted in RunSave (separate issue, not in scope)
- Removing dead `persistence` technique check in run_manager.gd (cosmetic only)

## Decisions

### Hold queue vs. indexed slots
**Decision:** Replace `input_hold()` with a queue: append to back if `held_pieces.size() < config.hold_slots`, otherwise pop front and push back.

**Rationale:** The original code had `held_pieces[0] = swap_type` (swap in place), which never filled slot 1. A queue is the minimal change that makes both slots work. `HoldDisplay` already iterates `held_pieces` by index so it renders correctly with no changes. The behavior for 1 slot is identical to the old swap: pop-front + push-back on a 1-element list is a swap.

**Alternative considered:** Indexed cycling (cycle which slot is "active"). More complex, no user-visible benefit since Tetris hold is typically single-purpose.

### Side Strike: locked_col via AttackContext
**Decision:** Add `locked_col: int = -1` to `AttackContext` (pivot.x of the locked piece). RunManager populates it in `_build_attack_context()`. Evaluator uses a new `"side_strike"` effect type that checks `ctx.lines_cleared == 4 and (ctx.locked_col == 0 or ctx.locked_col >= board_width - 4)`.

`board_width - 4` = 6 for a standard 10-wide board; the I-piece occupying columns 6-9 is the rightmost valid placement. The check covers pieces 4 cells wide. Hardcoded to 4 because only the I-piece makes 4-line clears in standard Tetris.

**Alternative considered:** Passing cleared row cell data to evaluate which column was used. Overkill — we already know the pivot from lock processing, and the I-piece width is constant.

### Tetris → Quad: rename tags in data, fix check in code
**Decision:** Rename the technique tag value `"tetris"` → `"quad"` in all .tres files. Update `_apply_keystone_flat_bonuses` to check `"quad" in t.tags`. This also fixes the silent specialist_discount bug where `ks.category = "Quad"` never matched `t.tags = ["tetris"]`.

The internal `effect_type = "tetris_echo"` and `id = "tetris_echo"` stay unchanged — they are internal identifiers not player-visible. Only `display_name` (→ "Quad Echo") and `description` change.

**Alternative considered:** Case-normalizing the specialist_discount comparison to make `"Quad" == "tetris"` work. Rejected — the root cause is the wrong tag value; normalizing would just paper over it.

### Midair lock: re-check ground after horizontal move
**Decision:** In `_move_horizontal()`, after `_try_move()` succeeds, call `_cells_valid(current_type, current_rotation, current_pivot + Vector2i(0, 1))`. If that returns `true` (the cell below is empty), the piece floated — set `is_on_ground = false` and reset `lock_timer = 0.0`. Otherwise call `_reset_lock()` as before.

**Rationale:** Minimal change — one extra validity check per successful horizontal move. `_try_rotate()` does not have the same bug because SRS kicks already re-evaluate the piece position relative to its surroundings.

### Starter filter: equality check
**Decision:** Replace `not starter_only or ks.is_starter` with `ks.is_starter == starter_only`. When `starter_only = false` (post-boss), this excludes all `is_starter = true` keystones. When `starter_only = true` (initial), it includes only starters.

## Risks / Trade-offs

- **Hold queue changes combo feel slightly**: With 2 slots and hold lockout disabled, players can cycle both held pieces in a single placement. This is the intended behavior for Simple Bag. No risk with hold lockout enabled (default).
- **Side Strike column check narrows the tech**: Players who relied on "Tetrises anywhere" getting +1 will lose that bonus on center placements. This is the intended design; the previous flat bonus was the bug.
- **Tag rename touches many files**: ~13 .tres files. Each is a small change (one field value). Risk is a missed file — mitigated by grepping `tags.*tetris` after edits.
- **"Tetris Echo" rename to "Quad Echo"**: If any save file stores technique display_name (it doesn't — RunSave stores technique IDs), this would be a save-compat issue. RunSave stores `id = "tetris_echo"` which is unchanged.

## Open Questions

*(none — all decisions resolved during exploration)*
