## 1. Viewport

- [x] 1.1 In `project.godot`, change `window/size/viewport_width` to `1440` and `window/size/viewport_height` to `900`

## 2. BossModifier Cleanup

- [x] 2.1 In `boss_modifier.gd`, remove the `@export var garbage_interval: float` field and the `# >0 = The Tide` comment
- [x] 2.2 Delete `game/resources/data/boss_modifiers/the_tide.tres`
- [x] 2.3 In `run_manager.gd`, delete the `_tick_tide()` method and its call in `_process()`

## 3. Enemy Resource

- [x] 3.1 Create `game/resources/enemy.gd` extending `Resource` with fields: `id: String`, `display_name: String`, `color: Color`, `sprite: Texture2D`, `tier: String`, `garbage_interval: float`, `ability: BossModifier`
- [x] 3.2 Create `game/resources/data/enemies/` directory
- [x] 3.3 Create Small tier enemy `.tres` files: `slimeling.tres` (green, interval=35), `cave_bat.tres` (dark purple, interval=35), `rock_crawler.tres` (brown, interval=35)
- [x] 3.4 Create Big tier enemy `.tres` files: `iron_shambler.tres` (steel blue, interval=27), `rust_golem.tres` (orange-brown, interval=27), `hex_wraith.tres` (teal, interval=27)
- [x] 3.5 Create Elite tier enemy `.tres` files: `void_knight.tres` (deep purple, interval=20), `the_warden.tres` (dark red, interval=20), `crimson_drake.tres` (crimson, interval=20)
- [x] 3.6 Create Boss tier enemy `.tres` files (one per remaining boss modifier, interval=15, referencing corresponding ability): `boss_enforcer.tres`, `boss_narrow.tres`, `boss_purge.tres`, `boss_surgeon.tres`, `boss_silencer.tres`, `boss_blinder.tres`, `boss_void.tres`

## 4. RoundConfig

- [x] 4.1 In `round_config.gd`, add `var enemy: Enemy = null` (not `@export`) and `var effective_garbage_interval: float = 0.0` (not `@export`)

## 5. RunState and RunSave

- [x] 5.1 In `run_state.gd`, add `var used_boss_enemy_ids: Array = []` and clear it in `reset()`
- [x] 5.2 In `run_save.gd` `save()`, write `cfg.set_value("inventory", "used_boss_enemy_ids", RunState.used_boss_enemy_ids)`
- [x] 5.3 In `run_save.gd` `load_into_state()`, read back `RunState.used_boss_enemy_ids = cfg.get_value("inventory", "used_boss_enemy_ids", [])`

## 6. RunManager — Enemy Assignment and Garbage Tick

- [x] 6.1 In `run_manager.gd`, add `_load_enemy_pool(tier: String) -> Array` that reads all `.tres` files from `res://resources/data/enemies/` and returns those matching the given tier string
- [x] 6.2 In `run_manager.gd`, add `_draw_enemy() -> Enemy` that calls `_load_enemy_pool()` for the current round tier; for boss tier, filters out `used_boss_enemy_ids`, shuffles with `RunState.seeded_shuffle()`, takes index 0, appends its id to `used_boss_enemy_ids`, and returns it; for common tiers, just shuffles and takes index 0
- [x] 6.3 In `_build_round_config()`, after creating `cfg`, call `_draw_enemy()`, assign to `cfg.enemy`, compute `cfg.effective_garbage_interval = cfg.enemy.garbage_interval * max(0.5, 1.0 - (RunState.stage - 1) * 0.1)`, and if the enemy has an ability call `cfg.enemy.ability.apply_to_config(cfg)`
- [x] 6.4 Remove the `_select_boss_modifier()` and `_load_all_boss_modifiers()` methods from `run_manager.gd` (replaced by `_draw_enemy()`)
- [x] 6.5 In `run_manager.gd`, add `var _enemy_timer: float = 0.0` instance variable and reset it to `0.0` in `start_round()`
- [x] 6.6 In `_process()`, replace the `_tick_tide(delta)` call with `_tick_enemy_garbage(delta)`; add `_tick_enemy_garbage(delta: float) -> void` that increments `_enemy_timer`, and when it exceeds `current_config.effective_garbage_interval`, resets it to `0.0` and calls `current_board.insert_garbage_row()`

## 7. EnemyDisplay Scene

