## ADDED Requirements

### Requirement: Backpack is displayed as a persistent HUD element
The HUD SHALL display 3 consumable backpack slots at all times during a run (including during active rounds, pre-round idle, and shop visits). Each occupied slot SHALL show the item name. Empty slots SHALL appear visually distinct from occupied ones.

#### Scenario: Backpack visible during active round
- **WHEN** a round is in progress
- **THEN** all 3 backpack slots are visible on the HUD

#### Scenario: Occupied slot shows item name
- **WHEN** the player has a consumable in a backpack slot
- **THEN** the slot displays the item's display name

#### Scenario: Empty slot is visually distinct
- **WHEN** a backpack slot contains no item
- **THEN** the slot is rendered with a dim or placeholder appearance to indicate it is empty

### Requirement: Backpack slots are interactive in the pre-round window
Attack-buff consumable slots SHALL be activatable as buttons during the pre-round idle state (before the first piece spawns). Time Shard slots SHALL be activatable during an active round. Slots SHALL be non-interactive when the activation timing is not valid.

#### Scenario: Attack-buff item can be activated pre-round
- **WHEN** the round has not yet started (pre-round idle) and an attack-buff consumable occupies a slot
- **THEN** clicking the slot activates the item, applies its bonuses to the round config, and empties the slot

#### Scenario: Time Shard can be activated mid-round
- **WHEN** a round is active and Time Shard occupies a backpack slot
- **THEN** clicking the slot activates Time Shard, adds 8 seconds to the timer, and empties the slot

#### Scenario: Attack-buff slot is inactive during an active round
- **WHEN** a round is in progress and an attack-buff consumable is in the backpack
- **THEN** the slot is non-interactive (cannot be clicked to activate)
