## Why

The keystone system lacks a progression arc within a run — starters feel disposable and non-starters don't connect to them. This change introduces an upgrade path for each starter, tunes several underperforming or confusing keystones, adds high-concept new picks, and cleans up UI language that no longer fits the combat framing.

## What Changes

- **Starter upgrades**: Four starters (Simple Sword, Simple Flail, Simple Shield, Simple Wand) and one economic starter (Slightly Magical Coin) gain upgradeable versions that replace them when picked
- **New `replaces_keystone_id` field** on Keystone: when the upgrade is picked the original is removed from the player's active keystones
- **Rebalance existing keystones**: Simple Shield nerfed, Great Sword rerouted and buffed, Double Trouble and Triple Threat lose suppression penalties, Magical Coin upgraded to replace Slightly Magical Coin at doubled value
- **New keystones**: Blessed Stone (one-time revive), Hybrid Reactor (technique-tag scaling), Reflect (garbage reflection)
- **Flavor text fields**: `flavor_text: String` added to both Keystone and Technique resources for future use
- **UI language**: "quota" replaced with enemy-kill framing throughout; death screen reads "Failed to defeat the enemy in time"

## Capabilities

### New Capabilities

- `keystone-upgrades`: Upgrade keystones that require and replace a starter keystone — new `replaces_keystone_id` field, removal logic in RunState, updated selection filtering
- `blessed-stone`: One-time per-run revive mechanic — on topout or timeout, clears the board and restores 2 minutes; consumed on use
- `hybrid-reactor`: Per-attack bonus scaled by how many active techniques have 2 or more tags; only applies when the clear already deals damage
- `reflect-keystone`: On garbage flush, reflects 50% of accepted lines as damage to the enemy; distinct from the boss Reflect modifier

### Modified Capabilities

- `keystone-data`: Six existing keystones are modified (stats, prerequisites, suppression flags)

## Impact

- `game/resources/keystone.gd` — new fields: `replaces_keystone_id`, `flavor_text`
- `game/resources/technique.gd` — new field: `flavor_text`
- `game/autoloads/run_state.gd` — `add_keystone()` must remove the replaced keystone
- `game/autoloads/resource_registry.gd` — new keystone entries added
- `game/scenes/game/run_manager.gd` — blessed stone death hook, hybrid reactor bonus, reflect-on-flush logic, death screen text update
- `game/resources/data/keystones/*.tres` — modified and new data files
- `game/scenes/screens/run_failure.gd` — death screen text
- `game/tests/unit/` — new and updated unit tests
