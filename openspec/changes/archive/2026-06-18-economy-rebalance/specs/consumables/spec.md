## MODIFIED Requirements

### Requirement: Consumable cost range
All consumables SHALL have costs in the 30-40 coin range. Costs are mapped from the previous 4-6 range using linear interpolation: `new_cost = 30 + round((old_cost - 4) / 2 * 10)`.

| Old Cost | New Cost |
|----------|----------|
| 4        | 30       |
| 5        | 35       |
| 6        | 40       |

#### Scenario: Cheapest consumables cost 30
- **WHEN** the shop displays a consumable that previously cost 4
- **THEN** the displayed cost SHALL be 30

#### Scenario: Most expensive consumables cost 40
- **WHEN** the shop displays a consumable that previously cost 6
- **THEN** the displayed cost SHALL be 40

### Requirement: Player backpack holds up to 3 consumables
The player's backpack SHALL be capped at 3 slots. This is the default capacity — no voucher is needed to unlock it. Purchasing a 4th consumable is not permitted until a slot is freed.

#### Scenario: Backpack full
- **WHEN** the player has 3 consumables and attempts to buy a fourth
- **THEN** the purchase is rejected with a visual indicator showing the backpack is full

#### Scenario: Backpack slot freed after activation
- **WHEN** the player activates a consumable before a round
- **THEN** that backpack slot becomes empty and a new consumable can be purchased
