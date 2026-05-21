## Why

The game already tracks back-to-back (B2B) chains and combo streaks internally in `TetrisBoard`, and the attack system awards bonuses for both — but the player has no visual feedback that these states are active. Adding on-screen B2B and combo counters makes scoring feel more reactive and lets players recognise high-value streaks as they build.

## What Changes

- Add a live B2B indicator to the gameplay HUD that appears while a B2B chain is active, shows the chain length ("B2B x{n}"), and disappears when the chain breaks.
- Add a live combo counter to the gameplay HUD that shows the current combo step ("Combo x{n}") and disappears when the combo resets.
- Both displays update immediately on each piece lock, synchronised with the existing `piece_locked` signal flow.

## Capabilities

### New Capabilities

- `b2b-combo-display`: On-screen HUD elements that show the active B2B chain length and current combo step during a round, updating in real time as the player clears lines.

### Modified Capabilities

- `round-hud-display`: The HUD gains two new display elements (B2B indicator and combo counter) alongside the existing score, timer, round name, and coin balance.

## Impact

- `game/scenes/game/hud.gd` — new update methods and label/node references
- `game/scenes/game/hud.tscn` — new Label or container nodes for B2B and combo
- `game/scenes/game/run_manager.gd` — wire B2B/combo signals or state to HUD update calls
- `game/scenes/tetris/tetris_board.gd` — add `b2b_count: int` variable to track consecutive qualifying clears; reset in `setup()` and updated in `_calculate_attack()`
