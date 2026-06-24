## ADDED Requirements

### Requirement: Relentless Assault technique
Relentless Assault SHALL be an epic technique that deals +1 damage on all attacks, increased by 1 for every attack performed. The counter SHALL reset to 0 when the enemy fires garbage.

#### Scenario: Damage scales with attacks
- **WHEN** the player performs their 4th clear without enemy garbage
- **THEN** Relentless Assault SHALL deal +4 damage (1 base + 3 from counter)

#### Scenario: Counter resets on enemy attack
- **WHEN** the enemy fires garbage after 5 player clears
- **THEN** the Relentless Assault counter SHALL reset to 0 and the next clear SHALL deal +1

#### Scenario: Counter resets each round
- **WHEN** a new round starts
- **THEN** the Relentless Assault counter SHALL be 0
