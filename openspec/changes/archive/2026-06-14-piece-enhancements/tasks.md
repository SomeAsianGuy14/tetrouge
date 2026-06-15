## 1. Enhancement data module

- [x] 1.1 Create `game/resources/piece_enhancements.gd` with `class_name PieceEnhancements`: constants `HONED`, `AMPLIFIED`, `GILDED`, `REINFORCED` (type id strings), per-cell magnitudes (honed = 1, amplified = 0.25, gilded = 1, reinforced = 1), and per-type style colors (silver fill, golden fill, brown fill + silver border, yellow triangle)
- [x] 1.2 Implement `count_in_rows(enh_grid: Array, rows: Array) -> Dictionary` returning per-type cell counts across the given rows
- [x] 1.3 Implement `honed_bonus(counts) -> int`, `gilded_coins(counts) -> int`, `shield_charges(counts) -> int` (all linear in cell count, 0 for empty counts)
- [x] 1.4 Implement `amplified_multiplier(counts) -> float` (1.0 + 0.25 × cells, clamped at 3.0)

## 2. Board: enhancement layer

- [x] 2.1 Add `enh_grid: Array` to `tetris_board.gd`, initialized to all `""` alongside `grid` in `_init_grid()`
- [x] 2.2 Mirror `enh_grid` in `_find_and_clear_rows()`: remove the same row indices, insert empty (`""`-filled) rows at index 0
- [x] 2.3 Mirror `enh_grid` in `insert_garbage_rows()`: pop the top row, append an unenhanced (`""`-filled) row at the bottom
- [x] 2.4 Verify `clear_board()` resets `enh_grid` via `_init_grid()`

## 3. Board: spawn signal, falling-piece enhancement, hold

- [x] 3.1 Add `current_enhancement: String = ""` field and a new `signal piece_spawned(piece_type: String)`, emitted from `_spawn_next()` only (not on hold swaps)
- [x] 3.2 Add `held_enhancements: Array` parallel to `held_pieces`, cleared alongside it in `clear_board()`
- [x] 3.3 Update `input_hold()` to move `current_enhancement` into/out of `held_enhancements` in lockstep with the `held_pieces`/`current_type` swap, without emitting `piece_spawned`

## 4. Board: lock-time stamping and pending counts

- [x] 4.1 In `_lock_piece()`, stamp `enh_grid` at the locked piece's cells with `current_enhancement` (mirroring the `grid` color stamp), then reset `current_enhancement = ""`
- [x] 4.2 In `_lock_piece()`, before any row removal, compute `pending_enhancement_counts := PieceEnhancements.count_in_rows(enh_grid, full_rows)` and store it as a board field readable by RunManager (valid identically with and without line-clear delay)

## 5. Board: rendering

- [x] 5.1 In `_draw()`, render each cell's per-type styling based on its `enh_grid` entry: `honed` = solid silver fill, `gilded` = solid golden fill, `reinforced` = solid brown fill with a silver border outline, `amplified` = retain the piece color and draw a small centered yellow triangle
- [x] 5.2 In `_draw()`, render the same per-type styling on the falling piece's cells (and ghost) when `current_enhancement != ""`

## 6. Consumable & technique data

- [x] 6.1 Add `enhance_type: String = ""` and `enhance_pieces: int = 0` exports to `game/resources/consumable.gd`
- [x] 6.2 Add `"piece_enhancer"` to `technique_evaluator.gd`'s no-op effect-type list (returns 0 attack/coins delta, no unknown-effect warning)
- [x] 6.3 Create 4 enhancement consumable `.tres` files (one per type: honed/amplified/gilded/reinforced), each with `enhance_pieces = 4`, `use_timing = DURING_ROUND`, in `resources/data/consumables/`
- [x] 6.4 Create 2-3 `piece_enhancer` technique `.tres` files with `params = {"enhancement": <type>, "every_n": N}` for `N` in the 4-6 range, in `resources/data/techniques/`

## 7. RunManager: grant assignment

- [x] 7.1 Connect to `current_board.piece_spawned` in `run_manager.gd`
- [x] 7.2 Add grant state: active consumable grant `{type, remaining}` (or null), per-round technique cadence counters; reset both at round start
- [x] 7.3 On `piece_spawned`, assign at most one enhancement to `current_board.current_enhancement`: active consumable grant wins (decrement/expire it), else the first technique whose cadence fires this spawn wins; all periodic cadence counters advance regardless of which grant wins
- [x] 7.4 Wire mid-round use of an enhancement consumable to start a new timed grant, extend the remaining count for a same-type active grant, or replace a different-type active grant (last use wins)

## 8. RunManager: benefit application

