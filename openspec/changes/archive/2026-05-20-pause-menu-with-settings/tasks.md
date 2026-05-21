## 1. Pause Keybind Setup

- [x] 1.1 Register a `pause` input action in `project.godot` with Escape as the default key
- [x] 1.2 Add `{"action": "pause", "label": "Pause / Settings"}` to `REBINDABLE_ACTIONS` in `game/scenes/screens/settings.gd`

## 2. Pause Menu Scene

- [x] 2.1 Create `game/scenes/game/pause_menu.tscn` with a full-screen `Control` root node and a semi-transparent `ColorRect` backdrop
- [x] 2.2 Add a centered `VBoxContainer` with a "Resume" `Button`, a "Settings" `Button`, and a "Quit to Main Menu" `Button`
- [x] 2.3 Add a `SettingsContainer` node below the buttons where `settings.tscn` will be instantiated at runtime
- [x] 2.4 Create `game/scenes/game/pause_menu.gd` with `class_name PauseMenu`, attach it to the scene root

## 3. Pause Menu Script

- [x] 3.1 Declare signals `resume_requested` and `quit_requested` in `pause_menu.gd`
- [x] 3.2 Connect Resume button `pressed` → emit `resume_requested`
- [x] 3.3 Connect Quit to Main Menu button `pressed` → emit `quit_requested`
- [x] 3.4 Connect Settings button `pressed` → instantiate `settings.tscn` and add it as a child of `SettingsContainer`; disable the Settings button while settings is open
- [x] 3.5 Detect when the Settings child is freed and re-enable the Settings button

## 4. RunManager — Pause Logic

- [x] 4.1 Add `_paused: bool = false` and `_pause_menu: PauseMenu = null` variables to `run_manager.gd`
- [x] 4.2 Add `_open_pause()` method: set `_paused = true`; if `current_board != null`, set `current_board.is_active = false` and call `current_board.input_move_released()`; instantiate and add the pause menu scene; connect `resume_requested` → `_close_pause()` and `quit_requested` → `_quit_to_menu()`
- [x] 4.3 Add `_close_pause()` method: set `_paused = false`; if `current_board != null`, propagate `Settings.load_das()` and `Settings.load_arr()` to `current_board.das_delay` and `current_board.arr_rate`, then set `current_board.is_active = true`; free the pause menu node and clear `_pause_menu`
- [x] 4.4 Add `_quit_to_menu()` method: call `RunState.reset()` and `Economy.reset()`, load and instantiate `main_menu.tscn`, add it to the scene tree, free RunManager
- [x] 4.5 In `RunManager._process()`, check `Input.is_action_just_pressed("pause")` at the top: if `_pause_menu == null`, call `_open_pause()`; otherwise call `_close_pause()`

## 5. Verification

- [ ] 5.1 Press the pause keybind during an active round — confirm the overlay appears and the timer freezes
- [ ] 5.2 Press the pause keybind again — confirm the game resumes
- [ ] 5.3 Press the pause keybind while in the shop — confirm the overlay appears over the shop without crashing
- [ ] 5.4 Close the overlay from the shop — confirm the shop is interactive again
- [ ] 5.5 Open Settings from the overlay, change DAS, close Settings, resume a round — confirm the new DAS is in effect
- [ ] 5.6 Rebind the Pause / Settings key in Settings — confirm the new key opens/closes the overlay
- [ ] 5.7 Click Quit to Main Menu from the overlay during a round — confirm the main menu loads cleanly
- [ ] 5.8 Click Quit to Main Menu from the overlay during the shop — confirm the main menu loads cleanly
- [ ] 5.9 Hold a directional key while pausing during a round — confirm the piece does not lurch on resume
