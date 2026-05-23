## 1. RunManager — Buffer State & Accumulation

- [x] 1.1 Add `pending_garbage: int` field to `RunManager`
- [x] 1.2 Modify `_tick_enemy_garbage()` to increment `pending_garbage` instead of calling `insert_garbage_row()` directly
- [x] 1.3 Connect `lock_processed` signal from the board in `_setup_round()`; disconnect in `_end_round()`

## 2. RunManager — Piece-Lock Flush

- [x] 2.1 Add `_on_lock_processed()` handler: compute `flush = mini(pending_garbage, 8)`, call `insert_garbage_row()` `flush` times, subtract `flush` from `pending_garbage`
- [x] 2.2 Call `_enemy_display.update_pending(pending_garbage)` after each change to `pending_garbage`

## 3. RunManager — Counter-Attack Drain

- [x] 3.1 In `_on_attack_generated()`, after Technique modifiers are applied, compute `drain = mini(modified_attack, pending_garbage)`, subtract from `pending_garbage`, and add `modified_attack - drain` to `quota_accumulated` instead of the full value

## 4. RunManager — Cleanup

- [x] 4.1 Reset `pending_garbage` to 0 in `_end_round()` so no state carries over between rounds
- [x] 4.2 Reset `pending_garbage` to 0 at the start of `_setup_round()` as a safety measure

## 5. Attack Bar — Board-Adjacent Visual

- [x] 5.1 Create an `AttackBar` scene (thin vertical container with 20 `ColorRect` segment children, each sized to 1/20 of the board height)
- [x] 5.2 Place `AttackBar` in the game scene directly adjacent to the board edge (left or right side, matching board height)
- [x] 5.3 Implement `update_pending(count: int)` on `AttackBar`: light the bottom `min(count, 20)` segments in warning color, unlit the rest, and hide the whole bar when `count == 0`
- [x] 5.4 Wire `RunManager` to call `_attack_bar.update_pending(pending_garbage)` wherever `pending_garbage` changes (after drain, after flush, after reset)

## 6. Testing

- [x] 6.1 Create `game/tests/unit/test_attack_buffer.gd` extending `GutTest`
- [x] 6.2 Add test: garbage timer fire increments `pending_garbage` by 1 and does not insert a board row
- [x] 6.3 Add test: 3 timer fires without counter-attack leaves `pending_garbage` at 3
- [x] 6.4 Add test: player attack of 3 with `pending_garbage` 2 → `pending_garbage` becomes 0, quota gains 1
- [x] 6.5 Add test: player attack of 2 with `pending_garbage` 4 → `pending_garbage` becomes 2, quota gains 0
- [x] 6.6 Add test: player attack of 3 with `pending_garbage` 0 → `pending_garbage` stays 0, quota gains 3
- [x] 6.7 Add test: piece lock with `pending_garbage` 3 → 3 rows flushed, `pending_garbage` becomes 0
- [x] 6.8 Add test: piece lock with `pending_garbage` 11 → 8 rows flushed, `pending_garbage` becomes 3 (cap enforced)
- [x] 6.9 Add test: piece lock with `pending_garbage` 0 → no rows inserted
- [x] 6.10 Add test: `pending_garbage` is 0 after round end regardless of pre-end value
- [x] 6.11 Run the full GUT test suite (`game/tests/run_tests.tscn`) and fix any failures in implementation code (do not modify test code to make tests pass)
