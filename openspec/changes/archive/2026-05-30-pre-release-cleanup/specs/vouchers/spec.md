## MODIFIED Requirements

### Requirement: Voucher pool for launch
The following vouchers SHALL be available in the initial build:

| Name | Effect |
|------|--------|
| **Interest Cap Up** | Maximum interest per shop visit increased from 5 to 8 coins |
| **Expanded Shop** | Shop Technique slots increased from 3 to 4 |
| **Consumable Expert** | Consumable inventory capacity increased from 2 to 3 |
| **Bonus Round** | Speed bonus payout formula doubled |

#### Scenario: Interest Cap Up increases interest ceiling
- **WHEN** Interest Cap Up is owned and the player holds 50 coins at shop open
- **THEN** interest earned is capped at 8 coins instead of 5

#### Scenario: Expanded Shop adds a fourth Technique slot
- **WHEN** Expanded Shop is owned
- **THEN** each subsequent shop visit generates 4 Technique slots instead of 3

## REMOVED Requirements

### Requirement: Sharp Eye voucher
**Reason**: The `sharp_eye_active` flag was set on purchase but never read anywhere in gameplay. The "Elite Blind" preview feature it described was not implemented. Shipping a purchasable item with no observable effect is misleading to players.
**Migration**: Remove `sharp_eye.tres` from the voucher data directory. Remove `sharp_eye_active` from `RunState` and `RunSave`. No save-file migration needed (no live saves contain this voucher).