- [x] 7.1 Create `game/scenes/game/enemy_display.gd` extending `Control` with `setup(enemy: Enemy, quota: int) -> void`, `update_hp(accumulated: float) -> void`, and `update_windup(timer: float, interval: float) -> void` methods
- [x] 7.2 In `enemy_display.gd`, build the node tree in code: a root `VBoxContainer` containing a `Panel` (portrait, sized ~120×120, background color = enemy.color), a `TextureRect` child of the Panel (visible when sprite non-null), a `Label` for the name, an `HpContainer` (`Control`) holding a `ProgressBar` (hp_bar, max=quota, value=quota) and a sibling `Label` (hp_label, anchored center, MOUSE_FILTER_IGNORE, text="quota/quota"), a `WindupContainer` holding a `ProgressBar` (windup_bar, max=1.0) and a `Label` (windup_label, text="⚡ Ns")
- [x] 7.3 Implement `update_hp(accumulated)`: set `hp_bar.value = max(0, quota - accumulated)`; set `hp_label.text = "%d / %d" % [int(accumulated), quota]`
- [x] 7.4 Implement `update_windup(timer, interval)`: set `windup_bar.value = timer / interval`; set `windup_label.text = "⚡ %ds" % max(0, int(interval - timer))`
- [x] 7.5 Create `game/scenes/game/enemy_display.tscn` with `enemy_display.gd` as the root script

## 8. RunManager — EnemyDisplay Wiring

- [x] 8.1 In `run_manager.gd`, add `const SCENE_ENEMY_DISPLAY := "res://scenes/game/enemy_display.tscn"` and `var _enemy_display: Control = null`
- [x] 8.2 In `start_round()`, after instantiating `_queue_display`, instantiate `_enemy_display`, add it to `board_container`, position it at `Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16 + 112 + 16, 0)`, and call `_enemy_display.setup(current_config.enemy, current_config.quota)`
- [x] 8.3 In `start_round()`, free any existing `_enemy_display` at the top alongside the existing `_hold_display` / `_queue_display` cleanup
- [x] 8.4 In `_tick_enemy_garbage()`, after inserting the garbage row, call `_enemy_display.update_windup(0.0, current_config.effective_garbage_interval)` to snap the bar to reset
- [x] 8.5 In `_process()`, after the existing board tick calls, call `_enemy_display.update_windup(_enemy_timer, current_config.effective_garbage_interval)` each frame while the board is active

## 9. HUD — Quota Bar Replacement

- [x] 9.1 In `hud.gd` and `hud.tscn`, replace the `quota_bar: ProgressBar` node with a plain `Label` (round_info_label); update `setup()` to set its text to the round name only
- [x] 9.2 In `hud.gd`, update `update_quota(accumulated, quota)` to call `_enemy_display.update_hp(accumulated)` — pass `_enemy_display` reference into HUD via a new `set_enemy_display(display: Control)` method called from RunManager after both are created

## 10. Testing

- [x] 10.1 In `game/tests/unit/test_enemy_encounters.gd`, add test: `test_effective_garbage_interval_stage1` — verify formula returns `base_interval × 1.0` at stage 1
- [x] 10.2 Add test: `test_effective_garbage_interval_stage5` — verify formula returns `base_interval × 0.6` at stage 5
- [x] 10.3 Add test: `test_effective_garbage_interval_floor` — verify formula never returns below `base_interval × 0.5` regardless of stage
- [x] 10.4 Add test: `test_boss_enemy_not_repeated` — simulate drawing boss enemies across 7 rounds, verify no id repeats until pool exhausted
- [x] 10.5 Add test: `test_common_enemy_from_correct_tier` — verify that for each round index 0–2 the drawn enemy's tier matches the expected tier string

## 11. Verification

- [ ] 11.1 Start a run — confirm every round shows an enemy name, colored rectangle, and draining HP bar
- [ ] 11.2 Confirm the wind-up bar fills and triggers a garbage row on schedule in Stage 1
- [ ] 11.3 Confirm garbage arrives noticeably faster in Stage 5 than Stage 1 for the same enemy type
- [ ] 11.4 Play through 2 boss rounds — confirm different boss enemies with different abilities appear
- [ ] 11.5 Confirm the quota number is overlaid on the HP bar and updates correctly
- [ ] 11.6 Confirm the queue display is unchanged (still runs down the right side of the board)
- [ ] 11.7 Confirm the viewport is 1440×900 and the layout has comfortable margins
