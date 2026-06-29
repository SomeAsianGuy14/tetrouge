## ADDED Requirements

### Requirement: Debuff status display
A debuff status display SHALL appear on the left side of the board during combat. It SHALL show active burn and poison debuffs with their remaining duration.

#### Scenario: Burn debuff visible
- **WHEN** burn is active with 4 seconds remaining
- **THEN** a burn icon SHALL be visible with "4s" countdown text

#### Scenario: Permanent debuff display
- **WHEN** permanent poison is active
- **THEN** a poison icon SHALL be visible with no countdown (or "∞" symbol)

#### Scenario: No debuffs active
- **WHEN** neither burn nor poison is active
- **THEN** the debuff display area SHALL be empty/hidden

#### Scenario: Both debuffs active
- **WHEN** both burn and poison are active simultaneously
- **THEN** both icons SHALL be visible stacked vertically with their respective countdowns
