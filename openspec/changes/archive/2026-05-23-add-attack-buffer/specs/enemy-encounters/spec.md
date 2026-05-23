## MODIFIED Requirements

### Requirement: Garbage attacks occur every round
Every round SHALL have periodic garbage row insertions driven by the assigned enemy's garbage interval scaled by stage. The effective interval SHALL be computed as `base_interval × max(0.5, 1.0 - (stage - 1) × 0.1)`, making attacks progressively faster at higher stages with a floor at 50% of the base rate.

On each timer expiry, one row SHALL be **added to the attack buffer** (`pending_garbage += 1`) rather than inserted directly into the board. A separate flush timer at the same effective interval delivers one buffered row to the board per tick (see attack-buffer spec).

#### Scenario: Garbage fires at the effective interval
- **WHEN** the elapsed time since the last garbage event reaches the effective interval
- **THEN** `pending_garbage` is incremented by 1 and the timer resets (no immediate board insertion)

#### Scenario: Garbage scales faster at higher stages
- **WHEN** the same enemy appears in Stage 1 and Stage 5
- **THEN** the Stage 5 effective interval is 60% of the Stage 1 interval

#### Scenario: Buffered garbage delivers after flush interval
- **WHEN** a garbage row has been in the buffer for one full effective interval
- **THEN** it is inserted into the board by the flush timer (assuming no player counter-attack cancelled it)
