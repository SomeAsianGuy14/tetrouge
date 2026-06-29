## ADDED Requirements

### Requirement: Burn debuff
Burn SHALL add 1 garbage line to the attack buffer every 3 seconds while active. Burn is a binary state — multiple sources do not stack the tick rate. Shield can absorb burn lines when the buffer flushes. Burn has a duration in seconds; permanent burn has no expiry.

#### Scenario: Burn ticks into buffer
- **WHEN** burn is active and 3 seconds pass
- **THEN** 1 garbage line SHALL be added to the attack buffer

#### Scenario: Burn does not stack
- **WHEN** burn is already active and a new burn source is applied
- **THEN** the tick rate SHALL remain 1 line per 3 seconds (duration extended if new source is longer)

#### Scenario: Shield blocks burn garbage
- **WHEN** burn garbage is in the buffer and shield charges exist
- **THEN** shield SHALL absorb burn lines on flush, same as normal garbage

### Requirement: Poison debuff
Poison SHALL add 1 garbage line directly onto the board every 5 seconds while active, bypassing the attack buffer and shield. Poison is a binary state. Poison has a duration; permanent poison has no expiry.

#### Scenario: Poison ticks onto board
- **WHEN** poison is active and 5 seconds pass
- **THEN** 1 garbage line SHALL be inserted directly onto the board

#### Scenario: Poison bypasses shield
- **WHEN** poison ticks and the player has shield charges
- **THEN** the garbage line SHALL still be placed on the board (shield not consumed)

### Requirement: True damage
True damage SHALL instantly place a permanent unclearable row at the bottom of the board. True damage rows SHALL NOT be cleared by line clears. True damage rows SHALL render with a distinct color.

#### Scenario: True damage row placed
- **WHEN** 1 true damage is dealt
- **THEN** a full unclearable row SHALL appear at the bottom of the board

#### Scenario: True damage rows survive line clears
- **WHEN** a line clear occurs above true damage rows
- **THEN** true damage rows SHALL remain in place

### Requirement: Unblocked damage triggers
Crimson Drake burn and Venomous Archer poison SHALL only apply when the enemy attack is "unblocked" — at least 1 garbage line reaches the board after shield absorption.

#### Scenario: Shield fully blocks attack, no debuff
- **WHEN** the enemy attacks for 2 lines and the player has 3 shield charges
- **THEN** no burn or poison SHALL be applied

#### Scenario: Shield partially blocks, debuff applies
- **WHEN** the enemy attacks for 3 lines and the player has 1 shield charge
- **THEN** the debuff (burn or poison) SHALL be applied

### Requirement: Cursed keystones apply debuffs at round start
Poisoned Blood SHALL apply permanent poison at round start. Blazing Heart SHALL apply permanent burn at round start. Glass Cannon SHALL apply 10 true damage rows at round start.

#### Scenario: Poisoned Blood activates
- **WHEN** a round starts with Poisoned Blood equipped
- **THEN** permanent poison SHALL be active for the entire round

#### Scenario: Glass Cannon true damage
- **WHEN** a round starts with Glass Cannon equipped
- **THEN** 10 unclearable rows SHALL be placed at the bottom of the board

### Requirement: Boss damage type abilities
The Tide SHALL deal 1 true damage every 30 seconds. The Serpent SHALL apply permanent poison at round start. The Furnace SHALL apply permanent burn at round start.

#### Scenario: The Tide true damage
- **WHEN** 30 seconds pass fighting The Tide
- **THEN** 1 permanent unclearable row SHALL be added to the board

#### Scenario: The Serpent poison
- **WHEN** fighting The Serpent
- **THEN** poison SHALL tick every 5 seconds for the entire fight
