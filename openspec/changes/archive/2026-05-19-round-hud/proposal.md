## Why

The play screen has no visible score, quota target, or round timer because `hud.setup()` is never called from `RunManager` — the quota bar's `max_value` is never set, the round label never updates, and the coin label's Economy signal is never connected. Additionally, the current HUD elements are crammed into a small top bar with no clear labels, making them hard to read even when they do work.

## What Changes

- **Fix**: Call `hud.setup(current_config)` at the start of every round so all HUD elements initialise correctly.
- **Fix**: Guard the `Economy` signal connection in `HUD._ready()` so repeated `setup()` calls across rounds do not create duplicate connections.
- **Enhance**: Add prominent, clearly-labelled **Score** and **Target** displays showing accumulated attack vs. quota in large text, distinct from the thin progress bar.
- **Enhance**: Make the **Timer** countdown more prominent — large text, centred, turns red in the final 10 seconds.
- **Enhance**: Add a **Round label** (e.g. "Stage 2 — Boss Round") clearly visible below the timer.
- Existing quota progress bar is retained as a secondary visual indicator.

## Capabilities

### New Capabilities

- `round-hud-display`: A complete, always-accurate HUD during active rounds showing: score vs. target (large text), round timer (large, colour-coded), ante/round name, coin balance, and active boss modifier name.

### Modified Capabilities

- `run-structure`: `RunManager.start_round()` now calls `hud.setup(current_config)` to initialise the HUD at the start of every round.

## Impact

- **Modified**: `game/scenes/game/hud.gd` — move Economy signal connection to `_ready()`; add prominent score/target labels; improve timer sizing.
- **Modified**: `game/scenes/game/run_manager.tscn` — add new Label nodes for large score/target/timer display; reorganise HUD layout.
- **Modified**: `game/scenes/game/run_manager.gd` — add `hud.setup(current_config)` call in `start_round()`.
- **No changes** to Tetris engine, roguelike logic, or attack system.
