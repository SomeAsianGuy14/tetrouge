## ADDED Requirements

### Requirement: Ignition keystone burn system
Ignition SHALL multiply all attack damage by ×1.5 but redirect the damage to a burn pool. The burn pool SHALL drain linearly over 5 seconds, applying the drained amount to the enemy's quota.

#### Scenario: Damage redirected to burn
- **WHEN** the player deals 10 damage with Ignition active
- **THEN** 15 damage (10 × 1.5) SHALL be added to the burn pool instead of applying instantly

#### Scenario: Burn drains over time
- **WHEN** the burn pool has 15 damage
- **THEN** 3 damage per second SHALL be applied to the enemy quota over 5 seconds

#### Scenario: Multiple attacks stack burn
- **WHEN** the player deals damage twice before the first burn completes
- **THEN** both amounts SHALL be added to the burn pool and drain together

#### Scenario: Burn continues after clear
- **WHEN** no more clears are performed but burn pool has remaining damage
- **THEN** the burn SHALL continue draining until the pool is empty
