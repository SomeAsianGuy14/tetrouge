## ADDED Requirements

### Requirement: Specific techniques are amplified by their matching mastery track
Techniques with a specific `on` field (`"quad"`, `"tspin_double"`, `"tspin_mini"`) SHALL have their flat bonus increased by `floor(matching_mastery_level / 2)`.

#### Scenario: Hone amplified by quad mastery
- **WHEN** the player owns Hone (on="quad", bonus=2) and has quad mastery level 6
- **THEN** Hone contributes +2 + floor(6/2) = +5 attack on quad clears

#### Scenario: Dualcasting amplified by T-Spin Double mastery
- **WHEN** the player owns Dualcasting (on="tspin_double", bonus=3) and has tspin_double mastery level 4
- **THEN** Dualcasting contributes +3 + floor(4/2) = +5 on T-Spin Doubles

#### Scenario: Mastery level 1 does not amplify (floor rounds down)
- **WHEN** the player owns Hone and has quad mastery level 1
- **THEN** Hone contributes +2 + floor(1/2) = +2 (no amplification)

### Requirement: Broad techniques use the highest matching mastery track
Techniques with a broad `on` field SHALL use the highest mastery level among matching tracks for amplification:
- `"all_clear"` → highest of all 7 tracks
- `"tspin"` → highest of tspin_single, tspin_double, tspin_triple
- `"multiline"` → highest of double, triple, quad

#### Scenario: Brass Knuckles uses highest track across all types
- **WHEN** the player owns Brass Knuckles (on="all_clear", bonus=1) with singles mastery 2, quads mastery 8
- **THEN** Brass Knuckles contributes +1 + floor(8/2) = +5 on all clears

#### Scenario: Spinning Strike uses highest T-spin track
- **WHEN** the player owns Spinning Strike (on="tspin", bonus=2) with tspin_single mastery 0, tspin_double mastery 6, tspin_triple mastery 2
- **THEN** Spinning Strike contributes +2 + floor(6/2) = +5 on all T-spins

### Requirement: B2B-gated and perfect clear techniques are not amplified
Techniques with `require_b2b: true` or `on="perfect_clear"` SHALL NOT receive mastery amplification.

#### Scenario: Back to Back Pressure not amplified
- **WHEN** the player owns Back to Back Pressure (on="quad", require_b2b=true) with quad mastery level 10
- **THEN** Back to Back Pressure contributes its base bonus only, no mastery amplification

#### Scenario: Perfect Spark not amplified
- **WHEN** the player owns Perfect Spark (on="perfect_clear") with any mastery levels
- **THEN** Perfect Spark contributes its base bonus only
