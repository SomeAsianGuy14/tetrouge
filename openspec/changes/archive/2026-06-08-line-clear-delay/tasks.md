## 1. Data Model

- [x] 1.1 Add `line_clear_delay: float = 0.5` to `game/resources/round_config.gd`
- [x] 1.2 Add `skip_line_clear_delay: bool = false` to `game/resources/keystone.gd`
- [x] 1.3 In `Keystone.apply_to_config()`, add: if `skip_line_clear_delay`, set `config.line_clear_delay = 0.0`
- [x] 1.4 Set `skip_line_clear_delay = true` in `game/resources/data/keystones/full_potential.tres`

## 2. TetrisBoard — State Fields

- [x] 2.1 Add `_in_line_clear_delay: bool = false` to TetrisBoard
- [x] 2.2 Add `_line_clear_timer: float = 0.0` to TetrisBoard
- [x] 2.3 Add pending-state fields: `_pending_clear_rows: Array[int]`, `_pending_piece_type: String`, `_pending_pivot: Vector2i`, `_pending_rotation: int`, `_pending_was_rotation: bool`

## 3. TetrisBoard — Logic Refactor

- [x] 3.1 Extract `_find_full_rows() -> Array[int]` from `_process_clears`: scans grid and returns row indices that are full, no grid mutation
- [x] 3.2 Create `_execute_pending_clears()`: removes `_pending_clear_rows` from grid (existing removal logic), then calls the t-spin/PC detection, clear type classification, signal emission, and attack events using the saved pending state
- [x] 3.3 In `_lock_piece()`, after stamping cells and emitting `piece_locked`, call `_find_full_rows()`:
  - If rows found AND `config.line_clear_delay > 0.0`: save pending state, set `_in_line_clear_delay = true`, `_line_clear_timer = 0.0`, return early (do not spawn yet)
  - Otherwise: call the existing combined clear path (for zero-row or zero-delay cases), then spawn
- [x] 3.4 In `tick()`, add early-return branch for `_in_line_clear_delay`: increment `_line_clear_timer`, call `queue_redraw()`, check if timer >= `config.line_clear_delay` — if so, clear flag, call `_execute_pending_clears()`, then spawn next piece

## 4. TetrisBoard — Rendering

- [x] 4.1 In `_draw()`, after drawing placed cells, check `_in_line_clear_delay`; if true, iterate `_pending_clear_rows` and draw each row's cells with `lerp(original_color, Color.WHITE, abs(sin(_line_clear_timer * PI / config.line_clear_delay * 3.0)))`

## 5. Testing

- [x] 5.1 Add test: `piece_locked` fires immediately when piece locks, before `lines_cleared`
- [x] 5.2 Add test: `lines_cleared` and `lock_processed` do NOT fire before the delay expires when `line_clear_delay > 0.0`
- [x] 5.3 Add test: with `line_clear_delay = 0.0`, rows clear synchronously in the same call (no delay state entered)
- [x] 5.4 Add test: `Keystone.apply_to_config` sets `line_clear_delay = 0.0` when `skip_line_clear_delay = true`
- [x] 5.5 Add test: `_find_full_rows` returns correct row indices for a grid with mixed full and partial rows
- [x] 5.6 Add test: `_find_full_rows` returns empty array when no rows are full

## 6. Run Tests

- [x] 6.1 Run the full GUT test suite (`game/tests/run_tests.tscn`) and confirm all tests pass
