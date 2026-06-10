## ADDED Requirements

### Requirement: Board enters a delay state when rows are cleared
When a piece locks onto full rows, the board SHALL suspend input and gravity for the duration of `RoundConfig.line_clear_delay` before removing the rows, emitting clear signals, and spawning the next piece.

#### Scenario: Delay begins on lock with full rows
- **WHEN** a piece locks and one or more rows are full
- **THEN** the board enters the line clear delay state, input is frozen, gravity is frozen, and full rows are drawn with a flashing animation

#### Scenario: Rows are not removed until delay expires
- **WHEN** the board is in the line clear delay state
- **THEN** the grid still contains the full rows (they have not been removed) and no clear signals have fired yet

#### Scenario: Clear completes after delay expires
- **WHEN** `line_clear_delay` seconds have elapsed since entering the delay state
- **THEN** the board removes the full rows from the grid, emits `lines_cleared`, `rows_cleared`, and `attack_generated` signals, emits `lock_processed`, and spawns the next piece

### Requirement: Signal ordering is preserved through the delay
The board SHALL emit signals in the same relative order regardless of whether a delay occurred.

#### Scenario: piece_locked fires immediately on lock
- **WHEN** a piece stamps its cells to the grid
- **THEN** `piece_locked` is emitted immediately, before any delay begins

#### Scenario: lock_processed fires after clear signals
- **WHEN** the line clear completes (either immediately or after a delay)
- **THEN** `lock_processed` is emitted after `lines_cleared`, `rows_cleared`, and `attack_generated`

### Requirement: No delay when line_clear_delay is zero
The board SHALL skip the delay state entirely and clear rows synchronously when `RoundConfig.line_clear_delay` is 0.0.

#### Scenario: Immediate clear with zero delay
- **WHEN** `config.line_clear_delay` is 0.0 and a piece locks onto full rows
- **THEN** rows are removed and all signals fire in the same frame as the lock, with no delay state entered

#### Scenario: No delay when no rows are cleared
- **WHEN** a piece locks and no rows are full
- **THEN** no delay state is entered and `lock_processed` fires immediately

### Requirement: Flashing animation during the delay
While the board is in the line clear delay state, the pending full rows SHALL be rendered with a pulsing flash animation.

#### Scenario: Rows flash during delay
- **WHEN** the board is in the line clear delay state
- **THEN** the rows that will be cleared are drawn with a color that pulses between the original cell color and white approximately 3 times across the delay duration

### Requirement: RoundConfig controls delay duration
`RoundConfig` SHALL expose a `line_clear_delay: float` field (default 0.5) that TetrisBoard reads to determine delay duration.

#### Scenario: Default delay is 0.5 seconds
- **WHEN** no keystone overrides the delay
- **THEN** `RoundConfig.line_clear_delay` is 0.5 and the board delays for 0.5 seconds

### Requirement: Full Potential keystone suppresses the delay
The Full Potential keystone SHALL set `line_clear_delay` to 0.0 via `apply_to_config`, giving instant clears consistent with its instant-ARR / instant-soft-drop identity.

#### Scenario: Full Potential removes the delay
- **WHEN** the Full Potential keystone is active
- **THEN** `RoundConfig.line_clear_delay` is 0.0 and rows clear instantly on lock

### Requirement: Keystone resource supports delay suppression flag
`Keystone` SHALL expose a `skip_line_clear_delay: bool` field (default false). When true, `apply_to_config` SHALL set `config.line_clear_delay = 0.0`.

#### Scenario: skip_line_clear_delay applies to config
- **WHEN** a keystone has `skip_line_clear_delay = true` and `apply_to_config` is called
- **THEN** `config.line_clear_delay` is set to 0.0
