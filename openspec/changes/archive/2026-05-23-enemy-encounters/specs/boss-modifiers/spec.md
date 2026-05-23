## MODIFIED Requirements

### Requirement: Boss modifier pool for launch
The following boss modifiers SHALL be available in the initial build as board-rule abilities assigned to boss enemies. The Tide modifier is removed; its garbage effect is now a universal enemy mechanic applied every round.

| Name | Effect |
|------|--------|
| **The Void** | Hold piece is disabled for this round |
| **The Blinder** | Preview is reduced to 1 next piece |
| **The Enforcer** | Time limit is reduced to 45 seconds (quota unchanged) |
| **The Purge** | Singles and Doubles send 0 attack; only Triples, Tetrises, and T-spins count |
| **The Surgeon** | Only T-spins count toward the quota (all other clears send 0) |
| **The Silencer** | Back-to-back chain is disabled; every clear starts a fresh chain |
| **The Narrow** | Board width reduced to 8 columns (leftmost 2 columns are walled off) |

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

#### Scenario: The Surgeon restricts quota contribution
- **WHEN** The Surgeon ability is active and the player clears lines with a non-T-spin
- **THEN** attack is generated but does NOT accumulate toward the quota

## REMOVED Requirements

### Requirement: The Tide adds garbage periodically
**Reason:** Garbage row insertion is now a universal enemy mechanic active every round. The Tide modifier served no other purpose and is removed. Every enemy has a base garbage interval; The Tide's effect is subsumed by the general garbage system.
**Migration:** Remove `the_tide.tres`. Remove `garbage_interval` from `BossModifier`. Garbage timing is now owned by the `Enemy` resource and `RoundConfig.effective_garbage_interval`.
