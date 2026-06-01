## MODIFIED Requirements

### Requirement: Each round has a quota and time limit
Every round SHALL have an attack quota (enemy HP that must be depleted) and a time limit (seconds). The player must reach the quota before the timer expires or the board tops out. The HUD SHALL be initialised with the correct quota and time limit at the start of each round so displayed values are accurate from the first frame. At ascension level 4 or above, the quota SHALL be multiplied by 1.2 (rounded up).

#### Scenario: Quota met before time expires
- **WHEN** the player's accumulated modified attack reaches the quota
- **THEN** the round ends as a success immediately; remaining time feeds the speed bonus

#### Scenario: Time expires before quota met
- **WHEN** the timer reaches zero and the quota has not been met
- **AND** the Blessed Stone has already been spent or is not held
- **THEN** the round ends as a failure and the run ends (permadeath)

#### Scenario: Board tops out before quota met
- **WHEN** the board tops out
- **AND** the Blessed Stone has already been spent or is not held
- **THEN** the round ends as a failure and the run ends (permadeath)

#### Scenario: HUD shows correct quota at round start
- **WHEN** a round begins
- **THEN** the HUD quota display shows "0 / N" where N is the correct quota for that stage and round, not a stale or default value

#### Scenario: Ascension level 4 increases quota
- **WHEN** ascension level >= 4
- **AND** the base quota for a round would be 50
- **THEN** the actual quota SHALL be ceil(50 * 1.2) = 60

## ADDED Requirements

### Requirement: Victory triggers profile update and unlock check
When the player clears the Boss Blind of Ante 5, before showing the victory screen the system SHALL: call `ProfileSave.record_victory(AscensionManager.current_level)`, call `ProfileSave.accumulate_stats(run_stats)`, and call `UnlockChecker.check_all(run_stats)`.

#### Scenario: Profile updated on victory
- **WHEN** the player wins a run at ascension level 2
- **THEN** `ProfileSave.highest_beaten` SHALL be updated to at least 2
- **THEN** cumulative stats SHALL reflect the completed run's damage totals

### Requirement: Starter keystone selection is skipped at ascension level 5+
At ascension level 5 or above, the initial keystone selection screen (starter keystones only) SHALL NOT be shown. The run proceeds directly to round 1 with no keystone.

#### Scenario: Starter selection present at level 0–4
- **WHEN** ascension level is 0, 1, 2, 3, or 4
- **THEN** the starter keystone selection screen SHALL appear before round 1

#### Scenario: Starter selection absent at level 5+
- **WHEN** ascension level is 5 or 6
- **THEN** the starter keystone selection screen SHALL NOT appear
- **THEN** the player SHALL have 0 keystones at the start of round 1
