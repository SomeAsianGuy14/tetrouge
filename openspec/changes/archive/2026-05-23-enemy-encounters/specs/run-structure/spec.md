## ADDED Requirements

### Requirement: Every round has an assigned enemy
Each round in a run SHALL have exactly one enemy assigned to it via seeded tier pool draw. The enemy determines the periodic garbage attack rate and, for boss rounds, the board-rule modification. Round progression and quota mechanics are unchanged.

#### Scenario: Enemy assigned before round starts
- **WHEN** a round is built
- **THEN** an enemy has been drawn from the appropriate tier pool and is available for display and mechanics before the first piece spawns

#### Scenario: Non-boss rounds have no board-rule modification
- **WHEN** a Small, Big, or Elite round begins
- **THEN** only the enemy's garbage interval affects the round; no board rules are changed

#### Scenario: Boss rounds have both enemy garbage and board-rule modification
- **WHEN** a Boss round begins
- **THEN** the enemy's garbage interval is active and the enemy's board-rule ability is applied to RoundConfig

### Requirement: Used boss enemy IDs are tracked per run
The run SHALL track which boss enemies have already appeared so they are not repeated. Used boss enemy IDs SHALL be persisted in the save file and cleared on run reset.

#### Scenario: Boss enemy not repeated within a run
- **WHEN** a boss enemy has appeared in a previous Boss round of the current run
- **THEN** it is excluded from the draw pool for subsequent Boss rounds unless all boss enemies have been used
