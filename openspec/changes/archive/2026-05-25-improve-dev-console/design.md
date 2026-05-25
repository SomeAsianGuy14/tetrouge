## Context

The dev console (`game/scenes/debug/dev_console.gd`) is currently instantiated by `RunManager._setup_debug_tools()` and lives as a child of the RunManager node. This means it only exists during active rounds — the console is unreachable from the main menu, shop, or keystone selection screens. When open, the console calls `run_manager.current_board.set_process_input(false)` to block board input but does not call the RunManager's pause logic (`_paused`, `_open_pause()`), so the round timer keeps running. After granting a keystone or technique via `give_keystone`/`give_technique`, the HUD's `_refresh_keystone_icons()` / `_refresh_technique_icons()` methods are not called, so the inventory panel stays stale until the next round.

## Goals / Non-Goals

**Goals:**
- DevConsole is accessible via F1 on any screen during a run (and during debug/dev play).
- Opening the console sets `run_manager._paused = true` and disables board input; closing it restores both.
- `give_keystone` and `give_technique` call the HUD refresh methods immediately after granting.

**Non-Goals:**
- Console accessible outside of a run (main menu before starting). The console is still a dev tool, not a menu feature.
- Animated or styled console UI.
- Persisting console log across scene changes.

## Decisions

**Global availability: autoload vs. root-level node**

Chosen: Register `DevConsole` as a Godot autoload (like `RunState` and `Economy`). This makes it always present in the scene tree, F1 input is always processed via `_unhandled_input`, and no individual scene needs to know about it. The `run_manager` reference is set by `RunManager._ready()` via `DevConsole.set_run_manager(self)` and cleared on `RunManager._exit_tree()` via `DevConsole.set_run_manager(null)`.

Alternative considered: Add the console node manually to each scene that needs it. Rejected — every screen would need a wiring step and the console log would reset on scene transition.

**Pause integration**

Chosen: On `_toggle()` open, set `run_manager._paused = true` and call `run_manager.current_board.set_process_input(false)`. On close, set `run_manager._paused = false` and restore board input. This reuses the existing `_paused` flag that `RunManager._process()` already checks before advancing the timer, so the timer freezes with zero additional logic.

Calling the full `_open_pause()` / `_close_pause()` methods is not appropriate — those spawn/destroy the pause menu UI. The console is its own overlay; it just needs the flag and the board input gate.

**HUD refresh**

Chosen: In `_cmd_give_keystone()`, after `RunState.add_keystone(ks)`, call `run_manager.hud._refresh_keystone_icons()` when `run_manager` is non-null. Same pattern for `_cmd_give_technique()`. The `hud` field is a direct `@onready` var on RunManager; no signal or indirection needed.

## Risks / Trade-offs

- [Autoload DevConsole adds overhead even in release builds] → Wrap instantiation in an `OS.is_debug_build()` guard in the autoload's `_ready()`, or use the existing export-stripping pattern. Acceptable risk for a school project.
- [Clearing `run_manager` reference on `_exit_tree()` requires that RunManager calls `DevConsole.set_run_manager(null)`] → Straightforward one-liner; low risk of being missed.
- [Autoload scene vs. script] → DevConsole uses `@onready` vars that require a scene. Register the `.tscn` as the autoload target (Godot supports this).
