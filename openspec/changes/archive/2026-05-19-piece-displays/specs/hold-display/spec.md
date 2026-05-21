## ADDED Requirements

### Requirement: Hold display renders the held piece to the left of the board
A `HoldDisplay` panel SHALL be rendered to the left of the main board during every active round. It SHALL display the piece currently stored in `TetrisBoard.held_pieces[0]` as a small tetromino using the same colour scheme as the board.

#### Scenario: Hold piece renders with correct colour
- **WHEN** the player holds a T-piece and the display is visible
- **THEN** the hold panel shows a purple T-shaped tetromino at mini-cell size

#### Scenario: Empty hold shows blank panel
- **WHEN** no piece has been held yet (`held_pieces` is empty)
- **THEN** the hold panel shows only the background with no piece drawn

### Requirement: Hold display dims when hold is disabled
When `config.hold_disabled` is true (e.g., The Void boss modifier is active), the `HoldDisplay` SHALL render its background at reduced opacity and SHALL NOT draw any piece, indicating the hold action is unavailable.

#### Scenario: The Void modifier disables hold display
- **WHEN** `config.hold_disabled` is true
- **THEN** the hold panel background renders at alpha ≤ 0.35 and no piece is drawn

### Requirement: Hold display supports two slots for Extended Buffer keystone
When `config.hold_slots` is 2 (Extended Buffer keystone active), the `HoldDisplay` SHALL render two vertical slots. The first slot shows `held_pieces[0]` and the second shows `held_pieces[1]` if it exists, or an empty slot otherwise.

#### Scenario: Two hold slots shown with Extended Buffer
- **WHEN** `config.hold_slots` is 2
- **THEN** the hold panel shows two stacked slot areas, each large enough for one tetromino

#### Scenario: Second slot empty when only one piece held
- **WHEN** `config.hold_slots` is 2 and only one piece is held
- **THEN** the first slot shows the piece and the second slot is visually empty

### Requirement: Hold display updates on every board_updated signal
The `HoldDisplay` SHALL call `queue_redraw()` each time the `TetrisBoard` emits `board_updated`, ensuring the displayed piece always reflects the current hold state.

#### Scenario: Display refreshes after a hold swap
- **WHEN** the player swaps the hold piece
- **THEN** the hold display updates to show the new held piece within the same frame
