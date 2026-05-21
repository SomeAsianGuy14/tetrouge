## Why

The current control scheme only binds clockwise rotation to the Up arrow, missing the standard Tetris guideline key (X). Soft drop is bound to Down arrow but provides no visual feedback, making it hard to confirm it is active. Both omissions make the game feel unresponsive to players familiar with modern Tetris.

## What Changes

- Add **X** as a second input event for the existing `rotate_cw` action (right/clockwise rotation). Up arrow remains as a primary binding.
- Add **S** as a second input event for the existing `soft_drop` action, matching the standard WASD layout alternative.
- Add a **soft drop visual indicator** on the ghost piece: when soft dropping, the ghost piece cells render with increased brightness so the player can see the faster fall is active.

## Capabilities

### New Capabilities

- `soft-drop-feedback`: Visual state on the ghost piece (brighter colour) when `soft_dropping` is true on the active `TetrisBoard`. Resets when soft drop is released.

### Modified Capabilities

- `tetris-core`: The existing `soft_drop` and `rotate_cw` input actions gain additional key bindings (S and X respectively). No logic changes to the Tetris engine itself.

## Impact

- **Modified**: `game/project.godot` — add X to `rotate_cw` events array, add S to `soft_drop` events array.
- **Modified**: `game/scenes/tetris/tetris_board.gd` — `_draw()` uses a brighter ghost colour when `soft_dropping` is true.
- **No changes** to Tetris logic, attack system, or roguelike layer.
