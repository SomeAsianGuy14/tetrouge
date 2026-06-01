## Why

Beating the game currently ends with a static victory screen and no reason to replay — there is no post-run progression. An ascension system gives players a repeatable challenge ladder and a framework for unlocking new content over time.

## What Changes

- **Post-victory ascension loop**: Beating the game at ascension level N unlocks level N+1. Players can select any unlocked level when starting a new run.
- **Ascension selector screen**: Appears after "New Run" is chosen, but only if the player has beaten the game at least once.
- **6 cumulative difficulty modifiers**: Each ascension level stacks a new modifier on top of all previous ones (combinatorial).
- **Base game rebalance**: Enemy garbage intervals increased by ~25% across all tiers to create breathing room that ascension 1 then partially removes.
- **Persistent profile save**: New `user://profile.cfg` stores highest ascension beaten and cross-run stats — completely separate from the per-run `user://save.cfg`.
- **Unlock framework**: Items (keystones, techniques) can carry an `unlock_condition_id`. A `ProfileSave` stat-accumulation layer and `UnlockChecker` evaluate conditions at victory. No items are locked yet; the infrastructure enables future additions.

## Capabilities

### New Capabilities

- `ascension-progression`: Ascension level selection, persistent profile save, victory hook that advances the beaten level and checks unlocks
- `ascension-modifiers`: The six stacked difficulty modifiers and how they are applied to each run
- `unlock-framework`: `UnlockCondition` resource type, per-run `RunStats` tracking, cumulative stat accumulation in `ProfileSave`, `UnlockChecker` stub
- `profile-save`: Persistent cross-run storage (`user://profile.cfg`) for ascension state, cumulative stats, and unlocked item ids

### Modified Capabilities

- `run-structure`: Victory now triggers profile updates and ascension unlock logic before showing the victory screen; run start conditionally skips the starter keystone selection at ascension level 5+

## Impact

- `game/autoloads/run_state.gd` — starter keystone skip flag consumed at run start
- `game/scenes/game/run_manager.gd` — ascension modifiers applied in `_build_round_config()`; victory path updated; base garbage intervals increased
- `game/scenes/screens/run_victory.gd` — calls `ProfileSave.record_victory()` and `UnlockChecker.check_all()`
- `game/scenes/main_menu/` — "New Run" flow conditionally opens ascension selector
- New files: `ProfileSave`, `AscensionManager`, `RunStats`, `UnlockCondition`, `UnlockChecker`, ascension selector scene
- `game/resources/keystone.gd`, `game/resources/technique.gd` — new `unlock_condition_id: String` field
- `game/autoloads/resource_registry.gd` — filtering locked items from pools
- `game/tests/unit/` — new unit tests
