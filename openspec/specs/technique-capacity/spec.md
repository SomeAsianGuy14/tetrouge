## ADDED Requirements

### Requirement: Players have a technique capacity that scales with stage
`RunState` SHALL track `technique_capacity: int`, which defines the maximum number of Techniques the player may own simultaneously. The capacity starts at 4 and increases by 1 each stage, reaching 8 at stage 5.

| Stage | Capacity |
|-------|----------|
| 1 | 4 |
| 2 | 5 |
| 3 | 6 |
| 4 | 7 |
| 5 | 8 |

The capacity SHALL be updated whenever the stage advances.

#### Scenario: Capacity is 4 at start of run
- **WHEN** a new run begins
- **THEN** `RunState.technique_capacity` is 4

#### Scenario: Capacity increases on stage advance
- **WHEN** `RunState.advance_round()` causes the stage to increment
- **THEN** `RunState.technique_capacity` becomes `4 + (new_stage - 1)`

### Requirement: Shop disables technique purchase when at capacity
The shop SHALL disable the Buy button for any Technique slot when `RunState.techniques.size() >= RunState.technique_capacity`.

#### Scenario: Buy button disabled at capacity
- **WHEN** the player owns exactly `technique_capacity` techniques and the shop opens
- **THEN** all Technique Buy buttons are disabled and a capacity-indicator message is visible

#### Scenario: Buy button enabled when below capacity
- **WHEN** the player owns fewer techniques than `technique_capacity`
- **THEN** technique Buy buttons follow normal affordability rules

#### Scenario: Selling a technique re-enables purchase
- **WHEN** the player sells a technique in the collection panel, dropping below capacity
- **THEN** technique Buy buttons reflect the new available slot (re-enabled if affordable)
