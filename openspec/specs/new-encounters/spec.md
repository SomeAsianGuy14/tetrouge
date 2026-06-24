## ADDED Requirements

### Requirement: Tutor encounter
The Tutor encounter SHALL select a random mastery track and offer to grant +2 levels to it. The player SHALL choose to accept or leave.

#### Scenario: Player accepts
- **WHEN** the player accepts the Tutor's offer
- **THEN** a randomly selected mastery track SHALL increase by 2 levels

#### Scenario: Player leaves
- **WHEN** the player selects "Leave" in the Tutor encounter
- **THEN** no mastery levels SHALL change

### Requirement: Sleeping Beast encounter
The Sleeping Beast encounter SHALL offer the player a choice: fight a combat one tier higher than the current floor's normal combat difficulty, or leave. Winning the fight SHALL grant a random technique and bonus coins.

#### Scenario: Player fights and wins
- **WHEN** the player chooses to fight and defeats the Sleeping Beast
- **THEN** the player SHALL receive a random technique (if below capacity) and bonus coins

#### Scenario: Player leaves
- **WHEN** the player chooses to leave
- **THEN** the encounter SHALL be marked cleared with no reward

### Requirement: Laboratory encounter
The Laboratory encounter SHALL display 3 random consumables. The player SHALL be able to take any or all of them (if backpack capacity allows), then leave.

#### Scenario: Player takes consumables
- **WHEN** the player takes 2 of 3 available consumables
- **THEN** those 2 consumables SHALL be added to the player's backpack

#### Scenario: Player at capacity
- **WHEN** the player's backpack is full
- **THEN** the take buttons SHALL be disabled

### Requirement: Demonic Deal encounter
The Demonic Deal encounter SHALL only appear if the player has at least 3 levels in any mastery track. It SHALL offer to trade 3 levels of a chosen mastery for 150 coins.

#### Scenario: Player accepts deal
- **WHEN** the player selects a mastery with 5 levels and accepts the deal
- **THEN** that mastery SHALL decrease by 3 levels and 150 coins SHALL be awarded

#### Scenario: Player has no qualifying mastery
- **WHEN** no mastery track has 3+ levels
- **THEN** the Demonic Deal SHALL not appear in the encounter pool

### Requirement: Mimic encounter
The Mimic encounter SHALL appear on the dungeon map as a treasure chest room. When the player enters and attempts to claim the treasure, a combat with a Mimic enemy SHALL be triggered instead. Defeating the Mimic SHALL drop 50 coins.

#### Scenario: Player enters mimic room
- **WHEN** the player enters a room displayed as "Treasure Chest" that is actually a Mimic
- **THEN** a combat encounter with the Mimic enemy SHALL begin

#### Scenario: Player defeats mimic
- **WHEN** the player defeats the Mimic enemy
- **THEN** 50 coins SHALL be awarded

### Requirement: Beggar encounter
The Beggar encounter SHALL offer the player a choice: pay 50 gold for a random rare-or-lower technique, or leave.

#### Scenario: Player pays and receives technique
- **WHEN** the player pays 50 gold
- **THEN** a random technique of common or rare rarity SHALL be added to the player's inventory (if below capacity)

#### Scenario: Player cannot afford
- **WHEN** the player has fewer than 50 coins
- **THEN** the pay button SHALL be disabled

### Requirement: Map Room encounter
The Map Room encounter SHALL offer the player a choice: examine the map to reveal all fogged rooms on the current floor, or leave.

#### Scenario: Player examines map
- **WHEN** the player chooses to examine the map
- **THEN** all rooms on the current floor SHALL be revealed (fog removed)

#### Scenario: Player leaves
- **WHEN** the player chooses to leave
- **THEN** the fog state SHALL remain unchanged