- [x] 8.1 In `_on_line_clear_delay_started`, read `current_board.pending_enhancement_counts` and compute per-type counts via `PieceEnhancements.count_in_rows`
- [x] 8.2 Pay Gilded coins (`PieceEnhancements.gilded_coins`) and add Reinforced charges to `_garbage_shield` immediately, alongside the existing technique coin payout
- [x] 8.3 In `_on_attack_generated`, for primary clear events only (not `b2b`/`combo`), add `PieceEnhancements.honed_bonus(counts)` into `modified` before suppression/keystone flat bonuses
- [x] 8.4 For primary clear events only, apply `PieceEnhancements.amplified_multiplier(counts)` after keystone multipliers are applied
- [x] 8.5 Reset `_garbage_shield = 0` at round start

## 9. RunManager: shield absorption

- [x] 9.1 In `_tick_enemy_garbage()`, before packet creation, reduce the wave's line count by `_garbage_shield` (`n = max(0, n - shield)`), consuming only the charges used; if the wave reduces to 0 lines, create no packet and skip the enemy attack animation

## 10. UI: ShieldBar

- [x] 10.1 Create `game/scenes/game/shield_bar.gd` (`class_name ShieldBar extends Control`), mirroring `attack_bar.gd`'s pattern: `_draw()` renders one silver block per charge stacked from the bottom, capped at 8, with "+N" overflow text above the filled blocks when charges > 8; `update_charges(charges: int)` triggers `queue_redraw()`
- [x] 10.2 In `run_manager.gd`, instantiate `ShieldBar` alongside `_attack_bar`, position it on the opposite side of the board, call `update_charges(_garbage_shield)` whenever the shield pool changes, and free it on round teardown

## 11. UI: HoldDisplay enhancement styling

- [x] 11.1 Update `hold_display.gd` to read `TetrisBoard.held_enhancements` and render the matching per-type styling over each held piece slot, refreshing on `board_updated`

## 12. Feedback popups

- [x] 12.1 In `run_manager.gd`, schedule one popup entry per enhancement type that contributed to a clear (e.g. "+3 Gilded"), using a color distinct from technique/keystone popups, in the same cascade scheduled in `_on_line_clear_delay_started`

## 13. Testing

- [x] 13.1 `honed_bonus`: 0 cells → 0, 3 cells → 3
- [x] 13.2 `amplified_multiplier`: 0 cells → 1.0, 2 cells → 1.5, 10 cells → 3.0 (clamped)
- [x] 13.3 `gilded_coins` and `shield_charges`: linear in cell count, 0 for empty counts
- [x] 13.4 `count_in_rows`: correctly tallies per-type counts across a given set of rows, ignoring rows not included
- [x] 13.5 `enh_grid` stays aligned with `grid` through `_find_and_clear_rows()` for single-row and multi-row clears
- [x] 13.6 `enh_grid` stays aligned with `grid` through `insert_garbage_rows()`, with inserted garbage rows unenhanced
- [x] 13.7 `clear_board()` resets `enh_grid` to fully empty
- [x] 13.8 Locking an enhanced piece stamps `enh_grid` at the same cells as the `grid` stamp, matching `current_enhancement`
- [x] 13.9 `pending_enhancement_counts` captured at lock matches `enh_grid` counts in the full rows, before rows are removed (same result with and without line-clear delay)
- [x] 13.10 Holding an enhanced piece moves its enhancement into `held_enhancements` at the matching index
- [x] 13.11 Swapping a held enhanced piece back into play restores `current_enhancement`, does not consume an active grant, and does not advance periodic cadence
- [x] 13.12 Grant precedence: an active consumable grant wins over a periodic technique grant firing on the same spawn, and the periodic counter still advances
- [x] 13.13 Periodic technique grant fires on exactly every Nth spawn
- [x] 13.14 Consumable grant enhances exactly the next N spawned pieces and then expires
- [x] 13.15 Using a same-type enhancement consumable while a grant is active extends `remaining`; using a different-type consumable replaces the grant
- [x] 13.16 Shield pool absorbs a wave fully (no packet, charges reduced) and partially (smaller packet, charges hit 0)
- [x] 13.17 Shield pool resets to 0 at round start
- [x] 13.18 Honed bonus is added before keystone multipliers: 2 honed cells, base 4, ×2 keystone → 12
- [x] 13.19 Amplified multiplier is applied after keystone multipliers: 2 amplified cells, base 4, ×2 keystone → `int(4 × 2 × 1.5)` = 12
- [x] 13.20 Gilded coins are paid exactly once per clear even when the clear also generates b2b/combo bonus attack events
- [x] 13.21 A suppressed clear (attack = 0) still pays Gilded coins and Reinforced charges from the cleared cells
