## MODIFIED Requirements

### Requirement: Starter keystones catalog
The following keystones SHALL have `is_starter = true` and be available from the first keystone selection. `simple_bow` is renamed to `simple_flail`.

| ID | Display Name | Key Effect |
|---|---|---|
| `simple_flail` | Simple Flail | `single_bonus = 1`, `double_bonus = 1` |
| `simple_shield` | Simple Shield | `start_shield = 5` |
| `simple_sword` | Simple Sword | `quad_bonus = 2` |
| `simple_wand` | Simple Wand | `tspin_single_bonus = 2`, `tspin_double_bonus = 2`, `tspin_triple_bonus = 2` |
| `simple_bag` | Simple Bag | `hold_slots_bonus = 1` |
| `slightly_magical_coin` | Slightly Magical Coin | `end_round_coins = 1` |

#### Scenario: Simple Flail adds 1 to singles and doubles only
- **WHEN** a single-clear attack fires and the player owns Simple Flail
- **THEN** 1 is added to the attack value; quad clears are unaffected

#### Scenario: simple_bow id is no longer valid
- **WHEN** the keystones directory is loaded
- **THEN** no keystone with `id = "simple_bow"` exists; the renamed keystone has `id = "simple_flail"`

### Requirement: New upgrade keystones exist in the keystone pool
The following keystones SHALL exist as `.tres` data files and be registered in `ResourceRegistry.all_keystones`:
- **Mace and Chain**: `requires_keystone_id = "simple_flail"`, `replaces_keystone_id = "simple_flail"`, `single_bonus = 3`, `double_bonus = 3`
- **Legionnaire's Shield**: `requires_keystone_id = "simple_shield"`, `replaces_keystone_id = "simple_shield"`, `start_shield = 10`
- **Crystal Staff**: `requires_keystone_id = "simple_wand"`, `replaces_keystone_id = "simple_wand"`, `tspin_any_bonus = 10`

#### Scenario: Mace and Chain is only offered when Simple Flail is held
- **WHEN** the player holds Simple Flail
- **THEN** Mace and Chain SHALL be eligible for the keystone selection screen

#### Scenario: Legionnaire's Shield starts each round with 10 shield charges
- **WHEN** the player holds Legionnaire's Shield and a new round begins
- **THEN** `_garbage_shield` is 10 at the start of the round

#### Scenario: Crystal Staff adds +10 to all T-Spin damage
- **WHEN** the player holds Crystal Staff and performs any T-Spin
- **THEN** the T-Spin attack SHALL receive +10 flat damage via `tspin_any_bonus`

## REMOVED Requirements

### Requirement: Simple Shield reduces incoming garbage by 1
**Reason**: Simple Shield is redesigned to grant starting garbage-shield charges (see "Simple Shield and Legionnaire's Shield grant starting shield charges") instead of reducing garbage-flush capacity. `garbage_flush_reduction` is removed from `Keystone` and `RoundConfig` entirely, as Legionnaire's Shield was its only other user.
**Migration**: No player action required. `garbage_flush_reduction` was derived from keystone ownership at round-config build time, not stored in save data, so there is nothing to migrate.

Simple Shield SHALL set `garbage_flush_reduction = 1` (previously 2).

#### Scenario: Simple Shield reduces flush capacity by 1
- **WHEN** the player holds Simple Shield
- **THEN** the garbage flush capacity SHALL be `max(0, 8 - 1) = 7` lines per flush

## ADDED Requirements

### Requirement: Simple Shield and Legionnaire's Shield grant starting shield charges
Simple Shield SHALL set `start_shield = 5`. Legionnaire's Shield SHALL set `start_shield = 10` (and continues to require and replace Simple Shield on pick, per the keystone-upgrades capability).

#### Scenario: Simple Shield starts the round with 5 shield charges
- **WHEN** the player holds Simple Shield (and no other `start_shield` keystone) and a new round begins
- **THEN** `_garbage_shield` is 5 at the start of the round

#### Scenario: Legionnaire's Shield replaces Simple Shield's starting shield
- **WHEN** the player picks Legionnaire's Shield while holding Simple Shield
- **THEN** Simple Shield is removed, Legionnaire's Shield is active, and the next round starts with `_garbage_shield = 10` (not 15)

### Requirement: Midas Touch grants periodic Gilded enhancement
Midas Touch SHALL set `piece_enhance_every_n = 7, piece_enhance_type = "gilded"` and SHALL NOT set `overkill_coins`. (Its previous overkill-to-coins effect is removed; see the economy capability.)

#### Scenario: Every 7th piece spawns Gilded while Midas Touch is owned
- **WHEN** the player owns Midas Touch and no timed enhancement grant is active
- **THEN** every 7th spawned piece is enhanced with `gilded`

### Requirement: Enhancement-focused keystones exist in the keystone pool
The following keystones SHALL exist as `.tres` data files with `category = "Enhancement"` and be registered in `ResourceRegistry.all_keystones`:
- **Extraordinary Bag**: `piece_enhance_every_n = 7, piece_enhance_type = "random"`
- **Charging Up**: `piece_enhance_every_n = 10, piece_enhance_type = "amplified"`
- **Jack of All Trades**: `double_enhancement_benefits = true`
- **Refined**: `honed_bonus_per_cell = 2`
- **Armored**: `reinforced_bonus_per_cell = 2`
- **Polished**: `gilded_bonus_per_cell = 1`
- **Overclocked**: `amplified_bonus_per_cell = 0.125`

#### Scenario: Extraordinary Bag enhances every 7th piece with a random type
- **WHEN** the player owns Extraordinary Bag and no timed enhancement grant is active
- **THEN** every 7th spawned piece is enhanced with one of `honed`, `amplified`, `gilded`, `reinforced`, resolved independently each time

#### Scenario: Charging Up enhances every 10th piece with Amplified
- **WHEN** the player owns Charging Up and no timed enhancement grant is active
- **THEN** every 10th spawned piece is enhanced with `amplified`

#### Scenario: Jack of All Trades doubles clear-time enhancement benefits
- **WHEN** the player owns Jack of All Trades and a clear contains 2 honed cells
- **THEN** the honed attack bonus is computed from a count of 4 (doubled)

#### Scenario: Refined increases honed attack per cell
- **WHEN** the player owns Refined and a clear contains 1 honed cell
- **THEN** the honed attack bonus is 3 (1 base + 2 from Refined)

#### Scenario: Armored increases reinforced shield per cell
- **WHEN** the player owns Armored and a clear contains 1 reinforced cell
- **THEN** the shield charge gain is 3 (1 base + 2 from Armored)

#### Scenario: Polished increases gilded coins per cell
- **WHEN** the player owns Polished and a clear contains 1 gilded cell
- **THEN** the coin gain is 2 (1 base + 1 from Polished)

#### Scenario: Overclocked increases amplified rate per cell
- **WHEN** the player owns Overclocked and a clear contains 1 amplified cell
- **THEN** the amplified multiplier is `1.0 + (0.25 + 0.125) = 1.375`

### Requirement: Sharpen's keystone identity is retired
No keystone with `id = "sharpen"` SHALL exist, and `Keystone.per_technique_quad_bonus` is removed. The "Sharpen" identity is now a technique that periodically grants Honed pieces (see the techniques capability).

#### Scenario: sharpen id is no longer a keystone
- **WHEN** the keystones directory is loaded
- **THEN** no keystone with `id = "sharpen"` exists
