## Why

With 48+ keystones, 68+ techniques, 15+ consumables, 27+ enemies, and 14+ bosses, players have no way to review what they've found across runs. A compendium accessible from the main menu gives players a collection goal and a reference for build planning.

## What Changes

- New "Compendium" button on the main menu opens a tabbed screen
- Five tabs: Keystones, Techniques, Consumables, Enemies, Bosses
- **Discovered items** show name + details:
  - Keystones: name, description, flavor text, category
  - Techniques: name, description, rarity color, tags
  - Consumables: name, description
  - Enemies: name, flavor text
  - Bosses: name, boss modifier description
- **Undiscovered items** show "???" placeholder. If the item has an `unlock_condition_id`, the compendium displays progress toward unlocking it
- Discovery counter per tab: "12 / 48 discovered"
- Discovery is tracked persistently in `ProfileSave` across runs:
  - Keystones discovered on acquisition (`RunState.add_keystone()`)
  - Techniques discovered on acquisition (`RunState.add_technique()`)
  - Consumables discovered on acquisition (`RunState.add_consumable()`)
  - Enemies discovered on defeat (round-end success)
  - Bosses discovered on defeat (round-end success, boss rooms only)

## Capabilities

### New Capabilities
- `compendium`: Main menu compendium screen with discovery tracking across four item categories

### Modified Capabilities

_(none)_

## Impact

- **New file**: `game/scenes/screens/compendium_screen.gd` (+ `.tscn`)
- **Modified**: `ProfileSave` — 5 new persistent arrays for discovered IDs, save/load
- **Modified**: `RunState.add_keystone()`, `RunState.add_technique()`, `RunState.add_consumable()` — mark items as discovered
- **Modified**: `RunManager._end_round()` success path — mark enemy/boss as discovered
- **Modified**: `main_menu.gd` — add Compendium button
- **Modified**: `main_menu.tscn` — add button node
