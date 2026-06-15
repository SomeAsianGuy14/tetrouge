# Design: piece-enhancements

## Context

The board (`tetris_board.gd`) stores cells as ints in `grid` (0 = empty, 1–7 = piece colors, 9 = garbage). Rows are cleared by `_find_and_clear_rows()` (remove row arrays, insert empty rows at top) and garbage enters via `insert_garbage_rows()` (pop top rows, append garbage rows at bottom). Since the line-clear-delay change, `line_clear_delay_started` fires on every clear (with or without delay) before clears are processed, and RunManager evaluates techniques there against pre-clear state.

RunManager owns the attack pipeline: `raw + technique_atk → suppression → keystone flats → consumable flats → surge → keystone multipliers`. Consumables (`Consumable` resource) apply via `apply_to_config()` or mid-round handlers; techniques are data resources dispatched by `effect_type`.

## Goals / Non-Goals

**Goals:**
- Enhanced cells persist on the board and survive row shifts correctly (clears, garbage, board reset).
- Benefits trigger when rows containing enhanced cells clear: Honed (+attack/cell), Amplified (×attack/cell), Gilded (+coins/cell), Reinforced (+1 garbage-shield charge/cell).
- Grants from consumables ("next N pieces") and techniques ("every Nth piece"), composable and deterministic.
- Benefit math lives in pure, unit-testable functions.
- Identical behaviour with and without the line-clear delay (Full Potential).
- Holding an enhanced piece preserves its enhancement; swapping it back in does not consume a new grant.

**Non-Goals:**
- Mid-round save/load of board enhancement state (runs save between rounds; board state is never persisted).
- Per-enhancement magnitudes configured on granting items (v1 uses global constants; items only choose type and piece count).
- New shop UI; enhancement consumables/techniques flow through the existing pools automatically.

## Decisions

**1. Parallel enhancement grid, not encoded cell values.**
`tetris_board.gd` gains `enh_grid: Array` (same shape as `grid`, `""` = none, else type id). Encoding enhancement into the int cell value (bit flags) was rejected: a dozen consumers read `grid` (`_is_row_full`, perfect-clear checks, `_draw`, crack rendering, debug overlay, tests) and any unmasked read would silently break. The parallel array needs mirroring in exactly three choke points — `_init_grid`, `_find_and_clear_rows`, `insert_garbage_rows` — each covered by unit tests.

**2. New `piece_enhancements.gd` static helper for types and benefit math.**
Constants (`HONED/AMPLIFIED/GILDED/REINFORCED`, per-cell magnitudes, per-type style colors) plus pure functions: `count_in_rows(enh_grid, rows) -> Dictionary`, `honed_bonus(counts) -> int`, `amplified_multiplier(counts) -> float`, `gilded_coins(counts) -> int`, `shield_charges(counts) -> int`. Pure functions keep the GUT tests trivial and keep RunManager thin.

**3. Assignment at spawn via a new `piece_spawned` signal.**
`_spawn_next()` emits `piece_spawned(piece_type)`; RunManager's handler consults its grant state and sets `board.current_enhancement` (String). The board renders the falling piece with its per-type styling and stamps `enh_grid` on lock. Alternatives rejected: a callback property on the board (couples board to RunManager types), or deciding at lock time (falling piece couldn't be rendered as enhanced).

**4. Grant precedence: timed (consumable) over periodic (technique); one enhancement per piece.**
- Consumable grant: `{type, remaining}` — decrements per spawned piece while active; multiple uses of the same consumable extend `remaining`; a different-type consumable replaces the active grant (last use wins).
- Technique grant: every Nth spawn (per-round spawn counter; N from params). If both fire on the same spawn, the consumable wins but the technique cadence still advances — keeps cadence deterministic and independent.
- Two periodic techniques colliding on the same spawn: first in `RunState.techniques` order wins.

**5. Counts captured at lock, applied once per clear on the primary attack event.**
`_lock_piece()` computes `pending_enhancement_counts` from the full rows *before* clearing (the unified `line_clear_delay_started` emission point), so both delay paths see identical counts. RunManager reads them in `_on_line_clear_delay_started`, pays Gilded coins and Reinforced charges immediately (alongside technique coins), and stores Honed/Amplified for the matching primary `attack_generated` event:
- Honed joins the pre-pipeline sum (`raw + technique_atk + honed`) so suppression and keystone multipliers treat it like other flat damage.
- Amplified applies after keystone multipliers: `int(attack * (1.0 + 0.25 × cells))`.
- Suppressed clears (e.g. Holy Cheese non-singles) zero Honed/Amplified like all attack, but Gilded and Reinforced still pay — they are not attack.
- b2b/combo bonus events never re-trigger enhancement benefits.

