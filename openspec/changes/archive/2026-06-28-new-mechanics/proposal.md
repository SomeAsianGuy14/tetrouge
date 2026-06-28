## Why

Several planned techniques and keystones require engine-level features that don't exist yet: damage-over-time, per-technique persistent state that scales across fights, attack-counting that resets on enemy actions, and mastery-suppression keystones. These need new code patterns before the content can be data-driven.

## What Changes

### New Techniques (requiring new mechanics)
- **Thrash**: Whenever you receive garbage, deal 1 damage (on-garbage-received trigger → damage)
- **Retribution**: Whenever you receive garbage, your next attack deals +3 damage (on-garbage-received trigger → buff next attack)
- **Blood Offering** (Epic): All attacks deal +3. Whenever you defeat an enemy, permanently increase this technique's damage by 2 (persistent per-technique state across rounds)
- **Relentless Assault** (Epic): All attacks deal +1 damage, increased by 1 for every attack performed. Resets on enemy attack (attack counter that resets on enemy garbage event)

### New Keystones (requiring new mechanics)
- **Ignition**: All attacks deal ×1.5 damage but damage is dealt as a burn over 5 seconds (damage-over-time system on enemies)
- **Master of None**: Lose all techniques, can no longer gain techniques. Mastery levels gain 2× XP (technique suppression + mastery XP modifier)
- **Master of One**: Your highest mastery clear deals ×3 damage, all other clears deal no damage (dynamic clear-type suppression based on mastery state)

## Capabilities

### New Capabilities
- `on-garbage-trigger`: Techniques that fire when the player receives garbage (Thrash, Retribution)
- `persistent-technique-state`: Per-technique mutable data that persists across rounds within a run (Blood Offering)
- `enemy-action-reset`: Attack counters that reset when the enemy fires garbage (Relentless Assault)
- `damage-over-time`: Burn system that delivers damage to enemies over time instead of instantly (Ignition)
- `mastery-keystones`: Keystones that modify mastery XP rates or suppress clear types based on mastery state (Master of None, Master of One)

### Modified Capabilities

_(none)_

## Impact

- **New system**: Garbage-received signal/callback in RunManager for technique triggers
- **New system**: Per-technique runtime state dictionary on RunState (persists across rounds, resets on run reset)
- **New system**: Enemy DoT tick system (timer-based damage application with visual feedback)
- **New system**: Mastery XP multiplier support in RunState
- **New system**: Dynamic clear-type suppression based on mastery levels
- **Modified**: `TechniqueEvaluator` for new effect types
- **Modified**: `RunManager._on_attack_generated()` for enemy-action-reset counters
- **Modified**: RunState mastery system for XP multipliers
