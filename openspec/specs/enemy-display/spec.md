## ADDED Requirements

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

### Requirement: HP bar displays remaining quota as draining health
The EnemyDisplay SHALL show a ProgressBar representing the enemy's remaining HP. The bar SHALL start full and drain as the player accumulates attack toward the quota. The current and maximum quota values SHALL be overlaid as a label on the bar (e.g. "32 / 44").

#### Scenario: HP bar starts full
- **WHEN** a round begins
- **THEN** the HP bar is at maximum value equal to the round quota

#### Scenario: HP bar drains with each attack
- **WHEN** the player's accumulated attack increases
- **THEN** the HP bar value decreases by the same amount, and the overlaid label updates to reflect the new values

#### Scenario: HP bar reaches zero on quota completion
- **WHEN** accumulated attack equals or exceeds the quota
- **THEN** the HP bar value is at or near zero

### Requirement: Wind-up indicator shows time until next garbage attack
The EnemyDisplay SHALL show a secondary progress bar (wind-up bar) that fills over the effective garbage interval. When it reaches full, a garbage row fires and the bar resets. A label SHALL display the remaining seconds until the next attack.

#### Scenario: Wind-up bar fills over the garbage interval
- **WHEN** the round is active
- **THEN** the wind-up bar progresses from empty to full over exactly one effective garbage interval

#### Scenario: Wind-up bar resets after garbage fires
- **WHEN** the wind-up bar reaches full and a garbage row is inserted
- **THEN** the wind-up bar resets to empty and begins filling again

#### Scenario: Countdown label shows remaining seconds
- **WHEN** the round is active
- **THEN** the wind-up label displays the integer seconds remaining until the next garbage attack
