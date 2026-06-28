## Context

The main menu currently has Continue, New Run, Stats, Settings, and Quit buttons. Stats opens a `StatsScreen` overlay that builds its UI programmatically via `_populate()`. The compendium follows the same pattern: a new scene instantiated as a child of the main menu, with a Close button to dismiss it.

All keystones, techniques, and enemies are registered in `ResourceRegistry` as preloaded arrays. The compendium iterates these arrays and checks each item's ID against the discovered sets in `ProfileSave`.

## Goals / Non-Goals

**Goals:**
- Persistent discovery tracking that survives across runs
- Tabbed UI showing discovered vs undiscovered items with progress
- Accessible from main menu

**Non-Goals:**
- In-run compendium access (may add later)
- Lore/story entries beyond existing flavor text and descriptions
- Discovery notifications during gameplay (popups like "New entry!")

## Decisions

### 1. Discovery storage in ProfileSave as simple ID arrays

Five new arrays in `ProfileSave`: `discovered_keystones`, `discovered_techniques`, `discovered_consumables`, `discovered_enemies`, `discovered_bosses`. Saved/loaded alongside existing stats. Using arrays of strings (IDs) keeps it simple and compatible with the existing save format.

Checking discovery is `id in discovered_keystones` — O(n) but arrays are small (<100 items). No need for dictionaries.

### 2. Discovery hooks in RunState and RunManager

- **Keystones**: `RunState.add_keystone()` already centralizes all keystone acquisition. Add `ProfileSave.discover_keystone(keystone.id)` call there.
- **Techniques**: `RunState.add_technique()` similarly. Add `ProfileSave.discover_technique(technique.id)` call.
- **Consumables**: `RunState.add_consumable()` similarly. Add `ProfileSave.discover_consumable(consumable.id)` call.
- **Enemies/Bosses**: In `RunManager._end_round(true)` success path, before `_flow.resolve_combat(true)`, add `ProfileSave.discover_enemy(current_config.enemy.id)`. Check `current_config.enemy.tier` to route to the boss list for Boss/FinalBoss tiers.

`ProfileSave.discover_*()` methods check for duplicates, append if new, and save.

### 3. Compendium screen uses tabs via button row

A horizontal row of 5 buttons at the top toggles which category is displayed. The content area below is a `ScrollContainer` with a `VBoxContainer` that rebuilds when the tab changes. This matches the existing UI patterns (no TabContainer dependency).

### 4. Undiscovered items show unlock progress when applicable

For items with a non-empty `unlock_condition_id`, the compendium looks up the matching `UnlockCondition` in `UnlockChecker.CONDITIONS` and evaluates progress. For items without a condition, just "???" is shown.

Progress display format: condition description + progress bar + "7/10" text.

### 5. Item ordering: discovered first, then undiscovered

Within each tab, discovered items are listed first (alphabetically by display_name), followed by undiscovered items. This puts the useful reference content at the top and the collection targets at the bottom.

### 6. Encounter-only enemies are excluded from the compendium

Enemies with `encounter_only = true` (Pickpocket, Robbers, Mimic) are excluded from the compendium since they're tied to specific encounters and would clutter the enemy list. They still appear in-game but don't need a bestiary entry.

Actually — they should be included since fighting them is a distinct experience. But they go in the Enemies tab alongside general enemies. The player discovers them by defeating them.

## Risks / Trade-offs

**Save size** — Four additional arrays of strings. Negligible.

**Unlock progress for items with no conditions** — Most items don't have unlock conditions yet. The compendium will show "???" with no progress bar for these. This is fine — it keeps things mysterious.
