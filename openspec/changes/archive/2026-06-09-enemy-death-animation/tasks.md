## 1. EnemyDisplay — signal and death animation

- [x] 1.1 Add `signal death_animation_finished` to `EnemyDisplay`
- [x] 1.2 Add `var _death_tween: Tween = null` and `var _death_pending_success: bool = false` fields
- [x] 1.3 Implement `play_death_animation()`: kill all active tweens, then branch on `_enemy.ability != null` for boss vs. regular variant
- [x] 1.4 Regular variant tween: flash portrait anchor to WHITE (0.10s), then parallel fade alpha to 0 (0.50s ease-in) and scale to 1.1× (0.50s ease-out); emit `death_animation_finished` on finished
- [x] 1.5 Boss variant tween: flash to WHITE (0.10s), then parallel fade alpha to 0 (0.80s ease-in), scale to 1.18× (0.80s ease-out), and shake position:x (+8→−8→+4→−4→0, ~0.07s per step); emit `death_animation_finished` on finished
- [x] 1.6 Update `stop_animations()` to kill `_death_tween` and, if `_death_pending_success` is true, call the stored callback (or emit the signal manually) so the overlay path is never left stuck

## 2. RunManager — gate post-round overlays

- [x] 2.1 In `_end_round(true)`, after all state changes, store which transition to make (`_pending_round_end: Callable`) instead of calling it directly
- [x] 2.2 If `_enemy_display` is non-null, connect `death_animation_finished` one-shot to a `_on_death_animation_finished` method, set `_death_pending_success = true` on the display, then call `_enemy_display.play_death_animation()`
- [x] 2.3 If `_enemy_display` is null, call the stored transition callable immediately
- [x] 2.4 Implement `_on_death_animation_finished()` in RunManager: clear `_death_pending_success`, call the stored transition callable
- [x] 2.5 Ensure both `_show_round_success()` and `_show_victory()` are routed through this gate (the `is_run_complete()` branch must also defer)

## 3. Testing

- [x] 3.1 Add test: `play_death_animation()` emits `death_animation_finished` — confirm signal fires (use signal watcher / `watch_signals`)
- [x] 3.2 Add test: boss variant is selected when `_enemy.ability != null`, regular variant when null
- [x] 3.3 Add test: calling `stop_animations()` while `_death_pending_success` is true does not leave the display in a stuck state (signal fires or callback is called)
- [x] 3.4 Add test: calling `play_death_animation()` while a pulse tween is active kills the pulse tween first
