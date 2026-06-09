## ADDED Requirements

### Requirement: A popup label appears below the hold display after every line clear
After every line clear, RunManager SHALL spawn a transient label positioned below the hold display showing the human-readable name of the clear type. The label SHALL appear for all clear types: Single, Double, Triple, Quad, T-Spin Mini, T-Spin, T-Spin Double, T-Spin Triple, and Perfect Clear.

#### Scenario: Single clear shows "Single"
- **WHEN** the player clears exactly 1 line with no T-spin
- **THEN** a popup appears below the hold display with the text "Single"

#### Scenario: Quad clear shows "Quad"
- **WHEN** the player clears 4 lines at once
- **THEN** a popup appears below the hold display with the text "Quad"

#### Scenario: T-Spin Double shows "T-Spin Double"
- **WHEN** the player performs a T-spin clearing 2 lines
- **THEN** a popup appears below the hold display with the text "T-Spin Double"

#### Scenario: T-Spin (single) shows "T-Spin"
- **WHEN** the player performs a T-spin clearing 1 line
- **THEN** a popup appears below the hold display with the text "T-Spin"

#### Scenario: Perfect Clear shows "Perfect Clear"
- **WHEN** the player clears all filled cells from the board
- **THEN** a popup appears below the hold display with the text "Perfect Clear"

### Requirement: Popup color reflects clear tier
The popup label SHALL use a tier-based color: white for plain clears (Single/Double/Triple), cyan for Quad, purple for all T-Spin variants, and gold for Perfect Clear.

#### Scenario: Plain clear is white
- **WHEN** a Single, Double, or Triple is cleared
- **THEN** the popup label color is white

#### Scenario: Quad is cyan
- **WHEN** a Quad is cleared
- **THEN** the popup label color is cyan (approximately Color(0.3, 0.9, 1.0))

#### Scenario: T-Spin variant is purple
- **WHEN** any T-spin clear occurs (mini, single, double, or triple)
- **THEN** the popup label color is purple (approximately Color(0.7, 0.4, 1.0))

#### Scenario: Perfect Clear is gold
- **WHEN** a Perfect Clear is achieved
- **THEN** the popup label color is gold (approximately Color(1.0, 0.85, 0.1))

### Requirement: High-tier clears play a scale-up pop animation
Quad, all T-Spin variants, and Perfect Clear SHALL play a brief scale-up animation (scale overshoot then settle) at spawn time before the fade begins. Plain clears (Single/Double/Triple) SHALL only fade with no scale change.

#### Scenario: Quad popup plays pop animation
- **WHEN** a Quad is cleared
- **THEN** the popup briefly scales up past its normal size before settling, then fades out

#### Scenario: T-Spin popup plays pop animation
- **WHEN** any T-spin clear occurs
- **THEN** the popup plays the same scale-up pop animation as a Quad

#### Scenario: Single popup does not scale
- **WHEN** a Single is cleared
- **THEN** the popup appears at normal scale and only fades out — no scale animation plays

### Requirement: Popup lifetime matches the line clear delay
When `RoundConfig.line_clear_delay > 0`, the popup SHALL appear at the moment `line_clear_delay_started` fires (before lines are removed from the board) and SHALL fade to invisible over the full line clear delay duration. When `line_clear_delay` is 0, the popup SHALL appear when `lines_cleared` fires and SHALL fade over a default duration of approximately 0.5 seconds.

#### Scenario: Popup fades during line clear delay
- **WHEN** `line_clear_delay` is 0.5s and a clear occurs
- **THEN** the popup is fully visible at the start of the delay and fully transparent by the time the delay ends

#### Scenario: Zero-delay popup uses default fade duration
- **WHEN** `line_clear_delay` is 0.0 and a clear occurs
- **THEN** a popup appears at the moment the clear resolves and fades over approximately 0.5 seconds

### Requirement: Only one clear-type popup is shown per piece lock
Each piece lock SHALL produce at most one clear-type popup. When `line_clear_delay_started` handles the popup for a given lock, the `lines_cleared` signal handler SHALL NOT spawn a second popup for the same lock.

#### Scenario: No double popup when delay is active
- **WHEN** `line_clear_delay > 0` and both `line_clear_delay_started` and `lines_cleared` fire for the same lock
- **THEN** exactly one clear-type popup appears, not two
