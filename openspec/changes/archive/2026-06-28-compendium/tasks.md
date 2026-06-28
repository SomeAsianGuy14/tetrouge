## 1. ProfileSave discovery storage

- [x] 1.1 Add `discovered_keystones: Array = []`, `discovered_techniques: Array = []`, `discovered_consumables: Array = []`, `discovered_enemies: Array = []`, `discovered_bosses: Array = []` to ProfileSave
- [x] 1.2 Add load/save for all 5 arrays in `load_profile()` and `save_profile()` with empty array defaults
- [x] 1.3 Add helper methods: `discover_keystone(id)`, `discover_technique(id)`, `discover_consumable(id)`, `discover_enemy(id)`, `discover_boss(id)` — each checks for duplicates, appends if new, and calls `save_profile()`

## 2. Discovery hooks

- [x] 2.1 In `RunState.add_keystone()`, call `ProfileSave.discover_keystone(keystone.id)` after appending
- [x] 2.2 In `RunState.add_technique()`, call `ProfileSave.discover_technique(technique.id)` after appending
- [x] 2.3 In `RunState.add_consumable()`, call `ProfileSave.discover_consumable(consumable.id)` after appending
- [x] 2.4 In `RunManager._end_round()` success path, call `ProfileSave.discover_enemy(current_config.enemy.id)` or `ProfileSave.discover_boss(current_config.enemy.id)` based on tier (Boss/FinalBoss → boss, else → enemy)

## 3. Compendium screen

- [x] 3.1 Create `game/scenes/screens/compendium_screen.gd` extending Control with a Panel, tab buttons row (Keystones, Techniques, Consumables, Enemies, Bosses), ScrollContainer with VBoxContainer for content, counter label, and Close button
- [x] 3.2 Implement tab switching — each button rebuilds the content VBox for its category
- [x] 3.3 Implement `_build_keystones_tab()` — iterate `ResourceRegistry.all_keystones`, sort discovered first then undiscovered, show name+description+category for discovered, "???" with optional unlock progress for undiscovered
- [x] 3.4 Implement `_build_techniques_tab()` — iterate `ResourceRegistry.all_techniques`, show name+description with rarity color for discovered, "???" for undiscovered
- [x] 3.5 Implement `_build_consumables_tab()` — iterate `ResourceRegistry.all_consumables`, show name+description for discovered, "???" for undiscovered
- [x] 3.6 Implement `_build_enemies_tab()` — iterate `ResourceRegistry.all_enemies` filtering to non-boss tiers, show name+flavor_text for discovered, "???" for undiscovered
- [x] 3.6 Implement `_build_bosses_tab()` — iterate `ResourceRegistry.all_enemies` filtering to Boss+FinalBoss tiers, show name+ability.description for discovered, "???" for undiscovered
- [x] 3.7 Implement discovery counter label: "N / M discovered" updated on tab switch
- [x] 3.8 Implement unlock progress display for undiscovered items with `unlock_condition_id` — look up condition in `UnlockChecker.CONDITIONS`, evaluate current progress, show progress bar and text

## 4. Main menu integration

- [x] 4.1 Add a "Compendium" Button node to `main_menu.tscn` between Stats and Settings
- [x] 4.2 Wire the button in `main_menu.gd` to instantiate and add `compendium_screen.tscn` as a child

## 5. Testing

- [x] 5.1 Add test: `discover_keystone()` adds ID to `discovered_keystones`, does not duplicate
- [x] 5.2 Add test: `discover_technique()` adds ID to `discovered_techniques`, does not duplicate
- [x] 5.3 Add test: `discover_consumable()` adds ID to `discovered_consumables`, does not duplicate
- [x] 5.4 Add test: `discover_enemy()` and `discover_boss()` add to correct arrays
- [x] 5.4 Add test: discovery arrays persist through save/load cycle
- [x] 5.5 Update test save/restore in `test_run_stats_screen.gd` and `test_ascension_system.gd` to include discovered arrays
- [x] 5.6 Run full test suite and fix any remaining failures
