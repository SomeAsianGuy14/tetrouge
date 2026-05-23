## ADDED Requirements

### Requirement: Pending garbage counter accumulates enemy attacks
`RunManager` SHALL maintain a `pending_garbage: int` counter. Each time the enemy garbage timer fires, the counter SHALL be incremented by 1. No garbage row SHALL be inserted into the board at that moment.

#### Scenario: Garbage timer fire increments buffer
- **WHEN** the enemy garbage timer expires
- **THEN** `pending_garbage` is incremented by 1 and `insert_garbage_row()` is NOT called

#### Scenario: Multiple timer fires accumulate
- **WHEN** the enemy garbage timer fires 3 times without any player counter-attack or flush
- **THEN** `pending_garbage` equals 3

### Requirement: Player attacks cancel buffered garbage 1:1
When processing an outgoing player attack, `RunManager` SHALL first drain `pending_garbage` by up to the attack amount. The remainder (attack minus drained rows) SHALL be applied to the quota accumulator. Draining SHALL happen after Technique modifiers are applied.

#### Scenario: Attack fully cancels buffered garbage
- **WHEN** `pending_garbage` is 2 and the player generates 3 attack lines
- **THEN** `pending_garbage` becomes 0 and 1 line is added to `quota_accumulated`

#### Scenario: Partial cancel when attack is less than buffer
- **WHEN** `pending_garbage` is 4 and the player generates 2 attack lines
- **THEN** `pending_garbage` becomes 2 and 0 lines are added to `quota_accumulated`

#### Scenario: No buffered garbage — full attack goes to quota
- **WHEN** `pending_garbage` is 0 and the player generates 3 attack lines
- **THEN** `pending_garbage` remains 0 and 3 lines are added to `quota_accumulated`

### Requirement: Buffer flushes on piece lock, capped at 8 rows
When the player locks a piece, `RunManager` SHALL insert `min(pending_garbage, 8)` garbage rows into the board and decrement `pending_garbage` by that amount. The flush SHALL occur on the `lock_processed` signal (after line-clear processing and attack generation for that lock). If `pending_garbage` is 0 the flush does nothing.

#### Scenario: Full flush when buffer is within cap
- **WHEN** the player locks a piece and `pending_garbage` is 3
- **THEN** 3 garbage rows are inserted and `pending_garbage` becomes 0

#### Scenario: Cap limits flush to 8 rows
- **WHEN** the player locks a piece and `pending_garbage` is 11
- **THEN** 8 garbage rows are inserted and `pending_garbage` becomes 3

#### Scenario: No flush when buffer is empty
- **WHEN** the player locks a piece and `pending_garbage` is 0
- **THEN** no garbage row is inserted and the board is unchanged

### Requirement: Buffer resets on round end
When a round ends (win or loss), `pending_garbage` SHALL be reset to 0 so no garbage carries over to the next round.

#### Scenario: Buffer cleared on round completion
- **WHEN** a round ends with `pending_garbage` greater than 0
- **THEN** `pending_garbage` is set to 0 before the next round begins

### Requirement: Attack bar displays pending garbage alongside the board
A vertical bar node SHALL be placed adjacent to the board in the game scene, spanning the full board height and divided into 20 segments (one per board row). The bar SHALL always be visible. Segments SHALL fill from the bottom up: the bottom `pending_garbage` segments are lit (warning color), the rest are shown in an empty/dim color. `RunManager` SHALL call `update_pending(count: int)` on the bar whenever `pending_garbage` changes.

#### Scenario: Bar segments fill from bottom proportional to pending count
- **WHEN** `pending_garbage` is 5
- **THEN** the bottom 5 segments of the bar are lit and the top 15 are shown in the empty color

#### Scenario: Bar shows all empty segments when buffer is zero
- **WHEN** `pending_garbage` is 0
- **THEN** all 20 segments are shown in the empty color and the bar remains visible

#### Scenario: Bar is fully lit at or above 20 pending rows
- **WHEN** `pending_garbage` is 20 or more
- **THEN** all 20 segments are lit
