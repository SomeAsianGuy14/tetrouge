## Why

The Tetris board is the visual centrepiece of every game session, but currently renders with flat-coloured squares and no stylistic identity. Adding bevelled stone blocks, cracked garbage tiles, and a rune-outline ghost piece gives the board a dungeon crawler aesthetic that matches the game's roguelite theme.

## What Changes

- Placed piece cells gain a bevelled stone-block look: lightened top/left highlight edges, darkened bottom/right shadow edges
- Garbage cells gain the same bevel plus a position-seeded crack pattern drawn over the block
- The ghost piece changes from a solid grey fill to a dark void fill with a bright piece-coloured outline (rune-inscription effect); outline turns white while soft-dropping
- The board background shifts from neutral near-black to a slightly cooler/darker tone with faint violet warmth

## Capabilities

### New Capabilities

- `board-cell-rendering`: Visual rendering of individual Tetris cells — bevel, garbage crack patterns, ghost rune outline, board background colour

### Modified Capabilities

_(none — no spec-level behaviour changes)_

## Impact

- `game/scenes/tetris/tetris_board.gd` — all changes are contained here (`_draw`, `_draw_cell`, plus two new helper functions)
- No other files, no autoloads, no save data, no tests required (pure rendering)
