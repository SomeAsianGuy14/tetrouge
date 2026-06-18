## REMOVED Requirements

### Requirement: Run consists of 5 antes of 4 rounds each
**Reason**: Replaced by the dungeon-floor system. Runs now consist of 4 floors, each a dungeon map. Linear ante/round sequencing is removed.
**Migration**: `RunState.stage` and `RunState.round_index` are replaced by `RunState.floor` and `RunState.current_floor_data`. Any code referencing `stage` or `round_index` for progression must migrate to the floor model.

---

## MODIFIED Requirements

### Requirement: Each round has a quota and time limit
Every combat room SHALL have an attack quota (enemy HP that must be depleted) and a time budget (seconds). The player must deplete the quota within the time budget; topping out ends the run in failure. The timer expiry and Blitz rules are unchanged. The base time budget is 180 seconds. The HUD SHALL be initialised with the correct quota and time budget at the start of each combat room so displayed values are accurate from the first frame. At ascension level 4 or above, the quota SHALL be multiplied by 1.2 (rounded up).

For non-boss combat rooms, the quota SHALL be additionally multiplied by `(1.0 + combat_rooms_cleared_this_floor * 0.08)`, applied after all other modifiers. The Boss/Exit room quota SHALL NOT apply this multiplier.

Quota base formula (replacing the stage/round formula): `quota = 20 * (2 ^ (floor - 1)) + room_tier_bonus` where `room_tier_bonus` is 0 for Small, 12 for Big, 24 for Elite, and 36 for Boss.

#### Scenario: Quota met before time budget expires
- **WHEN** the player's accumulated modified attack reaches the quota
- **THEN** the combat room ends as a success immediately

#### Scenario: Time budget expires in a standard combat room
- **WHEN** the timer reaches zero in a room that is not The Blitz
- **THEN** the timer SHALL clamp to zero and the combat SHALL continue
- **THEN** the run SHALL NOT end

#### Scenario: Time budget expires during The Blitz
- **WHEN** the timer reaches zero during a Blitz boss modifier room
- **THEN** the combat ends as a failure and the run ends (permadeath)

#### Scenario: Board tops out before quota met
- **WHEN** the board tops out
- **AND** the Blessed Stone has already been spent or is not held
- **THEN** the combat ends as a failure and the run ends (permadeath)

#### Scenario: HUD shows correct quota at combat start
- **WHEN** a combat room begins
- **THEN** the HUD quota display shows "0 / N" where N is the correct quota for that floor and room tier, not a stale or default value

#### Scenario: Ascension level 4 increases quota
- **WHEN** ascension level >= 4
- **AND** the base quota for a room would be 50
- **THEN** the actual quota SHALL be ceil(50 * 1.2) = 60

#### Scenario: Non-boss combat scaling by rooms cleared
- **WHEN** `combat_rooms_cleared_this_floor` is 3 before entering a Small combat room on floor 2
- **THEN** the effective quota is `ceil(base_quota * 1.24)` (1.0 + 3 * 0.08)

#### Scenario: Boss quota unaffected by rooms-cleared counter
- **WHEN** the player enters the Boss/Exit room after clearing 5 combat rooms
- **THEN** the Boss quota uses only the floor and tier formula, with no within-floor multiplier

### Requirement: Boss Blind has a modifier
The Boss/Exit room in each floor SHALL have exactly one active boss modifier applied at room start. Boss modifiers alter the rules for that room only and are independent of the augment reward. Selection is seeded per run.

#### Scenario: Boss modifier applies from room start
- **WHEN** a Boss/Exit room begins
- **THEN** the selected boss modifier is active for the entire combat with no grace period

#### Scenario: Boss modifier does not carry over
- **WHEN** the Boss/Exit room combat ends
- **THEN** the boss modifier is removed

### Requirement: Starting state
At the start of each run, the player SHALL receive a base coin amount and one randomly drawn Augment from the starter Augment pool.

#### Scenario: Run initialisation
- **WHEN** a new run begins
- **THEN** the player's coin balance is set to the base starting amount and one starter Augment is assigned and active

### Requirement: Permadeath
If the player fails any combat room (tops out or Blitz timer expires), the run SHALL end immediately with no recovery.

#### Scenario: Failure ends the run
- **WHEN** any combat room ends in failure
- **THEN** the run ends, a failure screen is shown, and the player is returned to the main menu

### Requirement: Run lifecycle includes save and delete events
A run SHALL be persisted to disk after each room is resolved (combat cleared, shop closed, or encounter completed), and deleted from disk when the run concludes (victory or failure) or is abandoned via New Run.

#### Scenario: Run saved after each room
- **WHEN** the player resolves any room and the dungeon map is shown
- **THEN** the run state (including floor map and cleared rooms) is saved to disk

#### Scenario: Run deleted on natural conclusion
- **WHEN** the run ends in victory or failure
- **THEN** the save file is removed so the main menu no longer offers a Continue option

### Requirement: Between-floor reward is a keystone selection
After defeating the Boss/Exit of floors 1–3, the player SHALL be shown the keystone selection screen before the next floor's dungeon map is generated and displayed.

#### Scenario: Keystone selection shown between floors
- **WHEN** the player clears the Boss/Exit of floor 1, 2, or 3
- **THEN** the keystone selection screen is shown

#### Scenario: No keystone selection after floor 4 Boss
- **WHEN** the player clears the Boss/Exit of floor 4
- **THEN** the victory screen is shown directly (no keystone selection)

### Requirement: Victory triggers profile update and unlock check
When the player clears the Boss/Exit of floor 4, before showing the victory screen the system SHALL call `ProfileSave.record_victory(AscensionManager.current_level)`, `ProfileSave.accumulate_stats(run_stats)`, and `UnlockChecker.check_all(run_stats)`.

#### Scenario: Profile updated on victory
- **WHEN** the player wins a run at ascension level 2
- **THEN** `ProfileSave.highest_beaten` SHALL be updated to at least 2

### Requirement: Starter keystone selection is skipped at ascension level 5+
At ascension level 5 or above, the initial keystone selection screen SHALL NOT be shown. The run proceeds directly to floor 1 with no keystone.

#### Scenario: Starter selection present at level 0–4
- **WHEN** ascension level is 0, 1, 2, 3, or 4
- **THEN** the starter keystone selection screen SHALL appear before floor 1

#### Scenario: Starter selection absent at level 5+
- **WHEN** ascension level is 5 or 6
- **THEN** the starter keystone selection screen SHALL NOT appear
