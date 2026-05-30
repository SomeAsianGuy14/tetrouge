## MODIFIED Requirements

### Requirement: Starter keystones catalog
The following keystones SHALL have `is_starter = true` and be available from the first keystone selection. `simple_bow` is renamed to `simple_flail`.

| ID | Display Name | Key Effect |
|---|---|---|
| `simple_flail` | Simple Flail | `single_bonus = 1`, `double_bonus = 1` |
| `simple_shield` | Simple Shield | `garbage_flush_reduction = 2` |
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
