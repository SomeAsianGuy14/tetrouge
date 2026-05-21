## ADDED Requirements

### Requirement: Each Boss Blind has exactly one modifier active
Every Boss Blind round SHALL have one boss modifier applied for its entire duration. The modifier is selected from the boss modifier pool (randomly, without repeating within a run where possible).

#### Scenario: Modifier is active from round start
- **WHEN** a Boss Blind round begins
- **THEN** the modifier effect is in place before the first piece spawns

#### Scenario: Modifier is cleared after round ends
- **WHEN** the Boss Blind round ends (success or failure)
- **THEN** the modifier has no effect on subsequent rounds

### Requirement: Boss modifiers are independent of augment rewards
The modifier active in a Boss Blind round SHALL be chosen independently of which Augments are offered as rewards after that boss. There is no thematic or mechanical link required between them.

#### Scenario: Modifier and augment pool are drawn independently
- **WHEN** a Boss Blind is resolved
- **THEN** the modifier was selected from the modifier pool and the augment options were drawn from the augment pool as separate operations

### Requirement: Boss modifier pool for launch
The following boss modifiers SHALL be available in the initial build:

| Name | Effect |
|------|--------|
| **The Void** | Hold piece is disabled for this round |
| **The Blinder** | Preview is reduced to 1 next piece |
| **The Tide** | A garbage line appears at the bottom every 20 seconds |
| **The Enforcer** | Time limit is reduced to 45 seconds (quota unchanged) |
| **The Purge** | Singles and Doubles send 0 attack; only Triples, Tetrises, and T-spins count |
| **The Surgeon** | Only T-spins count toward the quota (all other clears send 0) |
| **The Silencer** | Back-to-back chain is disabled; every clear starts a fresh chain |
| **The Narrow** | Board width reduced to 8 columns (leftmost 2 columns are walled off) |

#### Scenario: The Void disables hold
- **WHEN** The Void modifier is active
- **THEN** the hold action is rejected for the entire round with a visual indicator

#### Scenario: The Surgeon restricts quota contribution
- **WHEN** The Surgeon modifier is active and the player clears lines with a non-T-spin
- **THEN** attack is generated but does NOT accumulate toward the quota (standard attack signal is suppressed for quota purposes)

#### Scenario: The Tide adds garbage periodically
- **WHEN** The Tide modifier is active and 20 seconds have elapsed since the last garbage insertion
- **THEN** one complete row of garbage (with one random gap) is inserted at the bottom of the board, pushing all existing rows up
