## ADDED Requirements

### Requirement: Vouchers are permanent meta-upgrades purchased from the shop
Vouchers SHALL be purchasable from the shop and apply a permanent run-wide change from the moment of purchase. Each voucher can only be purchased once per run.

#### Scenario: Voucher activates on purchase
- **WHEN** the player buys a voucher
- **THEN** its effect is active immediately for the rest of the run

#### Scenario: Voucher cannot be repurchased
- **WHEN** a voucher the player already owns appears in the shop
- **THEN** it is marked as owned and cannot be purchased again

### Requirement: At most one voucher slot appears per shop visit
Each shop visit SHALL contain at most one voucher slot. The slot may be empty in early antes. Vouchers are rarer than Techniques.

#### Scenario: Voucher slot may be empty
- **WHEN** the shop generates its inventory
- **THEN** the voucher slot has a chance of containing no item (weighted by ante — lower antes have lower voucher chance)

### Requirement: Vouchers are more expensive than Techniques
Vouchers SHALL cost more than standard Techniques to create a meaningful save-vs-spend decision and reward the interest mechanic.

Reference pricing: Techniques 4–8 coins, Vouchers 10–14 coins.

#### Scenario: Voucher costs more than a technique
- **WHEN** both a Technique and a Voucher are in the shop
- **THEN** the Voucher's coin cost is visibly higher

### Requirement: Voucher pool for launch
The following vouchers SHALL be available in the initial build:

| Name | Effect |
|------|--------|
| **Interest Cap Up** | Maximum interest per shop visit increased from 5 to 8 coins |
| **Expanded Shop** | Shop Technique slots increased from 3 to 4 |
| **Consumable Expert** | Consumable inventory capacity increased from 2 to 3 |
| **Bonus Round** | Speed bonus payout formula doubled |
| **Sharp Eye** | Elite Blind rounds show a preview of the upcoming Boss Blind modifier |

#### Scenario: Interest Cap Up increases interest ceiling
- **WHEN** Interest Cap Up is owned and the player holds 50 coins at shop open
- **THEN** interest earned is capped at 8 coins instead of 5

#### Scenario: Expanded Shop adds a fourth Technique slot
- **WHEN** Expanded Shop is owned
- **THEN** each subsequent shop visit generates 4 Technique slots instead of 3

#### Scenario: Sharp Eye reveals boss modifier
- **WHEN** Sharp Eye is owned and an Elite Blind round ends
- **THEN** the upcoming Boss Blind's modifier name and description are displayed before the shop opens
