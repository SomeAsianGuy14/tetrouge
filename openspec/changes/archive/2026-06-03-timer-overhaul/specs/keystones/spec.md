## MODIFIED Requirements

### Requirement: Golden Watch reveals the round timer and earns coins per remaining second
Golden Watch SHALL set `RoundConfig.show_timer = true` at round build time, making the HUD timer visible. At round end, Golden Watch grants 1 coin per 5 seconds remaining on the timer (unchanged mechanic, new description). Description: "Gain a 3-minute timer. At round end, earn 1 coin for every 5 seconds remaining on the timer."

#### Scenario: Golden Watch makes timer visible
- **WHEN** the player holds Golden Watch and a round begins
- **THEN** the HUD timer label SHALL be visible for that round

#### Scenario: Golden Watch grants coins at round end
- **WHEN** the round ends successfully with time remaining
- **AND** the player holds Golden Watch
- **THEN** `floor(round_timer / 5)` coins SHALL be added

### Requirement: Blessed Stone description updated
Blessed Stone's description SHALL reflect that it only triggers on topout, not timeout. Suggested: "The first time your board tops out, it is cleared and you gain 2 minutes."

#### Scenario: Blessed Stone description does not mention timer death
- **WHEN** Blessed Stone is displayed
- **THEN** the description SHALL reference topping out as the trigger condition, not time running out
