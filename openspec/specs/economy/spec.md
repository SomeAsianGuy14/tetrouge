## ADDED Requirements

### Requirement: Base payout after every round
At round end, `Economy.pay_round()` SHALL pay only the base payout. Speed bonus and technique income SHALL NOT be separate line items. Technique coins earned mid-round (via technique effects) SHALL be silently added to `Economy.coins` at round end without a dedicated UI row. The round success screen SHALL display the base payout total only.

Starting reference value: 4 coins per round (subject to playtesting).

#### Scenario: Base payout on round success
- **WHEN** a round ends in success
- **THEN** the base coin amount is added to the player's balance before the shop opens

#### Scenario: Round success screen shows base payout only
- **WHEN** the round success screen is shown
- **THEN** only the base payout amount SHALL be displayed
- **THEN** no speed bonus or technique income rows SHALL appear

#### Scenario: No speed bonus paid
- **WHEN** any round ends successfully
- **THEN** `Economy.calculate_speed_bonus()` SHALL NOT be called
- **THEN** no coins SHALL be awarded based on remaining time (except via Golden Watch keystone)

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

### Requirement: Golden Watch — timer visibility and time-remaining coin bonus
Golden Watch SHALL set `RoundConfig.show_timer = true` at round build time, making the HUD timer visible. When the player wins a round and owns Golden Watch, `RunManager` SHALL grant `floor(time_remaining / 5)` coins at round end, where `time_remaining` is the seconds left on the round timer at the moment the quota is met. Description: "Gain a 3-minute timer. At round end, earn 1 coin for every 5 seconds remaining on the timer."

#### Scenario: Golden Watch makes timer visible
- **WHEN** the player holds Golden Watch and a round begins
- **THEN** the HUD timer label SHALL be visible for that round

#### Scenario: Coins granted proportional to time remaining
- **WHEN** Golden Watch is owned and the round is won with 17 seconds remaining
- **THEN** 3 coins are granted (floor(17 / 5) = 3)

#### Scenario: Zero coins when time remaining is less than 5 seconds
- **WHEN** Golden Watch is owned and the round is won with 4 seconds remaining
- **THEN** 0 coins are granted from Golden Watch

## REMOVED Requirements

### Requirement: Speed bonus rewards fast round completion
**Reason:** Without a visible timer, players cannot track or optimise for speed bonus. The mechanic is hidden and therefore not meaningful.
**Migration:** Remove `Economy.calculate_speed_bonus()`. Remove `speed_bonus` parameter from `Economy.pay_round()`. Remove speed bonus display from `round_success.gd`. The `speed_bonus_multiplier` field on Economy (used by Bonus Round voucher) becomes unused and is removed.
