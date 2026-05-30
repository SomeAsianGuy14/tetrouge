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
