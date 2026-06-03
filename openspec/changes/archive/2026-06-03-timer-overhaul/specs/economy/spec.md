## MODIFIED Requirements

### Requirement: Round payout contains base payout only
At round end, `Economy.pay_round()` SHALL pay only the base payout. Speed bonus and technique income SHALL NOT be separate line items. Technique coins earned mid-round (via technique effects) SHALL be silently added to `Economy.coins` at round end without a dedicated UI row. The round success screen SHALL display the base payout total only.

#### Scenario: Round success screen shows base payout only
- **WHEN** the round success screen is shown
- **THEN** only the base payout amount SHALL be displayed
- **THEN** no speed bonus or technique income rows SHALL appear

#### Scenario: No speed bonus paid
- **WHEN** any round ends successfully
- **THEN** `Economy.calculate_speed_bonus()` SHALL NOT be called
- **THEN** no coins SHALL be awarded based on remaining time (except via Golden Watch keystone)

## REMOVED Requirements

### Requirement: Speed bonus rewards fast round completion
**Reason:** Without a visible timer, players cannot track or optimise for speed bonus. The mechanic is hidden and therefore not meaningful.
**Migration:** Remove `Economy.calculate_speed_bonus()`. Remove `speed_bonus` parameter from `Economy.pay_round()`. Remove speed bonus display from `round_success.gd`. The `speed_bonus_multiplier` field on Economy (used by Bonus Round voucher) becomes unused and is removed.
