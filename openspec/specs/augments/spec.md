## ADDED Requirements

### Requirement: Augments are mechanic-level changes awarded after boss rounds
After clearing each Boss Blind, the player SHALL be presented with a choice of 3 Augments drawn from the Augment pool. The player picks exactly 1. The chosen Augment is applied permanently for the rest of the run.

#### Scenario: Augment selection after boss
- **WHEN** the Boss Blind round ends in success
- **THEN** 3 Augments are drawn from the pool and displayed; the player must choose one before proceeding

#### Scenario: Augment applies from next round
- **WHEN** the player selects an Augment
- **THEN** it is active for all subsequent rounds in the run

#### Scenario: Augment persists across all subsequent rounds
- **WHEN** a new round begins after an Augment was selected
- **THEN** the Augment's mechanic changes are applied via the RoundConfig passed to the TetrisBoard

### Requirement: Augments modify TetrisBoard configuration, not attack calculation
Augments SHALL change capabilities, information, or rules of the Tetris engine itself. They SHALL NOT directly modify attack output values — that is the role of Techniques.

#### Scenario: Augment does not affect attack math
- **WHEN** an Augment is active
- **THEN** base attack values from the attack-system spec are unchanged; only the board mechanics are affected

### Requirement: Augments are drawn without replacement within a run
The same Augment SHALL NOT be offered to the player twice in the same run.

#### Scenario: No duplicate Augment offers
- **WHEN** the pool is drawn for Augment selection
- **THEN** already-owned Augments are excluded from the draw

### Requirement: Starting Augment is drawn from a starter subset
At run start, one Augment is assigned from a curated starter pool designed to avoid overwhelming early interactions.

#### Scenario: Starting Augment from starter pool
- **WHEN** a new run begins
- **THEN** the starting Augment is drawn from the starter subset, not the full pool

### Requirement: Augment pool for launch
The following Augments SHALL be available in the initial build:

| Name | Effect | Starter Pool |
|------|--------|:---:|
| **Foresight** | Preview shows 7 next pieces instead of 5 | Yes |
| **Extended Buffer** | Hold piece stores 2 pieces instead of 1 | Yes |
| **Loose Lock** | Lock delay increased by 150ms | Yes |
| **Quick Swap** | Hold piece has no lockout (can re-hold immediately) | Yes |
| **Bag Shift** | 7-bag randomiser resets every 5 pieces instead of 7 | No |
| **Iron Will** | Lock delay maximum resets increased from 15 to 25 | Yes |
| **Deep Sight** | Soft drop distance is shown numerically on the ghost piece | No |
| **Second Wind** | Once per round, if quota is unmet at 10 seconds remaining, timer pauses for 5 seconds | No |

#### Scenario: Foresight increases preview count
- **WHEN** Foresight is the active Augment
- **THEN** the TetrisBoard preview queue displays 7 pieces

#### Scenario: Extended Buffer allows two held pieces
- **WHEN** Extended Buffer is active and the player holds a piece while the hold slot is occupied
- **THEN** both pieces are stored; the player can swap to either on the next hold action

#### Scenario: Quick Swap removes hold lockout
- **WHEN** Quick Swap is active
- **THEN** the player can hold immediately after a hold swap without waiting for the next piece to lock

### Requirement: Augment selection screen presents each option as a card with separated name and description
The augment selection UI SHALL display each augment option as a distinct card. Each card SHALL present the augment name and its description as visually separated elements.

#### Scenario: Augment card layout
- **WHEN** the augment selection screen is shown
- **THEN** each of the 3 options is rendered as a card with the augment name and description in separate, visually distinct areas of the card
