## ADDED Requirements

### Requirement: Museum reworked to Treasure Chest
The Museum encounter SHALL be renamed to Treasure Chest. Its behavior SHALL remain the same: the player can claim a randomly determined keystone or leave.

#### Scenario: Treasure Chest displays keystone
- **WHEN** the player enters the Treasure Chest encounter
- **THEN** a random keystone SHALL be offered for the player to claim or leave

### Requirement: Pickpocket revenge combat
After a Pickpocket encounter steals the player's gold, a corresponding combat room SHALL be generated later in the floor path. Defeating the Pickpocket enemy in that combat SHALL return the stolen gold.

#### Scenario: Revenge room generated after pickpocket
- **WHEN** the player encounters a Pickpocket and loses gold
- **THEN** an uncleared combat room on the same floor SHALL be marked as a pickpocket revenge room

#### Scenario: Player defeats pickpocket enemy
- **WHEN** the player wins the pickpocket revenge combat
- **THEN** the stolen gold amount SHALL be awarded to the player

#### Scenario: No suitable room available
- **WHEN** all remaining combat rooms are already cleared when the pickpocket fires
- **THEN** no revenge room SHALL be created and the gold is lost

### Requirement: Head Trauma speed dodge
If the player owns a technique with a "speed" tag or a keystone with `instant_arr` or `instant_soft_drop`, the Head Trauma encounter SHALL display a dodge message and not remove any technique.

#### Scenario: Player has speed technique
- **WHEN** the player has a technique with "speed" tag and enters Head Trauma
- **THEN** a "You dodge the falling rock!" message SHALL be shown and no technique SHALL be removed

#### Scenario: Player has no speed items
- **WHEN** the player has no speed-tagged techniques or speed keystones
- **THEN** a random technique SHALL be removed as normal
