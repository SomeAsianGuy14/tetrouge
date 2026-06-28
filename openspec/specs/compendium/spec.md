## ADDED Requirements

### Requirement: Compendium screen accessible from main menu
A "Compendium" button SHALL appear on the main menu. Pressing it SHALL open a compendium screen overlay with five tabs: Keystones, Techniques, Consumables, Enemies, Bosses. A Close button SHALL dismiss the screen.

#### Scenario: Opening the compendium
- **WHEN** the player presses the Compendium button on the main menu
- **THEN** the compendium screen SHALL appear with the Keystones tab selected by default

### Requirement: Discovery tracking persistence
`ProfileSave` SHALL maintain five arrays: `discovered_keystones`, `discovered_techniques`, `discovered_consumables`, `discovered_enemies`, `discovered_bosses`. These SHALL persist across runs via the save file. Each array SHALL contain unique item IDs.

#### Scenario: Discovery persists across runs
- **WHEN** the player acquires a keystone in one run and starts a new run
- **THEN** the keystone SHALL still appear as discovered in the compendium

#### Scenario: No duplicate entries
- **WHEN** the player acquires the same keystone in two different runs
- **THEN** the discovered array SHALL contain the ID only once

### Requirement: Keystone discovery on acquisition
When a keystone is added to the player's build via `RunState.add_keystone()`, the keystone's ID SHALL be added to `ProfileSave.discovered_keystones`.

#### Scenario: Keystone discovered
- **WHEN** the player selects a keystone from the selection screen
- **THEN** the keystone SHALL appear as discovered in the compendium

### Requirement: Technique discovery on acquisition
When a technique is added to the player's inventory via `RunState.add_technique()`, the technique's ID SHALL be added to `ProfileSave.discovered_techniques`.

#### Scenario: Technique discovered via shop
- **WHEN** the player buys a technique from the shop
- **THEN** the technique SHALL appear as discovered in the compendium

### Requirement: Consumable discovery on acquisition
When a consumable is added to the player's backpack via `RunState.add_consumable()`, the consumable's ID SHALL be added to `ProfileSave.discovered_consumables`.

#### Scenario: Consumable discovered via Laboratory
- **WHEN** the player picks up a consumable from the Laboratory encounter
- **THEN** the consumable SHALL appear as discovered in the compendium

### Requirement: Enemy discovery on defeat
When the player wins a combat round, the defeated enemy's ID SHALL be added to `ProfileSave.discovered_enemies` (for non-boss tiers) or `ProfileSave.discovered_bosses` (for Boss/FinalBoss tiers).

#### Scenario: Enemy discovered on defeat
- **WHEN** the player defeats a Stone Crab in combat
- **THEN** "Stone Crab" SHALL appear as discovered in the Enemies tab

#### Scenario: Boss discovered on defeat
- **WHEN** the player defeats The Ram
- **THEN** "The Ram" SHALL appear as discovered in the Bosses tab

### Requirement: Discovered items show details
Discovered keystones SHALL display name, description, and category. Discovered techniques SHALL display name, description, rarity (with color), and tags. Discovered consumables SHALL display name and description. Discovered enemies SHALL display name and flavor text. Discovered bosses SHALL display name and boss modifier description.

#### Scenario: Discovered keystone details
- **WHEN** the player views a discovered keystone in the compendium
- **THEN** the name, description, and category SHALL be visible

### Requirement: Undiscovered items show placeholder
Undiscovered items SHALL display "???" as the name. If the item has an `unlock_condition_id` that maps to a condition in `UnlockChecker.CONDITIONS`, the progress toward that condition SHALL be displayed.

#### Scenario: Undiscovered item with no unlock condition
- **WHEN** the player views an undiscovered technique with no unlock condition
- **THEN** only "???" SHALL be displayed

#### Scenario: Undiscovered item with unlock progress
- **WHEN** the player views an undiscovered keystone that requires "total_damage >= 5000" and the player has 3500 total damage
- **THEN** "???" SHALL be displayed with a progress indicator showing 3500/5000

### Requirement: Discovery counter per tab
Each tab SHALL display a counter showing "N / M discovered" where N is the count of discovered items and M is the total count of items in that category.

#### Scenario: Counter accuracy
- **WHEN** the player has discovered 5 of 48 keystones
- **THEN** the Keystones tab SHALL show "5 / 48 discovered"
