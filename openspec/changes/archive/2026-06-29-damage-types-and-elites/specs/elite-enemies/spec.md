## ADDED Requirements

### Requirement: Elite enemy class
A new enemy class "Elite Special" SHALL have a distinct map tile and one guaranteed spawn per floor. Elite enemies have normal garbage attacks plus a bonus board-modifying effect defined by their `elite_attack` field.

#### Scenario: One elite per floor
- **WHEN** a dungeon floor is generated
- **THEN** at least one room SHALL be an elite special combat room

#### Scenario: Elite has bonus attack
- **WHEN** fighting an elite enemy with an elite_attack type
- **THEN** the bonus attack SHALL fire alongside normal garbage generation

### Requirement: Corrupted Mage elite attack
The Corrupted Mage SHALL randomly fill 4-6 empty cells on the player's board with garbage cells when its bonus attack fires.

#### Scenario: Cells filled on board
- **WHEN** the Corrupted Mage's bonus attack fires
- **THEN** 4-6 random empty cells on the board SHALL become garbage cells

### Requirement: Possessed Blade elite attack
The Possessed Blade SHALL delete a random 3 contiguous row section from the board, removing both player cells and garbage. True damage rows SHALL NOT be deleted.

#### Scenario: Three rows deleted
- **WHEN** the Possessed Blade's bonus attack fires
- **THEN** 3 contiguous clearable rows SHALL be removed and rows above SHALL shift down

#### Scenario: True damage rows protected
- **WHEN** the Possessed Blade targets rows containing true damage
- **THEN** true damage rows SHALL be skipped and other rows selected instead

### Requirement: Crimson Drake elite attack
The Crimson Drake SHALL apply burn for 4 seconds when its attack is unblocked (at least 1 garbage line reaches the board).

#### Scenario: Unblocked attack applies burn
- **WHEN** the Crimson Drake attacks and shield does not fully absorb
- **THEN** burn SHALL be active for 4 seconds

### Requirement: Venomous Archer elite attack
The Venomous Archer SHALL apply poison for 6 seconds when its attack is unblocked.

#### Scenario: Unblocked attack applies poison
- **WHEN** the Venomous Archer attacks and shield does not fully absorb
- **THEN** poison SHALL be active for 6 seconds

### Requirement: Elite attack patterns in compendium
Elite enemy attack descriptions SHALL be visible in the compendium only after the player has defeated that elite enemy. Before discovery, the attack pattern is hidden.

#### Scenario: Undiscovered elite shows no attack info
- **WHEN** the player views an undiscovered elite in the compendium
- **THEN** only "???" SHALL be shown with no attack description

#### Scenario: Discovered elite shows attack info
- **WHEN** the player views a discovered Corrupted Mage in the compendium
- **THEN** the elite attack description SHALL be visible
