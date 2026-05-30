## 1. Clean Up Legacy Techniques

- [x] 1.1 Delete all 10 `.tres` files in `game/resources/data/techniques/`
- [x] 1.2 Rewrite `game/resources/technique.gd`: remove legacy fields, add `tags`, `effect_type`, `params`

## 2. Core Architecture — New Data Objects

- [x] 2.1 Create `game/resources/attack_context.gd` (extends Resource) with fields: `lines_cleared`, `combo`, `b2b`, `tspin`, `perfect_clear`, `garbage_sent`, `board_height`, `held_this_piece`, `used_soft_drop`, `piece_placement_count`
- [x] 2.2 Create `game/resources/technique_round_state.gd` (extends RefCounted) with fields: `clears_this_round`, `attack_events_this_round`, `total_garbage_sent`, `tspin_count`, `b2b_count`, `perfect_clear_count`, `pieces_placed`, `tetris_count`, `last_clear_was_tetris`

## 3. TechniqueEvaluator

- [x] 3.1 Create `game/scenes/game/technique_evaluator.gd` as a static class with `compute_attack_bonus(techniques, ctx, round_state) -> int`
- [x] 3.2 Add `compute_economy_bonus(techniques, ctx, round_state) -> int` to TechniqueEvaluator
- [x] 3.3 Add combined `evaluate(techniques, ctx, round_state) -> Dictionary` returning `{ "attack_delta", "coins_delta", "flags" }`
- [x] 3.4 Implement effect type handlers for all 52 techniques: `flat_all_clears`, `flat_on_multiline`, `flat_on_tetris`, `flat_on_tspin`, `b2b_tetris_flat`, `every_nth_clear`, `every_nth_combo`, `board_height_above`, `board_height_below`, `first_clear_round`, `enemy_hp_below`, `economy_per_event`, `flash_step_arr`, `discipline_hold`, `gambler_rng`, `periodic_damage`
- [x] 3.5 Add push_warning for unknown effect_type values

## 4. Board Telemetry

- [x] 4.1 Add `summit_height: int` property to `TetrisBoard`; update on line-clear and piece placement
- [x] 4.2 Call telemetry update from the appropriate board update hook

## 5. RunState — Technique Capacity

- [x] 5.1 Add `technique_capacity: int = 4` to `RunState`
- [x] 5.2 Reset `technique_capacity = 4` in `RunState.reset()`
- [x] 5.3 Update `technique_capacity` in `RunState.advance_round()` using formula `4 + (stage - 1)`

## 6. RunManager — Evaluator Integration

- [x] 6.1 Create a `TechniqueRoundState` instance at `_start_round()` and store it on RunManager
- [x] 6.2 Construct `AttackContext` after each attack event and populate it from board telemetry and round state
- [x] 6.3 Call `TechniqueEvaluator.evaluate()` and apply `attack_delta` and `coins_delta` to the round
- [x] 6.4 Update `TechniqueRoundState` counters after each event (clears, attack events, T-spins, B2B, Tetrises, pieces placed, etc.)
- [x] 6.5 Handle lifecycle flags: `glass_cannon` (+4 atk / +2 incoming), `burning_board` (+3 atk / periodic damage timer), `flash_step_arr` (set ARR=0 for next piece), `greedy_hands` (+2 coins/round, enemy +1 atk/wave)
- [x] 6.6 Add Whirl keystone handler: if T-spin clear and Whirl owned, increment combo counter by 2 instead of 1

## 7. Shop — Technique Slot Style and Capacity Enforcement

- [x] 7.1 Restyle technique slots to use the same card layout as item (consumable/voucher) slots: name label, description label, cost label, Buy button
- [x] 7.2 In `shop.gd`, check `RunState.techniques.size() < RunState.technique_capacity` before enabling technique Buy buttons
- [x] 7.3 Display a "Technique slots full" message when at capacity
- [x] 7.4 Re-evaluate technique Buy button states after a technique is sold from the collection panel

## 8. Whirl Keystone

- [x] 8.1 Create `game/resources/data/keystones/whirl.tres` with `id="whirl"`, `display_name="Whirl"`, `effect_type="whirl"`
- [x] 8.2 Add Whirl to the keystone pool (ensure it is drawable from the shop keystone slot)

## 9. Technique Data — 52 .tres Files

- [x] 9.1 Create files for 8 general techniques: `brass_knuckles`, `clean_strike`, `sharpen`, `follow_up`, `attack_battery`, `opening_blow`, `finisher`, `escalation`
- [x] 9.2 Create files for 6 tetris techniques: `back_to_back_pressure`, `side_strike`, `delayed_cannon`, `reckless_assault`, `tetris_echo`, `four_disciplines`
- [x] 9.3 Create files for 6 t-spin techniques: `spinning_strike`, `mini_spark`, `back_to_back_spin`, `dualcasting`, `compact_setup`, `aggressive_positioning`
- [x] 9.4 Create files for 5 combo techniques: `chain_starter`, `combo_spark`, `chain_battery`, `flurry`, `combo_spike`
- [x] 9.5 Create files for 4 speed techniques: `constant_pressure`, `flash_step`, `flow_step`, `switch_up`
- [x] 9.6 Create files for 4 precision techniques: `flatline`, `perfect_spark`, `low_pressure`, `discipline`
- [x] 9.7 Create files for 6 risk techniques: `redzone`, `glass_cannon`, `adrenaline_rush`, `gamblers_blade`, `burning_board`, `greedy_hands`
- [x] 9.8 Create files for 6 economy techniques: `coupon`, `specialist_discount`, `smooth_haggling`, `bounty_list`, `combo_payout`, `green_thumb`
- [x] 9.9 Create files for 4 utility techniques: `patience`, `controlled_drop`, `rotation_training`, `good_planning`
- [x] 9.10 Create files for 2 garbage techniques: `recycling`, `counter_strike`

## 10. Testing

- [x] 10.1 Add tests for `TechniqueRoundState`: all counters start at zero, incrementing each counter
- [x] 10.2 Add tests for `TechniqueEvaluator.compute_attack_bonus`: no techniques returns 0; two flat-bonus techniques stack additively; unknown effect_type returns 0
- [x] 10.3 Add tests for `TechniqueEvaluator.compute_economy_bonus`: economy technique credits coins for matching event
- [x] 10.4 Add tests for `TechniqueEvaluator.evaluate`: result has correct keys; flags array populated for lifecycle techniques
- [ ] 10.5 Add tests for `TetrisBoard.summit_height`: 0 on empty board, reflects highest filled row
- [x] 10.6 Add tests for `RunState.technique_capacity`: is 4 at run start; increases by 1 per stage advance
- [x] 10.7 Run full GUT test suite at `game/tests/run_tests.tscn` and confirm all tests pass
