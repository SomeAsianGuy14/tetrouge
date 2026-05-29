## MODIFIED Requirements

### Requirement: Pending garbage counter accumulates enemy attacks
`RunManager` SHALL maintain a `_garbage_packets: Array` queue of dictionaries with shape `{lines: int, is_filth: bool}`. Each time the enemy garbage interval fires, one or more packets SHALL be appended to the queue depending on the active boss modifier. No garbage row SHALL be inserted into the board at that moment. The integer field `pending_garbage: int` is removed.

#### Scenario: Garbage interval fire appends a packet
- **WHEN** the enemy garbage timer expires and N lines would be sent
- **THEN** one packet `{lines: N, is_filth: false}` is appended to `_garbage_packets` and `insert_garbage_rows()` is NOT called immediately

#### Scenario: Filth interval fire appends individual 1-line packets
- **WHEN** The Filth modifier is active and the garbage interval fires N lines
- **THEN** N separate `{lines: 1, is_filth: true}` packets are each appended to `_garbage_packets`

#### Scenario: Multiple timer fires accumulate multiple packets
- **WHEN** the enemy garbage timer fires 3 times without any player counter-attack or flush
- **THEN** `_garbage_packets` contains 3 entries, one per fire

### Requirement: Player attacks cancel buffered garbage 1:1
When processing an outgoing player attack, `RunManager` SHALL drain `_garbage_packets` starting from index 0 (the oldest packet). Lines are subtracted from `packets[0].lines`; when a packet reaches 0 it is removed and draining continues into the next packet. The total lines drained count against the attack amount; the remainder goes to `quota_accumulated`. Draining SHALL happen after Technique modifiers are applied.

#### Scenario: Attack fully cancels oldest packet and surplus goes to quota
- **WHEN** `_garbage_packets` is `[{lines: 2, is_filth: false}]` and the player generates 3 attack lines
- **THEN** the packet is removed, `_garbage_packets` becomes empty, and 1 line is added to `quota_accumulated`

#### Scenario: Partial cancel depletes oldest packet in-place
- **WHEN** `_garbage_packets` is `[{lines: 4, is_filth: false}]` and the player generates 2 attack lines
- **THEN** the packet becomes `{lines: 2}` and 0 lines are added to `quota_accumulated`

#### Scenario: Attack drains across multiple packets
- **WHEN** `_garbage_packets` is `[{lines: 1, is_filth: false}, {lines: 3, is_filth: false}]` and the player generates 3 attack lines
- **THEN** the first packet is consumed, the second packet becomes `{lines: 1}`, and 1 line is added to `quota_accumulated`

#### Scenario: No buffered garbage — full attack goes to quota
- **WHEN** `_garbage_packets` is empty and the player generates 3 attack lines
- **THEN** `_garbage_packets` remains empty and 3 lines are added to `quota_accumulated`

### Requirement: Buffer flushes on piece lock, capped at 8 rows
When the player locks a piece, `RunManager` SHALL consume up to 8 lines from `_garbage_packets` (oldest packets first), calling `insert_garbage_rows(1, col)` once per line consumed. The flush SHALL occur on the `lock_processed` signal after line-clear processing and attack generation. If `_garbage_packets` is empty the flush does nothing.

#### Scenario: Full flush when total buffered lines are within cap
- **WHEN** the player locks a piece and `_garbage_packets` totals 3 lines
- **THEN** 3 garbage rows are inserted and all packets are consumed

#### Scenario: Cap limits flush to 8 rows across packets
- **WHEN** the player locks a piece and `_garbage_packets` totals 11 lines
- **THEN** 8 garbage rows are inserted and the remaining 3 lines stay in `_garbage_packets`

#### Scenario: No flush when queue is empty
- **WHEN** the player locks a piece and `_garbage_packets` is empty
- **THEN** no garbage row is inserted and the board is unchanged

### Requirement: Buffer resets on round end
When a round ends (win or loss), `_garbage_packets` SHALL be cleared to an empty array so no garbage carries over to the next round.

#### Scenario: Queue cleared on round completion
- **WHEN** a round ends with `_garbage_packets` containing entries
- **THEN** `_garbage_packets` is set to `[]` before the next round begins

### Requirement: Attack bar renders packet queue as colored segments
A vertical Control node SHALL be placed adjacent to the board, spanning `VISIBLE_ROWS * CELL_SIZE` pixels in height. The bar SHALL render via `_draw()`, drawing each packet in `_garbage_packets` as a filled rectangle proportional to its line count, stacked from the bottom (index 0 at the bottom). Regular packets SHALL be drawn in a warning red; filth packets SHALL be drawn in yellow-orange. A 1px separator line SHALL be drawn at the top edge of each packet. `RunManager` SHALL call `update_packets(packets: Array)` whenever `_garbage_packets` changes; the bar then calls `queue_redraw()`. Total filled height SHALL be capped at bar height.

#### Scenario: Bar renders regular and filth packets in distinct colors
- **WHEN** `_garbage_packets` is `[{lines: 3, is_filth: false}, {lines: 2, is_filth: true}]`
- **THEN** the bottom 3 rows are drawn in red and the next 2 rows above are drawn in yellow-orange, with a 1px separator between them

#### Scenario: Bar shows no fill when queue is empty
- **WHEN** `_garbage_packets` is empty
- **THEN** the bar area is fully unlit and `_draw()` draws no filled rectangles

#### Scenario: Bar height is capped when queue exceeds visible rows
- **WHEN** `_garbage_packets` totals more than VISIBLE_ROWS lines
- **THEN** the rendered fill does not exceed `VISIBLE_ROWS * CELL_SIZE` pixels in height
