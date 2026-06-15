## ADDED Requirements

### Requirement: Enhancement-granting technique effect type
Techniques SHALL support `effect_type = "piece_enhancer"` with `params = {"enhancement": <type>, "every_n": N}`: every Nth spawned piece in a round is enhanced with the given type (subject to grant precedence rules in the piece-enhancements capability). The technique evaluator SHALL treat `piece_enhancer` as a no-op for attack and economy evaluation and SHALL NOT emit an unknown-effect-type warning for it.

#### Scenario: Evaluator ignores piece_enhancer
- **WHEN** a `piece_enhancer` technique is equipped and a clear is evaluated
- **THEN** `compute_attack_bonus` and `compute_economy_bonus` return 0 for it and no warning is pushed

#### Scenario: Spawn cadence counts per round
- **WHEN** a `piece_enhancer` technique with `every_n = 5` is equipped and a new round starts
- **THEN** the spawn counter restarts and the 5th spawned piece of the round is enhanced
