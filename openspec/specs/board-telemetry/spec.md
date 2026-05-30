## ADDED Requirements

### Requirement: TetrisBoard exposes summit height
`TetrisBoard` SHALL maintain a `summit_height: int` property representing the number of filled rows from the top down (i.e., 0 on an empty board; increases as the stack grows). The value SHALL be updated on every line-clear event and every piece placement.

#### Scenario: summit_height is 0 on empty board
- **WHEN** the board is empty
- **THEN** `TetrisBoard.summit_height` is 0

#### Scenario: summit_height reflects highest filled row
- **WHEN** the highest filled cell is 6 rows below the top of a 20-row board
- **THEN** `TetrisBoard.summit_height` is 6
