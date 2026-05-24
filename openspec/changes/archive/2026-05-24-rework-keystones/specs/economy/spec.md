## ADDED Requirements

### Requirement: Keystone end-of-round coin grants
At the end of a won round, `RunManager` SHALL sum `end_round_coins` across all owned keystones and credit that total to the player's coin balance before the payout screen is shown. This runs in addition to normal round payout.

#### Scenario: Two keystones with end_round_coins accumulate
- **WHEN** the player owns Slightly Magical Coin (`end_round_coins = 1`) and Magical Coin (`end_round_coins = 2`) and wins a round
- **THEN** 3 coins are credited from keystone grants before the payout screen

#### Scenario: No coin grant when no economic keystones are owned
- **WHEN** the player owns no keystones with `end_round_coins > 0` and wins a round
- **THEN** no additional coins are credited beyond normal payout

### Requirement: Midas Touch — overkill damage converted to coins
When the player wins a round and owns Midas Touch, `RunManager` SHALL convert `surplus_attack` (accumulated damage beyond the round quota) into coins at a 1:1 rate and add them to the player's balance before the payout screen.

#### Scenario: Overkill converted 1:1 to coins
- **WHEN** Midas Touch is owned, the quota is 20, and `quota_accumulated` is 27
- **THEN** 7 coins are added at round end from Midas Touch

#### Scenario: No coins if surplus is zero
- **WHEN** Midas Touch is owned and the player meets quota exactly (surplus = 0)
- **THEN** Midas Touch grants 0 coins

### Requirement: Golden Watch — time-remaining coin bonus
When the player wins a round and owns Golden Watch, `RunManager` SHALL grant `floor(time_remaining / 5)` coins at round end, where `time_remaining` is the seconds left on the round timer at the moment the quota is met.

#### Scenario: Coins granted proportional to time remaining
- **WHEN** Golden Watch is owned and the round is won with 17 seconds remaining
- **THEN** 3 coins are granted (floor(17 / 5) = 3)

#### Scenario: Zero coins when time remaining is less than 5 seconds
- **WHEN** Golden Watch is owned and the round is won with 4 seconds remaining
- **THEN** 0 coins are granted from Golden Watch