**6. Shield charges live on RunManager and absorb at wave generation.**
`_garbage_shield: int` accumulates from Reinforced cells; `_tick_enemy_garbage()` reduces the incoming line count (`n = max(0, n - shield)`, consuming only what's used) before packets enter the buffer, stacking with `garbage_flush_reduction` keystones. Absorbing at flush time instead was rejected: the attack bar would show garbage the player has already paid to block.

**7. Data shape.**
- Consumable: new exports `enhance_type: String`, `enhance_pieces: int`, `use_timing = DURING_ROUND`.
- Technique: `effect_type = "piece_enhancer"`, `params = {"enhancement": <type>, "every_n": N}`; added to the evaluator's no-op effect list (no warning, no attack/coins).
- v1 magnitudes: Honed +1 attack/cell, Amplified +25%/cell, Gilded +1 coin/cell, Reinforced 1 charge/cell. Initial items: one consumable per type (N=4 pieces) and 2–3 techniques (every 4th–6th piece).

**8. Rendering: per-type cell styling in `_draw`.**
Each enhancement type gets a distinct cell treatment instead of a uniform marker: `honed` cells render a solid silver fill, `gilded` cells render a solid golden fill, `reinforced` cells render a solid brown fill with a silver border outline, and `amplified` cells keep their normal piece color with a small centered yellow triangle. The falling piece (and its ghost) draws the same per-type styling when `current_enhancement != ""`. No new nodes, no per-cell sprites — consistent with the existing immediate-mode board rendering.

**9. Hold preserves enhancement via parallel `held_enhancements` array.**
`tetris_board.gd`'s `held_pieces: Array` (piece type strings) gains a parallel `held_enhancements: Array` (same indices, `""` = none). `input_hold()` pushes/pops both arrays together: when holding for the first time, `current_enhancement` is appended alongside `held_type`; when swapping, both the current piece's and the held slot's type/enhancement pairs are exchanged. A piece returned from hold did not just spawn, so it does NOT emit `piece_spawned` and does NOT consume an active grant or advance periodic cadence. `HoldDisplay` reads `held_enhancements[i]` and renders the same per-type styling as the falling piece (Decision 8).

**10. Shield charge indicator: mirrored `ShieldBar` control.**
A new `ShieldBar` control follows `AttackBar`'s pattern (`_draw()`-based vertical stack of blocks, `custom_minimum_size = Vector2(BAR_WIDTH, VISIBLE_ROWS * CELL_SIZE)`) and renders on the opposite side of the board from the attack bar. Each shield charge draws one silver block from the bottom, capped at 8 (matching `flush_capacity`); charges beyond 8 render as "+N" overflow text above the filled blocks. RunManager calls `update_charges(_garbage_shield)` whenever the shield pool changes (Reinforced clears in Decision 5, absorption in Decision 6).

## Risks / Trade-offs

- [Parallel grid desync] All `grid` row mutations must mirror `enh_grid` → mutations are confined to the three existing choke points; unit tests assert both arrays stay aligned through clear/garbage/reset sequences.
- [Recolored cells lose piece identity] Honed/Gilded/Reinforced fully overwrite the cell's piece color, so a locked enhanced cell no longer shows which piece type it came from → acceptable since piece-type color only matters while a piece is active/falling, not for settled board state.
- [Amplified stacking balance] 25%/cell with 4-cell pieces means a fully banked row could double damage repeatedly → magnitudes are single constants in `piece_enhancements.gd`, trivially tunable; clamp the per-clear multiplier at ×3 as a safety rail.
- [Boss modifiers with forced/random pieces] The Fateless forces T pieces etc.; spawn-based grants are piece-type-agnostic so no interaction, but quota filters must not double-pay Gilded → coins pay at `line_clear_delay_started`, which fires once per clear regardless of boss filtering.
- [Perfect clears] PC empties the board; enhanced cells in the cleared rows still pay (they were cleared), and `enh_grid` rows shift identically, so nothing special is needed.
