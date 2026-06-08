## ADDED Requirements

### Requirement: every_nth_clear fires on the Nth clear
The `"every_nth_clear"` evaluator SHALL fire its bonus on the Nth clear of the round (where N = `params.n`), then again on the 2Nth, 3Nth, and so on. The round-state counter `clears_this_round` is incremented after evaluation, so the condition SHALL use `(rs.clears_this_round + 1) % n == 0` rather than `rs.clears_this_round % n == 0`.

#### Scenario: Bonus fires on the 4th clear for n=4
- **WHEN** a technique with `effect_type = "every_nth_clear"` and `n = 4` is equipped
- **AND** the player has cleared exactly 3 lines this round (so this is the 4th clear)
- **THEN** `compute_attack_bonus` SHALL return the technique's bonus value

#### Scenario: Bonus does not fire on the 3rd clear for n=4
- **WHEN** a technique with `effect_type = "every_nth_clear"` and `n = 4` is equipped
- **AND** the player has cleared exactly 2 lines this round (so this is the 3rd clear)
- **THEN** `compute_attack_bonus` SHALL return 0

#### Scenario: Bonus fires again on the 8th clear for n=4
- **WHEN** a technique with `effect_type = "every_nth_clear"` and `n = 4` is equipped
- **AND** the player has cleared exactly 7 lines this round (so this is the 8th clear)
- **THEN** `compute_attack_bonus` SHALL return the technique's bonus value

#### Scenario: Bonus does not fire on the 1st clear
- **WHEN** a technique with `effect_type = "every_nth_clear"` is equipped
- **AND** `clears_this_round == 0` (this is the very first clear)
- **THEN** `compute_attack_bonus` SHALL return 0
