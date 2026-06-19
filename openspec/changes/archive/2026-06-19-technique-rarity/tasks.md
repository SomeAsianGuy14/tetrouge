## 1. Technique Resource

- [x] 1.1 Add `@export var rarity: String = "common"` to `technique.gd`
- [x] 1.2 Add rarity constants to `technique.gd`: `RARITY_BASE_COST`, `RARITY_COLOR`, `RARITY_WEIGHT` dictionaries
- [x] 1.3 Add `get_base_cost() -> int` method that returns `RARITY_BASE_COST[rarity]`

## 2. Assign Rarity to All Techniques

- [x] 2.1 Set `rarity = "common"` and `cost = 40` on 31 Common techniques: brass_knuckles, clean_strike, mini_spark, smooth_haggling, green_thumb, chain_starter, constant_pressure, controlled_drop, follow_up, rotation_training, side_strike, flurry, low_pressure, finisher, tetris_echo, coupon, patience, switch_up, opening_blow, hone, spinning_strike, discipline, counter_strike, good_planning, escalation, barricade, sharpen, backpedaling, bounty_list, dualcasting, combo_payout
- [x] 2.2 Set `rarity = "rare"` and `cost = 52` on 14 Rare techniques: preparation, last_stand, combo_spark, golden_blade, recycling, specialist_discount, attack_battery, back_to_back_pressure, back_to_back_spin, chain_battery, flatline, flow_step, greedy_hands, redzone
- [x] 2.3 Set `rarity = "epic"` and `cost = 64` on 12 Epic techniques: adrenaline_rush, aggressive_positioning, combo_spike, compact_setup, delayed_cannon, four_disciplines, glass_cannon, reckless_assault, perfect_spark, gamblers_blade, flash_step, burning_board

## 3. Weighted Draw Helper

- [x] 3.1 Add `weighted_technique_draw(pool: Array, rng: RandomNumberGenerator) -> Technique` static method to ResourceRegistry (or Technique) that picks a technique from the pool using rarity weights
- [x] 3.2 Add `weighted_technique_draw_n(pool: Array, n: int, rng: RandomNumberGenerator) -> Array` that draws n unique techniques using weighted selection

## 4. Shop Integration

- [x] 4.1 Update `_populate_technique_slots()` in `shop.gd` to use weighted draw instead of simple shuffle
- [x] 4.2 Add ±4 cost variance to shop technique display: compute `display_cost = item.cost + RunState.rng.randi_range(-4, 4)` at populate time, store on the slot, use for buy button and affordability check
- [x] 4.3 Apply rarity color to technique name labels in shop item cards
- [x] 4.4 Ensure sell price uses `item.cost` (base), not the variant shop cost
- [x] 4.5 Apply rarity color to technique sell buttons in shop collection panel

## 5. Encounter Integration

- [x] 5.1 Update `_wishing_well_award()` in `encounter_room.gd` to use weighted draw when selecting a technique
- [x] 5.2 Update `_build_library()` to use weighted draw when building the 10-candidate list
- [x] 5.3 Apply rarity color to Library technique choice buttons

## 6. HUD Integration

- [x] 6.1 Update `_refresh_technique_icons()` in `hud.gd` to color technique icon labels by rarity

## 7. Testing

- [x] 7.1 Add test: all techniques have a non-empty `rarity` field
- [x] 7.2 Add test: `get_base_cost()` returns 40 for common, 52 for rare, 64 for epic
- [x] 7.3 Add test: Common technique count is 31, Rare is 14, Epic is 12
- [x] 7.4 Add test: weighted draw favors Common over Rare over Epic (statistical test over 100+ draws)
- [x] 7.5 Add test: technique cost range validation — common costs 40, rare costs 52, epic costs 64
- [x] 7.6 Run full GUT test suite and fix any failures
