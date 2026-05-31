## MODIFIED Requirements

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

## ADDED Requirements

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
