## ADDED Requirements

### Requirement: B2B indicator is visible only while a back-to-back chain is active
The HUD SHALL display a B2B indicator label while `is_b2b` is true and hide it when `is_b2b` is false. The indicator SHALL be updated on every piece lock.

#### Scenario: B2B indicator appears on second consecutive qualifying clear
- **WHEN** the player completes a qualifying clear (Tetris or T-spin) immediately after a previous qualifying clear
- **THEN** the B2B indicator becomes visible before the next piece is active

#### Scenario: B2B indicator is hidden at round start
- **WHEN** a new round begins
- **THEN** the B2B indicator is not visible

#### Scenario: B2B indicator hides when chain breaks
- **WHEN** the player performs a non-qualifying clear (Single, Double, or Triple) that breaks the B2B chain
- **THEN** the B2B indicator becomes hidden

### Requirement: Combo counter is visible only while a combo streak is active
The HUD SHALL display a combo counter label showing the current combo multiplier step while `combo >= 0` and hide it when `combo` resets to −1. The label text SHALL follow the format "Combo x{n}" where `n = combo + 1`. The counter SHALL be updated on every piece lock.

#### Scenario: Combo counter appears on first consecutive clearing lock
- **WHEN** the player locks a piece that clears at least one line immediately after a previous clearing lock
- **THEN** the combo counter becomes visible and shows "Combo x2"

#### Scenario: Combo counter shows correct step
- **WHEN** the player has cleared lines on 5 consecutive pieces
- **THEN** the combo counter shows "Combo x5"

#### Scenario: Combo counter is hidden at round start
- **WHEN** a new round begins
- **THEN** the combo counter is not visible

#### Scenario: Combo counter hides on non-clearing lock
- **WHEN** the player locks a piece without clearing any lines
- **THEN** the combo counter becomes hidden

### Requirement: B2B and combo indicators initialise hidden on round setup
Both the B2B indicator and the combo counter SHALL be hidden when the HUD is set up for a new round, regardless of any state carried over from a previous round.

#### Scenario: Both indicators start hidden
- **WHEN** `hud.setup()` is called at the start of a round
- **THEN** neither the B2B indicator nor the combo counter is visible
