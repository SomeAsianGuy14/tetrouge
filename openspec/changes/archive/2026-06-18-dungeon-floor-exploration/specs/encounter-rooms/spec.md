## ADDED Requirements

### Requirement: Encounter rooms present a text-based interaction and a leave option
Every encounter room SHALL display a descriptive text panel and one or more interaction choices. Every encounter room SHALL include a way for the player to leave the room without interacting (except rooms whose effect is instant and unavoidable: Head Trauma, Pickpocket). After leaving or completing an encounter, the dungeon map is shown.

#### Scenario: Leave option present on interactive rooms
- **WHEN** the player enters a Wishing Well, Altar, Library, Robbers, or Museum room
- **THEN** a "Leave" button is visible that returns the player to the dungeon map with no effect

#### Scenario: Instant rooms have no leave option
- **WHEN** the player enters a Head Trauma or Pickpocket room
- **THEN** the effect is applied immediately upon entry and the player is returned to the dungeon map

---

### Requirement: Wishing Well — coin-by-coin probability gamble
The Wishing Well SHALL allow the player to offer coins one at a time. Each offering costs 1 coin deducted from `Economy`. The probability of receiving a reward starts at 1% and increases by 1 percentage point after each unsuccessful offering. On a successful pull, a reward is granted and the probability resets to 1%. The player may stop and leave at any time. The reward type is determined by a weighted draw: 40% chance technique, 20% chance keystone, 40% chance consumable. Each reward item is drawn randomly from the respective pool using `RunState.rng`.

#### Scenario: First offering has 1% success chance
- **WHEN** the player makes their first offering at the Wishing Well
- **THEN** the success probability is 1%

#### Scenario: Probability increases after each failure
- **WHEN** the player has made N consecutive unsuccessful offerings
- **THEN** the current success probability is (N + 1)%

#### Scenario: Success resets probability to 1%
- **WHEN** a Wishing Well offering succeeds
- **THEN** the player receives a reward and the probability resets to 1%

#### Scenario: Player can continue after success
- **WHEN** a Wishing Well offering succeeds
- **THEN** the room remains open and the player may make additional offerings at the reset 1% probability

#### Scenario: Offering costs 1 coin
- **WHEN** the player makes a Wishing Well offering
- **THEN** 1 coin is deducted from Economy regardless of success or failure

#### Scenario: Reward type distribution
- **WHEN** a Wishing Well offering succeeds
- **THEN** a reward type is drawn: 40% technique, 20% keystone, 40% consumable

#### Scenario: Player leaves without offering
- **WHEN** the player chooses to leave the Wishing Well
- **THEN** no coins are spent and no reward is given

---

### Requirement: Altar (Technique) — sacrifice a technique for a blind random replacement
The Altar (Technique) room SHALL present the player with their current techniques and prompt them to sacrifice one. The player selects which technique to offer. Upon confirmation, the selected technique is removed from `RunState.techniques` and a random technique is granted from the full technique pool, drawn using `RunState.rng`. The replacement technique is not revealed before the sacrifice is confirmed. The player may leave without sacrificing.

#### Scenario: Player selects which technique to sacrifice
- **WHEN** the player is in an Altar (Technique) room
- **THEN** all currently owned techniques are listed as selectable options

#### Scenario: Sacrifice removes the technique and grants a random one
- **WHEN** the player confirms a sacrifice
- **THEN** the selected technique is removed and a randomly drawn technique is added to RunState.techniques

#### Scenario: Replacement technique is blind
- **WHEN** the player selects a technique to sacrifice
- **THEN** the replacement technique is NOT revealed before the player confirms

#### Scenario: Leave without sacrificing
- **WHEN** the player chooses to leave the Altar (Technique)
- **THEN** RunState.techniques is unchanged

#### Scenario: No techniques — cannot sacrifice
- **WHEN** the player has no techniques
- **THEN** the sacrifice option is not available (leave is the only option)

---

### Requirement: Altar (Keystone) — sacrifice a keystone for a blind random replacement
The Altar (Keystone) room SHALL present the player with their current keystones and prompt them to sacrifice one. Upon confirmation, the selected keystone is removed from `RunState.keystones` and a random keystone is granted, drawn using `RunState.rng`. The replacement is not revealed before confirmation. The player may leave without sacrificing.

#### Scenario: Player selects which keystone to sacrifice
- **WHEN** the player is in an Altar (Keystone) room
- **THEN** all currently owned keystones are listed as selectable options

#### Scenario: Sacrifice removes the keystone and grants a random one
- **WHEN** the player confirms a sacrifice
- **THEN** the selected keystone is removed and a randomly drawn keystone is added to RunState.keystones

#### Scenario: Replacement keystone is blind
- **WHEN** the player selects a keystone to sacrifice
- **THEN** the replacement keystone is NOT revealed before the player confirms

#### Scenario: Leave without sacrificing
- **WHEN** the player chooses to leave the Altar (Keystone)
- **THEN** RunState.keystones is unchanged

