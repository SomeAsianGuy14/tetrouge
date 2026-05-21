## ADDED Requirements

### Requirement: Attack system tests cover all clear types and bonuses
`tests/unit/test_attack_system.gd` SHALL verify base attack values for every clear type, B2B bonus application, B2B chain reset, combo table values, and perfect clear override.

#### Scenario: Tetris base attack is 4
- **WHEN** `_calculate_attack` is called with clear_type "tetris", no B2B, combo -1
- **THEN** the returned attack value is 4

#### Scenario: T-spin double base attack is 4
- **WHEN** `_calculate_attack` is called with clear_type "tspin_double", no B2B, combo -1
- **THEN** the returned attack value is 4

#### Scenario: B2B bonus adds 1 to qualifying clear
- **WHEN** a Tetris follows another Tetris (B2B active)
- **THEN** the returned attack value is 5

#### Scenario: B2B resets on non-qualifying clear
- **WHEN** a Double is played after a Tetris
- **THEN** the subsequent Tetris receives no B2B bonus

#### Scenario: Perfect clear returns 10 regardless of clear type
- **WHEN** `_calculate_attack` is called with is_pc = true
- **THEN** the returned attack value is 10

#### Scenario: Combo step 4 adds 2 bonus attack
- **WHEN** combo counter is at step 4
- **THEN** the combo bonus is 2

### Requirement: Economy tests cover payout, interest, and spending
`tests/unit/test_economy.gd` SHALL verify base payout, interest calculation at various balances, interest cap enforcement, spending success/failure, and speed bonus calculation.

#### Scenario: Interest on 12 coins is 2
- **WHEN** `apply_interest()` is called with a balance of 12 and a cap of 5
- **THEN** 2 coins are added and the balance becomes 14

#### Scenario: Interest is capped at 5 for large balances
- **WHEN** `apply_interest()` is called with a balance of 50 and a cap of 5
- **THEN** exactly 5 coins are added regardless of balance

#### Scenario: Spending more than balance fails
- **WHEN** `spend_coins(10)` is called with a balance of 7
- **THEN** the call returns false and the balance remains 7

#### Scenario: pay_round credits base plus speed plus technique income
- **WHEN** `pay_round(4, 2, 1)` is called
- **THEN** 7 coins are added to the balance

### Requirement: Bag randomiser tests verify 7-bag distribution
`tests/unit/test_bag_randomizer.gd` SHALL verify that every piece type appears at least once in the first 7 draws, and that 14 draws produce each piece exactly twice.

#### Scenario: All 7 pieces appear in first 7 draws
- **WHEN** 7 pieces are drawn from a fresh BagRandomizer
- **THEN** the set of drawn types equals {I, O, T, S, Z, J, L}

#### Scenario: Bag shift interval draws 5 then refills
- **WHEN** BagRandomizer is created with reset_interval=5 and 5 pieces are drawn
- **THEN** the 6th draw triggers a new shuffle

### Requirement: RoundConfig quota scaling tests verify the formula
`tests/unit/test_round_config.gd` SHALL verify `RunState.calculate_quota()` output at known ante/round combinations.

#### Scenario: Ante 1 Small Blind quota is 20
- **WHEN** `calculate_quota(1, 0)` is called
- **THEN** the result is 20

#### Scenario: Ante 5 Boss Blind quota is 104
- **WHEN** `calculate_quota(5, 3)` is called
- **THEN** the result is 104

### Requirement: T-spin detection tests verify 3-corner rule
`tests/unit/test_tspin_detection.gd` SHALL verify T-spin detection with a constructed grid that satisfies the 3-corner rule, and rejection when fewer than 3 corners are occupied.

#### Scenario: 3 occupied corners classifies as T-spin
- **WHEN** a T-piece locks after rotation with 3 diagonal corners occupied by blocks or walls
- **THEN** the clear is classified as a T-spin type

#### Scenario: Non-rotated T lock is not a T-spin
- **WHEN** a T-piece locks without a preceding rotation (last_move_was_rotation = false)
- **THEN** the clear is classified as a standard clear type
