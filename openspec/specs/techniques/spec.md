## ADDED Requirements

### Requirement: Techniques are passive attack modifiers purchased from the shop
Techniques SHALL be permanent passive items purchased from the shop that modify the attack output calculation for the remainder of the run. A Technique is active from the moment of purchase. Technique bonuses are computed by `TechniqueEvaluator` using `AttackContext` and `TechniqueRoundState`.

#### Scenario: Technique activates on purchase
- **WHEN** the player buys a Technique
- **THEN** it is added to the active Technique list and its modifier applies to all subsequent attack events in the run

#### Scenario: Techniques persist across rounds
- **WHEN** a new round begins
- **THEN** all previously purchased Techniques remain active

### Requirement: Multiple Techniques stack additively on flat bonuses, multiplicatively on multipliers
When multiple Techniques modify the same event type, flat bonuses SHALL be summed. Multipliers SHALL be applied after all additive bonuses. The order of application SHALL be: base attack + sum(flat bonuses) × product(multipliers).

#### Scenario: Two flat bonus Techniques stack
- **WHEN** two Techniques each add +1 to T-spin Double attack
- **THEN** a T-spin Double generates 4 + 1 + 1 = 6 attack

### Requirement: Enhancement-granting technique effect type
Techniques SHALL support `effect_type = "piece_enhancer"` with `params = {"enhancement": <type>, "every_n": N}`: every Nth spawned piece in a round is enhanced with the given type (subject to grant precedence rules in the piece-enhancements capability). The technique evaluator SHALL treat `piece_enhancer` as a no-op for attack and economy evaluation and SHALL NOT emit an unknown-effect-type warning for it.

#### Scenario: Evaluator ignores piece_enhancer
- **WHEN** a `piece_enhancer` technique is equipped and a clear is evaluated
- **THEN** `compute_attack_bonus` and `compute_economy_bonus` return 0 for it and no warning is pushed

#### Scenario: Spawn cadence counts per round
- **WHEN** a `piece_enhancer` technique with `every_n = 5` is equipped and a new round starts
- **THEN** the spawn counter restarts and the 5th spawned piece of the round is enhanced
