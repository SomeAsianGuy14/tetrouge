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

## ADDED Requirements

### Requirement: HUD side panel displays owned Techniques as icon labels
The HUD side panel SHALL display a Techniques section below the Keystones section. Each owned Technique SHALL be rendered as a compact label showing the first character of its display name, with a tooltip containing the full name and description. The section SHALL include a "Techniques" header label. The display SHALL be rebuilt at the start of every round via `hud.setup()`.

#### Scenario: Technique icons appear when techniques are owned
- **WHEN** the player owns one or more Techniques and a round begins
- **THEN** each owned Technique is shown as a single-character label in the Techniques section of the side panel

#### Scenario: Technique tooltip shows full name and description
- **WHEN** the player hovers over a Technique icon in the side panel
- **THEN** a tooltip displays the Technique's full name and description

#### Scenario: Techniques section is empty when no techniques are owned
- **WHEN** the player owns no Techniques at the start of a round
- **THEN** the Techniques icon row is empty (the header label remains visible)

#### Scenario: Technique icons update after shop visit
- **WHEN** the player purchases a Technique in the shop and a new round begins
- **THEN** the newly acquired Technique appears in the side panel for that round

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
