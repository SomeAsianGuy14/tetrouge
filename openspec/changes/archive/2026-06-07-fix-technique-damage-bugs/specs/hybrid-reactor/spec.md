## MODIFIED Requirements

### Requirement: Hybrid Reactor bonus is applied to attacking clears only
During `RunManager._on_attack_generated()`, after all other keystone and technique bonuses are applied and before `_drain_attack()`, if any active keystone has `per_attack_tag_bonus > 0`, the current `modified` attack value is greater than zero, **and the event is a primary clear event (not a b2b or combo bonus event)**, the system SHALL add `per_attack_tag_bonus × N` to `modified`, where N is the count of active techniques whose `tags` array has size ≥ 2.

#### Scenario: Bonus applies when attack is non-zero on a primary clear
- **WHEN** an attack event produces `modified > 0`
- **AND** the event type is a primary clear (e.g. `"quad"`, `"single"`)
- **AND** the player holds Hybrid Reactor (`per_attack_tag_bonus = 3`)
- **AND** two active techniques each have 2 or more tags
- **THEN** `modified` SHALL be increased by 6 before `_drain_attack()` is called

#### Scenario: Bonus does not apply to b2b bonus events
- **WHEN** an attack event fires with `event_type == "b2b"`
- **AND** the player holds Hybrid Reactor
- **AND** the resulting `modified` value is greater than zero
- **THEN** `modified` SHALL NOT be increased by the Hybrid Reactor tag bonus

#### Scenario: Bonus does not apply to combo bonus events
- **WHEN** an attack event fires with `event_type == "combo"`
- **AND** the player holds Hybrid Reactor
- **AND** the resulting `modified` value is greater than zero
- **THEN** `modified` SHALL NOT be increased by the Hybrid Reactor tag bonus

#### Scenario: Bonus does not apply when attack is zero
- **WHEN** an attack event produces `modified == 0` after all other modifiers
- **AND** the player holds Hybrid Reactor
- **THEN** `modified` SHALL remain 0 (no bonus applied)

#### Scenario: Bonus is zero when no techniques qualify
- **WHEN** an attack event produces `modified > 0`
- **AND** the player holds Hybrid Reactor
- **AND** no active technique has 2 or more tags
- **THEN** `modified` SHALL NOT be increased by the Hybrid Reactor field
