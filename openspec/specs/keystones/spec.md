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

### Requirement: Great Sword requires and replaces Simple Sword
Great Sword SHALL require `simple_sword` (previously `slightly_magical_coin`), replace `simple_sword` on pick, and grant `quad_bonus = 10` (previously 8).

#### Scenario: Great Sword is offered only when player holds Simple Sword
- **WHEN** the player holds Simple Sword and does not hold Great Sword
- **THEN** Great Sword SHALL appear as an eligible keystone in the selection screen

#### Scenario: Great Sword grants +10 quad damage
- **WHEN** the player holds Great Sword
- **THEN** every quad clear SHALL receive +10 flat damage

### Requirement: Double Trouble has no suppression penalties
Double Trouble SHALL grant `tspin_double_multiplier = 2.0` with no suppression flags. T-Spin Singles and Triples SHALL deal their normal damage.

#### Scenario: Double Trouble does not suppress T-Spin Singles
- **WHEN** the player holds Double Trouble and performs a T-Spin Single
- **THEN** `suppress_tspin_single` SHALL be false and the T-Spin Single SHALL deal damage normally

#### Scenario: Double Trouble does not suppress T-Spin Triples
- **WHEN** the player holds Double Trouble and performs a T-Spin Triple
- **THEN** `suppress_tspin_triple` SHALL be false and the T-Spin Triple SHALL deal damage normally

### Requirement: Triple Threat has no suppression penalties
Triple Threat SHALL grant `tspin_triple_multiplier = 3.0` with no suppression flags. T-Spin Singles and Doubles SHALL deal their normal damage.

#### Scenario: Triple Threat does not suppress T-Spin Singles
- **WHEN** the player holds Triple Threat and performs a T-Spin Single
- **THEN** `suppress_tspin_single` SHALL be false and the T-Spin Single SHALL deal damage normally

#### Scenario: Triple Threat does not suppress T-Spin Doubles
- **WHEN** the player holds Triple Threat and performs a T-Spin Double
- **THEN** `suppress_tspin_double` SHALL be false and the T-Spin Double SHALL deal damage normally

### Requirement: Magical Coin requires and replaces Slightly Magical Coin and grants 4 end-round coins
Magical Coin SHALL require `slightly_magical_coin`, replace it on pick, and grant `end_round_coins = 4` (previously 2, previously additive).

#### Scenario: Magical Coin grants 4 coins per round
- **WHEN** the player holds Magical Coin and completes a round
- **THEN** 4 coins SHALL be added via `end_round_coins`
- **THEN** Slightly Magical Coin SHALL no longer be active (removed on pick)

### Requirement: Run-start starter keystone selection
Before the first board of every run is loaded, the game SHALL present the keystone selection screen in starter-only mode. The pool SHALL contain only keystones with `is_starter = true`. Three options SHALL be drawn using the seeded run PRNG. The player SHALL choose one; the chosen keystone is added to RunState before `start_round()` is called.

#### Scenario: Starter selection screen shown before round 1
- **WHEN** a new run begins
- **THEN** the keystone selection screen appears showing 3 starter keystones before any board is loaded

#### Scenario: Only is_starter keystones appear in the run-start pool
- **WHEN** the run-start selection pool is drawn
- **THEN** no keystone with `is_starter = false` is included in the offered options

#### Scenario: Chosen starter is added to RunState before round 1
- **WHEN** the player picks a starter keystone
- **THEN** `RunState.keystones` contains that keystone when `start_round()` is called

### Requirement: Post-boss keystone selection excludes starters
Post-boss keystone draws SHALL exclude all keystones with `is_starter = true`. The `KeystoneSelection` scene uses `starter_only: bool` to control this. When `starter_only = false`, the filter SHALL be `ks.is_starter == false` (equivalently, `ks.is_starter == starter_only`).

#### Scenario: Starter keystones absent from post-boss draw
- **WHEN** `starter_only = false` and the selection pool is built
- **THEN** no keystone with `is_starter = true` is included (Simple Flail, Simple Sword, etc. do not appear)

#### Scenario: Non-starter keystones absent from run-start draw
- **WHEN** `starter_only = true` and the selection pool is built
- **THEN** no keystone with `is_starter = false` is included

### Requirement: Keystone descriptions use "Quad" terminology
All keystone descriptions and display names SHALL use the term "Quad" to refer to 4-line clears. The term "Tetris" SHALL NOT appear in any player-facing keystone text.

#### Scenario: Dual Wielding description uses Quad
- **WHEN** Dual Wielding is displayed
- **THEN** the description reads "Consecutive Quads deal 2× damage." (not "Tetrises")

#### Scenario: Daze description uses Quad
- **WHEN** Daze is displayed
- **THEN** the description refers to "Quads" not "Tetrises"

### Requirement: Keystone and Technique resources include a flavor_text field
Both `Keystone` and `Technique` resources SHALL include a `flavor_text: String` field (default `""`). The field is data-only in this change; rendering is deferred.

#### Scenario: flavor_text defaults to empty string
- **WHEN** a Keystone or Technique resource is created without setting flavor_text
- **THEN** `flavor_text` SHALL equal `""`

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

### Requirement: Blessed Stone keystone exists in the keystone pool
Blessed Stone SHALL exist as a `.tres` data file with `blessed_stone = true`, registered in `ResourceRegistry.all_keystones`. Description: "The first time your board tops out, it is cleared and you gain 2 minutes." Blessed Stone only triggers on topout — it SHALL NOT activate on timer expiry.

#### Scenario: Blessed Stone is a non-starter keystone with no category prerequisite
- **WHEN** the player does not hold any specific other keystone
- **THEN** Blessed Stone SHALL be eligible for the keystone selection screen (no `requires_keystone_id`)

#### Scenario: Blessed Stone description references topout as trigger
- **WHEN** Blessed Stone is displayed
- **THEN** the description SHALL reference topping out as the trigger condition, not time running out

### Requirement: Hybrid Reactor keystone exists in the keystone pool
Hybrid Reactor SHALL exist as a `.tres` data file with `per_attack_tag_bonus = 3`, registered in `ResourceRegistry.all_keystones`.

#### Scenario: Hybrid Reactor is a non-starter keystone with no category prerequisite
- **WHEN** the Hybrid Reactor keystone is active
- **THEN** `per_attack_tag_bonus` SHALL equal 3

### Requirement: Reflect keystone exists in the keystone pool
Reflect SHALL exist as a `.tres` data file with `reflect_on_flush = 0.5`, registered in `ResourceRegistry.all_keystones`.

#### Scenario: Reflect keystone sets reflect_on_flush to 0.5
- **WHEN** the Reflect keystone is active
- **THEN** `reflect_on_flush` SHALL equal 0.5

### Requirement: Death screen displays enemy-kill language
The run failure screen SHALL display "Failed to defeat the enemy in time." instead of any "quota not met" phrasing.

#### Scenario: Death screen text uses enemy-kill framing
- **WHEN** the run failure screen is shown
- **THEN** the message SHALL contain "Failed to defeat the enemy in time"
- **THEN** the message SHALL NOT contain the word "quota"

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
