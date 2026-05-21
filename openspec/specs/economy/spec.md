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
