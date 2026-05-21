## ADDED Requirements

### Requirement: Score and target are prominently displayed during active rounds
During an active round, the HUD SHALL display the current accumulated attack and the round quota target as large, clearly labelled text. Both values SHALL update immediately whenever attack is generated.

#### Scenario: Score and target visible at round start
- **WHEN** a round begins
- **THEN** the score label shows "0" and the target label shows the round quota before any piece is placed

#### Scenario: Score updates on line clear
- **WHEN** the player clears lines and attack is accumulated
- **THEN** the score display updates to the new accumulated value within the same frame

### Requirement: Round timer is prominently displayed and colour-coded
The round timer SHALL be shown in large text, counting down from the round time limit. When 10 seconds or fewer remain, the timer text SHALL turn red.

#### Scenario: Timer visible at round start
- **WHEN** a round begins
- **THEN** the timer shows the full time limit (e.g. "1:00") in white text

#### Scenario: Timer turns red in final 10 seconds
- **WHEN** the timer reaches 10 seconds remaining
- **THEN** the timer text changes to red

### Requirement: Ante and round name are displayed
The HUD SHALL show the current ante number and round name (e.g. "Ante 2 — Boss Blind") during active rounds.

#### Scenario: Round name updates at start of each round
- **WHEN** a new round begins
- **THEN** the round name label reflects the correct ante and round name

### Requirement: Coin balance is displayed and kept current
The HUD SHALL display the player's current coin balance. The displayed value SHALL update immediately whenever coins are added or spent.

#### Scenario: Coin balance updates on purchase
- **WHEN** the player spends coins in the shop and returns to a round
- **THEN** the coin label reflects the updated balance

#### Scenario: Economy signal connected only once
- **WHEN** multiple rounds occur in a single run
- **THEN** the coin label does not receive duplicate updates from multiple signal connections

## ADDED Requirements

### Requirement: HUD exposes an update method for B2B and combo state
The HUD SHALL provide an `update_b2b_combo(is_b2b: bool, b2b_count: int, combo: int)` method that RunManager calls on every piece lock to keep the B2B indicator and combo counter current.

#### Scenario: Method drives B2B indicator visibility and chain length
- **WHEN** `update_b2b_combo(true, 3, -1)` is called
- **THEN** the B2B indicator is visible showing "B2B x3" and the combo counter is hidden

#### Scenario: Method drives combo counter visibility and text
- **WHEN** `update_b2b_combo(false, 0, 2)` is called
- **THEN** the combo counter is visible and shows "Combo x3", and the B2B indicator is hidden

#### Scenario: Method hides both when inactive
- **WHEN** `update_b2b_combo(false, 0, -1)` is called
- **THEN** both the B2B indicator and the combo counter are hidden
