## MODIFIED Requirements

### Requirement: DAS and ARR
Horizontal movement SHALL implement Delayed Auto Shift (DAS) and Auto Repeat Rate (ARR) following guideline defaults (DAS 167ms, ARR 33ms). Both values SHALL be configurable. ARR of 0 SHALL be treated as instant (piece moves to wall in a single frame).

#### Scenario: DAS triggers auto-repeat
- **WHEN** the player holds a horizontal direction for longer than DAS
- **THEN** the piece begins repeating movement at the ARR interval

#### Scenario: ARR zero causes instant movement to wall
- **WHEN** ARR is set to 0 and DAS has elapsed
- **THEN** the piece moves all the way to the wall in a single frame without looping indefinitely

## ADDED Requirements

### Requirement: Clockwise rotation is bound to X key in addition to Up arrow
The `rotate_cw` input action SHALL accept both the Up arrow key and the X key as valid triggers. Either key SHALL produce the same clockwise rotation.

#### Scenario: X key rotates clockwise
- **WHEN** the player presses X
- **THEN** the current piece rotates clockwise, including SRS wall kicks

#### Scenario: Up arrow still rotates clockwise
- **WHEN** the player presses Up arrow
- **THEN** the current piece rotates clockwise (unchanged from before)

### Requirement: Soft drop is bound to S key in addition to Down arrow
The `soft_drop` input action SHALL accept both the Down arrow key and the S key. Either key held down SHALL accelerate piece gravity to 20× normal speed.

#### Scenario: S key activates soft drop
- **WHEN** the player holds S
- **THEN** the active piece falls at 20× normal gravity

#### Scenario: Releasing S deactivates soft drop
- **WHEN** the player releases S (and Down is not also held)
- **THEN** the piece returns to normal gravity speed
