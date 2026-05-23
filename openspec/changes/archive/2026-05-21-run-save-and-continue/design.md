## Context

`RunState` and `Economy` are singleton autoloads that hold all live run data. Resources owned by the player (keystones, techniques, consumables, vouchers) are identified by string IDs and backed by `.tres` files in `res://resources/data/`. The settings system already uses `ConfigFile` for persistence (`user://settings.cfg`). The main menu has three buttons; it loads and frees itself when transitioning to a run.

## Goals / Non-Goals

**Goals:**
- Save the full run state on every round start and on quit-to-menu.
- Delete the save on run end (victory, failure) and on New Run.
- Show/hide a Continue button on the main menu based on save existence.
- Restore RunState + Economy from the save and resume the run at the correct round.

**Non-Goals:**
- Multiple save slots — one save file only.
- Mid-round save (save is always at a round boundary).
- Saving the board grid state — the player resumes at the start of the current round, not mid-piece.
- Cloud sync or export.

## Decisions

### 1. Save format: ConfigFile at `user://save.cfg`

`ConfigFile` is already used for settings and is human-readable for debugging. The save uses two sections:
- `[run]` — stage, round_index, shop_technique_slots, consumable_capacity, sharp_eye_active, second_wind_used_this_round
- `[economy]` — coins, interest_cap, speed_bonus_multiplier
- `[inventory]` — keystone_ids (PackedStringArray), technique_ids, consumable_ids, voucher_ids, used_boss_modifier_ids, used_keystone_ids

Resources are serialised as ID arrays only; on load, each ID is resolved back to a resource by scanning the data directories (same logic as the shop's `_load_from_dir`).

### 2. Save/load logic in a new static helper: `RunSave`

A `game/scripts/run_save.gd` with `class_name RunSave` exposes three static methods:
- `save()` — reads from RunState + Economy singletons and writes `user://save.cfg`
- `load_into_state()` — reads `user://save.cfg`, restores RunState + Economy, returns `true` on success
- `delete()` — erases `user://save.cfg`
- `exists()` → bool

This keeps save/load logic isolated and off the autoloads themselves.

### 3. Save trigger: `start_round()` in RunManager

`RunManager.start_round()` is called at the beginning of every round (including the first). Saving here means the save always reflects "about to begin this round" — a clean resumption point. Additionally, `_quit_to_menu()` also calls `RunSave.save()` before navigating away.

### 4. Delete trigger: run end + New Run

`RunSave.delete()` is called from:
- `RunManager._show_failure()` — run lost
- `RunManager._show_victory()` — run won
- `MainMenu._on_new_run()` — player explicitly starts fresh

### 5. Resume: load save → instantiate RunManager → call `start_round()`

`MainMenu._on_continue()`:
1. `RunSave.load_into_state()` restores all singleton state
2. Instantiate RunManager and add to tree (same as New Run)
3. Call `run.start_round()` instead of `run.start_run()` — skips `RunState.reset()` and `Economy.reset()`

### 6. Resource resolution on load

On load, each ID array (keystone_ids, technique_ids, …) is resolved by iterating the corresponding `res://resources/data/<type>/` directory and matching IDs. This reuses the same scanning approach as `Shop._load_from_dir`. Voucher effects (`_apply_voucher_effects`) are re-applied during load since they modify RunState flags that ARE saved (shop_technique_slots, consumable_capacity, etc.) — no re-application needed. Keystone effects modify `RoundConfig` at round start, so they don't need re-application either.

## Risks / Trade-offs

- [Save file becomes stale after a game update changes item data] → ID-based resolution means removed items are silently skipped on load. Run continues with fewer items — acceptable behaviour.
- [Player edits save file manually] → Not a concern; there's no competitive integrity requirement.
- [RunState.reset() is called before start_run() on New Run but NOT on continue] → `RunState.reset()` is NOT called for continue; the save is the source of truth. `RunSave.delete()` must be called before `RunState.reset()` on New Run to avoid a window where the save reflects a reset state.

## Migration Plan

1. Create `RunSave` script with the four static methods.
2. Add `RunSave.save()` call to `RunManager.start_round()`.
3. Add `RunSave.save()` call to `RunManager._quit_to_menu()`.
4. Add `RunSave.delete()` calls to `_show_failure()`, `_show_victory()`, and `MainMenu._on_new_run()`.
5. Add `ContinueButton` to `main_menu.tscn`; wire `_on_continue()` in `main_menu.gd`.
6. Show/hide ContinueButton based on `RunSave.exists()` in `MainMenu._ready()`.
