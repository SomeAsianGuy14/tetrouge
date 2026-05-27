## Why

Enemy attacks currently fire at a fixed interval and always deliver exactly one garbage row, making them completely predictable and low-impact. Varying both the timing and the size of attacks — and aligning garbage holes per attack — will make rounds feel more dynamic and threatening.

## What Changes

- Instead of a fixed interval, each enemy attack fires within a randomised window (`interval_min` to `interval_max`) that is re-rolled after every attack.
- Instead of always sending 1 row, each attack sends a randomised number of garbage rows (`lines_min` to `lines_max`).
- Both the interval range and the lines range scale with stage: attacks come faster and harder at higher stages.
- Ranges are tier-uniform (all normal enemies share one set of constants; all boss enemies share another). No per-enemy .tres changes are needed.
- All garbage rows from a single attack share the same hole column, so multi-row attacks are readable and clearable.
- A new `insert_garbage_rows(count, col)` method is added to `TetrisBoard` to support aligned multi-row insertion.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `enemy-encounters`: The "Garbage attacks occur every round" requirement changes from a fixed interval and fixed 1-row delivery to a randomised interval range and randomised multi-row delivery, both scaling with stage.

## Impact

- `game/resources/enemy.gd` — no changes (ranges are baked into RunManager constants, not per-enemy data).
- `game/scenes/game/run_manager.gd` — `_tick_enemy_garbage()` updated; four new computed fields added to `RoundConfig`; `_next_garbage_interval` runtime var added.
- `game/resources/round_config.gd` — four new fields: `garbage_interval_min`, `garbage_interval_max`, `garbage_lines_min`, `garbage_lines_max`. `effective_garbage_interval` removed.
- `game/scenes/tetris/tetris_board.gd` — new `insert_garbage_rows(count: int, col: int)` method; existing `insert_garbage_row()` remains for single-row use (dev console, etc.).
- `game/scenes/game/enemy_display.gd` — windup bar denominator updated to use `_next_garbage_interval` instead of removed `effective_garbage_interval`.
