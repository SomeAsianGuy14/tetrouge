### Requirement: Keystone resource supports per-attack technique-tag bonus
The Keystone resource SHALL include a `per_attack_tag_bonus: int` field (default `0`). When non-zero, it contributes a flat damage bonus to attack events scaled by the number of active techniques that have two or more tags.

#### Scenario: Field defaults to zero
- **WHEN** a Keystone resource is created with no explicit `per_attack_tag_bonus`
- **THEN** `per_attack_tag_bonus` SHALL equal `0`

### Requirement: Hybrid Reactor bonus is applied to attacking clears only
During `RunManager._on_attack_generated()`, after all other keystone and technique bonuses are applied and before `_drain_attack()`, if any active keystone has `per_attack_tag_bonus > 0` and the current `modified` attack value is greater than zero, the system SHALL add `per_attack_tag_bonus × N` to `modified`, where N is the count of active techniques whose `tags` array has size ≥ 2.

#### Scenario: Bonus applies when attack is non-zero
- **WHEN** an attack event produces `modified > 0`
- **AND** the player holds Hybrid Reactor (`per_attack_tag_bonus = 3`)
- **AND** two active techniques each have 2 or more tags
- **THEN** `modified` SHALL be increased by 6 before `_drain_attack()` is called

#### Scenario: Bonus does not apply when attack is zero
- **WHEN** an attack event produces `modified == 0` after all other modifiers
- **AND** the player holds Hybrid Reactor
- **THEN** `modified` SHALL remain 0 (no bonus applied)

#### Scenario: Bonus is zero when no techniques qualify
- **WHEN** an attack event produces `modified > 0`
- **AND** the player holds Hybrid Reactor
- **AND** no active technique has 2 or more tags
- **THEN** `modified` SHALL NOT be increased by the Hybrid Reactor field