#### Scenario: No keystones — cannot sacrifice
- **WHEN** the player has no keystones
- **THEN** the sacrifice option is not available (leave is the only option)

---

### Requirement: Library — free technique pick from 10 random options
The Library room SHALL present 10 randomly drawn techniques from the full technique pool (drawn using `RunState.rng`). The player may choose one technique to add to `RunState.techniques` for free, or leave without picking. No coin cost is applied.

#### Scenario: 10 techniques are shown
- **WHEN** the player enters the Library
- **THEN** exactly 10 techniques are displayed as selectable options

#### Scenario: Choosing a technique adds it for free
- **WHEN** the player selects a technique from the Library list
- **THEN** the technique is added to RunState.techniques with no coin deduction

#### Scenario: Leave without picking
- **WHEN** the player leaves the Library without selecting
- **THEN** RunState.techniques is unchanged

#### Scenario: Library draw is seeded
- **WHEN** the Library is entered
- **THEN** the 10 displayed techniques are drawn using RunState.rng

---

### Requirement: Robbers — lose all gold or fight an Elite combat
The Robbers room SHALL present the player with two choices: surrender all coins (Economy is set to 0) or fight an Elite-tier enemy. If the player chooses to fight, a standard combat room is initiated using an Elite enemy drawn via the normal enemy-draw process. All normal combat rules apply (topout = run failure, quota must be met). The player cannot leave without choosing one of the two options.

#### Scenario: Surrendering sets Economy to 0
- **WHEN** the player chooses to lose all gold
- **THEN** Economy.coins is set to 0 and the dungeon map is shown

#### Scenario: Fighting initiates Elite combat
- **WHEN** the player chooses to fight
- **THEN** an Elite-tier Tetris combat begins using the normal combat flow

#### Scenario: No leave option
- **WHEN** the player is in the Robbers room
- **THEN** only the two choices (surrender gold / fight) are available; there is no leave option

#### Scenario: Combat failure ends the run
- **WHEN** the player chooses to fight and tops out before meeting quota
- **THEN** the run ends in failure (permadeath applies as normal)

---

### Requirement: Unfortunate Head Trauma — lose a random technique (with flavor fallback)
The Head Trauma room SHALL immediately remove one randomly selected technique from `RunState.techniques` upon entry. If the player has at least one technique, the room displays the message: "You seem to have forgotten [technique name]." If the player has no techniques, the effect is skipped and the room displays: "You seem to have forgotten something, but you don't think it was that important." In both cases the player is returned to the dungeon map after dismissing the message.

#### Scenario: Technique is removed at random
- **WHEN** the player enters a Head Trauma room and has at least one technique
- **THEN** one technique is selected at random using RunState.rng, removed from RunState.techniques, and the message "You seem to have forgotten [technique name]" is shown

#### Scenario: No techniques — effect skipped with fallback message
- **WHEN** the player enters a Head Trauma room and has no techniques
- **THEN** RunState.techniques is unchanged and the message "You seem to have forgotten something, but you don't think it was that important" is shown

#### Scenario: Dismissing message returns to dungeon map
- **WHEN** the player dismisses the Head Trauma message
- **THEN** the dungeon map is shown

---

### Requirement: Pickpocket — lose 50% of current gold
The Pickpocket room SHALL immediately reduce Economy.coins by floor(Economy.coins * 0.5) upon entry. The room SHALL display the amount lost as a numeric value before returning the player to the dungeon map. The player dismisses the message to return to the map.

#### Scenario: 50% of coins are deducted
- **WHEN** the player enters a Pickpocket room with 14 coins
- **THEN** 7 coins are deducted (floor(14 * 0.5)) and the message shows "−7 coins stolen"

#### Scenario: 0 coins — no change
- **WHEN** the player enters a Pickpocket room with 0 coins
- **THEN** Economy.coins remains 0 and the message shows "−0 coins stolen"

#### Scenario: Numeric loss is displayed
- **WHEN** the Pickpocket room triggers
- **THEN** the exact number of coins lost is shown to the player

---

### Requirement: Museum — preview a free keystone then decide
The Museum room SHALL draw one random keystone using `RunState.rng` and display it to the player with its name and description before they decide. The player may take the keystone for free (it is added to `RunState.keystones`) or leave without taking it.

#### Scenario: Keystone is shown before decision
- **WHEN** the player enters the Museum
- **THEN** one random keystone's name and description are visible before the player commits

#### Scenario: Taking the keystone adds it for free
- **WHEN** the player chooses to take the keystone
- **THEN** the keystone is added to RunState.keystones with no coin deduction

#### Scenario: Leaving does not grant the keystone
- **WHEN** the player leaves the Museum without taking the keystone
- **THEN** RunState.keystones is unchanged

#### Scenario: Museum draw is seeded
- **WHEN** the Museum room is entered
- **THEN** the displayed keystone is drawn using RunState.rng
