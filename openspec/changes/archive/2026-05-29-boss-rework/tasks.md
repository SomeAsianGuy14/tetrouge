## 1. BossModifier and RoundConfig resources

- [x] 1.1 Add `hide_all_previews: bool`, `random_pieces: bool`, `garbage_individual_lines: bool`, and `reflect_ratio: float` fields to `game/resources/boss_modifier.gd`
- [x] 1.2 Update `apply_to_config()` in `boss_modifier.gd` to set `config.preview_count = 0` when `hide_all_previews` is true, and to copy `random_pieces`, `garbage_individual_lines`, and `reflect_ratio` to the config
- [x] 1.3 Add `random_pieces: bool`, `garbage_individual_lines: bool`, and `reflect_ratio: float` fields to `game/resources/round_config.gd`

## 2. Boss modifier data files (rename and retune)

- [x] 2.1 Update `game/resources/data/boss_modifiers/the_blinder.tres`: set `id="the_fateless"`, `display_name="The Fateless"`, `description="The piece queue and next piece are completely hidden."`, remove `preview_override`, add `hide_all_previews = true`
- [x] 2.2 Update `game/resources/data/boss_modifiers/the_enforcer.tres`: set `id="the_blitz"`, `display_name="The Blitz"`, `description="Time limit cut to 60 seconds. Quota unchanged."`, set `time_limit_override = 60.0`
- [x] 2.3 Update `game/resources/data/boss_modifiers/the_narrow.tres`: set `id="the_thin"`, `display_name="The Thin"`, keep `board_width_override = 8`, update description to match
- [x] 2.4 Update `game/resources/data/boss_modifiers/the_purge.tres`: remove `"triple"` from `quota_whitelist`, update description to "Only Tetrises and T-spins count toward the quota."
- [x] 2.5 Delete `game/resources/data/boss_modifiers/the_surgeon.tres`
- [x] 2.6 Create `game/resources/data/boss_modifiers/the_ancient.tres` with `id="the_ancient"`, `display_name="The Ancient"`, `description="All pieces are drawn at random — any of the 7 types each turn."`, `random_pieces = true`
- [x] 2.7 Create `game/resources/data/boss_modifiers/the_filth.tres` with `id="the_filth"`, `display_name="The Filth"`, `description="All garbage arrives as individual lines, each with its own random hole."`, `garbage_individual_lines = true`
- [x] 2.8 Create `game/resources/data/boss_modifiers/the_reflection.tres` with `id="the_reflection"`, `display_name="The Reflection"`, `description="No direct attacks. Half of every attack that hurts it is sent back to you."`, `reflect_ratio = 0.5`

## 3. Enemy data files (rename and add)

