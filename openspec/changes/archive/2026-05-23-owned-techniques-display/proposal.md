## Why

Players purchase Techniques in the shop and they persist for the whole run, but there is no in-game display showing which Techniques are currently active. During a round the player has no way to remind themselves of what modifiers are affecting their attacks — they have to remember from the shop visit. This is especially confusing as the run progresses and multiple Techniques stack.

## What Changes

- Add a **Techniques** section to the existing HUD side panel, directly below the existing Keystones section.
- Each owned Technique is shown as a small icon label (first letter of the technique name) with a tooltip containing the full name and description — the same compact format already used for Keystones.
- The Technique list updates whenever `RunState.techniques` changes (on run start and after shop visits).
- A small "Techniques" header label sits above the icon row to distinguish it from the Keystones section.

## Capabilities

### New Capabilities

*(none — this extends the existing HUD rather than introducing a separate capability)*

### Modified Capabilities

- `round-hud-display`: The HUD side panel gains a Techniques section with icon labels and tooltips, parallel to the existing Keystones section.

## Impact

- `game/scenes/game/run_manager.tscn` — add `TechniquesHeader` Label and `TechniqueIcons` HBoxContainer inside `HUD/SidePanel`
- `game/scenes/game/hud.gd` — add `@onready` refs, `_refresh_technique_icons()` method, call it from `setup()`
