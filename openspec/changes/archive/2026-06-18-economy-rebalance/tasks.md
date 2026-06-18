## 1. Remove Voucher System

- [x] 1.1 Delete voucher data files: `game/resources/data/vouchers/interest_cap_up.tres`, `expanded_shop.tres`, `consumable_expert.tres`, `bonus_round.tres`
- [x] 1.2 Delete `game/resources/voucher.gd` resource script
- [x] 1.3 Remove `all_vouchers` constant and preloads from `game/autoloads/resource_registry.gd`
- [x] 1.4 Remove `vouchers` array, `has_voucher()`, `add_voucher()`, `_apply_voucher_effects()` from `game/autoloads/run_state.gd`; update `shop_technique_slots` default to 5 and `consumable_capacity` default to 3
- [x] 1.5 Remove voucher save/load from `game/scripts/run_save.gd`
- [x] 1.6 Remove voucher slot, `_all_vouchers`, `_populate_voucher_slot()`, and voucher purchase handling from `game/scenes/shop/shop.gd`; remove voucher slot node from `game/scenes/shop/shop.tscn`

## 2. Remove Interest Mechanic

- [x] 2.1 Remove `interest_cap` field and `apply_interest()` method from `game/autoloads/economy.gd`
- [x] 2.2 Remove interest calculation and `interest_label` display from `game/scenes/shop/shop.gd` `_ready()`

## 3. Income Buffs

- [x] 3.1 Update `BASE_PAYOUT` from 4 to 15 in `game/scenes/game/run_manager.gd`
- [x] 3.2 Update `STARTING_COINS` from 8 to 30 in `game/autoloads/run_state.gd`
- [x] 3.3 Update `slightly_magical_coin.tres` keystone: `end_round_coins` from 1 to 5
- [x] 3.4 Update `magical_coin.tres` keystone: `end_round_coins` from 4 to 15
- [x] 3.5 Update Golden Watch time-coins formula in `_apply_keystone_economy()`: multiply by 3 (`int(round_timer / 5.0) * 3`)
- [x] 3.6 Update `combo_payout.tres` technique params: coins from 5 to 20
- [x] 3.7 Update Greedy Hands income from 2 to 8 in `_calculate_surplus_income()` (or the `_greedy_hands_active` branch)
- [x] 3.8 Update `green_thumb.tres` technique params: coins per trigger from 1 to 4 (or adjust `rows_per_coin` equivalent)
- [x] 3.9 Update Bounty List income from 10 to 40 in `_calculate_surplus_income()`
- [x] 3.10 Update default surplus divisor from 3 to 2 in `_calculate_surplus_income()`

## 4. Price Rescaling — Techniques

- [x] 4.1 Update all techniques with old cost 3 to new cost 40 (brass_knuckles, clean_strike, green_thumb, mini_spark, smooth_haggling)
- [x] 4.2 Update all techniques with old cost 4 to new cost 44 (backpedaling, chain_starter, constant_pressure, controlled_drop, coupon, follow_up, last_stand, opening_blow, patience, preparation, rotation_training, side_strike, switch_up)
- [x] 4.3 Update all techniques with old cost 5 to new cost 48 (barricade, bounty_list, combo_payout, combo_spark, counter_strike, discipline, escalation, finisher, flurry, gamblers_blade, golden_blade, good_planning, low_pressure, recycling, sharpen, specialist_discount, spinning_strike, tetris_echo)
- [x] 4.4 Update all techniques with old cost 6 to new cost 52 (attack_battery, back_to_back_pressure, back_to_back_spin, burning_board, chain_battery, dualcasting, flash_step, flatline, flow_step, greedy_hands, redzone)
- [x] 4.5 Update all techniques with old cost 7 to new cost 56 (adrenaline_rush, aggressive_positioning, combo_spike, compact_setup, delayed_cannon, four_disciplines, glass_cannon, reckless_assault)
- [x] 4.6 Update all techniques with old cost 8 to new cost 60 (perfect_spark)
- [x] 4.7 Fix `hone.tres` missing cost field — assign cost 48 (mid-range, +2 quad attack)

## 5. Price Rescaling — Consumables

- [x] 5.1 Update all consumables with old cost 4 to new cost 30 (power_fragment)
- [x] 5.2 Update all consumables with old cost 5 to new cost 35 (attack_surge, b2b_booster, charged_battery, combo_coil, gold_leaf, lottery_ticket, perfected_spike, quad_stone, sharpening_stone, spin_amplifier)
- [x] 5.3 Update all consumables with old cost 6 to new cost 40 (power_shard, steel_plates)

## 6. Shop Layout Changes

- [x] 6.1 Add 2 additional technique slot nodes to `game/scenes/shop/shop.tscn` (total 5)
- [x] 6.2 Add 1 additional consumable slot node to `game/scenes/shop/shop.tscn` (total 3)
- [x] 6.3 Update `_populate_shop()` and `_populate_technique_slots()` in `shop.gd` to populate 5 technique and 3 consumable slots
- [x] 6.4 Remove voucher-related UI references from shop.tscn (voucher slot, any "Items" header that referenced vouchers)

## 7. Wishing Well Rework

- [x] 7.1 Rewrite `_build_wishing_well()` in `game/scenes/dungeon/encounter_room.gd`: replace gold payout with item drop logic (60% consumable, 30% technique, 10% keystone)
- [x] 7.2 Add reward cap tracking (max 3 per visit) with throw button disabled after cap reached
- [x] 7.3 Add pool exhaustion handling: reroll into remaining categories when a rolled category is full/exhausted
- [x] 7.4 Add capacity checks: treat technique/consumable categories as exhausted when at capacity
- [x] 7.5 Update result label messages for item drops (show item name and type)

## 8. Testing

- [x] 8.1 Update `test_economy.gd`: remove interest tests (`test_interest_cap_up_voucher_raises_cap`), add test for base payout = 15, add test for starting coins = 30
- [x] 8.2 Update `test_resource_registry.gd`: remove `test_all_vouchers_non_empty` and voucher references in ID uniqueness test
- [x] 8.3 Add Wishing Well loot tests: test drop category distribution (consumable/technique/keystone), test 3-reward cap, test pool exhaustion reroll, test capacity-full handling
- [x] 8.4 Add income buff tests: test Greedy Hands awards 8, test Bounty List awards 40, test surplus divisor = 2, test Golden Watch 3×multiplier
- [x] 8.5 Verify technique/consumable cost mapping: spot-check that representative .tres files have correct new costs
- [x] 8.6 Run full GUT test suite and fix any failures from removed voucher/interest references
