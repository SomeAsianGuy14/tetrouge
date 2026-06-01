## ADDED Requirements

### Requirement: Base game garbage intervals are increased by 25%
All enemy garbage interval constants SHALL be multiplied by 1.25 compared to their pre-ascension values, giving players more breathing room in the base game. This applies at ascension level 0.

#### Scenario: Small enemy base interval is slower
- **WHEN** ascension level is 0
- **THEN** Small enemy garbage interval SHALL be approximately 22.5–35s (previously 18–28s)

### Requirement: Ascension modifiers are cumulative
Each ascension level adds one new modifier that stacks with all modifiers from lower levels. A run at level N applies the modifiers from levels 1 through N simultaneously.

#### Scenario: Level 3 includes level 1 and 2 modifiers
- **WHEN** the player starts a run at ascension level 3
- **THEN** garbage intervals SHALL use pre-rebalance speeds (level 1)
- **THEN** garbage lines SHALL be increased by 1 (level 2)
- **THEN** consumable capacity SHALL be reduced by 1 (level 3)

### Requirement: Level 1 — Enemy attacks return to pre-rebalance speed
At ascension level 1 or above, garbage interval multipliers SHALL revert to the original pre-rebalance values (i.e. the 25% increase is removed), making enemies attack at their original speed.

#### Scenario: Level 1 restores original intervals
- **WHEN** ascension level >= 1
- **THEN** garbage interval generation SHALL use the pre-rebalance base constants (no ×1.25 factor)

### Requirement: Level 2 — Enemy attacks deal +1 garbage line
At ascension level 2 or above, `garbage_lines_min` and `garbage_lines_max` SHALL each be increased by 1 after all other modifiers are applied.

#### Scenario: Level 2 increases line count
- **WHEN** ascension level >= 2
- **AND** a round would normally produce 1–2 garbage lines
- **THEN** the round SHALL produce 2–3 garbage lines instead

### Requirement: Level 3 — Consumable capacity reduced by 1
At ascension level 3 or above, the starting `consumable_capacity` SHALL be reduced by 1 (minimum 0). This is applied at run initialisation, before any voucher effects.

#### Scenario: Level 3 reduces backpack size
- **WHEN** ascension level >= 3
- **THEN** `RunState.consumable_capacity` SHALL start at 2 instead of 3

### Requirement: Level 4 — Enemy HP increased by 20%
At ascension level 4 or above, the quota (enemy HP) calculated for each round SHALL be multiplied by 1.2, rounded up.

#### Scenario: Level 4 increases round quota
- **WHEN** ascension level >= 4
- **AND** a round's base quota would be 50
- **THEN** the actual quota SHALL be `ceil(50 * 1.2) = 60`

### Requirement: Level 5 — No starter keystone
At ascension level 5 or above, the starter keystone selection screen SHALL NOT appear at run start. The player begins with no keystone and must acquire them through post-boss selections.

#### Scenario: Level 5 skips starter selection
- **WHEN** ascension level >= 5
- **THEN** `_show_starter_keystone_selection()` SHALL NOT be called at run start
- **THEN** the player SHALL have zero keystones at the start of round 1

### Requirement: Level 6 — Starting technique capacity reduced by 1
At ascension level 6 or above, the base `technique_capacity` at stage 1 SHALL be 3 instead of 4. The per-stage scaling (capacity = base + stage − 1) continues to apply on top of this reduced base.

#### Scenario: Level 6 reduces technique capacity
- **WHEN** ascension level >= 6
- **THEN** `technique_capacity` at stage 1 SHALL be 3
- **THEN** `technique_capacity` at stage 2 SHALL be 4 (3 + 1)
