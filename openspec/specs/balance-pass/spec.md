## ADDED Requirements

### Requirement: Burning Board keystone
The Burning Board keystone SHALL multiply all attack damage by 1.5×. It SHALL also cause the player to receive 1 garbage line every 5 seconds (existing burning board self-damage behavior). `keystone.gd` SHALL have a new property `all_attack_multiplier: float` applied unconditionally in the keystone multiplier pipeline, and a `burning_board: bool` flag for the self-damage timer.

#### Scenario: Burning Board multiplies all damage
- **WHEN** the player has the Burning Board keystone and deals 10 base damage
- **THEN** the final damage SHALL be 15 (10 × 1.5)

#### Scenario: Burning Board self-damage fires every 5 seconds
- **WHEN** the player has the Burning Board keystone and 5 seconds pass
- **THEN** 1 garbage line SHALL be added to the player's board

### Requirement: Enchant as technique
Enchant SHALL be a rare technique with effect_type `per_tspin_technique`. It SHALL add +3 damage to T-Spins for each technique with a "tspin" tag the player owns.

#### Scenario: Enchant with 2 tspin techniques
- **WHEN** the player has Enchant and 2 other techniques with "tspin" tag and performs a T-Spin
- **THEN** Enchant SHALL add +6 damage (3 × 2)

#### Scenario: Enchant does not count itself
- **WHEN** the player has only Enchant (which has a "tspin" tag) and no other tspin techniques
- **THEN** Enchant SHALL add +3 damage (counting itself as 1 tspin technique)

### Requirement: Backpedaling shield-per-clear rework
Backpedaling SHALL grant 1 shield per line clear while the player's combo count exceeds 3.

#### Scenario: Shield granted during combo above 3
- **WHEN** the player's combo count is 4 and they clear a line
- **THEN** 1 shield charge SHALL be added

#### Scenario: No shield granted at combo 3 or below
- **WHEN** the player's combo count is 3 and they clear a line
- **THEN** no shield charge SHALL be added

### Requirement: Escalation rework
Escalation SHALL deal +5 bonus damage on every 5th attack event (non-bonus clear events only).

#### Scenario: 5th attack gets bonus
- **WHEN** the player performs their 5th line clear of the round
- **THEN** that clear SHALL deal +5 additional damage

#### Scenario: 4th attack no bonus
- **WHEN** the player performs their 4th line clear of the round
- **THEN** no escalation bonus SHALL be applied

### Requirement: Switch-Up rework
Switch-Up SHALL deal +2 bonus damage when the current clear type is different from the previous clear type.

#### Scenario: Different clear type grants bonus
- **WHEN** the player performs a quad after a single
- **THEN** the quad SHALL deal +2 additional damage

#### Scenario: Same clear type no bonus
- **WHEN** the player performs a quad after a quad
- **THEN** no Switch-Up bonus SHALL be applied

### Requirement: Green Thumb rework
Green Thumb SHALL grant 20 coins after the player clears 6 cumulative garbage lines in a round.

#### Scenario: 6th garbage line cleared triggers payout
- **WHEN** the player clears their 6th garbage line in a round
- **THEN** 20 coins SHALL be awarded

#### Scenario: Counter resets each round
- **WHEN** a new round starts
- **THEN** the garbage lines cleared counter for Green Thumb SHALL reset to 0

### Requirement: One-Two Punch (Delayed Cannon rework)
One-Two Punch SHALL deal +6 bonus damage when the current clear type matches the previous clear type.

#### Scenario: Same clear type grants bonus
- **WHEN** the player performs a quad after a quad
- **THEN** the second quad SHALL deal +6 additional damage

#### Scenario: Different clear type no bonus
- **WHEN** the player performs a single after a quad
- **THEN** no One-Two Punch bonus SHALL be applied

### Requirement: Gambler's Blade rework
Gambler's Blade SHALL have a 50% chance to add +8 damage and a 50% chance to subtract 4 damage from each attack.

#### Scenario: Win roll adds damage
- **WHEN** the RNG roll is below 0.5
- **THEN** +8 damage SHALL be added to the attack

#### Scenario: Loss roll subtracts damage
- **WHEN** the RNG roll is 0.5 or above
- **THEN** 4 damage SHALL be subtracted from the attack (minimum 0)

### Requirement: Combo Spike triggers every 3rd combo clear
Combo Spike SHALL fire its bonus on every 3rd combo clear instead of every 5th.

#### Scenario: 3rd combo clear triggers
- **WHEN** the player performs their 3rd consecutive combo clear
- **THEN** Combo Spike bonus damage SHALL be applied

### Requirement: Golden Watch earns 1 coin per second remaining
Golden Watch SHALL earn 1 coin for each full second remaining on the timer at round end, instead of 1 per 5 seconds.

#### Scenario: 45 seconds remaining
- **WHEN** the round ends with 45 seconds on the Golden Watch timer
- **THEN** 45 coins SHALL be earned

### Requirement: Technique and keystone removals
Chain Starter, Mini Spark, Chain Battery, Four Disciplines, Hybrid Reactor, Whirl, and Flexible SHALL be removed. Their IDs SHALL be added as legacy aliases resolving to null in ResourceRegistry so existing saves do not crash.

#### Scenario: Removed technique ID in save file
- **WHEN** a save file references technique ID "chain_starter"
- **THEN** the item SHALL be silently dropped from the loaded inventory

### Requirement: Technique and keystone number changes
All damage/shield/coin values specified in the proposal SHALL be updated in the corresponding `.tres` resource files. All renames SHALL update `display_name` and `description` while preserving `id`.

#### Scenario: Simple Sword damage increased
- **WHEN** the player has Simple Sword and performs a quad
- **THEN** the keystone flat bonus SHALL be +3 (previously +2)

#### Scenario: Simplicity multiplier increased
- **WHEN** the player has Simplicity and performs a quad
- **THEN** the keystone multiplier SHALL be 3.0× (previously 2.0×)

#### Scenario: Renamed technique retains save compatibility
- **WHEN** a save file references technique ID "coupon"
- **THEN** it SHALL load successfully and display as "Haggling"
