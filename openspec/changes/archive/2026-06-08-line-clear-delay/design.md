## Context

`TetrisBoard._lock_piece()` currently stamps cells, identifies and removes full rows, emits all signals, and spawns the next piece in a single synchronous call within one frame. There is no pause between lock and spawn. `RunManager` listens to `piece_locked`, `rows_cleared`, `lines_cleared`, `attack_generated`, and `lock_processed` — the last of which controls whether pending garbage is flushed (only flushed when no lines were cleared). Signal ordering is therefore load-bearing and must be preserved.

## Goals / Non-Goals

**Goals:**
- Introduce a 0.5s delay between piece lock and row removal, with full rows flashing during the delay
- Freeze input and gravity during the delay so the player cannot interact
- Preserve the existing signal ordering exactly (`piece_locked` → `lines_cleared` / `rows_cleared` / `attack_generated` → `lock_processed`)
- Allow `line_clear_delay = 0.0` to short-circuit the delay path with zero behavioral change
- Allow keystones (specifically Full Potential) to suppress the delay via `RoundConfig`

**Non-Goals:**
- Animating individual rows collapsing (rows disappear instantly once the delay ends)
- ARE (Appearance Delay / entry delay after spawn)
- Changing the delay duration at runtime (it's fixed per round by `RoundConfig`)

## Decisions

### 1. Delay state lives in TetrisBoard, not RunManager

**Decision:** Add `_in_line_clear_delay: bool` and `_line_clear_timer: float` directly to `TetrisBoard`, with a `_pending_*` block of saved lock state.

**Rationale:** The board owns all timing state (gravity, DAS, ARR, lock delay). RunManager already delegates per-frame tick to the board. Putting the delay in the board keeps the state machine cohesive and avoids RunManager needing to know about board internals.

**Alternative considered:** A Tween or one-shot timer node. Rejected — the board already has a hand-rolled tick loop; adding a node dependency for a simple countdown would complicate testing and scene structure.

### 2. `_process_clears` is split into two phases

**Decision:** Extract `_find_full_rows()` (pure identification, no grid mutation) called at lock time, and `_execute_pending_clears()` (grid mutation + signal emission) called after the delay ends.

**Rationale:** The lock-time phase needs to know *whether* rows are full so it can decide to enter the delay. The clear-time phase needs the saved lock metadata (piece type, pivot, rotation, was_rotation) to compute t-spin, clear type, and attacks. Splitting cleanly separates these concerns.

**Saved state across delay:**
```
_pending_clear_rows: Array[int]
_pending_piece_type: String
_pending_pivot: Vector2i
_pending_rotation: int
_pending_was_rotation: bool
```

### 3. `is_active` is NOT set to false during the delay

**Decision:** Use `_in_line_clear_delay` as a guard inside `tick()` rather than toggling `is_active`.

**Rationale:** `is_active` is the external flag RunManager checks to decide whether to stop ticking the board (`_process` guard). Setting it false during the delay would stop the delay timer itself from advancing. A separate internal flag keeps the timer running without exposing internal state to RunManager.

**tick() structure during delay:**
```gdscript
func tick(delta):
    if not is_active:
        return
    if _in_line_clear_delay:
        _line_clear_timer += delta
        queue_redraw()
        if _line_clear_timer >= config.line_clear_delay:
            _in_line_clear_delay = false
            _execute_pending_clears()
        return          # skip DAS / gravity / lock
    # ... normal path
```

### 4. Flash animation driven by `sin()` in `_draw()`

**Decision:** During `_in_line_clear_delay`, pending rows are drawn by lerping between the piece color and white using `abs(sin(_line_clear_timer * PI / config.line_clear_delay * 3))` — roughly 3 pulses across 0.5s.

**Rationale:** No extra nodes or tweens needed; pure draw-call logic that integrates naturally with the existing `_draw()` override.

### 5. `RoundConfig.line_clear_delay` is the single source of truth

**Decision:** `Keystone.apply_to_config()` writes `config.line_clear_delay = 0.0` when `skip_line_clear_delay` is true. `TetrisBoard` reads `config.line_clear_delay` at lock time to decide whether to enter the delay.

**Rationale:** Consistent with how other keystone overrides work (instant_arr, instant_soft_drop). Zero delay means the `if cleared_rows.is_empty() or config.line_clear_delay <= 0.0` guard skips the delay branch entirely — no behavioral change for Full Potential players.

## Risks / Trade-offs

- **Signal timing regression** — Any code that assumes `lock_processed` fires in the same frame as `piece_locked` could break. Mitigation: the RunManager signal handlers have been audited; `_on_piece_locked` (technique state) fires immediately; `_on_lock_processed` (garbage flush decision) fires after the delay, which is correct.
- **Input buffering during delay** — Player keypresses during the 0.5s window are ignored (DAS/gravity/lock handlers all skipped). Hard drops or rotations pressed during the flash are silently dropped. This is intentional but may feel unresponsive at first. Mitigation: 0.5s is short enough that this is unlikely to be noticed; can be tuned later.
- **Burning Board timer still ticks** — `RunManager._tick_burning_board()` runs every frame regardless of the delay state, so burning board garbage can still be inserted mid-delay. This is fine — the board state is consistent since the piece is already stamped.

## Migration Plan

No save-state migration needed. `RoundConfig` is constructed fresh each round; adding a new field with a default value requires no changes to `RunSave`. No player-facing data changes.
