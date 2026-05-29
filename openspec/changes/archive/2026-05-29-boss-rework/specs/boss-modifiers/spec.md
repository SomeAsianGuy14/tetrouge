## MODIFIED Requirements

### Requirement: Boss modifier pool for launch
The following boss modifiers SHALL be available as board-rule abilities assigned to boss enemies. The Tide modifier is removed; its garbage effect is now a universal enemy mechanic applied every round.

| Name | Effect |
|------|--------|
| **The Void** | Hold piece is disabled for this round |
| **The Fateless** | Preview queue and next piece are both hidden entirely |
| **The Blitz** | Time limit is reduced to 60 seconds (quota unchanged) |
| **The Aristocrat** | Only Tetrises and T-spin variants count toward quota; singles, doubles, and triples send 0 attack |
| **The Silencer** | Back-to-back chain is disabled; every clear starts a fresh chain |
| **The Thin** | Board width reduced to 8 columns (leftmost 2 columns are walled off) |
| **The Ancient** | All generated pieces are truly random (each draw picks any of the 7 types with equal probability, ignoring the bag sequence) |
| **The Filth** | All enemy garbage arrives as individual 1-line attacks, each with its own independently re-rolled hole column |
| **The Reflection** | Enemy does not send garbage; instead, 50% of attack that reduces the boss's HP is reflected back as pending garbage for the player |

#### Scenario: Modifier is active from round start
- **WHEN** a Boss round begins
- **THEN** the ability effect is in place before the first piece spawns

#### Scenario: Modifier is cleared after round ends
- **WHEN** the Boss round ends (success or failure)
- **THEN** the ability has no effect on subsequent rounds

#### Scenario: Modifier and augment pool are drawn independently
- **WHEN** a Boss round is resolved
- **THEN** the boss enemy (and its ability) was drawn from the enemy pool and the augment options were drawn from the augment pool as separate operations

#### Scenario: The Void disables hold
- **WHEN** The Void ability is active
- **THEN** the hold action is rejected for the entire round with a visual indicator

#### Scenario: The Fateless hides all previews
- **WHEN** The Fateless ability is active
- **THEN** neither the queue display nor the next-piece slot shows any piece

#### Scenario: The Blitz shortens the time limit to exactly half of standard
- **WHEN** The Blitz ability is active
- **THEN** the round time limit is 60 seconds (half of the 120-second standard)

#### Scenario: The Aristocrat restricts quota contribution to quads and T-spins
- **WHEN** The Aristocrat ability is active and the player clears lines with a single, double, or triple
- **THEN** attack is generated but does NOT accumulate toward the quota

## REMOVED Requirements

### Requirement: The Surgeon modifier
**Reason**: Mechanically redundant with The Aristocrat — both restrict which clear types count toward quota. The Surgeon (T-spin only) is a stricter subset of The Aristocrat and adds no meaningful design variety on top of it.
**Migration**: Delete `game/resources/data/boss_modifiers/boss_surgeon.tres` and `game/resources/data/enemies/boss_surgeon.tres`.

## ADDED Requirements

### Requirement: The Ancient produces truly random pieces
When The Ancient is active, `TetrisBoard` SHALL bypass the bag randomizer and generate each piece by drawing uniformly at random from all 7 piece types. The same piece type may appear on consecutive draws.

#### Scenario: Consecutive identical pieces are possible
- **WHEN** The Ancient is active
- **THEN** the same piece type may be generated on consecutive draws, with each draw having 1/7 probability for every type

#### Scenario: BagRandomizer is not advanced
- **WHEN** The Ancient is active and a piece is spawned
- **THEN** `BagRandomizer.next()` is NOT called; the draw goes directly through `rng.randi_range(1, 7)`

### Requirement: The Filth sends garbage as individual 1-line packets
When The Filth is active, each garbage interval fire SHALL append each line as a separate 1-line packet with an independently re-rolled hole column, rather than batching all lines from that interval into a single multi-line packet.

#### Scenario: Each garbage line gets its own hole column
- **WHEN** The Filth is active and a garbage interval fires N lines
- **THEN** N separate `{lines: 1, is_filth: true}` packets are appended to the queue, each with a fresh independently selected hole column

#### Scenario: Filth packets are visually distinct in the attack bar
- **WHEN** filth packets are present in the attack bar
- **THEN** they are rendered in yellow-orange, distinct from the red used for regular garbage packets

### Requirement: The Reflection mirrors player damage as pending garbage
When The Reflection is active, the enemy SHALL NOT send garbage on any timer. After each player attack that reduces the boss's HP, `floor(damage_to_hp * 0.5)` lines SHALL be appended to the player's garbage packet queue as a regular (non-filth) packet.

#### Scenario: Reflection sends no garbage independently
- **WHEN** The Reflection is active
- **THEN** no garbage timer fires; all garbage the player receives comes from reflected damage only

#### Scenario: Reflection is proportional to effective HP reduction only
- **WHEN** The Reflection is active and a player attack reduces the boss's HP by 4
- **THEN** 2 lines (floor(4 × 0.5)) are appended to the garbage queue

#### Scenario: Surplus attack beyond quota is not reflected
- **WHEN** The Reflection is active and a player attack exceeds the remaining quota
- **THEN** only the portion that actually reduced HP is used to compute reflected lines; the overkill surplus is NOT reflected
