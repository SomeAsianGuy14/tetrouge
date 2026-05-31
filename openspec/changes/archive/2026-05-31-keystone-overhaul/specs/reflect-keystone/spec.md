## ADDED Requirements

### Requirement: Keystone resource supports garbage reflection ratio
The Keystone resource SHALL include a `reflect_on_flush: float` field (default `0.0`). When greater than zero, it causes a portion of flushed garbage lines to be dealt as damage to the enemy.

#### Scenario: Field defaults to zero
- **WHEN** a Keystone resource is created with no explicit `reflect_on_flush`
- **THEN** `reflect_on_flush` SHALL equal `0.0`

### Requirement: Reflect keystone deals damage equal to a fraction of flushed lines
During `RunManager._flush_pending_garbage()`, after each batch of garbage lines is sent to the player's board, if any active keystone has `reflect_on_flush > 0`, the system SHALL add `floor(lines_flushed × reflect_on_flush)` to `quota_accumulated` and update the HUD.

#### Scenario: Reflect converts half of flushed lines to damage
- **WHEN** 4 garbage lines are flushed to the board
- **AND** the player holds the Reflect keystone (`reflect_on_flush = 0.5`)
- **THEN** `floor(4 × 0.5) = 2` SHALL be added to `quota_accumulated`
- **THEN** the HUD SHALL be updated to reflect the new accumulated damage

#### Scenario: Reflect does not trigger when no garbage is flushed
- **WHEN** no garbage packets are pending at flush time
- **THEN** no damage SHALL be added via `reflect_on_flush`

#### Scenario: Reflect floors fractional lines
- **WHEN** 3 garbage lines are flushed
- **AND** `reflect_on_flush = 0.5`
- **THEN** `floor(1.5) = 1` damage SHALL be added (not 2)

### Requirement: Reflect keystone is independent of the boss Reflect modifier
The `reflect_on_flush` keystone mechanic operates on lines that physically reach the player's board. The boss Reflect modifier (`RoundConfig.reflect_ratio`) prevents garbage from being sent to the player entirely. The two systems SHALL NOT interact — when the boss modifier is active, no garbage is queued so the keystone never triggers.

#### Scenario: No double-reflection when boss and keystone both active
- **WHEN** the current boss applies the Reflection modifier
- **AND** the player holds the Reflect keystone
- **THEN** the boss modifier prevents garbage from entering `_garbage_packets`
- **THEN** `_flush_pending_garbage()` has nothing to flush so `reflect_on_flush` does not trigger
