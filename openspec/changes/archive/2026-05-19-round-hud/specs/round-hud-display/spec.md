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
