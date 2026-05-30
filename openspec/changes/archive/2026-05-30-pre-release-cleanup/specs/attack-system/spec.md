## MODIFIED Requirements

### Requirement: AttackContext captures full attack snapshot
An `AttackContext` resource SHALL be constructed by `RunManager` after every attack-generating event. It SHALL contain:
- `lines_cleared: int`
- `combo: int` — combo count at the time of the clear
- `b2b: bool` — whether this clear continues a B2B chain
- `tspin: String` — `""`, `"mini"`, `"single"`, `"double"`, or `"triple"`
- `perfect_clear: bool`
- `garbage_sent: int` — base garbage before technique bonuses
- `board_height: int` — summit height from `TetrisBoard` telemetry
- `held_this_piece: bool` — whether the player used hold on the piece that caused this clear
- `piece_placement_count: int` — total pieces placed this round (for Escalation)
- `used_soft_drop: bool` — whether the piece was placed with soft drop
- `rotations_this_placement: int` — number of rotations performed before lock
- `locked_col: int` — the pivot x-coordinate of the piece at lock time (`-1` if not applicable)

#### Scenario: AttackContext populated after T-spin Double
- **WHEN** the player performs a T-spin Double
- **THEN** the constructed `AttackContext` has `lines_cleared=2`, `tspin="double"`, `b2b=true` (if B2B active), and `garbage_sent=4`

#### Scenario: locked_col set on piece lock
- **WHEN** a piece locks on the board
- **THEN** `AttackContext.locked_col` equals the piece's pivot x-coordinate at the moment of locking
