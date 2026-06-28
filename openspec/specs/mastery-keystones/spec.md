## ADDED Requirements

### Requirement: Master of None keystone
Master of None SHALL remove all techniques at run start and set technique capacity to 0 (preventing technique acquisition). Mastery XP gains SHALL be doubled.

#### Scenario: Techniques removed at run start
- **WHEN** the player starts a run with Master of None
- **THEN** all techniques SHALL be removed and technique capacity SHALL be 0

#### Scenario: Cannot gain techniques
- **WHEN** the player visits a shop or encounter that offers techniques
- **THEN** technique acquisition SHALL be blocked

#### Scenario: Double mastery XP
- **WHEN** the player performs a quad with Master of None
- **THEN** 2 XP SHALL be granted to the quad mastery track instead of 1

### Requirement: Master of One keystone
Master of One SHALL identify the player's highest mastery track. Clears matching that track SHALL deal ×3 damage. All other clear types SHALL deal no damage.

#### Scenario: Highest mastery clear deals triple
- **WHEN** the player's highest mastery is quads at level 4 and they perform a quad
- **THEN** the quad SHALL deal ×3 damage

#### Scenario: Non-highest mastery clear suppressed
- **WHEN** the player's highest mastery is quads and they perform a t-spin
- **THEN** the t-spin SHALL deal 0 damage

#### Scenario: Tie in mastery levels
- **WHEN** two mastery tracks are tied for highest (e.g. quads and doubles both at level 3)
- **THEN** both clear types SHALL deal ×3 damage and all others SHALL be suppressed

### Requirement: Mastery XP multiplier
`RunState` SHALL support a `mastery_xp_multiplier: int` field (default 1). `grant_mastery_xp()` SHALL multiply XP gains by this value.

#### Scenario: Multiplier of 2
- **WHEN** mastery_xp_multiplier is 2 and the player clears a quad
- **THEN** 2 XP SHALL be granted to the quad track instead of 1
