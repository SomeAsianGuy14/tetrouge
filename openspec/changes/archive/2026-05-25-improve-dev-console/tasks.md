## 1. Promote DevConsole to Autoload

- [x] 1.1 In `game/project.godot`, add `DevConsole="*res://scenes/debug/dev_console.tscn"` under `[autoload]` so the console persists across all scenes
- [x] 1.2 In `game/scenes/game/run_manager.gd`, remove the `_dev_console` field and the `SCENE_DEV_CONSOLE` constant
- [x] 1.3 In `run_manager._setup_debug_tools()`, replace the manual DevConsole instantiation with `DevConsole.set_run_manager(self)`
- [x] 1.4 In `run_manager._exit_tree()` (add if missing), call `DevConsole.set_run_manager(null)` so the reference is cleared when the run ends

## 2. Pause Integration

- [x] 2.1 In `dev_console._toggle()`, when opening the panel, set `run_manager._paused = true` (after the existing board input disable call)
- [x] 2.2 In `dev_console._toggle()`, when closing the panel, set `run_manager._paused = false` (after the existing board input restore call)
- [x] 2.3 Guard both writes behind `if run_manager` so toggling the console outside a run does not error

## 3. HUD Refresh on Give Commands

- [x] 3.1 In `dev_console._cmd_give_keystone()`, after `RunState.add_keystone(ks)`, add `if run_manager: run_manager.hud._refresh_keystone_icons()`
- [x] 3.2 In `dev_console._cmd_give_technique()`, after `RunState.add_technique(t)`, add `if run_manager: run_manager.hud._refresh_technique_icons()`

## 4. Testing

- [x] 4.1 No unit-testable pure logic is introduced by this change (all changes are scene wiring, autoload registration, and method calls on existing nodes). Verify manually: open console during a round, grant a keystone, confirm the icon appears immediately; open console and confirm the timer freezes.
