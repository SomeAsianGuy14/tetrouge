## Why

The current technique and keystone pools need more variety to support diverse build paths. This batch adds new techniques and keystones that use existing effect patterns (flat damage bonuses, shield grants, conditional triggers) so they can be implemented as data resources without new engine-level mechanics.

## What Changes

### New Common Techniques
- **Guard**: Quads grant 2 shield
- **Staff Spin**: T-Spins grant 2 shield
- **Brace**: At the start of each round gain 2 shield
- **Volley**: Your first 3 attacks deal +2 damage
- **Perfect Placement**: Perfect clears deal +8 damage

### New Rare Techniques
- **Slow and Steady**: Clears that take longer than 5 seconds gain +4 damage
- **Safe Distance**: Clears during the last 10 seconds of enemy attack bar grant 4 shield
- **Double Barrel**: Consecutive t-spins deal +6 damage
- **Concentrate**: If you have not received garbage this combat, all attacks deal +2
- **Whirlwind**: Quads deal +3 damage for each quad technique

### New Epic Techniques
- **Charging Up** (technique version): When your combo count exceeds 5 your next piece spawns amplified

### New Keystones
- **Investment**: Gain an additional coin for every 10 coins you have after each combat
- **Hardened Steel**: Whenever you gain shield, gain 2× the amount
- **Shield Bash**: Whenever you gain shield, deal that amount as damage
- **Cripple**: All enemies take 5 seconds longer to attack
- **Nothing to Waste**: Gain an additional 20 gold whenever you defeat an enemy
- **Equivalent Exchange**: Trade a technique you own for a technique of the same tier in shops
- **Big Brain**: Gain 2 additional technique slots
- **Ramping Rhythm**: All attacks deal +1 damage, increasing by 1 every 3 seconds

## Capabilities

### New Capabilities
- `new-content`: New techniques and keystones using existing effect patterns

### Modified Capabilities

_(none)_

## Impact

- **New**: ~8 technique `.tres` resource files + technique GDScript effect types where needed
- **New**: ~8 keystone `.tres` resource files + keystone properties where needed
- **Modified**: Test count assertions in `test_technique_rarity.gd` and `test_resource_registry.gd`
- **New code**: Some new effect types needed: shield-on-clear, round-start-shield, first-N-attacks bonus, garbage-received tracking, per-tag-count scaling, shield-gain interception (Hardened Steel/Shield Bash), enemy interval modifier (Cripple), coin-per-10-coins economy (Investment), technique trading (Equivalent Exchange)
