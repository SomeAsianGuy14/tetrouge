## Why

Line clears currently happen in the same frame the piece locks — rows vanish instantly with no visual pause, giving the player no moment to register the clear or feel the impact of their move. A short delay with a flashing animation makes clears feel satisfying and creates the natural resolution window that technique/keystone visual feedback will later use.

## What Changes

- `TetrisBoard` enters a locked state for 0.5s when a piece locks onto full rows: input and gravity are suspended, cleared rows flash, then rows are removed and the next piece spawns.
- Signal ordering is preserved — `piece_locked` still fires immediately on lock; `lines_cleared`, `rows_cleared`, `attack_generated`, and `lock_processed` all fire after the delay ends.
- If `line_clear_delay == 0.0`, the delay path is skipped entirely and the board behaves exactly as before.
- `RoundConfig` gains `line_clear_delay: float` (default 0.5).
- `Keystone` gains `skip_line_clear_delay: bool` (default false); when true, `apply_to_config` sets `line_clear_delay` to 0.0.
- The Full Potential keystone (`full_potential.tres`) sets `skip_line_clear_delay = true`, preserving its instant-play identity.

## Capabilities

### New Capabilities

- `line-clear-delay`: A timed delay state in TetrisBoard between piece lock and row removal, with flashing row animation and frozen input/gravity.

### Modified Capabilities

*(none — no existing spec-level requirements are changing)*

## Impact

- `game/scenes/tetris/tetris_board.gd` — new state fields, tick() branching, _draw() flash rendering, refactored _process_clears split
- `game/resources/round_config.gd` — new `line_clear_delay` field
- `game/resources/keystone.gd` — new `skip_line_clear_delay` field and apply_to_config logic
- `game/resources/data/keystones/full_potential.tres` — sets `skip_line_clear_delay = true`
- `game/tests/unit/` — new unit tests for signal ordering and delay-skip behavior
