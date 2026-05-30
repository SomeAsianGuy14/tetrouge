## ADDED Requirements

### Requirement: Whirl keystone makes T-spins count as two combo steps
When the player owns the Whirl keystone, every T-spin (mini or full) SHALL advance the combo counter by 2 steps instead of 1. This applies regardless of how many lines were cleared.

Non-T-spin clears advance the combo counter as normal (1 step).

#### Scenario: T-spin advances combo by 2 with Whirl
- **WHEN** Whirl is owned and the player performs a T-spin that clears lines
- **THEN** the combo counter increments by 2

#### Scenario: Non-T-spin unaffected by Whirl
- **WHEN** Whirl is owned and the player performs a Tetris (no T-spin)
- **THEN** the combo counter increments by 1 as normal

#### Scenario: T-spin mini also advances by 2 with Whirl
- **WHEN** Whirl is owned and the player performs a T-spin mini
- **THEN** the combo counter increments by 2

### Requirement: Whirl keystone is available in the keystone pool
The Whirl keystone SHALL have `id = "whirl"`, `display_name = "Whirl"`, and be drawable from the keystone shop pool like any other keystone. It SHALL NOT appear in the technique pool.

#### Scenario: Whirl keystone has correct id
- **WHEN** the Whirl `.tres` file is loaded
- **THEN** its `id` field equals `"whirl"`
