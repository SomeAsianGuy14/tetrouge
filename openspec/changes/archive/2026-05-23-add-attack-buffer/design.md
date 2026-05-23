## Context

Enemy garbage is currently delivered by `RunManager._tick_enemy_garbage()`, which calls `current_board.insert_garbage_row()` the instant the interval timer expires. Players have no warning and no way to react — the row appears immediately. The proposal introduces a queue so attacks can be telegraphed and countered.

The relevant surface area is small: `RunManager` owns the timer and all attack plumbing; `TetrisBoard` exposes `insert_garbage_row()` unchanged.

## Goals / Non-Goals

**Goals:**
- Queue incoming garbage rows instead of inserting them immediately
- Let outgoing player attacks drain the queue 1:1 before contributing to quota
- Show pending row count as a vertical bar running alongside the board
- Keep garbage interval scaling rules unchanged

**Non-Goals:**
- Complex per-row delivery timers (one shared flush timer is sufficient)
- Saving buffer state across sessions (buffer clears on round end)
- Technique or keystone interactions with the buffer (out of scope for this change)

## Decisions

### 1. Buffer as an integer counter, not a list

The buffer stores `pending_garbage: int` in `RunManager`. Each garbage interval expiry increments it by 1; each flush decrements it by 1. No per-row metadata is needed because all garbage rows are identical.

*Alternative considered*: An `Array` of timestamps for per-row countdowns. Rejected — adds complexity for no gameplay benefit; a single shared flush timer is predictable and communicable to the player.

### 2. Flush on piece lock, capped at 8 rows

`RunManager` connects to the board's `lock_processed` signal. Each time the player locks a piece, up to `min(pending_garbage, 8)` rows are inserted immediately (one `insert_garbage_row()` call per row) and `pending_garbage` is reduced by that amount. The cap of 8 prevents a large accumulated buffer from instantly losing the game in one lock event.

*Alternative considered*: Separate timer-based flush. Rejected — decouples delivery from player action, removing the reaction-window feeling; piece-lock delivery is directly tied to the player's pace.

*Alternative considered*: No cap (flush all pending rows). Rejected — a large buffer accumulated while the player was distracted could be lethally delivered all at once.

### 3. Counter-attack drain happens before quota addition

In `RunManager._on_attack_generated()`, before adding attack to `quota_accumulated`, the code drains `pending_garbage`:

```
var drain := mini(raw_after_techniques, pending_garbage)
pending_garbage -= drain
quota_accumulated += (raw_after_techniques - drain)
```

This means attacking a lot is doubly rewarded (clears buffer AND damages enemy), which reinforces the "play aggressively" strategy.

*Alternative considered*: Counter-attacks go to quota AND drain buffer independently (no tradeoff). Rejected — removes the tension of choosing when buffer drain matters.

### 4. HUD indicator is a vertical bar alongside the board

A thin `ColorRect` strip (or equivalent `NinePatchRect`) is placed directly adjacent to the left or right edge of the `TetrisBoard` node in the game scene. It spans the full board height and is subdivided into 20 equal segments (one per board row). Segments fill from the bottom up, one segment lit per pending garbage row. `RunManager` calls `_attack_bar.update_pending(count: int)` whenever `pending_garbage` changes; the bar lights the bottom `count` segments in a warning color (e.g. red/orange).

This mirrors the visual convention in competitive Tetris clients (Tetris 99, Jstris) where incoming garbage is shown as a colored column beside the board, making the threat immediately legible at a glance.

*Alternative considered*: Numeric label inside EnemyDisplay. Rejected — too far from the board; players must look away from the play field to read it.

*Alternative considered*: Coloring the board's left border. Rejected — requires modifying TetrisBoard rendering; a separate overlay node is simpler and non-invasive.

## Risks / Trade-offs

- **Balance shift**: Players who attack aggressively will rarely receive garbage. Passive runs will be punished more. This is intentional but may need tuning.
  → Mitigation: the 8-row cap is a constant that can be adjusted without touching logic.

- **Buffer persists if round ends mid-flush**: On round end, `pending_garbage` must be reset to 0 in `_cleanup_round()` to avoid carryover.
  → Mitigation: add explicit reset in `_end_round()`.

## Decisions (resolved)

### 5. Counter-attack drain precedes piece-lock flush

Within a single lock event, attack generation (`attack_generated` signal → `_on_attack_generated` → drain) fires before `lock_processed` → flush. This ordering is intentional: the player's outgoing attack from that lock reduces the buffer first, then whatever remains is flushed onto the board. A player who clears a line on the same piece that triggers a flush gets to cancel garbage before it arrives.
