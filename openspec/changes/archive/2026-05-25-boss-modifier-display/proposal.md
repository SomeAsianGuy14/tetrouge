## Why

During boss rounds the HUD shows the active modifier's name (e.g. "The Void") but not what it does. Players must remember the effect from a previous encounter or guess, which is frustrating — especially early in a run when modifiers are new.

## What Changes

- The InfoPanel modifier label shows the modifier's name and its description on separate lines during boss rounds.
- The compact TopBar modifier label gains a hover tooltip containing the description.
- No new scene nodes, assets, or data fields are needed — `BossModifier` already carries a `description: String` field and all seven .tres files already have it populated.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `round-hud-display`: boss modifier display now includes the description text alongside the name, both in the InfoPanel label and as a tooltip on the TopBar label.

## Impact

- `game/scenes/game/hud.gd` — `setup()` updated to write description into modifier labels.
- No scene file changes required.
- No new tests required (pure display logic with no computable output).
