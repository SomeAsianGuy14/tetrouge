# Proposal: piece-enhancements

## Why

Runs currently express build identity only through techniques, keystones, and consumables that modify *how clears are scored*. There is no way to invest in the pieces themselves. Piece enhancements add a Balatro-style enhancement layer: pieces can spawn enhanced, leave enhanced cells on the board, and pay off when those cells are cleared — rewarding stacking, planning, and a new family of economy/defense builds.

## What Changes

- **New enhancement system**: pieces can carry one of four enhancement types. When an enhanced piece locks, its cells become enhanced cells on the board. When a row containing enhanced cells is cleared, each type grants its benefit:
  - **Honed** — additive bonus attack per enhanced cell cleared
  - **Amplified** — multiplicative bonus to the clear's attack per enhanced cell cleared
  - **Gilded** — coins per enhanced cell cleared
  - **Reinforced** — each cleared cell adds 1 charge to a garbage shield that blocks incoming garbage lines
- **Two acquisition channels**:
  - **Consumables** that enhance the next N spawned pieces with a given type (timed grant)
  - **Techniques** that enhance every Nth spawned piece with a given type (periodic grant)
- **Board rendering**: enhanced cells get distinct per-type styling (solid silver/golden/brown+silver-border fills for Honed/Gilded/Reinforced, a yellow triangle overlay for Amplified) so the player can see what is banked on the board.
- **Hold preserves enhancements**: a held piece keeps its enhancement, and swapping it back in does not consume a new grant.
- **Shield indicator**: a mirrored bar on the opposite side of the board from the garbage attack bar shows banked Reinforced charges as silver blocks.
- **Feedback**: enhancement payouts appear in the existing event-popup cascade alongside technique/keystone events.

## Capabilities

### New Capabilities
- `piece-enhancements`: enhancement types and their benefits; assignment of enhancements to spawning pieces (grant sources, precedence, cadence); enhanced-cell tracking on the board through clears, garbage insertion, and board resets; benefit evaluation when enhanced cells are cleared; hold preserves enhancement.

### Modified Capabilities
- `consumables`: new consumable kind that activates a timed enhancement grant ("next N pieces spawn with <type>").
- `techniques`: new passive effect type granting an enhancement to every Nth spawned piece; the evaluator must treat it as a no-op for attack/economy scoring.
- `board-cell-rendering`: enhanced cells render distinct per-type styling; styling moves with rows on clears and garbage shifts.
- `hold-display`: held pieces render their enhancement styling; `held_pieces`/`held_enhancements` stay in sync through hold swaps.
- `attack-buffer`: shield charges from cleared Reinforced cells reduce incoming garbage lines before they enter the pending-garbage queue; a new `ShieldBar` control visualizes the banked charge pool.

## Impact

- `game/scenes/tetris/tetris_board.gd` — enhancement grid parallel to `grid`, stamped on lock, shifted on row clears / garbage insertion, reset on `clear_board()`; pending-clear enhancement counts captured at lock time (works with and without line-clear delay); `_draw` overlay; `held_enhancements` array kept in sync with `held_pieces` through `input_hold()`.
- `game/scenes/game/run_manager.gd` — grant bookkeeping (consumable counters, technique cadence), per-spawn enhancement assignment, benefit application in the attack pipeline (honed before multipliers, amplified after), coin payout, shield consumption in `_tick_enemy_garbage`, payout popups, `ShieldBar` updates.
- `game/scenes/game/technique_evaluator.gd` — new effect type added to the no-op list (no warning, no attack/coins).
- `game/scenes/game/hold_display.gd` — reads `held_enhancements` and renders the per-type styling on held pieces.
- `game/scenes/game/shield_bar.gd` (new) — mirrors `attack_bar.gd`'s rendering pattern for the shield-charge pool.
- `game/resources/consumable.gd` / technique resources — params for enhancement type and piece counts; new `.tres` data files registered in `ResourceRegistry` (shop pools pick them up automatically).
- `game/tests/unit/` — new test files for grid tracking, grant cadence, hold preservation, and benefit math.
- No save-format impact: grants and board state are round-scoped; runs save between rounds.
