## Why

Currently, any run that's interrupted — by quitting to the main menu or closing the game — is lost entirely. Players who want to stop mid-run have no way to resume, which limits how long a session can comfortably be. Auto-saving the run state and offering a "Continue" button on the main menu lets players pick up exactly where they left off.

## What Changes

- The run is automatically saved to a persistent file (`user://save.cfg`) at every round start and whenever the player quits to the main menu.
- The main menu shows a **Continue** button when a valid save exists, allowing the player to resume from where they left off.
- Starting a **New Run** overwrites and discards any existing save.
- When a run ends naturally (victory or failure), the save file is deleted so "Continue" no longer appears.
- The save captures all run state: stage, round index, coin balance, interest cap, speed bonus multiplier, owned keystone IDs, technique IDs, consumable IDs, voucher IDs, used boss modifier IDs, used keystone IDs, and per-run flags (consumable capacity, shop technique slots, sharp eye, second wind).

## Capabilities

### New Capabilities

- `run-persistence`: Automatic save/load of run state to disk, with a Continue button on the main menu.

### Modified Capabilities

- `run-structure`: The run now has a save/load lifecycle — it is persisted on each round start and deleted on run end.

## Impact

- New `game/scripts/run_save.gd` — static helper that writes/reads/deletes `user://save.cfg`
- `game/autoloads/run_state.gd` — call `RunSave.save()` at round start; call `RunSave.delete()` on reset
- `game/scenes/game/run_manager.gd` — call `RunSave.delete()` on run end (failure/victory); call `RunSave.save()` on quit to menu
- `game/scenes/main_menu/main_menu.gd` — add Continue button, show/hide based on save existence, load save and resume run on click
- `game/scenes/main_menu/main_menu.tscn` — add ContinueButton node
