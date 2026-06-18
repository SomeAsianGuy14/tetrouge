## MODIFIED Requirements

### Requirement: Base payout after every round
At round end, `Economy.pay_round()` SHALL pay only the base payout. Technique coins earned mid-round (via technique effects) SHALL be silently added to `Economy.coins` at round end without a dedicated UI row. The round success screen SHALL display the base payout total only.

Starting reference value: 15 coins per round.

#### Scenario: Base payout on round success
- **WHEN** a round ends in success
- **THEN** 15 coins are added to the player's balance before the next room

#### Scenario: Round success screen shows base payout only
- **WHEN** the round success screen is shown
- **THEN** only the base payout amount SHALL be displayed
- **THEN** no speed bonus or technique income rows SHALL appear

#### Scenario: No speed bonus paid
- **WHEN** any round ends successfully
- **THEN** `Economy.calculate_speed_bonus()` SHALL NOT be called
- **THEN** no coins SHALL be awarded based on remaining time (except via Golden Watch keystone)

### Requirement: Coins persist across rounds and shops
The player's coin balance SHALL persist throughout the entire run. Coins are only added via payouts, and only removed via shop purchases.

#### Scenario: Balance persists between rounds
- **WHEN** the player has 50 coins at the end of a shop visit
- **THEN** the next round begins with 50 coins

### Requirement: Technique-gated income streams
Certain Techniques (Combo Payout, Green Thumb, Greedy Hands, Bounty List, surplus conversion) generate additional coins based on in-round performance. These SHALL be credited to the player's balance after the round ends, before the next room.

#### Scenario: Technique income credited after round
- **WHEN** a round ends in success and a Technique generated coin events during the round
- **THEN** the total technique-gated coins are added to the balance as part of the round payout

### Requirement: Starting coins for a new run
A new run SHALL begin with 30 coins (`RunState.STARTING_COINS = 30`).

#### Scenario: Run starts with 30 coins
- **WHEN** a new run begins
- **THEN** the player's coin balance is set to 30

## REMOVED Requirements

### Requirement: Interest on unspent coins
**Reason**: Interest was designed for frequent shop visits (after every round). With shops appearing as 1-in-7 room types under dual-spine dungeon generation, the banking incentive is gone and interest is dead weight.
**Migration**: Remove `Economy.apply_interest()`, `Economy.interest_cap` field, and interest display from the shop header. Remove the `interest_cap_up` voucher effect from `RunState._apply_voucher_effects()`.