- [x] 3.1 Update `game/resources/data/enemies/boss_blinder.tres`: set `id="boss_fateless"`, `display_name="The Fateless"`, update `ability` ext_resource path to `the_blinder.tres` (file renamed in step 2.1 — update reference)
- [x] 3.2 Update `game/resources/data/enemies/boss_enforcer.tres`: set `id="boss_blitz"`, `display_name="The Blitz"`, update ability reference path to point to updated enforcer file
- [x] 3.3 Update `game/resources/data/enemies/boss_narrow.tres`: set `id="boss_thin"`, `display_name="The Thin"`, update ability reference path to point to updated narrow file
- [x] 3.4 Delete `game/resources/data/enemies/boss_surgeon.tres`
- [x] 3.5 Create `game/resources/data/enemies/boss_ancient.tres` referencing `the_ancient.tres`, with `id="boss_ancient"`, `display_name="The Ancient"`, tier="Boss", reasonable garbage_interval
- [x] 3.6 Create `game/resources/data/enemies/boss_filth.tres` referencing `the_filth.tres`, with `id="boss_filth"`, `display_name="The Filth"`, tier="Boss", reasonable garbage_interval
- [x] 3.7 Create `game/resources/data/enemies/boss_reflection.tres` referencing `the_reflection.tres`, with `id="boss_reflection"`, `display_name="The Reflection"`, tier="Boss"; garbage_interval can be non-zero (timer still fires for windup display even though lines won't send — or set to 0 if cleaner)

## 4. TetrisBoard: random pieces bypass

- [x] 4.1 In `game/scenes/tetris/tetris_board.gd`, read `config.random_pieces` in `refill_queue()`: when true, call `config.rng.randi_range(1, 7)` directly to get the piece type instead of calling `bag.next()`

## 5. RunManager: replace pending_garbage with packet queue

- [x] 5.1 Replace `pending_garbage: int = 0` with `_garbage_packets: Array = []` in `run_manager.gd`; update the reset at round start (line ~108) to `_garbage_packets = []`
- [x] 5.2 Rewrite `_drain_attack(modified)` to subtract from `_garbage_packets[0].lines` first (in-place depletion, remove packet when it reaches 0, continue into next packet); return the remaining lines for quota
- [x] 5.3 Rewrite `_flush_pending_garbage()` to consume up to `8 - reduction` lines from `_garbage_packets` (oldest first), insert one garbage row per line via `insert_garbage_rows(1, col)` with a fresh random column per line; return number of rows flushed
- [x] 5.4 Update the garbage interval fire block (~line 340) to append a packet `{lines: n, is_filth: false}` to `_garbage_packets` when `garbage_individual_lines` is false; when true, append N separate `{lines: 1, is_filth: true}` packets each with a fresh random column stored alongside, and call `insert_garbage_rows` individually at flush time
- [x] 5.5 Add reflection logic in `_on_attack_generated`: after computing `to_quota`, if `current_config.reflect_ratio > 0.0`, compute `reflect_lines = floori(to_quota * current_config.reflect_ratio)` and append `{lines: reflect_lines, is_filth: false}` to `_garbage_packets` when `reflect_lines > 0`
- [x] 5.6 Replace `_notify_attack_bar()` to call `_attack_bar.update_packets(_garbage_packets)` instead of `update_pending(pending_garbage)`
- [x] 5.7 Update the round-end reset block (~line 542) to clear `_garbage_packets = []` and call `_notify_attack_bar()`

## 6. AttackBar: packet-based _draw() renderer

- [x] 6.1 Rewrite `game/scenes/game/attack_bar.gd` as a `Control` (not VBoxContainer): remove `_segments` array and `_ready` segment setup; add `_packets: Array = []` and `const FILTH_COLOR := Color(0.95, 0.6, 0.1)` alongside existing `WARNING_COLOR`
- [x] 6.2 Replace `update_pending(count: int)` with `update_packets(packets: Array) -> void` that sets `_packets = packets` and calls `queue_redraw()`
- [x] 6.3 Implement `_draw()`: compute `bar_height = VISIBLE_ROWS * CELL_SIZE` and `pixels_per_line = bar_height / float(VISIBLE_ROWS)`; iterate packets from index 0 upward, drawing each as a filled rect from the bottom, colored by `is_filth`, with a 1px separator line at the top edge; cap total drawn height at `bar_height`

## 7. Testing

- [x] 7.1 Add `game/tests/unit/test_garbage_packets.gd`: test drain fully removes packet when attack exceeds its lines
- [x] 7.2 Test drain partially reduces a packet in-place when attack is less than its lines
- [x] 7.3 Test drain chains across multiple packets correctly
- [x] 7.4 Test flush consumes up to 8 lines from oldest packets and leaves remainder
- [x] 7.5 Test flush does nothing when queue is empty
- [x] 7.6 Test reflection: `floori(to_quota * 0.5)` packet appended; verify 0-line packets are not appended
- [x] 7.7 Test round-end reset clears the packet queue to empty

## 8. Run tests

- [x] 8.1 Run the full GUT test suite (`game/tests/run_tests.tscn`) and confirm all tests pass
