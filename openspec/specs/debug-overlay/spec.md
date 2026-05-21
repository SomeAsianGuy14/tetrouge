## ADDED Requirements

### Requirement: Debug overlay is toggled with F2 during an active round
The debug overlay SHALL be togglable by pressing F2 at any point during an active round. It SHALL be hidden by default when a round begins.

#### Scenario: F2 shows overlay when hidden
- **WHEN** F2 is pressed and the overlay is not visible
- **THEN** the overlay becomes visible

#### Scenario: F2 hides overlay when shown
- **WHEN** F2 is pressed and the overlay is visible
- **THEN** the overlay becomes hidden

### Requirement: Debug overlay displays live game state
The overlay SHALL display the following values, updated at least 4 times per second:
- Current ante and round name
- Quota accumulated / quota total
- Time remaining
- Combo count and B2B flag
- Current piece type and rotation
- Names of all active Keystones
- Names of all active Techniques
- Coin balance

#### Scenario: Overlay reflects quota after a clear
- **WHEN** the player clears lines and the overlay is visible
- **THEN** the quota accumulated value updates within 250ms to reflect the new total

### Requirement: Debug overlay does not affect gameplay
The overlay SHALL be implemented as a `CanvasLayer` and SHALL NOT intercept input events that would reach the `TetrisBoard`.

#### Scenario: Overlay visible but input passes through
- **WHEN** the overlay is visible and the player presses a movement key
- **THEN** the piece moves normally as if the overlay were not present
