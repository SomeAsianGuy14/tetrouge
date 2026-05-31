## ADDED Requirements

### Requirement: Blessed Stone triggers on first death event of the run
When the player holds the Blessed Stone keystone and a death event occurs for the first time in the run, the system SHALL intercept the failure, revive the player, and consume the stone. A death event is defined as either (a) the board topping out or (b) the round timer reaching zero.

#### Scenario: Blessed Stone triggers on topout
- **WHEN** the board emits `game_over` (topout)
- **AND** the player holds the Blessed Stone keystone
- **AND** the stone has not yet been spent this run
- **THEN** `_end_round(false)` SHALL NOT be called
- **THEN** the board SHALL be cleared
- **THEN** the round timer SHALL be increased by 120 seconds
- **THEN** the stone SHALL be marked spent

#### Scenario: Blessed Stone triggers on timeout
- **WHEN** `round_timer` reaches zero or below
- **AND** the player holds the Blessed Stone keystone
- **AND** the stone has not yet been spent this run
- **THEN** `_end_round(false)` SHALL NOT be called
- **THEN** the board SHALL be cleared
- **THEN** the round timer SHALL be set to 120 seconds
- **THEN** the stone SHALL be marked spent

#### Scenario: Blessed Stone does not trigger a second time
- **WHEN** a death event occurs
- **AND** the stone has already been spent this run
- **THEN** the death SHALL proceed normally via `_end_round(false)`

#### Scenario: Damage accumulated is preserved after Blessed Stone triggers
- **WHEN** Blessed Stone triggers
- **THEN** `quota_accumulated` (damage dealt to the enemy so far) SHALL NOT be reset

### Requirement: Blessed Stone spent state resets between runs
The `_blessed_stone_spent` flag in RunManager SHALL be reset when a new round begins, but SHALL persist across rounds within a single run (once spent, it remains spent for the rest of the run).

#### Scenario: Stone spent state persists within a run
- **WHEN** Blessed Stone is consumed in round 2
- **AND** the player reaches round 3
- **THEN** Blessed Stone SHALL NOT trigger again in round 3

#### Scenario: Stone spent state resets on new run
- **WHEN** `RunState.reset()` is called
- **THEN** the spent state SHALL be cleared for the new run
