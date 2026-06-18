## Why

Gilded income (Midas Touch + Polished) generates 16-56 coins/round passively while all other income sources combined top out around 12-15. With techniques costing 3-8 coins and shops appearing at most 1-2 times per floor under dual-spine generation, gilded builds buy out entire shops in 1-2 rounds with no strategic tension. Interest was designed for frequent shop visits and is now dead weight. Vouchers solved shop-size problems that should just be the new defaults.

## What Changes

- **Buff all non-gilded income sources** to gilded-tier levels: base payout 4→15, starting coins 8→30, keystone/technique economy rewards scaled 3-5×
- **Raise all item prices** to match the new income ceiling: techniques 3-8→40-60 range, consumables 4-6→30-40 range
- **Expand default shop layout**: 3→5 technique slots, 2→3 consumable slots
- **BREAKING**: Remove the interest mechanic entirely (Economy.apply_interest, interest_cap, interest display)
- **BREAKING**: Remove the voucher system entirely (all 4 voucher data files, voucher.gd, RunState tracking, shop slot, save/load, ResourceRegistry references)
- **Rework Wishing Well**: replace gold payout with random item drops (60% consumable, 30% technique, 10% keystone), capped at 3 rewards per visit

## Capabilities

### New Capabilities
- `wishing-well-loot`: Wishing Well awards random items (consumable/technique/keystone) instead of gold, with drop weighting and a per-visit reward cap

### Modified Capabilities
- `economy`: Income values rebalanced (base payout, starting coins, surplus divisor), interest mechanic removed
- `shop-system`: Default slot counts increased (5 technique, 3 consumable), voucher slot removed, interest display removed
- `techniques`: All technique costs rescaled to 40-60 range; economy technique reward values buffed (Combo Payout, Greedy Hands, Green Thumb, Bounty List, surplus divisor)
- `consumables`: All consumable costs rescaled to 30-40 range
- `keystones`: Economy keystone reward values buffed (Slightly Magical Coin, Magical Coin, Golden Watch)
- `vouchers`: **REMOVED** — entire voucher system deleted

## Impact

- **Economy autoload** (`economy.gd`): remove interest_cap, apply_interest()
- **RunState autoload** (`run_state.gd`): remove voucher tracking (array, has_voucher, add_voucher, _apply_voucher_effects), update STARTING_COINS, shop_technique_slots, consumable_capacity defaults
- **Shop scene** (`shop.gd`, `shop.tscn`): remove voucher slot, interest display, add consumable/technique slots
- **RunManager** (`run_manager.gd`): update BASE_PAYOUT, surplus divisor, bounty_list/greedy_hands income values
- **Encounter room** (`encounter_room.gd`): rewrite Wishing Well from gold gamble to item drop
- **All technique .tres files** (56 files): rescale cost field
- **All consumable .tres files** (13 files): rescale cost field
- **Keystone .tres files**: update end_round_coins and time_coins values
- **Technique .tres files** for economy techniques: update params (coins, rows_per_coin, divisor)
- **Voucher data files** (4 .tres): delete
- **voucher.gd**: delete
- **ResourceRegistry** (`resource_registry.gd`): remove voucher references
- **RunSave** (`run_save.gd`): remove voucher save/load
- **Tests**: update economy tests, voucher tests, shop tests, add Wishing Well loot tests
