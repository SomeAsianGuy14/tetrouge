## ADDED Requirements

### Requirement: 7 mastery tracks with XP and level progression
RunState SHALL maintain 7 mastery tracks: `single`, `double`, `triple`, `quad`, `tspin_single`, `tspin_double`, `tspin_triple`. Each track stores `xp` (int) and `level` (int), both starting at 0 for each new run.

#### Scenario: New run starts with all mastery at zero
- **WHEN** a new run begins
- **THEN** all 7 mastery tracks have xp=0 and level=0

#### Scenario: Mastery state persists across floors
- **WHEN** the player advances from floor 1 to floor 2 with quad mastery level 3
- **THEN** quad mastery remains at level 3 on floor 2

### Requirement: Clears grant 1 XP to the matching mastery track
Each line clear of a tracked type SHALL grant exactly 1 XP to its mastery track. B2B bonus events, combo bonus events, and perfect clears SHALL NOT grant mastery XP.

#### Scenario: Single clear grants 1 XP to singles track
- **WHEN** the player clears 1 line (single) and the singles track has 3 XP
- **THEN** the singles track has 4 XP

#### Scenario: T-Spin Double grants 1 XP to tspin_double track
- **WHEN** the player performs a T-Spin Double
- **THEN** the tspin_double track gains 1 XP

#### Scenario: B2B bonus event does not grant XP
- **WHEN** a B2B bonus event fires
- **THEN** no mastery track gains XP

#### Scenario: Perfect clear does not grant XP
- **WHEN** a perfect clear event fires
- **THEN** no mastery track gains XP

### Requirement: XP thresholds escalate with level
The XP required for the next level SHALL be `base + increment * current_level`, where base and increment vary by clear type. Singles/Doubles/T-Spin Singles/T-Spin Doubles: base=10, increment=2. Triples/Quads/T-Spin Triples: base=5, increment=1. When XP reaches the threshold, the track levels up and XP resets to the remainder.

#### Scenario: Quad track level 1 requires 5 XP
- **WHEN** the quad track is level 0 with 4 XP and the player clears a quad
- **THEN** the quad track becomes level 1 with 0 XP (threshold was 5 + 1×0 = 5)

#### Scenario: Quad track level 2 requires 6 XP
- **WHEN** the quad track is level 1 with 5 XP and the player clears a quad
- **THEN** the quad track becomes level 2 with 0 XP (threshold was 5 + 1×1 = 6)

#### Scenario: Singles track level 1 requires 10 XP
- **WHEN** the singles track is level 0 with 9 XP and the player clears a single
- **THEN** the singles track becomes level 1 with 0 XP (threshold was 10 + 2×0 = 10)

#### Scenario: Singles track level 3 requires 14 XP
- **WHEN** the singles track is level 2 with 13 XP and the player clears a single
- **THEN** the singles track becomes level 3 with 0 XP (threshold was 10 + 2×2 = 14)

### Requirement: Each mastery level grants +1 flat attack on that clear type
During attack calculation, each mastery level SHALL add +1 flat attack to clears of its type. This bonus is applied before keystone multipliers and amplified multiplier.

#### Scenario: Quad mastery level 5 adds 5 attack to quads
- **WHEN** the player has quad mastery level 5 and clears a quad (base 4 attack)
- **THEN** the mastery system contributes +5 flat attack to the quad

#### Scenario: Mastery does not affect B2B or combo events
- **WHEN** a B2B or combo bonus event fires
- **THEN** no mastery flat bonus is applied

#### Scenario: Mastery level 0 contributes nothing
- **WHEN** the player has singles mastery level 0 and clears a single
- **THEN** mastery contributes +0 to the attack
