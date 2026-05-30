## MODIFIED Requirements

### Requirement: Hold piece
The player SHALL be able to hold up to `RoundConfig.hold_slots` pieces (default 1). Hold uses a queue model: pressing hold appends the current piece to the back of the held queue if space is available and spawns the next piece from the piece queue; if the held queue is full, the front piece is removed from the held queue, the current piece is appended to the back, and the removed piece becomes the active piece. The player cannot hold again until the current piece locks (when `hold_lockout_enabled = true`).

#### Scenario: First hold with empty queue
- **WHEN** the player holds with no pieces in reserve
- **THEN** the current piece is appended to the held queue and the next piece from the piece queue becomes active

#### Scenario: Hold with full queue (single slot)
- **WHEN** the player holds with one piece already in reserve (queue full at 1)
- **THEN** the held piece is removed from the front, the active piece is appended to the back, and the previously-held piece becomes active

#### Scenario: Hold fills second slot (two-slot keystone)
- **WHEN** the player holds for the first time after hold lockout resets and the held queue has 1 piece with capacity 2
- **THEN** the current piece is appended to the back of the held queue and the next piece from the piece queue becomes active (second slot now occupied)

#### Scenario: Hold cycles with full two-slot queue
- **WHEN** the held queue holds 2 pieces and the player holds
- **THEN** the oldest held piece (front of queue) becomes active and the current piece is added to the back

#### Scenario: Hold lockout
- **WHEN** the player attempts to hold immediately after a hold swap (lockout enabled)
- **THEN** the hold action is rejected until the current piece locks

## ADDED Requirements

### Requirement: Horizontal slide re-checks ground state
After a successful horizontal move, `TetrisBoard` SHALL re-evaluate whether the piece is still on the ground. If the cell directly below the piece's new position is empty (i.e., the piece slid over a hole), `is_on_ground` SHALL be set to `false` and the lock timer SHALL be cleared. If the cell below is still occupied, the lock delay is reset via the normal reset mechanic.

#### Scenario: Slide over hole clears ground state
- **WHEN** a piece slides horizontally into a position where the cell directly below is empty
- **THEN** `is_on_ground` becomes `false` and the lock timer resets to 0

#### Scenario: Slide to another grounded position resets lock timer
- **WHEN** a piece slides horizontally to a position still directly above a block or the floor
- **THEN** `is_on_ground` remains `true` and the lock delay timer resets (counts as a lock reset)
