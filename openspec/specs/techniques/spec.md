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

### Requirement: Shield-granting technique effect types are evaluator no-ops
`effect_type = "attack_to_shield"` (The Best Defense) and `effect_type = "height_shield"` (Last Stand) SHALL be treated as no-ops by `TechniqueEvaluator` for attack and economy computation — `compute_attack_bonus` and `compute_economy_bonus` SHALL return 0 for techniques with these effect types, and no unknown-effect-type warning SHALL be pushed. Their actual effects (adding to the garbage-shield pool) are implemented as RunManager side-effects, per the piece-enhancements capability.

#### Scenario: Evaluator ignores attack_to_shield
- **WHEN** a technique with `effect_type = "attack_to_shield"` is equipped and a clear is evaluated
- **THEN** `compute_attack_bonus` and `compute_economy_bonus` return 0 for it and no warning is pushed

#### Scenario: Evaluator ignores height_shield
- **WHEN** a technique with `effect_type = "height_shield"` is equipped and a piece lock is evaluated
- **THEN** `compute_attack_bonus` and `compute_economy_bonus` return 0 for it and no warning is pushed

### Requirement: Post-clear enhancement grant effect types
`effect_type = "post_quad_enhance"` with `params = {"enhancement": <type>}` (Preparation) SHALL queue a 1-piece enhancement grant of `<type>` for the next spawned piece whenever a Quad clear occurs. `effect_type = "post_combo_enhance"` with `params = {"enhancement": <type>, "combo_threshold": N}` (Backpedaling) SHALL queue a 1-piece enhancement grant of `<type>` whenever `ctx.combo > N` on a clear. Both effect types SHALL be evaluator no-ops for attack and economy computation (return 0, no warning). Queuing follows the grant-queue rules defined in the piece-enhancements capability.

#### Scenario: Preparation queues a Honed grant after a Quad
- **WHEN** the player owns a technique with `effect_type = "post_quad_enhance", params = {"enhancement": "honed"}` and clears a Quad
- **THEN** a 1-piece `honed` grant is queued (or becomes active if no grant is currently active)

#### Scenario: Preparation does not queue on non-Quad clears
- **WHEN** the player owns Preparation and clears a Single, Double, or Triple
- **THEN** no grant is queued

#### Scenario: Backpedaling queues a Reinforced grant when combo exceeds the threshold
- **WHEN** the player owns a technique with `effect_type = "post_combo_enhance", params = {"enhancement": "reinforced", "combo_threshold": 5}` and a clear occurs with `ctx.combo = 6`
- **THEN** a 1-piece `reinforced` grant is queued (or becomes active if no grant is currently active)

#### Scenario: Backpedaling does not queue when combo is at or below the threshold
- **WHEN** the player owns Backpedaling and a clear occurs with `ctx.combo <= 5`
- **THEN** no grant is queued

### Requirement: Enhancement-aware attack bonus effect type
`effect_type = "golden_blade"` with `params = {"bonus": N}` SHALL add `N` to the attack delta for a clear when `ctx.cleared_enh_counts.get("gilded", 0) > 0`, and SHALL contribute 0 otherwise.

#### Scenario: Golden Blade adds its bonus when the clear contains a gilded cell
- **WHEN** the player owns a technique with `effect_type = "golden_blade", params = {"bonus": 2}` and a clear's `cleared_enh_counts` includes `gilded: 1`
- **THEN** the technique contributes +2 to the attack delta for that clear

#### Scenario: Golden Blade contributes nothing without a gilded cell
- **WHEN** the player owns Golden Blade and a clear's `cleared_enh_counts` does not include `gilded` (or it is 0)
- **THEN** the technique contributes 0 to the attack delta for that clear
