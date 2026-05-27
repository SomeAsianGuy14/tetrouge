## 1. RoundConfig — Replace Fixed Interval with Range Fields

- [x] 1.1 In `game/resources/round_config.gd`, remove `var effective_garbage_interval: float = 0.0`
- [x] 1.2 In `game/resources/round_config.gd`, add four new vars: `var garbage_interval_min: float = 0.0`, `var garbage_interval_max: float = 0.0`, `var garbage_lines_min: int = 1`, `var garbage_lines_max: int = 1`

## 2. RunManager — Constants, Round Setup, and Tick Loop

- [x] 2.1 In `game/scenes/game/run_manager.gd`, add six tier constants at the top of the file:
  ```
  const NORMAL_INTERVAL_MIN := 15.0
  const NORMAL_INTERVAL_MAX := 25.0
  const NORMAL_LINES_MIN := 1
  const NORMAL_LINES_MAX := 3
  const BOSS_INTERVAL_MIN := 10.0
  const BOSS_INTERVAL_MAX := 16.0
  const BOSS_LINES_MIN := 2
  const BOSS_LINES_MAX := 4
  ```
- [x] 2.2 In `run_manager.gd`, add a runtime variable `var _next_garbage_interval: float = 0.0` alongside `_enemy_timer`
- [x] 2.3 In `run_manager._start_round()` (or wherever `effective_garbage_interval` is currently set), replace the single-value computation with range computation: select the correct constant group based on `enemy.tier == "Boss"`, apply the stage scalar to both min and max, apply the lines stage bonus (`floor((stage-1)/2)`) to both lines min and max, and store all four on `cfg`
- [x] 2.4 After computing the config, initialise `_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)` so the first attack window is set
- [x] 2.5 In `_tick_enemy_garbage()`, replace the guard `current_config.effective_garbage_interval <= 0.0` with `current_config.garbage_interval_max <= 0.0`
- [x] 2.6 In `_tick_enemy_garbage()`, replace the comparison `_enemy_timer >= current_config.effective_garbage_interval` with `_enemy_timer >= _next_garbage_interval`
- [x] 2.7 In `_tick_enemy_garbage()`, replace `pending_garbage += 1` with `pending_garbage += randi_range(current_config.garbage_lines_min, current_config.garbage_lines_max)`
- [x] 2.8 In `_tick_enemy_garbage()`, after resetting `_enemy_timer = 0.0`, re-roll `_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)`

## 3. RunManager — Aligned Garbage Flush

- [x] 3.1 In the piece-lock flush section of `run_manager.gd`, replace the loop `for _i in flush: current_board.insert_garbage_row()` with a single column pick followed by `current_board.insert_garbage_rows(flush, col)` where `col = randi() % current_config.board_width`

## 4. TetrisBoard — Aligned Multi-Row Insert

- [x] 4.1 In `game/scenes/tetris/tetris_board.gd`, add a new method `insert_garbage_rows(count: int, col: int) -> void` that inserts `count` garbage rows all with the hole at column `col` (reuse the existing row-building logic from `insert_garbage_row()`, but use the provided `col` instead of a fresh random roll)

## 5. EnemyDisplay — Windup Bar Denominator

- [x] 5.1 In `run_manager.gd`, update the two `_enemy_display.update_windup(...)` calls to pass `_next_garbage_interval` instead of `current_config.effective_garbage_interval`

## 6. Testing

- [x] 6.1 In `game/tests/unit/test_enemy_attacks.gd` (create file), add a test that verifies the stage scalar lowers both `garbage_interval_min` and `garbage_interval_max` proportionally: at stage 5 both should be 60% of their stage-1 values
- [x] 6.2 Add a test that verifies the lines stage bonus: at stage 3 both `garbage_lines_min` and `garbage_lines_max` are 1 higher than at stage 1; at stage 5 they are 2 higher
- [x] 6.3 Add a test that verifies Boss tier produces narrower and lower interval ranges than Normal tier at the same stage
