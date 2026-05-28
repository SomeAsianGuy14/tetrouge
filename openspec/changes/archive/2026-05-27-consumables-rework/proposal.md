## Why

Consumables currently mix board manipulation, economy, and timing effects into a single loosely-defined category that doesn't reinforce the game's core identity of attack-oriented scoring. Items like Coin Purse and Clean Slate are passive conveniences with no connection to the round-by-round combat loop. Reworking consumables into temporary per-round attack buffs makes every item feel impactful and directly relevant to how the player scores.

## What Changes

- **Rename**: "Tetris" is replaced by "quad" everywhere in code, UI, and data.
- **Remove consumables**: Clean Slate, Coin Purse, and Piece Lock are removed from the pool.
- **Rework consumable identity**: Consumables are now one-round temporary attack buffs. Each item is stored in the player's backpack and activated before a round, granting enhanced attack values for that round only.
- **New item pool**: Flat attack buff items covering general (all-clear bonus) and specific clear types (quad, T-Spin, B2B, combo, perfect clear).
- **Time Shard retained**: Kept as-is (adds 8 seconds to the round timer mid-round).
- **Backpack expanded**: Player inventory grows from 2 slots to 3 persistent backpack slots, visible on the HUD at all times.
- **Shop consumable slots**: Shop now offers 2 consumable items per visit (was 1).
- **Pre-round activation**: Items are activated from the backpack before a round starts, applying their buff to that round's `RoundConfig`. Unused items remain in the backpack.

## Capabilities

### New Capabilities
- *(none — all changes are modifications to existing capabilities)*

### Modified Capabilities
- `consumables`: Item pool changes (remove 3, keep Time Shard, add attack buff items); per-round effect model replacing instant-use; inventory cap 2 → 3; pre-round activation flow.
- `shop-system`: Consumable slot count increases from 1 to 2 per shop visit.
- `round-hud-display`: Backpack (3 item slots) added as a persistent HUD element visible during rounds.

## Impact

- `game/resources/consumable.gd` — add `apply_to_config(cfg: RoundConfig)` method (parallel to keystones); existing instant-effect logic removed from non-TimeShard items.
- `game/resources/consumables/` — remove Clean Slate, Coin Purse, Piece Lock `.tres` files; add new attack buff `.tres` files.
- `game/scenes/shop/shop.gd` and shop scene — consumable slot count 1 → 2.
- `game/scenes/game/run_manager.gd` — apply active backpack item to `RoundConfig` before round starts.
- `game/scenes/game/run_manager.tscn` (HUD) — add 3-slot backpack display.
- `game/autoloads/run_state.gd` — consumable inventory array cap 2 → 3.
- Any string literal "tetris" or "Tetris" (non-brand) replaced with "quad" / "Quad".
