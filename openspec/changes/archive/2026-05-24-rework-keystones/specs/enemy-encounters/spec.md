## ADDED Requirements

### Requirement: Daze keystone stuns the enemy on quad clears
When the player owns the Daze keystone and a `"tetris"` attack event is processed, `RunManager` SHALL extend the enemy garbage timer by `daze_stun_seconds` (2.0 seconds). This delays the next garbage row from entering the attack buffer.

#### Scenario: Quad clear extends enemy timer by 2 seconds
- **WHEN** Daze is owned and the player sends a quad
- **THEN** the enemy garbage timer's remaining time is increased by 2 seconds

#### Scenario: Daze does not fire on non-quad clears
- **WHEN** Daze is owned and the player sends a T-spin double
- **THEN** the enemy garbage timer is not extended

#### Scenario: Multiple consecutive quads stack the stun
- **WHEN** Daze is owned and the player sends two quads in succession before the timer fires
- **THEN** the enemy timer is extended by 4 seconds total (2 seconds per quad)
