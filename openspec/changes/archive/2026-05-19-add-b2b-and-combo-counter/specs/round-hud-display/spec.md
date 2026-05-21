## ADDED Requirements

### Requirement: HUD exposes an update method for B2B and combo state
The HUD SHALL provide an `update_b2b_combo(is_b2b: bool, b2b_count: int, combo: int)` method that RunManager calls on every piece lock to keep the B2B indicator and combo counter current.

#### Scenario: Method drives B2B indicator visibility and chain length
- **WHEN** `update_b2b_combo(true, 3, -1)` is called
- **THEN** the B2B indicator is visible showing "B2B x3" and the combo counter is hidden

#### Scenario: Method drives combo counter visibility and text
- **WHEN** `update_b2b_combo(false, 0, 2)` is called
- **THEN** the combo counter is visible and shows "Combo x3", and the B2B indicator is hidden

#### Scenario: Method hides both when inactive
- **WHEN** `update_b2b_combo(false, 0, -1)` is called
- **THEN** both the B2B indicator and the combo counter are hidden
