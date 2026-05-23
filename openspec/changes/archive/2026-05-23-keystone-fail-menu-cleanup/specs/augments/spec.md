## ADDED Requirements

### Requirement: Augment selection screen presents each option as a card with separated name and description
Each of the three offered Augments SHALL be displayed as a card where the augment name and its description are visually distinct elements — the name SHALL be prominent and the description SHALL appear below it as secondary text.

#### Scenario: Augment name is visually prominent on each card
- **WHEN** the augment selection screen is shown
- **THEN** each card displays the augment's name in a larger or bold label at the top of the card

#### Scenario: Augment description is readable below the name
- **WHEN** the augment selection screen is shown
- **THEN** each card displays the augment's description in a smaller label beneath the name, with text wrapping enabled

#### Scenario: Selecting a card works the same as before
- **WHEN** the player clicks anywhere on an augment card
- **THEN** that augment is chosen and the selection screen closes
