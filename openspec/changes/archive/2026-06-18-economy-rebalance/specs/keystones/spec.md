## MODIFIED Requirements

### Requirement: Slightly Magical Coin grants 5 end-of-round coins
Slightly Magical Coin SHALL have `end_round_coins = 5` (previously 1).

#### Scenario: Round end with Slightly Magical Coin
- **WHEN** the player holds Slightly Magical Coin and wins a round
- **THEN** 5 coins are added via keystone end-of-round grants

### Requirement: Magical Coin requires and replaces Slightly Magical Coin and grants 15 end-round coins
Magical Coin SHALL require `slightly_magical_coin`, replace it on pick, and grant `end_round_coins = 15` (previously 4).

#### Scenario: Magical Coin grants 15 coins per round
- **WHEN** the player holds Magical Coin and completes a round
- **THEN** 15 coins SHALL be added via `end_round_coins`
- **THEN** Slightly Magical Coin SHALL no longer be active (removed on pick)

### Requirement: Golden Watch grants 3 coins per 5 seconds remaining
Golden Watch SHALL grant `floor(time_remaining / 5) * 3` coins at round end (previously `floor(time_remaining / 5) * 1`). The timer visibility behavior is unchanged.

#### Scenario: Coins granted proportional to time remaining
- **WHEN** Golden Watch is owned and the round is won with 17 seconds remaining
- **THEN** 9 coins are granted (floor(17 / 5) × 3 = 9)

#### Scenario: Zero coins when time remaining is less than 5 seconds
- **WHEN** Golden Watch is owned and the round is won with 4 seconds remaining
- **THEN** 0 coins are granted from Golden Watch
