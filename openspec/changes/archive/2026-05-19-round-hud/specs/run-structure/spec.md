## MODIFIED Requirements

### Requirement: Each round has a quota and time limit
Every round SHALL have an attack quota (lines that must be sent) and a time limit (seconds). The player must reach the quota before the timer expires. The HUD SHALL be initialised with the correct quota and time limit at the start of each round so displayed values are accurate from the first frame.

#### Scenario: Quota met before time expires
- **WHEN** the player's accumulated modified attack reaches the quota
- **THEN** the round ends as a success immediately; remaining time feeds the speed bonus

#### Scenario: Time expires before quota met
- **WHEN** the timer reaches zero and the quota has not been met
- **THEN** the round ends as a failure and the run ends (permadeath)

#### Scenario: HUD shows correct quota at round start
- **WHEN** a round begins
- **THEN** the HUD quota display shows "0 / N" where N is the correct quota for that ante and round, not a stale or default value
