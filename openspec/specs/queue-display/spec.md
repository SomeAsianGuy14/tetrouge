## ADDED Requirements

### Requirement: Queue display renders the next N pieces to the right of the board
A `QueueDisplay` panel SHALL be rendered to the right of the main board during every active round. It SHALL display the next `config.preview_count` pieces from `TetrisBoard.piece_queue` as small tetrominoes stacked vertically, top-to-bottom in draw order.

#### Scenario: Default preview shows 5 pieces
- **WHEN** no keystone modifies the preview count
- **THEN** the queue panel shows exactly 5 tetrominoes stacked vertically

#### Scenario: Pieces render with correct colours
- **WHEN** the next piece in the queue is an I-piece
- **THEN** the topmost slot in the queue display shows a cyan I-shaped tetromino

### Requirement: Queue display adapts to preview_count changes
The `QueueDisplay` SHALL read `board.config.preview_count` on each `_draw()` call. The number of slots drawn SHALL always equal the current `preview_count`, with no fixed layout assumptions.

#### Scenario: Foresight keystone expands preview to 7
- **WHEN** the Foresight keystone is active (`config.preview_count` is 7)
- **THEN** the queue panel shows 7 piece slots

#### Scenario: The Blinder boss modifier reduces preview to 1
- **WHEN** The Blinder boss modifier is active (`config.preview_count` is 1)
- **THEN** the queue panel shows exactly 1 piece slot

### Requirement: Queue display updates on every board_updated signal
The `QueueDisplay` SHALL call `queue_redraw()` each time the `TetrisBoard` emits `board_updated`.

#### Scenario: Display refreshes after piece locks
- **WHEN** the current piece locks and the queue advances
- **THEN** the queue display updates to show the shifted queue within the same frame

### Requirement: Each piece is centred within a 4×4 mini-grid slot
Each piece in both displays SHALL be drawn centred within a 4×4 bounding box using mini-cell size, so all piece types (including the wide I-piece) fit without clipping or misalignment.

#### Scenario: I-piece fits without clipping
- **WHEN** an I-piece appears in the queue display
- **THEN** all 4 cells of the I-piece are visible within the slot bounds

#### Scenario: O-piece is visually centred
- **WHEN** an O-piece appears in the queue or hold display
- **THEN** the 2×2 block appears centred within the slot, not flush to a corner
