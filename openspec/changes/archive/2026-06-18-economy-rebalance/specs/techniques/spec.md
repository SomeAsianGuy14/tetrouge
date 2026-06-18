## MODIFIED Requirements

### Requirement: Technique cost range
All techniques SHALL have costs in the 40-60 coin range. Costs are mapped from the previous 3-8 range using linear interpolation: `new_cost = 40 + round((old_cost - 3) / 5 * 20)`.

| Old Cost | New Cost |
|----------|----------|
| 3        | 40       |
| 4        | 44       |
| 5        | 48       |
| 6        | 52       |
| 7        | 56       |
| 8        | 60       |

Techniques with no previous cost (e.g., `hone.tres` missing cost field) SHALL be assigned a cost based on their power level within the new range.

#### Scenario: Cheapest techniques cost 40
- **WHEN** the shop displays a technique that previously cost 3 (e.g., brass_knuckles, clean_strike, green_thumb, mini_spark, smooth_haggling)
- **THEN** the displayed cost SHALL be 40

#### Scenario: Most expensive techniques cost 60
- **WHEN** the shop displays a technique that previously cost 8 (e.g., perfect_spark)
- **THEN** the displayed cost SHALL be 60

### Requirement: Combo Payout awards 20 coins
The Combo Payout technique SHALL grant 20 coins the first time the player reaches 5+ combo in a round (previously 5 coins).

#### Scenario: First 5+ combo awards 20 coins
- **WHEN** the player owns Combo Payout and reaches combo count ≥ 5 for the first time in a round
- **THEN** 20 coins are added to the player's balance

### Requirement: Greedy Hands awards 8 coins per round
The Greedy Hands technique SHALL grant 8 additional coins per round (previously 2), while enemies still gain +1 attack.

#### Scenario: Round end with Greedy Hands
- **WHEN** the player owns Greedy Hands and wins a round
- **THEN** 8 coins are added as surplus income

### Requirement: Green Thumb awards 4 coins per 5 garbage rows
The Green Thumb technique SHALL grant 4 coins per 5 garbage rows cleared (previously 1 coin per 5 rows).

#### Scenario: Clearing 10 garbage rows with Green Thumb
- **WHEN** the player owns Green Thumb and clears 10 garbage rows in a round
- **THEN** 8 coins are added (4 × floor(10/5))

### Requirement: Bounty List awards 40 coins on boss kill
The Bounty List technique SHALL grant 40 coins when a boss encounter is defeated (previously 10).

#### Scenario: Boss defeated with Bounty List
- **WHEN** the player owns Bounty List and defeats a boss
- **THEN** 40 coins are added to the player's balance

### Requirement: Surplus attack divisor is 2
The surplus-to-coins conversion technique SHALL use a divisor of 2 (previously 3). The default divisor in `_calculate_surplus_income()` SHALL be 2.

#### Scenario: Surplus conversion with 10 surplus attack
- **WHEN** the player owns a surplus conversion technique and has 10 surplus attack at round end
- **THEN** 5 coins are earned (10 ÷ 2)
