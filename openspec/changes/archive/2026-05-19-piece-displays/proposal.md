## Why

The play screen currently renders only the Tetris board. The held piece and upcoming piece queue are tracked internally by `TetrisBoard` but never shown to the player, making it impossible to plan holds or anticipate future pieces during a round. Both are standard information displays in any modern Tetris implementation.

## What Changes

- Add a **Hold Display** panel to the left of the board showing the currently held piece (or pieces, if the Extended Buffer keystone is active). When hold is disabled by a boss modifier (The Void), the panel shows a dimmed placeholder.
- Add a **Queue Display** panel to the right of the board showing the next N upcoming pieces, where N equals `config.preview_count` (default 5; 1 under The Blinder, 7 with Foresight keystone).
- Both displays render pieces as small tetrominoes using the same colour scheme as the main board.
- Both displays update immediately whenever the board emits `board_updated`.
- `RunManager` instantiates and positions both displays relative to the board each round.

## Capabilities

### New Capabilities

- `hold-display`: Panel rendered to the left of the board showing the held piece(s). Reflects `held_pieces` from `TetrisBoard`, dims when hold is disabled, supports up to 2 slots for Extended Buffer keystone.
- `queue-display`: Panel rendered to the right of the board showing the next `config.preview_count` pieces from `piece_queue`. Shrinks to 1 entry under The Blinder, expands to 7 under Foresight.

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- **New scenes**: `scenes/game/hold_display.gd` + `.tscn`, `scenes/game/queue_display.gd` + `.tscn`
- **Modified**: `scenes/game/run_manager.gd` — instantiate and position displays each round; pass board reference
- **Modified**: `scenes/game/run_manager.tscn` — layout accommodates side panels (board shifted right or window widened)
- **No changes to `TetrisBoard`** — all needed data is already exposed via `held_pieces`, `get_preview_types()`, `config`, and the `board_updated` signal
