## ADDED Requirements

### Requirement: Guard technique
Guard SHALL be a common technique that grants 2 shield when the player clears a quad.

#### Scenario: Quad grants shield
- **WHEN** the player clears a quad with Guard equipped
- **THEN** 2 shield charges SHALL be added

#### Scenario: Non-quad does not grant shield
- **WHEN** the player clears a double with Guard equipped
- **THEN** no shield charges SHALL be added

### Requirement: Staff Spin technique
Staff Spin SHALL be a common technique that grants 2 shield when the player performs a T-Spin.

#### Scenario: T-Spin grants shield
- **WHEN** the player performs a T-Spin Double with Staff Spin equipped
- **THEN** 2 shield charges SHALL be added

### Requirement: Brace technique
Brace SHALL be a common technique that grants 2 shield at the start of each combat round.

#### Scenario: Shield granted at round start
- **WHEN** a new combat round begins
- **THEN** 2 shield charges SHALL be added from Brace

### Requirement: Volley technique
Volley SHALL be a common technique that adds +2 damage to the player's first 3 attacks each round.

#### Scenario: First 3 attacks get bonus
- **WHEN** the player performs their 1st, 2nd, or 3rd clear of the round
- **THEN** each clear SHALL deal +2 additional damage

#### Scenario: 4th attack no bonus
- **WHEN** the player performs their 4th clear of the round
- **THEN** no Volley bonus SHALL be applied

### Requirement: Perfect Placement technique
Perfect Placement SHALL be a common technique that adds +8 damage to perfect clears.

#### Scenario: Perfect clear gets bonus
- **WHEN** the player performs a perfect clear with Perfect Placement equipped
- **THEN** +8 additional damage SHALL be dealt

### Requirement: Slow and Steady technique
Slow and Steady SHALL be a rare technique that adds +4 damage to clears that take longer than 5 seconds since the previous clear.

#### Scenario: Slow clear gets bonus
- **WHEN** more than 5 seconds have passed since the player's last clear
- **THEN** the clear SHALL deal +4 additional damage

#### Scenario: Fast clear no bonus
- **WHEN** less than 5 seconds have passed since the last clear
- **THEN** no Slow and Steady bonus SHALL be applied

### Requirement: Safe Distance technique
Safe Distance SHALL be a rare technique that grants 4 shield when the player clears lines during the last 10 seconds of the enemy's attack bar.

#### Scenario: Clear during last 10 seconds grants shield
- **WHEN** the enemy attack bar has 10 or fewer seconds remaining and the player clears lines
- **THEN** 4 shield charges SHALL be added

### Requirement: Double Barrel technique
Double Barrel SHALL be a rare technique that adds +6 damage when the player performs consecutive T-Spins.

#### Scenario: Consecutive T-Spins get bonus
- **WHEN** the player performs a T-Spin immediately after another T-Spin
- **THEN** the second T-Spin SHALL deal +6 additional damage

#### Scenario: First T-Spin no bonus
- **WHEN** the player performs a T-Spin after a non-T-Spin clear
- **THEN** no Double Barrel bonus SHALL be applied

### Requirement: Concentrate technique
Concentrate SHALL be a rare technique that adds +2 damage to all attacks if no garbage has been received during the current combat round.

#### Scenario: No garbage received grants bonus
- **WHEN** the player has not received garbage this round and clears a line
- **THEN** +2 additional damage SHALL be dealt

#### Scenario: Garbage received removes bonus
- **WHEN** the player has received garbage this round
- **THEN** no Concentrate bonus SHALL be applied

### Requirement: Whirlwind technique
Whirlwind SHALL be a rare technique that adds +3 damage to quads for each technique with a "quad" tag the player owns.

#### Scenario: Quad with 2 quad techniques
- **WHEN** the player has Whirlwind and 2 other quad-tagged techniques and performs a quad
- **THEN** Whirlwind SHALL add +6 damage (3 × 2)

### Requirement: Charging Up technique
Charging Up SHALL be an epic technique that causes the next piece to spawn Amplified when the player's combo count exceeds 5.

#### Scenario: Combo exceeds 5 triggers enhancement
- **WHEN** the player's combo count exceeds 5
- **THEN** the next piece SHALL spawn with the Amplified enhancement

### Requirement: Investment keystone
Investment SHALL grant additional coins after each combat, equal to 1 coin per 10 coins the player holds.

#### Scenario: Player has 85 coins
- **WHEN** a combat round ends and the player has 85 coins
- **THEN** 8 additional coins SHALL be awarded (floor(85/10))

### Requirement: Hardened Steel keystone
Whenever the player gains shield charges, Hardened Steel SHALL double the amount gained.

#### Scenario: Shield gain doubled
- **WHEN** the player would gain 5 shield charges with Hardened Steel
- **THEN** 10 shield charges SHALL be gained instead

### Requirement: Shield Bash keystone
Whenever the player gains shield charges, Shield Bash SHALL deal damage equal to the shield amount gained (after any multipliers).

#### Scenario: Shield gain deals damage
- **WHEN** the player gains 4 shield charges with Shield Bash
- **THEN** 4 damage SHALL be dealt to the enemy

### Requirement: Cripple keystone
Cripple SHALL increase all enemy attack intervals by 5 seconds, giving the player more time between garbage attacks.

#### Scenario: Enemy interval increased
- **WHEN** a round starts with the Cripple keystone
- **THEN** enemy garbage_interval_min and garbage_interval_max SHALL each increase by 5.0

### Requirement: Nothing to Waste keystone
Nothing to Waste SHALL grant 20 additional coins whenever the player defeats an enemy.

#### Scenario: Enemy defeated grants bonus coins
- **WHEN** the player wins a combat round with Nothing to Waste
- **THEN** 20 additional coins SHALL be awarded

### Requirement: Equivalent Exchange keystone
Equivalent Exchange SHALL allow the player to trade a technique they own for a technique of the same rarity tier in shops.

#### Scenario: Player trades technique in shop
- **WHEN** the player selects an owned technique to trade in the shop
- **THEN** the technique SHALL be replaced by a random technique of the same rarity

### Requirement: Big Brain keystone
Big Brain SHALL increase the player's technique capacity by 2.

#### Scenario: Capacity increased
- **WHEN** the player has Big Brain
- **THEN** the technique capacity SHALL be 7 (base 5 + 2)

### Requirement: Ramping Rhythm keystone
Ramping Rhythm SHALL add a flat damage bonus to all attacks that starts at +1 and increases by 1 every 3 seconds during combat.

#### Scenario: Bonus increases over time
- **WHEN** 9 seconds have passed in combat
- **THEN** all attacks SHALL deal +4 additional damage (1 base + 3 increments)

#### Scenario: Bonus resets each round
- **WHEN** a new round starts
- **THEN** the Ramping Rhythm bonus SHALL reset to +1
