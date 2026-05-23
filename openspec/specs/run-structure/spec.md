## ADDED Requirements

### Requirement: Run consists of 5 antes of 4 rounds each
A full run SHALL consist of 5 antes. Each ante SHALL contain 4 rounds: Small Blind, Big Blind, Elite Blind, and Boss Blind (in order).

#### Scenario: Run structure is fixed
- **WHEN** a run begins
- **THEN** the player progresses through Small → Big → Elite → Boss for each of the 5 antes in sequence

#### Scenario: Run ends after Ante 5 Boss
- **WHEN** the player clears the Boss Blind of Ante 5
- **THEN** the run is marked as a victory and the end screen is shown

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
- **THEN** the HUD quota display shows "0 / N" where N is the correct quota for that stage and round, not a stale or default value

### Requirement: Quota and time limit scale per ante and round
Quotas SHALL increase with each ante and each round within an ante. The time limit SHALL remain fixed at 60 seconds per round for the initial build.

Starting reference values (subject to playtesting):
- `quota = 20 + (ante - 1) * 15 + (round_index - 1) * 8`
  - Ante 1 Small: 20, Ante 1 Big: 28, Ante 1 Elite: 36, Ante 1 Boss: 44
  - Ante 5 Boss: 20 + 60 + 24 = 104

#### Scenario: Ante 1 Small Blind quota
- **WHEN** Ante 1 Small Blind begins
- **THEN** the quota is set to 20 attack lines and the timer to 60 seconds

### Requirement: Boss Blind has a modifier
The Boss Blind round in each ante SHALL have exactly one active boss modifier applied at round start. Boss modifiers alter the rules for that round only and are independent of the augment reward.

#### Scenario: Boss modifier applies from round start
- **WHEN** a Boss Blind round begins
- **THEN** the selected boss modifier is active for the entire round with no grace period

#### Scenario: Boss modifier does not carry over
- **WHEN** the Boss Blind round ends
- **THEN** the boss modifier is removed and the next round starts without it

### Requirement: Starting state
At the start of each run, the player SHALL receive a base coin amount and one randomly drawn Augment from the starter Augment pool.

#### Scenario: Run initialisation
- **WHEN** a new run begins
- **THEN** the player's coin balance is set to the base starting amount and one starter Augment is assigned and active

### Requirement: Permadeath
If the player fails any round (timer expires before quota is met), the run SHALL end immediately with no recovery. No continue or retry is available.

#### Scenario: Failure ends the run
- **WHEN** any round ends in failure
- **THEN** the run ends, a failure screen is shown, and the player is returned to the main menu

## ADDED Requirements

### Requirement: Run lifecycle includes save and delete events
A run SHALL be persisted to disk after each completed round (when the shop is closed), and deleted from disk when the run concludes (victory or failure) or is abandoned via New Run. These events are part of the run lifecycle and SHALL not alter any in-memory game state.

#### Scenario: Run saved after first shop visit
- **WHEN** the player exits the shop for the first time in a run
- **THEN** the run state is saved to disk before the next round begins

#### Scenario: Run deleted on natural conclusion
- **WHEN** the run ends in victory or failure
- **THEN** the save file is removed so the main menu no longer offers a Continue option
