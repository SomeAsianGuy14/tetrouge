## ADDED Requirements

### Requirement: Base attack values per clear type
The system SHALL assign attack (lines sent) to each clear type using guideline values.

| Clear Type       | Lines Sent |
|-----------------|------------|
| Single           | 0          |
| Double           | 1          |
| Triple           | 2          |
| Tetris           | 4          |
| T-spin Mini      | 1          |
| T-spin Single    | 2          |
| T-spin Double    | 4          |
| T-spin Triple    | 6          |
| Perfect Clear    | 10         |

#### Scenario: Tetris sends 4 lines
- **WHEN** the player clears exactly 4 rows with a single piece lock
- **THEN** 4 lines of attack are generated before Technique modifiers

#### Scenario: T-spin double sends 4 lines
- **WHEN** the player performs a valid T-spin clearing 2 rows
- **THEN** 4 lines of attack are generated before Technique modifiers

### Requirement: T-spin detection
A clear SHALL be classified as a T-spin if a T-piece was the last active piece, the lock was preceded by a rotation, and the standard 3-corner rule is satisfied (at least 3 of the 4 diagonal cells adjacent to the T-piece centre are occupied by blocks or walls).

#### Scenario: 3-corner T-spin valid
- **WHEN** a T-piece locks after rotation with 3 or more diagonal corners occupied
- **THEN** the clear is classified as a T-spin

#### Scenario: Non-rotated T placement is not a T-spin
- **WHEN** a T-piece locks without a preceding rotation
- **THEN** the clear is classified as a standard clear regardless of corner occupancy

### Requirement: Back-to-back chain
A back-to-back (B2B) bonus of +1 attack SHALL be added to any qualifying clear (Tetris or T-spin of any type) when it immediately follows another qualifying clear without a non-qualifying clear in between.

#### Scenario: B2B bonus on consecutive Tetrises
- **WHEN** the player clears a Tetris immediately after a previous Tetris
- **THEN** the second Tetris sends 4 + 1 = 5 attack

#### Scenario: B2B chain breaks on non-qualifying clear
- **WHEN** the player clears a non-qualifying line (Single, Double, Triple) between two Tetrises
- **THEN** the second Tetris receives no B2B bonus

### Requirement: Combo multiplier
A combo counter SHALL increment by 1 for each consecutive piece that results in at least one line clear. The combo resets to -1 when a piece locks without clearing a line. Attack bonus per combo step follows the guideline combo table.

Combo table (lines sent per step):
`[0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, ...]` (step 0 = first clear, step 1 = second consecutive, etc.)

#### Scenario: Combo bonus accumulates
- **WHEN** the player clears lines on 4 consecutive pieces
- **THEN** the 4th clear generates combo table[3] = 1 bonus attack line

#### Scenario: Combo resets on empty lock
- **WHEN** a piece locks without clearing any lines
- **THEN** the combo counter resets to -1

### Requirement: Perfect clear bonus
A perfect clear (all cells empty after a line clear) SHALL send 10 lines of attack in place of the base clear value (not in addition).

#### Scenario: Perfect clear overrides base value
- **WHEN** the board is completely empty after a line clear
- **THEN** exactly 10 lines of attack are generated regardless of how many rows were cleared

### Requirement: Attack event emission
The board SHALL emit an `attack_generated` signal for each clear event carrying the raw attack value. The roguelike layer intercepts this signal and applies Technique modifiers before adding to the round quota total. The board itself does not know about Techniques.

#### Scenario: Raw attack signal is unmodified
- **WHEN** a clear occurs
- **THEN** the board emits the guideline attack value with no Technique adjustments applied

#### Scenario: RunManager applies Technique modifiers
- **WHEN** RunManager receives the attack_generated signal
- **THEN** it applies all active Technique multipliers and flat bonuses before adding to the quota accumulator
