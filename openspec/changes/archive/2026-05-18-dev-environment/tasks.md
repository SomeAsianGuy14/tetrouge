## 1. GUT Installation and Configuration

- [x] 1.1 Download the latest GUT release compatible with Godot 4.6 from https://github.com/bitwes/Gut/releases and extract `addons/gut/` into `game/addons/gut/`
- [x] 1.2 Enable the GUT plugin in the Godot editor: Project → Project Settings → Plugins → GUT → Enable
- [x] 1.3 Create `game/tests/unit/` directory structure
- [x] 1.4 Create `game/tests/run_tests.tscn`: a scene with a GUT node configured to discover `tests/unit/`, set as prefix `test_`, and auto-run on start
- [x] 1.5 Create `game/.gutconfig.json` with `dirs`, `prefix`, `suffix`, and `should_exit` set to true for headless runs
- [x] 1.6 Verify headless run works: `godot --headless -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json` from the `game/` directory exits with code 0
- [x] 1.7 Document export exclusion: add `addons/gut/*`, `tests/*`, `scenes/debug/*` to export filter in the Godot export preset (Project → Export → Resources tab → Exclude filter)

## 2. Unit Tests — Attack System

- [x] 2.1 Create `game/tests/unit/test_attack_system.gd` extending `GutTest`
- [x] 2.2 Write helper to build a minimal `RoundConfig` with default values for test isolation
- [x] 2.3 Test base attack values: Single=0, Double=1, Triple=2, Tetris=4, T-spin Single=2, T-spin Double=4, T-spin Triple=6
- [x] 2.4 Test B2B bonus: second consecutive Tetris returns 5; chain resets after a non-qualifying clear
- [x] 2.5 Test perfect clear override: `is_pc=true` always returns 10 regardless of clear type
- [x] 2.6 Test combo table: steps 0–4 return 0,0,1,1,2 respectively
- [x] 2.7 Test Attack Surge doubling: next 3 clears return double base attack, 4th returns normal

## 3. Unit Tests — Economy

- [x] 3.1 Create `game/tests/unit/test_economy.gd` extending `GutTest`; call `Economy.reset()` in `before_each`
- [x] 3.2 Test `apply_interest`: balance 12 → +2 coins; balance 50 → capped at 5 coins
- [x] 3.3 Test `spend_coins`: sufficient balance returns true and deducts; insufficient returns false with no change
- [x] 3.4 Test `pay_round(4, 2, 1)` adds exactly 7 coins
- [x] 3.5 Test `calculate_speed_bonus`: 40s remaining of 60s limit returns 2

## 4. Unit Tests — Bag Randomiser

- [x] 4.1 Create `game/tests/unit/test_bag_randomizer.gd` extending `GutTest`
- [x] 4.2 Test standard 7-bag: first 7 draws contain all 7 piece types exactly once
- [x] 4.3 Test 14 draws: each piece type appears exactly twice
- [x] 4.4 Test Bag Shift (interval=5): after 5 draws the internal bag is empty and the 6th draw triggers a refill

## 5. Unit Tests — RoundConfig Quota Scaling

- [x] 5.1 Create `game/tests/unit/test_round_config.gd` extending `GutTest`
- [x] 5.2 Test `calculate_quota(1, 0)` returns 20 (Ante 1 Small Blind)
- [x] 5.3 Test `calculate_quota(1, 3)` returns 44 (Ante 1 Boss Blind)
- [x] 5.4 Test `calculate_quota(5, 3)` returns 104 (Ante 5 Boss Blind)

## 6. Unit Tests — T-spin Detection

- [x] 6.1 Create `game/tests/unit/test_tspin_detection.gd` extending `GutTest`
- [x] 6.2 Write helper to instantiate a minimal `TetrisBoard` with a `RoundConfig` and pre-fill grid cells
- [x] 6.3 Test 3-corner occupied + rotation = T-spin classified correctly
- [x] 6.4 Test only 2 corners occupied = not a T-spin
- [x] 6.5 Test `last_move_was_rotation = false` = not a T-spin regardless of corner count

## 7. Debug Overlay

- [x] 7.1 Create `game/scenes/debug/` directory
- [x] 7.2 Create `game/scenes/debug/debug_overlay.gd` as a `CanvasLayer` with `mouse_filter = MOUSE_FILTER_IGNORE`
- [x] 7.3 Add a `VBoxContainer` with `Label` nodes for: ante/round, quota, timer, combo, B2B, piece type, keystones, techniques, coins
- [x] 7.4 Implement a 0.25s `Timer` that calls `_refresh_labels()` to update all displayed values from `RunState`, `Economy`, and the active board reference
- [x] 7.5 Implement F2 toggle: connect `_unhandled_input` to show/hide the overlay; set `visible = false` by default
- [x] 7.6 Update `RunManager.start_round()` to instantiate `debug_overlay.tscn`, pass the board reference to it, and add it as a child
- [x] 7.7 Create `game/scenes/debug/debug_overlay.tscn` referencing the script with the CanvasLayer and label structure
- [x] 7.8 Verify overlay is visible in-game via F2 and does not block piece movement

## 8. Dev Console

- [x] 8.1 Create `game/scenes/debug/dev_console.gd` as a `CanvasLayer`
- [x] 8.2 Add a `PanelContainer` with a `VBoxContainer` containing: a `RichTextLabel` (scrollable log, 20-line history) and a `LineEdit` (command input)
- [x] 8.3 Implement F1 toggle: show/hide the panel; on show, call `grab_focus()` on the `LineEdit`; set `visible = false` by default
- [x] 8.4 Implement board input suspension: when console opens, set `current_board.set_process_input(false)`; restore on close
- [x] 8.5 Implement `_on_command_submitted(text)` connected to `LineEdit.text_submitted`: parse command, dispatch, log result, clear input
- [x] 8.6 Implement `help` command: print all commands and descriptions to the log
- [x] 8.7 Implement `skip_round` command: call `RunManager._end_round(true)` with zero payout flag
- [x] 8.8 Implement `set_ante <n>` command: set `RunState.ante` to n, clamp 1–5, log confirmation
- [x] 8.9 Implement `add_coins <n>` command: call `Economy.add_coins(n)`, log new balance
- [x] 8.10 Implement `give_keystone <id>` command: load keystone resource by id from data directory, call `RunState.add_keystone()`, log result
- [x] 8.11 Implement `give_technique <id>` command: load technique resource by id, call `RunState.add_technique()`, log result
- [x] 8.12 Implement `insert_garbage <n>` command: call `current_board.insert_garbage_row()` n times, log confirmation
- [x] 8.13 Implement `set_quota <n>` command: set `current_config.quota` to n on `RunManager`, log confirmation
- [x] 8.14 Create `game/scenes/debug/dev_console.tscn` referencing the script with the CanvasLayer panel structure
- [x] 8.15 Update `RunManager.start_round()` to instantiate `dev_console.tscn`, store reference for board suspension, and add as child
- [x] 8.16 Verify F1 opens console mid-round, commands execute correctly, and piece movement is suspended while console is open
