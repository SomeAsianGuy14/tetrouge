## ADDED Requirements

### Requirement: Collapsible mastery panel above InventoryPanel
The HUD SHALL include a collapsible mastery panel positioned above the InventoryPanel. The panel SHALL contain a clickable header label and 7 track labels showing each track's name and current level.

#### Scenario: Panel shows all 7 tracks when expanded
- **WHEN** the mastery panel is expanded
- **THEN** 7 labels are visible, each showing the track name, level, and XP progress (e.g., "Singles  Lv 3 (4/16)")

#### Scenario: Panel collapses to header only
- **WHEN** the player clicks the mastery header
- **THEN** the track labels are hidden, only the header remains visible

#### Scenario: Panel defaults to collapsed
- **WHEN** a run begins
- **THEN** the mastery panel starts in the collapsed state

### Requirement: Mastery panel follows InventoryPanel visibility
The mastery panel SHALL be visible during combat, encounter, and map screens. It SHALL be hidden during shop visits, matching the InventoryPanel's visibility behavior.

#### Scenario: Panel visible during encounter
- **WHEN** the player enters an encounter room
- **THEN** the mastery panel is visible (if expanded, tracks are shown)

#### Scenario: Panel hidden during shop
- **WHEN** the player enters the shop
- **THEN** the mastery panel is not visible

### Requirement: Mastery panel updates on level changes
The mastery panel track labels SHALL update whenever a mastery track levels up during combat. The panel SHALL also refresh when entering non-combat screens.

#### Scenario: Track label updates on level-up
- **WHEN** the quad track levels up from 2 to 3 during combat
- **THEN** the quad label updates to "Quads  Lv 3 (0/8)"

#### Scenario: Track label updates XP progress on each clear
- **WHEN** the quad track is level 2 with 3 XP (threshold 7) and the player clears a quad
- **THEN** the quad label updates to "Quads  Lv 2 (4/7)"

### Requirement: Level-up popup on mastery threshold
When a mastery track levels up, a popup label SHALL appear near the mastery panel with the track name and new level (e.g., "Quads Lv 3!"). The popup SHALL use the same fade-and-float animation pattern as technique event popups but with a distinct color (light green).

#### Scenario: Popup appears on quad level-up
- **WHEN** the quad mastery track reaches level 3
- **THEN** a popup reading "Quads Lv 3!" appears near the mastery panel in light green, floats upward, and fades out

#### Scenario: No popup when XP is gained without leveling
- **WHEN** the player gains XP but does not cross a level threshold
- **THEN** no mastery popup is spawned
