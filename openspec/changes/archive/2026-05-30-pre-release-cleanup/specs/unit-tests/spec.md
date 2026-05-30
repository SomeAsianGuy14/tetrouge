## MODIFIED Requirements

### Requirement: Keystone tests cover attack modifiers, suppressions, multipliers, and economy
`tests/unit/test_keystones.gd` SHALL verify keystone pipeline behaviour using the current Technique API. Tests SHALL NOT reference removed fields (`flat_bonus_by_event`) or removed RunManager state (`pending_garbage`). Tests for garbage-flush reduction SHALL be rewritten to use `_garbage_packets` and verify board-side effects.

#### Scenario: per_technique_quad_bonus counts quad-tagged techniques
- **WHEN** a keystone with `per_technique_quad_bonus = 2` is active and the player owns 2 techniques with `tags` containing `"quad"`
- **THEN** `_apply_keystone_flat_bonuses(4, "quad")` returns `4 + (2 × 2) = 8`

#### Scenario: Garbage flush reduction test uses _garbage_packets
- **WHEN** `test_garbage_flush_reduction_reduces_flush_amount` runs
- **THEN** it populates `_rm._garbage_packets` with a packet of `lines = 5` (not `_rm.pending_garbage`) and asserts that after `_flush_pending_garbage()` the total lines remaining in `_garbage_packets` is reduced by the expected amount (accounting for `garbage_flush_reduction = 2` and a `capacity = 8 - 2 = 6`, so all 5 lines are flushed and `_garbage_packets` is empty; a larger packet would be needed to test partial flush)

#### Scenario: All existing keystone tests pass
- **WHEN** the full test suite runs
- **THEN** all tests in `test_keystones.gd` complete with no failures or errors
