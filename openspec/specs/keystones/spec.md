### Requirement: Starter keystones catalog
The following keystones SHALL have `is_starter = true` and be available from the first keystone selection. `simple_bow` is renamed to `simple_flail`.

| ID | Display Name | Key Effect |
|---|---|---|
| `simple_flail` | Simple Flail | `single_bonus = 1`, `double_bonus = 1` |
| `simple_shield` | Simple Shield | `garbage_flush_reduction = 1` |
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

### Requirement: Simple Shield reduces incoming garbage by 1
Simple Shield SHALL set `garbage_flush_reduction = 1` (previously 2).

#### Scenario: Simple Shield reduces flush capacity by 1
- **WHEN** the player holds Simple Shield
- **THEN** the garbage flush capacity SHALL be `max(0, 8 - 1) = 7` lines per flush

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
- **Legionnaire's Shield**: `requires_keystone_id = "simple_shield"`, `replaces_keystone_id = "simple_shield"`, `garbage_flush_reduction = 3`
- **Crystal Staff**: `requires_keystone_id = "simple_wand"`, `replaces_keystone_id = "simple_wand"`, `tspin_any_bonus = 10`

#### Scenario: Mace and Chain is only offered when Simple Flail is held
- **WHEN** the player holds Simple Flail
- **THEN** Mace and Chain SHALL be eligible for the keystone selection screen

#### Scenario: Legionnaire's Shield reduces flush capacity by 3
- **WHEN** the player holds Legionnaire's Shield
- **THEN** the garbage flush capacity SHALL be `max(0, 8 - 3) = 5` lines per flush

#### Scenario: Crystal Staff adds +10 to all T-Spin damage
- **WHEN** the player holds Crystal Staff and performs any T-Spin
- **THEN** the T-Spin attack SHALL receive +10 flat damage via `tspin_any_bonus`

### Requirement: Blessed Stone keystone exists in the keystone pool
Blessed Stone SHALL exist as a `.tres` data file with `blessed_stone = true`, registered in `ResourceRegistry.all_keystones`.

#### Scenario: Blessed Stone is a non-starter keystone with no category prerequisite
- **WHEN** the player does not hold any specific other keystone
- **THEN** Blessed Stone SHALL be eligible for the keystone selection screen (no `requires_keystone_id`)

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
