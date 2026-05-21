## 1. Fix hud.setup() call and Economy signal

- [x] 1.1 In `game/scenes/game/hud.gd`, move `Economy.connect("coins_changed", _on_coins_changed)` from `setup()` into `_ready()` so it connects exactly once per run
- [x] 1.2 In `setup()`, add `coin_label.text = "Coins: %d" % Economy.coins` to immediately reflect the current balance when each round begins
- [x] 1.3 In `game/scenes/game/run_manager.gd`, add `hud.setup(current_config)` in `start_round()` immediately after `current_config` is built (before the board is instantiated)

## 2. InfoPanel — Scene Layout

- [x] 2.1 In `game/scenes/game/run_manager.tscn`, add a `VBoxContainer` named `InfoPanel` as a direct child of `HUD`; position it at anchor left=0, top below the TopBar (offset_top=56, offset_left=16, offset_right=160)
- [x] 2.2 Add a `Label` named `ScoreHeaderLabel` inside `InfoPanel` with text "SCORE" and a small font size override (12px)
- [x] 2.3 Add a `Label` named `ScoreLabel` inside `InfoPanel` with default text "0 / 0"; set a large font size override (28px)
- [x] 2.4 Add a `Label` named `TimerHeaderLabel` inside `InfoPanel` with text "TIME" and a small font size override (12px)
- [x] 2.5 Add a `Label` named `TimerBigLabel` inside `InfoPanel` with default text "1:00"; set a large font size override (36px)
- [x] 2.6 Add a `Label` named `RoundBigLabel` inside `InfoPanel` with default text "Stage 1 — Small Round"; set `autowrap_mode = 3` and a small font size override (11px)
- [x] 2.7 Add a `Label` named `ModifierBigLabel` inside `InfoPanel` with default text ""; set `autowrap_mode = 3` and a small font size override (11px); `modulate = Color(1, 0.6, 0.2)`

## 3. InfoPanel — Script Wiring

- [x] 3.1 In `game/scenes/game/hud.gd`, add `@onready` references for the new nodes: `score_label`, `timer_big_label`, `round_big_label`, `modifier_big_label`
- [x] 3.2 In `setup()`, set `score_label.text = "0 / %d" % config.quota`; set `round_big_label.text`; set `modifier_big_label.text` and visibility; set `timer_big_label.text` to the time limit formatted as `M:SS`; reset `timer_big_label.modulate = Color.WHITE`
- [x] 3.3 In `update_quota()`, also set `score_label.text = "%d / %d" % [int(accumulated), quota]`
- [x] 3.4 In `update_timer()`, also update `timer_big_label.text` and apply the same red/white colour logic as the existing `timer_label`
