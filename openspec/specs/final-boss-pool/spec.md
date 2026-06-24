## ADDED Requirements

### Requirement: Final boss pool for floor 4
Floor 4 boss rooms SHALL draw from a separate "FinalBoss" tier pool instead of the normal "Boss" pool. The final boss pool SHALL contain: The Mutant, The Titan, The Klepto, and The Origin.

#### Scenario: Floor 4 draws final boss
- **WHEN** the player reaches the floor 4 boss room
- **THEN** the boss SHALL be drawn from the FinalBoss pool

#### Scenario: Floors 1-3 use normal boss pool
- **WHEN** the player reaches a boss room on floors 1-3
- **THEN** the boss SHALL be drawn from the normal Boss pool

### Requirement: The Mutant final boss
The Mutant SHALL combine two randomly selected normal boss effects. Both boss modifier effects SHALL be applied simultaneously.

#### Scenario: Two effects applied
- **WHEN** The Mutant is the floor 4 boss
- **THEN** two randomly chosen normal boss modifiers SHALL both be active during the fight

### Requirement: The Titan final boss
The Titan SHALL have double the HP (quota) and double the garbage attack of a normal boss.

#### Scenario: Double HP and attack
- **WHEN** The Titan is the floor 4 boss
- **THEN** the quota SHALL be 2× the normal boss quota and garbage lines SHALL be 2× normal

### Requirement: The Klepto final boss
The Klepto SHALL reduce all mastery levels by 5 at the start of the fight (minimum 0).

#### Scenario: Mastery drained at fight start
- **WHEN** the fight against The Klepto begins
- **THEN** all mastery track levels SHALL be reduced by 5 (floored at 0)

### Requirement: The Origin final boss
The Origin SHALL grow stronger based on the total number of enemies defeated during the run. Its quota SHALL scale with the kill count.

#### Scenario: Quota scales with kills
- **WHEN** the player has defeated 15 enemies before reaching The Origin
- **THEN** The Origin's quota SHALL be higher than if only 5 enemies had been defeated

### Requirement: Enemy kill counter
`RunState` SHALL track `enemies_killed: int`, incrementing by 1 each time a non-boss combat is won. The counter SHALL reset on run start.

#### Scenario: Kill counter increments
- **WHEN** the player wins a Small combat room
- **THEN** `enemies_killed` SHALL increase by 1

#### Scenario: Kill counter resets on new run
- **WHEN** a new run starts
- **THEN** `enemies_killed` SHALL be 0
