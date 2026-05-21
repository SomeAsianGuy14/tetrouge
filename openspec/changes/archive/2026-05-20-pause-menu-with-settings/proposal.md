## Why

There is currently no way to pause an active round or adjust settings mid-run — the only path to settings is the main menu, which requires abandoning the current run. A pause menu gives players a way to tweak DAS, ARR, and keybindings between pieces without losing their progress.

## What Changes

- Add a pause/settings overlay triggered by a configurable keybind (default: Escape) from any screen within an active run — including active rounds, the shop, round success, and keystone selection.
- During an active round, pausing halts the round timer and board so no time is lost.
- During shop or transition screens, the overlay opens without any board to freeze.
- The pause overlay exposes the full existing Settings screen (DAS, ARR, keybindings) inline.
- DAS/ARR changes made while paused apply to the current board immediately on resume.
- Keybinding changes apply immediately (InputMap is live).
- The overlay includes a "Quit to Main Menu" option that safely ends the run.
- A new "Pause / Open Settings" input action is added to the project and included in the Settings rebind list so the pause key itself can be changed.

## Capabilities

### New Capabilities

- `pause-menu`: Overlay accessible from any run screen (round, shop, transitions) that optionally pauses the board and timer, embeds the Settings screen, and provides Close/Resume and Quit to Main Menu actions.

### Modified Capabilities

*(none — the Settings screen is reused as-is; no spec-level requirement changes)*

## Impact

- `game/scenes/game/run_manager.gd` — handle pause keybind input from any run state, pause/resume logic, load pause menu scene, propagate DAS/ARR changes to current board on resume
- New `game/scenes/game/pause_menu.tscn` + `game/scenes/game/pause_menu.gd` — the pause overlay scene
- `game/scenes/tetris/tetris_board.gd` — `is_active` already gates ticking; no logic changes required
- `game/scenes/screens/settings.tscn` — instantiated inside the pause menu overlay (no changes to the scene itself)
- `game/scenes/screens/settings.gd` — add "Pause / Open Settings" to `REBINDABLE_ACTIONS`
- `game/project.godot` — register new `pause` input action with default key Escape
