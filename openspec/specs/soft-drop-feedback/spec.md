## ADDED Requirements

### Requirement: Ghost piece renders brighter when soft dropping is active
When `TetrisBoard.soft_dropping` is true, the ghost piece cells SHALL render with a noticeably brighter colour than the standard ghost grey. When soft dropping is inactive, the ghost piece SHALL return to its standard appearance.

#### Scenario: Ghost brightens during soft drop
- **WHEN** the player holds the soft drop key and the board redraws
- **THEN** the ghost piece cells render visibly brighter than the default grey

#### Scenario: Ghost returns to normal when soft drop is released
- **WHEN** the player releases the soft drop key
- **THEN** the ghost piece cells return to the standard grey colour on the next redraw
