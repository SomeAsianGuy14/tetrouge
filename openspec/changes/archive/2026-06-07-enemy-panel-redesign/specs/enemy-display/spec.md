## MODIFIED Requirements

### Requirement: EnemyDisplay panel is shown during every round
An EnemyDisplay panel SHALL be visible during every round, positioned as a full-height Control on the right side of the viewport (not as a child of BoardContainer). It SHALL be created at round start, updated continuously during the round, and freed when the round ends.

#### Scenario: Panel is present from first frame
- **WHEN** a round begins
- **THEN** the EnemyDisplay panel is visible on the right side of the screen before the first piece spawns

#### Scenario: Panel is removed after round ends
- **WHEN** the round ends (success or failure)
- **THEN** the EnemyDisplay panel is no longer in the scene tree

### Requirement: Enemy is represented by a free-floating portrait with initial-letter placeholder or sprite
The EnemyDisplay SHALL show a free-floating portrait area (no background box or border) of approximately 360×360px. When no sprite is set, a large semi-transparent initial letter (first character of the enemy's display name, ~180pt, ~0.15 opacity, tinted in enemy color) SHALL fill the portrait area as a placeholder. When a sprite texture is assigned to the enemy resource, the sprite SHALL be displayed and the initial letter hidden.

#### Scenario: Initial-letter placeholder shown when no sprite
- **WHEN** the enemy's sprite field is null
- **THEN** a large, low-opacity, color-tinted letter matching the first character of the enemy's name is shown; no colored background box is visible

#### Scenario: Sprite shown and placeholder hidden when assigned
- **WHEN** the enemy's sprite field is non-null
- **THEN** the sprite texture is displayed in the portrait area and the initial-letter label is hidden
