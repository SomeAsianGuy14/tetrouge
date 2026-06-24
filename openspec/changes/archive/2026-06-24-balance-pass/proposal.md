## Why

The current technique and keystone numbers were tuned before mastery amplification, the damage log, and the technique capacity cap. Many techniques deal too little damage to justify a slot, and several items need renames for thematic consistency. This pass rebalances existing content and cleans up naming before new content is added.

## What Changes

### Technique Renames
- Coupon → Haggling
- Bounty List → Bounty Connections
- Hone → Slash
- Smooth Haggling → Upcharging
- Greedy Hands → Sticky Fingers (also coin gain 8 → 15)

### Technique Damage/Effect Changes
- Clean Strike: +1 → +2
- Backpedaling: reworked from "next piece Reinforced" to "while combo above 3, gain 1 shield per clear"
- Dualcasting: +3 → +2
- Escalation: reworked to "every 5 attacks deal +5 damage"
- Finisher: +1 → +4
- Green Thumb: reworked to "after clearing 6 garbage lines gain 20 coins"
- Low Pressure: +1 → +2
- Opening Blow: +3 → +5
- Patience: +1 → +2
- Quad Echo: +1 → +3
- Side Strike: +1 → +3
- Switch-Up: reworked to "if your clear is different from your last clear it deals +2 damage"
- Flatline: +2 → +5
- Flow Step: +2 → +5
- Golden Blade: +2 → +4
- Recycling: +3 → +4
- Redzone: +3 → +4
- Adrenaline Rush: +5 → +8
- Combo Spike: reworked to trigger every 3rd combo clear
- Compact Setup: threshold reduced to 30% board height
- Delayed Cannon → One-Two Punch: reworked to "if your clear is the same as the previous, +6 damage"
- Gambler's Blade: reworked to 50% chance +8 / 50% chance -4
- Glass Cannon: +4 → +8
- Reckless Assault: +4 → +6

### Technique Rarity Moves
- Sharpen: Common → Rare
- Barricade: Common → Rare
- Finisher: Common → Rare
- Perfect Spark: Epic → Rare
- Compact Setup: Epic → Rare

### Technique Removals
- Chain Starter
- Mini Spark
- Chain Battery
- Four Disciplines

### Keystone Changes
- Simple Sword: +2 → +3
- Simple Wand: +2 → +3
- Simple Flail → Simple Bow
- Mace and Chain → Recurve Bow
- Simple Shield: 5 → 10
- Legionnaire's Shield: 10 → 20
- Charging Up → Supercharge (keystone rename only)
- Blessed Stone: time bonus removed
- Golden Watch: 1 coin per 5 seconds → 1 coin per second remaining
- Simplicity: 2× → 3×
- Dizzy: +4 → +8
- Enchant: moved to rare technique, reworked to "t-spins deal +3 damage for each t-spin technique"
- Holy Cheese: 2× → 3×
- Burning Board: moved from technique to keystone, reworked to ×1.5 all damage + take 1 damage every 5 seconds

### Keystone Removals
- Hybrid Reactor
- Whirl
- Flexible

## Capabilities

### New Capabilities
- `balance-pass`: Rebalances existing techniques and keystones — damage numbers, rarity tiers, renames, reworks, and removals

### Modified Capabilities

_(none — no spec-level behavior changes, purely data and number tuning)_

## Impact

- **Modified**: ~25 technique `.tres` resource files (damage values, descriptions, rarity, IDs)
- **Modified**: ~13 keystone `.tres` resource files
- **Removed**: 4 technique `.tres` files, 3 keystone `.tres` files
- **Modified**: `ResourceRegistry` if any ID mappings need legacy aliases
- **Modified**: Test files that assert specific technique/keystone counts or costs
- **Modified**: Technique and keystone documentation files
- **New code needed**: Burning Board as a keystone with ×1.5 multiplier (new keystone property), Enchant conversion from keystone to technique, Backpedaling shield-per-clear mechanic, Green Thumb garbage-line-counting rework, Escalation attack-counting rework
