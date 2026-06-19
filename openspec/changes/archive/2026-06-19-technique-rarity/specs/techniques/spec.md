## MODIFIED Requirements

### Requirement: Techniques are passive attack modifiers purchased from the shop
Techniques SHALL be permanent passive items purchased from the shop that modify the attack output calculation for the remainder of the run. Each technique SHALL have a `rarity` field (`"common"`, `"rare"`, or `"epic"`) that determines its base cost and appearance frequency. A Technique is active from the moment of purchase. Technique bonuses are computed by `TechniqueEvaluator` using `AttackContext` and `TechniqueRoundState`.

#### Scenario: Technique activates on purchase
- **WHEN** the player buys a Technique
- **THEN** it is added to the active Technique list and its modifier applies to all subsequent attack events in the run

#### Scenario: Techniques persist across rounds
- **WHEN** a new round begins
- **THEN** all previously purchased Techniques remain active
