## 1. RunSave Helper Script

- [x] 1.1 Create `game/scripts/run_save.gd` with `class_name RunSave extends RefCounted`
- [x] 1.2 Implement `static func exists() -> bool` — returns `FileAccess.file_exists("user://save.cfg")`
- [x] 1.3 Implement `static func delete() -> void` — deletes `user://save.cfg` if it exists
- [x] 1.4 Implement `static func save() -> void` — writes a `ConfigFile` to `user://save.cfg` with sections `[run]`, `[economy]`, and `[inventory]` populated from `RunState` and `Economy` singletons; stores item arrays as comma-separated ID strings
- [x] 1.5 Implement `static func load_into_state() -> bool` — reads `user://save.cfg`, restores `RunState` and `Economy` fields, resolves each ID array back to Resource objects by scanning the data directories, returns `false` if the file is missing or malformed

## 2. Save Triggers — RunManager

- [x] 2.1 In `run_manager.gd` `start_round()`, call `RunSave.save()` after all round setup is complete (after board and displays are created)
- [x] 2.2 In `run_manager.gd` `_quit_to_menu()`, call `RunSave.save()` before navigating to the main menu

## 3. Delete Triggers

- [x] 3.1 In `run_manager.gd` `_show_failure()`, call `RunSave.delete()` before adding the failure screen
- [x] 3.2 In `run_manager.gd` `_show_victory()`, call `RunSave.delete()` before adding the victory screen
- [x] 3.3 In `main_menu.gd` `_on_new_run()`, call `RunSave.delete()` before starting the new run

## 4. Main Menu — Continue Button

- [x] 4.1 In `main_menu.tscn`, add a `Button` node named `ContinueButton` (text: "Continue") inside `Panel/VBox`, positioned above `NewRunButton`
- [x] 4.2 Add `@onready var continue_button: Button = $Panel/VBox/ContinueButton` to `main_menu.gd`
- [x] 4.3 In `MainMenu._ready()`, set `continue_button.visible = RunSave.exists()` and connect `continue_button.connect("pressed", _on_continue)`
- [x] 4.4 Implement `_on_continue()` in `main_menu.gd`: call `RunSave.load_into_state()`, instantiate RunManager, add to tree, `queue_free()` the main menu, call `run.start_round()`

## 5. Verification

- [x] 5.1 Start a run, play one round, quit to main menu — confirm Continue button appears
- [x] 5.2 Click Continue — confirm the run resumes at the correct stage and round with the correct coins and items
- [x] 5.3 Start a New Run after a saved run — confirm the Continue button disappears after the new run starts and the save is gone
- [x] 5.4 Let a run fail — confirm the Continue button is absent from the main menu
- [x] 5.5 Win a run — confirm the Continue button is absent from the main menu
- [x] 5.6 Close the game mid-run (without quitting to menu) — confirm that on relaunch the Continue button appears (save was written at round start)
