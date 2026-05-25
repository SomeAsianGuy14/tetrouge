## MODIFIED Requirements

### Requirement: Boss modifier name and description are displayed during boss rounds
During a boss round, the HUD InfoPanel modifier label SHALL display the modifier's `display_name` on the first line and its `description` on a second line. The compact TopBar modifier label SHALL display the `display_name` and SHALL provide the `description` as a hover tooltip. Both labels SHALL be hidden during non-boss rounds.

#### Scenario: InfoPanel shows name and description on boss round start
- **WHEN** a boss round begins with modifier "The Void"
- **THEN** the InfoPanel modifier label text is "The Void\nHold piece is disabled for this round."

#### Scenario: TopBar tooltip contains description on hover
- **WHEN** the player hovers over the TopBar modifier label during a boss round
- **THEN** the tooltip text is the modifier's description string

#### Scenario: Both labels hidden on non-boss rounds
- **WHEN** a non-boss round begins
- **THEN** both `modifier_label` and `modifier_big_label` are not visible
