## REMOVED Requirements

### Requirement: Midas Touch — overkill damage converted to coins
**Reason**: Midas Touch is redesigned to periodically grant Gilded-enhanced pieces instead of converting overkill damage to coins (see the keystones capability's "Midas Touch grants periodic Gilded enhancement").
**Migration**: `overkill_coins` is removed from `Keystone`, and the overkill-to-coins conversion code path is removed from `RunManager`'s round-end payout. No save migration needed — `overkill_coins` was derived from keystone ownership, not stored directly.

When the player wins a round and owns Midas Touch, `RunManager` SHALL convert `surplus_attack` (accumulated damage beyond the round quota) into coins at a 1:1 rate and add them to the player's balance before the payout screen.

#### Scenario: Overkill converted 1:1 to coins
- **WHEN** Midas Touch is owned, the quota is 20, and `quota_accumulated` is 27
- **THEN** 7 coins are added at round end from Midas Touch

#### Scenario: No coins if surplus is zero
- **WHEN** Midas Touch is owned and the player meets quota exactly (surplus = 0)
- **THEN** Midas Touch grants 0 coins
