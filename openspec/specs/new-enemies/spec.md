## ADDED Requirements

### Requirement: Encounter-specific enemies
Three encounter-specific enemies SHALL be created: Pickpocket (spawns in pickpocket revenge combat, drops stolen gold), Robbers (spawns during Robber encounter fight), and Mimic (spawns during Mimic encounter combat, drops 50 coins). These enemies SHALL have `encounter_only = true` and SHALL NOT appear in the general combat pool.

#### Scenario: Pickpocket enemy drops stolen gold
- **WHEN** the player defeats the Pickpocket enemy
- **THEN** coins equal to the previously stolen amount SHALL be awarded

#### Scenario: Mimic enemy drops 50 coins
- **WHEN** the player defeats the Mimic enemy
- **THEN** 50 coins SHALL be awarded

#### Scenario: Encounter enemies excluded from general pool
- **WHEN** the dungeon generates a Small/Big/Elite combat room
- **THEN** encounter-only enemies SHALL NOT appear in the draw pool

### Requirement: New general combat enemies
Six new enemies SHALL be added to the general combat pool: Corrupted Mage, Venomous Archer, Possessed Blade, Insane Adventurer, Giant Frog, and Unstable Construct. Each SHALL have a tier (Small, Big, or Elite), display name, flavor text, and color.

#### Scenario: New enemies appear in combat
- **WHEN** the player enters a combat room
- **THEN** new enemies SHALL be drawn from the pool alongside existing ones

### Requirement: Enemy renames
Seven existing enemies SHALL have their `display_name` updated: Rock Crawler → Stone Crab, The Warden → Dungeon Warden, Void Knight → Fallen Knight, Crimson Drake → Lesser Drake, Rust Golem → Rusty Golem, Slimeling → Slime, Iron Shambler → Armored Skeleton.

#### Scenario: Renamed enemy displays correctly
- **WHEN** the player encounters Rock Crawler
- **THEN** the display name SHALL show "Stone Crab"
