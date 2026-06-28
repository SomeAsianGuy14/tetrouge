## ADDED Requirements

### Requirement: Per-technique persistent state
`RunState` SHALL maintain a `technique_state: Dictionary` keyed by technique ID. This state SHALL persist across rounds within a run and reset on `RunState.reset()`.

#### Scenario: State persists across rounds
- **WHEN** Blood Offering's bonus is increased during round 1
- **THEN** the increased bonus SHALL still be active in round 2

#### Scenario: State resets on new run
- **WHEN** a new run starts
- **THEN** `technique_state` SHALL be empty

### Requirement: Blood Offering technique
Blood Offering SHALL be an epic technique that deals +3 damage on all attacks. Whenever the player defeats an enemy, the bonus SHALL permanently increase by 2 for the rest of the run.

#### Scenario: Base damage bonus
- **WHEN** the player has Blood Offering and clears a line
- **THEN** +3 additional damage SHALL be dealt

#### Scenario: Bonus increases after kill
- **WHEN** the player defeats an enemy with Blood Offering equipped
- **THEN** the bonus SHALL increase to +5 for all subsequent attacks

#### Scenario: Bonus accumulates across multiple kills
- **WHEN** the player has defeated 3 enemies
- **THEN** Blood Offering's bonus SHALL be +9 (3 base + 2×3 kills)
