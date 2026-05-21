## Context

`TetrisBoard` already tracks `is_b2b: bool` and `combo: int` (starts at −1; −1 means no active combo) as internal state. The board emits `attack_generated(raw_attack, event_type)` only when lines are cleared — so when a piece locks without clearing any lines the combo resets silently with no signal. `RunManager` receives `attack_generated` and updates the HUD quota display but never forwards B2B or combo state to `HUD`. The HUD has no nodes or methods for these counters today.

## Goals / Non-Goals

**Goals:**
- Display a live B2B indicator in the HUD showing chain length ("B2B x{n}") while `is_b2b` is true; hide it otherwise.
- Display a live combo counter in the HUD showing streak step ("Combo x{n}") while `combo >= 0`; hide it otherwise.
- Both indicators update on every piece lock, whether or not lines are cleared.

**Non-Goals:**
- Animations or particle effects on the counters (no visual flourishes beyond show/hide and text update).
- Modifying attack calculation logic (already correct in `TetrisBoard`).

## Decisions

### 1. Signal source: use `piece_locked` from RunManager rather than a new signal

`attack_generated` only fires when lines are cleared, missing the combo-reset case. Two alternatives:
- **A) Connect `piece_locked` in RunManager and read board state directly** — minimal signal plumbing; RunManager already holds a reference to `current_board`.
- **B) Add a new `clear_resolved(is_b2b, combo)` signal from TetrisBoard** — cleaner separation but modifies a core class for a purely visual concern.

**Decision: Option A.** Reading `current_board.is_b2b`, `current_board.b2b_count`, and `current_board.combo` in the `piece_locked` handler keeps signal surface minimal. `TetrisBoard` does gain a `b2b_count: int` variable (to track chain depth for the label), but no new signals or public API are added.

### 2. HUD update method: single `update_b2b_combo(is_b2b, b2b_count, combo)` call

RunManager calls `hud.update_b2b_combo(is_b2b: bool, b2b_count: int, combo: int)` from `_on_piece_locked`. The HUD method toggles label visibility and updates text. The B2B label reads "B2B x{b2b_count}" (e.g. "B2B x1" on the first qualifying clear that establishes the chain, "B2B x2" on the first clear that earns the bonus). The combo label reads "Combo x{combo+1}".

### 3. HUD node layout: two new Labels in the existing InfoPanel

The HUD already has an `InfoPanel` with `ScoreLabel`, `TimerBigLabel`, `RoundBigLabel`, and `ModifierBigLabel`. Adding a `B2BLabel` and `ComboLabel` to this panel keeps the display structure consistent without introducing a new container.

- `B2BLabel`: text "B2B", hidden when `is_b2b` is false.
- `ComboLabel`: text "Combo x{n}" where `n = combo + 1` (combo 0 = first consecutive = "x1"), hidden when `combo < 0`.

## Risks / Trade-offs

- [B2B state is read *after* `_calculate_attack` updates it] → `is_b2b` in `piece_locked` already reflects the new state set during locking, so the read is always current. No race condition.
- [Combo display shows +1 offset] → The internal `combo` variable starts at 0 on the first clearing lock; displaying `combo + 1` shows "x1" on the first consecutive clear, which matches player intuition. The offset must be documented in the HUD method to avoid future confusion.

## Migration Plan

1. Add `b2b_count: int` variable to `TetrisBoard`; reset in `setup()`; increment/reset in `_calculate_attack()`.
2. Add `B2BLabel` and `ComboLabel` nodes to `run_manager.tscn` (inside `HUD/InfoPanel`).
3. Add `@onready` references and `update_b2b_combo(is_b2b, b2b_count, combo)` method to `hud.gd`.
4. Connect `current_board.piece_locked` to a new `_on_piece_locked()` handler in `run_manager.gd`.
5. In `_on_piece_locked()`, call `hud.update_b2b_combo(current_board.is_b2b, current_board.b2b_count, current_board.combo)`.
6. Call `hud.update_b2b_combo(false, 0, -1)` inside `hud.setup()` to initialise both indicators hidden at round start.

No rollback risk — all changes are purely additive UI wiring.
