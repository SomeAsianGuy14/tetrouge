## Why

All 57 techniques currently appear with equal probability in shops, the Wishing Well, and the Library. There's no distinction between a simple "+1 on clears" technique and a build-defining "+4 with risk" technique — they just have different costs. Adding rarity tiers creates meaningful variety in what players find, makes powerful techniques feel special to discover, and gives a visual signal of technique power level at a glance.

## What Changes

- **Add a `rarity` field to Technique resource** — 3 tiers: Common (white), Rare (blue), Epic (purple)
- **Rarity drives cost** — Common base 40, Rare base 52, Epic base 64. Shop prices vary ±4 around the base using the seeded RNG
- **Shop appearance weighting** — Common techniques appear more frequently than Rare, Rare more than Epic. Weighted random draw when populating shop slots
- **Wishing Well and Library weighted by rarity** — Same weighting applies when these encounters draw techniques
- **Color-coded technique names** — Rarity color shown in shop item cards, HUD technique icons, and collection panels
- **Assign all 57 techniques to tiers** — 31 Common, 14 Rare, 12 Epic

### Tier Assignments

**Common (31):** brass_knuckles, clean_strike, mini_spark, smooth_haggling, green_thumb, chain_starter, constant_pressure, controlled_drop, follow_up, rotation_training, side_strike, flurry, low_pressure, finisher, tetris_echo, coupon, patience, switch_up, opening_blow, hone, spinning_strike, discipline, counter_strike, good_planning, escalation, barricade, sharpen, backpedaling, bounty_list, dualcasting, combo_payout

**Rare (14):** preparation, last_stand, combo_spark, golden_blade, recycling, specialist_discount, attack_battery, back_to_back_pressure, back_to_back_spin, chain_battery, flatline, flow_step, greedy_hands, redzone

**Epic (12):** adrenaline_rush, aggressive_positioning, combo_spike, compact_setup, delayed_cannon, four_disciplines, glass_cannon, reckless_assault, perfect_spark, gamblers_blade, flash_step, burning_board

## Capabilities

### New Capabilities
- `technique-rarity`: Rarity field on Technique resource, rarity-to-cost mapping, rarity color constants, weighted draw logic for shops/encounters

### Modified Capabilities
- `shop-system`: Shop technique slots use weighted random draw by rarity; displayed cost varies ±4 around rarity base
- `techniques`: Technique resource gains `rarity` field; cost derived from rarity with variance

## Impact

- **Technique resource** (`technique.gd`): Add `rarity` field (String: "common", "rare", "epic")
- **All 57 technique .tres files**: Add `rarity` field, remove hardcoded `cost` (or keep as base derived from rarity)
- **Shop** (`shop.gd`): Weighted technique draw, ±4 cost variance, rarity-colored name labels
- **Wishing Well** (`encounter_room.gd`): Weighted technique selection in `_wishing_well_award()`
- **Library** (`encounter_room.gd`): Weighted technique pool in `_build_library()`
- **HUD** (`hud.gd`): Technique icons colored by rarity
- **Shop collection panel**: Technique sell buttons colored by rarity
- **ResourceRegistry**: Rarity constants and weighted draw helper
