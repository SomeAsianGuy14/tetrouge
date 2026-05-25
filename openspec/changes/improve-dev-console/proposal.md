## Why

The in-game dev console (F1) is only available during active rounds, doesn't pause gameplay when open, and doesn't refresh the HUD after granting keystones or techniques. These limitations make it slow and awkward to use during testing and development.

## What Changes

- `give_keystone` and `give_technique` commands refresh the HUD immediately after granting, so icons appear without waiting for the next round.
- The console is promoted to a persistent overlay present across all screens (main menu, shop, keystone selection, round screens), not just during RunManager.
- Opening the console pauses the active board and blocks game input; closing it resumes.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `dev-console`: Console is now globally accessible, pauses gameplay when open, and triggers immediate HUD refresh on keystone/technique grants.

## Impact

- `game/scenes/debug/dev_console.gd` — HUD refresh calls added to `give_keystone`/`give_technique`; pause/resume wired to toggle; promoted to autoload or root-level persistent node.
- `game/scenes/game/run_manager.gd` — No longer spawns its own DevConsole instance; passes `self` to the shared console on `_ready()`.
- Autoloads or main scene — DevConsole registered so it persists across scene changes.
