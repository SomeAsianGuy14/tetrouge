## ADDED Requirements

### Requirement: Base payout after every round
After each round ends in success, the player SHALL receive a base coin payout. The base payout is fixed and does not scale with ante or round difficulty.

Starting reference value: 4 coins per round (subject to playtesting).

#### Scenario: Base payout on round success
- **WHEN** a round ends in success
- **THEN** the base coin amount is added to the player's balance before the shop opens

### Requirement: Speed bonus based on time remaining
After each round, the player SHALL receive a speed bonus proportional to the time remaining when the quota was met. If the quota is not met (failure), no speed bonus is awarded.

Starting reference: `speed_bonus = floor(time_remaining / 20)` (0–3 coins for a 60s round).

#### Scenario: Speed bonus for fast clear
- **WHEN** a round is cleared with 40 seconds remaining
- **THEN** speed bonus is floor(40 / 20) = 2 coins

#### Scenario: No speed bonus on failure
- **WHEN** a round ends in failure (timer expired)
- **THEN** no speed bonus is awarded (run ends)

### Requirement: Interest on unspent coins
At the start of each shop visit, the player SHALL earn interest on their current coin balance. Interest is 1 coin per 5 coins held, capped at 5 coins per visit.

#### Scenario: Interest calculation
- **WHEN** the shop opens and the player holds 12 coins
- **THEN** interest earned is floor(12 / 5) = 2 coins, added before any purchases

#### Scenario: Interest cap
- **WHEN** the shop opens and the player holds 40 coins
- **THEN** interest earned is capped at 5 coins regardless of balance

#### Scenario: Interest applied before purchases
- **WHEN** the shop opens
- **THEN** interest is calculated and added to balance before the player can buy anything

### Requirement: Technique-gated income streams
Certain Techniques (Windfall, Surplus, Stylist) generate additional coins based on in-round performance. These SHALL be credited to the player's balance after the round ends, before the shop opens.

#### Scenario: Technique income credited after round
- **WHEN** a round ends in success and a Technique generated coin events during the round
- **THEN** the total technique-gated coins are added to the balance as part of the round payout

### Requirement: Coins persist across rounds and shops
The player's coin balance SHALL persist throughout the entire run. Coins are only added via payouts and interest, and only removed via shop purchases.

#### Scenario: Balance persists between rounds
- **WHEN** the player has 8 coins at the end of a shop visit
- **THEN** the next round begins with 8 coins and interest is earned on 8 at the next shop

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
