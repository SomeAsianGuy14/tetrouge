## ADDED Requirements

### Requirement: Standard playfield dimensions
The playfield SHALL be 10 columns wide and 20 rows tall (with 2 additional hidden rows above the visible area for piece spawn).

#### Scenario: Piece spawns at correct position
- **WHEN** a new piece enters the board
- **THEN** it spawns centred horizontally at row 21 (hidden area) following guideline spawn positions

#### Scenario: Game over on block out
- **WHEN** a new piece cannot spawn because its spawn cells are occupied
- **THEN** the round ends immediately as a failure

### Requirement: SRS rotation system
The game SHALL implement Super Rotation System (SRS) including all wall kick tables for clockwise, counter-clockwise, and 180-degree rotations.

#### Scenario: Wall kick succeeds
- **WHEN** a piece rotation would overlap a wall or block
- **THEN** the system attempts all SRS kick offsets in order and uses the first valid position

#### Scenario: Wall kick fails
- **WHEN** no SRS kick offset produces a valid position
- **THEN** the rotation is rejected and the piece remains in its previous state

### Requirement: 7-bag piece randomiser
The game SHALL use a standard 7-bag randomiser: all 7 tetrominoes are shuffled into a bag and drawn in order; a new shuffled bag is prepared when the current bag is exhausted. All bag shuffles SHALL use the run-seeded PRNG from `RunState` rather than GDScript's global `randi()` so piece sequences are deterministic for a given seed.

#### Scenario: All pieces appear within 14 draws
- **WHEN** 14 pieces have been drawn
- **THEN** each of the 7 standard tetrominoes has appeared exactly twice

#### Scenario: Preview queue shows next pieces
- **WHEN** the board is active
- **THEN** the next 5 pieces in the queue are visible to the player (modifiable by Augments)

#### Scenario: Piece sequence is deterministic per seed
- **WHEN** two runs share the same seed
- **THEN** the bag draw order is identical in both runs from the first piece onwards

### Requirement: Hold piece
The player SHALL be able to hold one piece at a time. Holding swaps the current piece with the held piece. The player cannot hold again until the current piece locks.

#### Scenario: First hold
- **WHEN** the player holds with no piece in reserve
- **THEN** the current piece moves to the hold slot and the next piece from the queue becomes active

#### Scenario: Swap hold
- **WHEN** the player holds with a piece already in reserve
- **THEN** the active piece and the held piece swap; the swapped-in piece retains its original rotation state

#### Scenario: Hold lockout
- **WHEN** the player attempts to hold immediately after a hold swap
- **THEN** the hold action is rejected until the current piece locks

### Requirement: Ghost piece
A ghost piece SHALL be displayed showing where the active piece would land if hard-dropped.

#### Scenario: Ghost updates with movement
- **WHEN** the active piece moves or rotates
- **THEN** the ghost piece position updates immediately

### Requirement: Hard drop and soft drop
The player SHALL be able to hard drop (instantly place piece at ghost position) and soft drop (accelerate fall speed while held).

#### Scenario: Hard drop
- **WHEN** the player hard drops
- **THEN** the piece instantly moves to the ghost position and locks

#### Scenario: Soft drop
- **WHEN** the player holds the soft drop input
- **THEN** the piece falls at 20× the normal gravity speed

### Requirement: DAS and ARR
Horizontal movement SHALL implement Delayed Auto Shift (DAS) and Auto Repeat Rate (ARR) following guideline defaults (DAS 167ms, ARR 33ms). Both values SHALL be configurable via a slider for coarse adjustment and a SpinBox for exact integer millisecond entry; the two controls SHALL stay in sync. ARR of 0 SHALL be treated as instant (piece moves to wall in a single frame). Valid range: DAS 50–500ms, ARR 0–200ms.

#### Scenario: DAS triggers auto-repeat
- **WHEN** the player holds a horizontal direction for longer than DAS
- **THEN** the piece begins repeating movement at the ARR interval

#### Scenario: ARR zero causes instant movement to wall
- **WHEN** ARR is set to 0 and DAS has elapsed
- **THEN** the piece moves all the way to the wall in a single frame without looping indefinitely

#### Scenario: Player enters exact DAS value via SpinBox
- **WHEN** the player types 150 into the DAS SpinBox
- **THEN** DAS is set to exactly 150ms, the slider moves to match, and the value is saved to config

#### Scenario: Slider and SpinBox stay in sync
- **WHEN** the player drags the DAS slider
- **THEN** the DAS SpinBox updates to show the same integer value

#### Scenario: DAS value is clamped to valid range
- **WHEN** the player enters a value outside 50–500ms in the DAS SpinBox
- **THEN** the value is clamped to the nearest valid boundary automatically

### Requirement: Lock delay
A piece that has landed SHALL not lock immediately; it SHALL have a lock delay of 500ms during which the player can continue to move or rotate it. Each successful move or rotation resets the lock delay timer, up to a maximum of 15 resets.

#### Scenario: Lock delay reset
- **WHEN** the player moves or rotates a piece that has landed within the lock delay window
- **THEN** the lock delay timer resets

#### Scenario: Lock delay maximum resets
- **WHEN** the piece has been moved or rotated 15 times since landing
- **THEN** the piece locks on the next gravity tick regardless of timer

### Requirement: Line clear animation and board update
When one or more complete rows are formed, they SHALL be cleared and the rows above SHALL fall down. The clear SHALL be detected before the next piece spawns.

#### Scenario: Single line clear
- **WHEN** exactly one row is fully filled
- **THEN** that row is removed and all rows above shift down by one

#### Scenario: Multiple simultaneous line clear
- **WHEN** multiple rows are filled simultaneously by a single piece lock
- **THEN** all filled rows are cleared and rows above shift down accordingly

### Requirement: Clockwise rotation is bound to X key in addition to Up arrow
The `rotate_cw` input action SHALL accept both the Up arrow key and the X key as valid triggers. Either key SHALL produce the same clockwise rotation.

#### Scenario: X key rotates clockwise
- **WHEN** the player presses X
- **THEN** the current piece rotates clockwise, including SRS wall kicks

#### Scenario: Up arrow still rotates clockwise
- **WHEN** the player presses Up arrow
- **THEN** the current piece rotates clockwise (unchanged from before)

### Requirement: Soft drop is bound to S key in addition to Down arrow
The `soft_drop` input action SHALL accept both the Down arrow key and the S key. Either key held down SHALL accelerate piece gravity to 20× normal speed.

#### Scenario: S key activates soft drop
- **WHEN** the player holds S
- **THEN** the active piece falls at 20× normal gravity

#### Scenario: Releasing S deactivates soft drop
- **WHEN** the player releases S (and Down is not also held)
- **THEN** the piece returns to normal gravity speed

### Requirement: Garbage row insertion is triggered by the enemy attack timer
Garbage row insertion SHALL be driven by `RoundConfig.effective_garbage_interval` for every round type, not exclusively by a boss modifier. The timer is managed by `RunManager` and resets after each insertion. This replaces the previous boss-modifier-only garbage mechanism.

#### Scenario: Garbage fires in non-boss rounds
- **WHEN** a Small, Big, or Elite round is active and the effective garbage interval elapses
- **THEN** one garbage row is inserted at the bottom of the board

#### Scenario: Garbage fires in boss rounds
- **WHEN** a Boss round is active and the effective garbage interval elapses
- **THEN** one garbage row is inserted, the same as in any other round

#### Scenario: Garbage row has one random gap
- **WHEN** a garbage row is inserted
- **THEN** exactly one cell in the row is empty; all other cells are filled with garbage color; the gap position is determined by the run PRNG
