## 1. RoundConfig: show_timer flag

- [x] 1.1 Add `show_timer: bool = false` to `game/resources/round_config.gd`
- [x] 1.2 In `RunManager._build_round_config()`, set `cfg.show_timer = true` if `RunState.has_keystone("golden_watch")` or `cfg.boss_modifier.id == "the_blitz"`

## 2. HUD: hide timer by default

- [x] 2.1 In `HUD.setup(config)`, set `timer_label.visible = config.show_timer` and `timer_big_label.visible = config.show_timer`
- [x] 2.2 In `HUD.update_timer()`, early-return if `timer_label` is not visible

## 3. RunManager: timer no longer kills on timeout (except Blitz)

- [x] 3.1 In `_tick_timer()`, replace the unconditional `_end_round(false)` with: clamp `round_timer` to 0; only call `_end_round(false)` if `current_config.boss_modifier` is The Blitz (`current_config.boss_modifier != null and current_config.boss_modifier.id == "the_blitz"`)
- [x] 3.2 Remove the `_try_blessed_stone()` call from `_tick_timer()` — Blessed Stone no longer triggers on timeout

## 4. Base time limit and Blitz override

- [x] 4.1 In `RunState.calculate_time_limit()`, return `180.0` (was 120.0)
- [x] 4.2 In `game/resources/data/boss_modifiers/the_blitz.tres`, set `time_limit_override = 120.0` (was 60.0) and update description to make the kill condition explicit (e.g. "A 2-minute countdown begins. Defeat the enemy before time runs out or the run ends.")

## 5. Economy: remove speed bonus

- [x] 5.1 Remove `calculate_speed_bonus()` from `game/autoloads/economy.gd`
- [x] 5.2 Remove `speed_bonus_multiplier` field and its reset from `Economy`
- [x] 5.3 Change `Economy.pay_round(base, speed_bonus, technique_income)` to `Economy.pay_round(base)` — pays base payout; technique coins already accumulated in `Economy.coins` mid-round remain as-is
- [x] 5.4 In `RunManager._end_round(true)`, remove the `speed_bonus` calculation and pass only `BASE_PAYOUT` to `Economy.pay_round()`
- [x] 5.5 Remove `technique_income_this_round` tracking from `RunManager` (variable declaration, reset, and accumulation)

## 6. Round success screen: simplified payout

- [x] 6.1 In `game/scenes/screens/round_success.gd`, update `setup()` to accept only `base_payout: int`; remove `speed_bonus` and `technique_income` parameters
- [x] 6.2 Hide or remove `speed_label` and `technique_label` nodes from `round_success.tscn`; update `total_label` to show `base_payout` only
- [x] 6.3 Update the `_show_round_success()` call in `RunManager` to pass only `BASE_PAYOUT`

## 7. Voucher: remove Bonus Round speed multiplier

- [x] 7.1 In `RunState._apply_voucher_effects()`, remove the `"bonus_round"` case that sets `Economy.speed_bonus_multiplier` (or leave as no-op if the voucher should still exist without effect)

## 8. Keystone and consumable data updates

- [x] 8.1 Update `game/resources/data/keystones/golden_watch.tres` — set description to `"Gain a 3-minute timer. At round end, earn 1 coin for every 5 seconds remaining on the timer."`
- [x] 8.2 Update `game/resources/data/keystones/blessed_stone.tres` — set description to `"The first time your board tops out, it is cleared and you gain 2 minutes."`
- [x] 8.3 Delete `game/resources/data/consumables/time_shard.tres`
- [x] 8.4 Remove the `time_shard` preload entry from `ResourceRegistry.all_consumables` in `game/autoloads/resource_registry.gd`

## 9. Testing

- [x] 9.1 Add test: `_tick_timer()` with non-Blitz config clamps timer to 0 and does not call `_end_round(false)`
- [x] 9.2 Add test: `_tick_timer()` with Blitz config calls `_end_round(false)` when timer reaches 0
- [x] 9.3 Add test: `show_timer` is `false` when no Golden Watch and boss is not Blitz
- [x] 9.4 Add test: `show_timer` is `true` when Golden Watch is held
- [x] 9.5 Add test: `show_timer` is `true` when boss modifier id is `"the_blitz"`
- [x] 9.6 Add test: `Economy.pay_round(base)` adds only base amount to coins

## 10. Run tests

- [x] 10.1 Run the full GUT test suite via `game/tests/run_tests.tscn` and confirm all tests pass
