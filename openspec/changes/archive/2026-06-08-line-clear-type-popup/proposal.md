## Why

Players have no immediate visual confirmation of what kind of clear they just performed, which matters because many techniques trigger on specific clear types (T-spins, quads, singles). Adding a brief popup anchored under the hold piece gives players a clear, low-noise read on what fired.

## What Changes

- After every line clear, a transient label appears below the hold display naming the clear type
- Plain clears (Single, Double, Triple) appear in white and fade out over the line clear delay
- High-tier clears (Quad, T-Spin variants) and Perfect Clear play a brief scale-up pop before fading
- Color coding: white for plain, cyan for Quad, purple for T-Spins, gold for Perfect Clear
- Popup fires at the start of the line clear delay (before lines disappear); zero-delay rounds use the `lines_cleared` signal with a ~0.5s default fade

## Capabilities

### New Capabilities

- `line-clear-type-popup`: Transient announcement label shown below the hold display after every line clear, displaying the clear type name with tier-appropriate color and animation

### Modified Capabilities

<!-- none — purely additive -->

## Impact

- `game/scenes/game/run_manager.gd`: new `_spawn_clear_type_popup` method; new connection to `lines_cleared` signal for zero-delay handling; hook into existing `_on_line_clear_delay_started`
- No new scene nodes or exported scenes required
- No changes to `TetrisBoard`, `HUD`, or any autoload
