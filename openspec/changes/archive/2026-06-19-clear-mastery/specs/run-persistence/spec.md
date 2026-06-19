## MODIFIED Requirements

### Requirement: RunSave serializes mastery state
RunSave SHALL serialize the mastery Dictionary under a `"mastery"` section in the save config. On load, missing mastery data SHALL default to all tracks at xp=0, level=0.

#### Scenario: Save includes mastery data
- **WHEN** the game saves mid-run with quad mastery at level 3, xp 2
- **THEN** the save file contains mastery data with quad={xp:2, level:3}

#### Scenario: Load with no mastery section defaults to zero
- **WHEN** loading a save file from before the mastery system was added
- **THEN** all mastery tracks initialize to xp=0, level=0
