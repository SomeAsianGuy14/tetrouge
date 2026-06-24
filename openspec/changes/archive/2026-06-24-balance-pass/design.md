## Context

Techniques are `.tres` resource files with `id`, `display_name`, `description`, `cost`, `rarity`, `tags`, `effect_type`, and `params`. Keystones are `.tres` resource files with exported properties for flat bonuses, multipliers, suppression flags, and special mechanics. Both are loaded by `ResourceRegistry` and referenced by ID throughout the codebase (save files, shops, unlock conditions, tests).

Most changes in this pass are data-only edits to `.tres` files. A few require code changes: reworked effect types (Backpedaling, Escalation, Switch-Up, Green Thumb, Combo Spike), Burning Board moving from technique to keystone (needs a new keystone multiplier property), Enchant moving from keystone to technique, and Golden Watch earning formula change.

## Goals / Non-Goals

**Goals:**
- Update all technique/keystone numbers, descriptions, rarity tiers, and names
- Remove deprecated items cleanly with legacy ID aliases in ResourceRegistry
- Rework effect types that change behavior (not just numbers)
- Move Burning Board from technique to keystone and Enchant from keystone to technique
- Keep all existing tests passing (update assertions to match new values)

**Non-Goals:**
- Adding new items (that's the new-content change)
- New engine-level systems (that's new-mechanics)
- Visual or UI changes

## Decisions

### 1. Renames update the `.tres` file's `display_name` and `description` but keep the original `id` and filename

Changing IDs would break save files and require migration. The `display_name` field is what players see. The `id` stays as-is (e.g. `coupon` stays `coupon`, but `display_name` becomes "Haggling"). The filename stays too to avoid UID breakage.

Exception: Enchant (keystone → technique) and Burning Board (technique → keystone) need new resource files since they change resource type. The old IDs get legacy aliases.

### 2. Rarity moves update `rarity` and `cost` fields

When a technique moves from common to rare, set `rarity = "rare"` and `cost = 52` (the rare base cost). The `get_base_cost()` method already derives from rarity.

### 3. Removals: delete `.tres` files and add legacy aliases

Removed items (Chain Starter, Mini Spark, Chain Battery, Four Disciplines, Hybrid Reactor, Whirl, Flexible) get their `.tres` files deleted. Their IDs are added to the legacy alias map in `ResourceRegistry` mapping to `null` so old save files don't crash — they just silently drop the item.

### 4. Reworked techniques get new effect_type implementations

- **Backpedaling**: `post_combo_enhance` → new `shield_per_clear_while_combo` effect type (params: `combo_threshold`, `shield_per_clear`)
- **Escalation**: `escalation` effect type reworked — currently fires every N pieces, change to every N attacks with higher bonus (params: `every_n_attacks: 5`, `bonus: 5`)
- **Switch-Up**: `switch_up` effect type reworked — currently tracks hard-drop/soft-drop alternation, change to "different from last clear" (params: `bonus: 2`)
- **Green Thumb**: `green_thumb` reworked — currently coins per garbage rows cleared, change to threshold-based (params: `rows_threshold: 6`, `coins: 20`)
- **Combo Spike**: currently fires every 5th combo clear, change to every 3rd
- **Delayed Cannon → One-Two Punch**: `delayed_cannon` reworked — change to "same clear as previous" (params: `bonus: 6`)
- **Gambler's Blade**: change probabilities and values (50/50 instead of 25/25, +8/-4 instead of +4/-2)

### 5. Burning Board: technique → keystone

Create a new keystone resource `burning_board.tres` with a new keystone property `all_attack_multiplier: float = 0.0` (set to 1.5). The keystone multiplier is applied in `_apply_keystone_multipliers()` unconditionally when nonzero. The burning board's self-damage timer logic already exists in RunManager and can be triggered by a keystone flag `burning_board: bool` instead of checking technique presence.

Delete the technique version and add a legacy alias.

### 6. Enchant: keystone → technique

Create a new technique resource with effect_type `per_tspin_technique` (params: `bonus_per_technique: 3`). The evaluator counts techniques with "tspin" tag and multiplies by the per-technique bonus. Remove the keystone's `per_technique_tspin_bonus` property handling.

### 7. Golden Watch: coin formula change

Currently uses `time_coins: bool` flag and RunManager divides remaining seconds by 5. Change to divide by 1 (i.e. 1 coin per second remaining). This is a one-line change in RunManager's `_apply_keystone_economy()`.

## Risks / Trade-offs

**Save compatibility** → Renamed items keep their IDs, so existing saves work. Removed items get null aliases so they're silently dropped. Moved items (Burning Board, Enchant) get legacy aliases pointing to the new resource. Items that were removed from a keystone slot won't break — the slot will just be empty on load.

**Test count assertions** → `test_technique_rarity.gd` asserts exact counts per rarity tier. These will need updating after rarity moves and removals. The test for total technique count will also change.

**Burning Board as keystone with multiplier** → Adding `all_attack_multiplier` to `keystone.gd` is a new property but follows the existing pattern of keystone multipliers. Low risk.
