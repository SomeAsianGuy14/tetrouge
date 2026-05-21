## ADDED Requirements

### Requirement: Techniques are passive attack modifiers purchased from the shop
Techniques SHALL be permanent passive items purchased from the shop that modify the attack output calculation for the remainder of the run. A Technique is active from the moment of purchase.

#### Scenario: Technique activates on purchase
- **WHEN** the player buys a Technique
- **THEN** it is added to the active Technique list and its modifier applies to all subsequent attack events in the run

#### Scenario: Techniques persist across rounds
- **WHEN** a new round begins
- **THEN** all previously purchased Techniques remain active

### Requirement: Techniques target specific attack event types
Each Technique SHALL declare which attack event types it modifies (e.g., T-spin doubles, all B2B qualifying clears, combos above step 3). Techniques SHALL NOT modify event types outside their declaration.

#### Scenario: Technique applies only to declared event type
- **WHEN** an attack event is generated
- **THEN** only Techniques that declare that event type apply their modifier

### Requirement: Multiple Techniques stack additively on flat bonuses, multiplicatively on multipliers
When multiple Techniques modify the same event type, flat bonuses SHALL be summed and applied after all multipliers. Multipliers SHALL be applied in the order they were purchased.

#### Scenario: Two flat bonus Techniques stack
- **WHEN** two Techniques each add +1 to T-spin double attack
- **THEN** a T-spin double generates 4 + 1 + 1 = 6 attack

### Requirement: Technique pool for launch
The following Techniques SHALL be available in the initial build (purchasable from the shop pool):

| Name | Effect |
|------|--------|
| **Specialist** | T-spin Singles send +1, T-spin Doubles send +2, T-spin Triples send +3 |
| **Chain Reaction** | Combo attack bonus increased by 1 per step |
| **Perfectionist** | Perfect Clears send +6 (total 16) |
| **Momentum** | B2B bonus is +2 instead of +1 |
| **Efficiency** | Tetrises send +1 (total 5) |
| **Avalanche** | Combo steps 5 and above send double |
| **Persistence** | B2B chain does not reset on Doubles |
| **Windfall** | Earn 1 coin per T-spin during a round (economy stream) |
| **Surplus** | Earn 1 coin per 3 attack above quota (economy stream) |
| **Stylist** | Earn 1 coin per B2B qualifying clear during a round (economy stream) |

#### Scenario: Specialist applies to T-spin Doubles
- **WHEN** Specialist is active and the player performs a T-spin Double
- **THEN** the attack generated is 4 + 2 = 6 lines

#### Scenario: Windfall generates coins during round
- **WHEN** Windfall is active and the player performs any T-spin
- **THEN** 1 coin is added to the economy after the round ends (batch credited at round end)
