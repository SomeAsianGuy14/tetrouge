## MODIFIED Requirements

### Requirement: Each round has a quota and time limit
Every round SHALL have an attack quota (enemy HP that must be depleted) and a time budget (seconds). The player must deplete the quota; topping out ends the run in failure. Reaching the time budget without depleting the quota no longer ends the run, except during The Blitz boss modifier round where timeout remains a failure condition. The base time budget is 180 seconds.

#### Scenario: Quota met before time budget expires
- **WHEN** the player's accumulated attack reaches the quota
- **THEN** the round ends as a success immediately

#### Scenario: Time budget expires in a standard round
- **WHEN** the timer reaches zero in a round that is not The Blitz
- **THEN** the timer SHALL clamp to zero and the round SHALL continue
- **THEN** the run SHALL NOT end

#### Scenario: Time budget expires during The Blitz
- **WHEN** the timer reaches zero during a Blitz round
- **THEN** the round ends as a failure and the run ends (permadeath)

#### Scenario: Board tops out
- **WHEN** the board tops out in any round
- **AND** the Blessed Stone has already been spent or is not held
- **THEN** the round ends as a failure and the run ends (permadeath)

### Requirement: Blessed Stone only triggers on topout
Blessed Stone SHALL only intercept the `game_over` signal (board topout). It SHALL NOT intercept a timer expiry.

#### Scenario: Blessed Stone triggers on topout
- **WHEN** the board tops out
- **AND** Blessed Stone is held and unspent
- **THEN** the board is cleared and 120 seconds are added to the round timer

#### Scenario: Blessed Stone does not trigger on timeout
- **WHEN** the timer reaches zero in any round
- **THEN** Blessed Stone SHALL NOT activate regardless of spent state
