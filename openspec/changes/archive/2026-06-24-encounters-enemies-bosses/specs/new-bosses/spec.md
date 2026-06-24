## ADDED Requirements

### Requirement: The Ram boss modifier
The Ram's attacks SHALL bypass the player's shield charges entirely. Garbage from The Ram SHALL be applied directly to the board without being absorbed by shield.

#### Scenario: Garbage ignores shield
- **WHEN** The Ram sends garbage and the player has 5 shield charges
- **THEN** the garbage SHALL be applied to the board and the shield charges SHALL remain at 5

### Requirement: The Jester boss modifier
Attacks that are the same clear type as the player's previous clear SHALL deal no damage against The Jester.

#### Scenario: Same clear type deals no damage
- **WHEN** the player performs a quad after a quad against The Jester
- **THEN** the second quad SHALL deal 0 damage

#### Scenario: Different clear type deals normal damage
- **WHEN** the player performs a t-spin after a quad against The Jester
- **THEN** the t-spin SHALL deal normal damage

### Requirement: The Berserker boss modifier
The Berserker's attack interval SHALL decrease as its HP drops. At full HP the interval is normal; at low HP the interval SHALL be significantly faster.

#### Scenario: Attack speed increases at low HP
- **WHEN** The Berserker is at 30% HP
- **THEN** its garbage interval SHALL be shorter than at full HP

### Requirement: The Forgotten boss modifier
The Forgotten SHALL hide its HP bar, attack interval bar, and windup animation from the player. The player must defeat it without knowing how much HP remains or when the next attack will come.

#### Scenario: HP bar hidden
- **WHEN** fighting The Forgotten
- **THEN** the enemy HP bar, attack bar, and windup animation SHALL NOT be visible

### Requirement: The Furnace boss modifier
The Furnace SHALL send 1 garbage attack every 5 seconds at a fixed interval, ignoring normal garbage timing mechanics.

#### Scenario: Fixed 5-second attacks
- **WHEN** fighting The Furnace
- **THEN** garbage SHALL arrive every 5 seconds regardless of floor or stage scaling
