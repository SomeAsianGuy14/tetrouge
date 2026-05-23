## Why

Incoming enemy garbage currently fires directly onto the board the instant the timer expires, giving players zero warning or counterplay. Adding an attack buffer lets players see pending garbage and reduce or cancel it through offensive play, making the game feel more strategic and reactive rather than purely punishing.

## What Changes

- Enemy garbage rows are queued into an **attack buffer** instead of inserted immediately
- The buffer holds N pending rows (one per garbage interval expiry)
- Outgoing player attacks (line clears) cancel buffered rows 1:1 before they land
- After a short countdown the buffered rows are flushed to the board
- A HUD element shows the player how many rows are queued and when they will land

## Capabilities

### New Capabilities
- `attack-buffer`: Pending garbage queue that accumulates enemy attacks, allows player counter-attacks to reduce them 1:1, and flushes remaining rows to the board after a delay

### Modified Capabilities
- `enemy-encounters`: Garbage delivery now routes through the attack buffer instead of calling `insert_garbage_row()` directly; the effective garbage interval and scaling rules are unchanged

## Impact

- `RunManager` — `_tick_enemy_garbage()` queues into buffer instead of calling `insert_garbage_row()` directly; outgoing attacks drain the buffer before adding to quota
- `TetrisBoard` — no change to garbage insertion logic, only when it is called
- New buffer flush timer in `RunManager` or a dedicated `AttackBuffer` node
- HUD — new indicator node shows pending rows and flush countdown
- `test_attack_buffer.gd` — new GUT test file covering queue, counter-attack drain, flush
