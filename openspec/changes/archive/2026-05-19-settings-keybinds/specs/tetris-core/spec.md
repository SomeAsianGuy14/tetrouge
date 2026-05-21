## MODIFIED Requirements

### Requirement: DAS and ARR
Horizontal movement SHALL implement Delayed Auto Shift (DAS) and Auto Repeat Rate (ARR) following guideline defaults (DAS 167ms, ARR 33ms). Both values SHALL be configurable via a slider for coarse adjustment and a SpinBox for exact integer millisecond entry; the two controls SHALL stay in sync. ARR of 0 SHALL be treated as instant. Valid range: DAS 50–500ms, ARR 0–200ms.

#### Scenario: DAS triggers auto-repeat
- **WHEN** the player holds a horizontal direction for longer than DAS
- **THEN** the piece begins repeating movement at the ARR interval

#### Scenario: ARR zero causes instant movement to wall
- **WHEN** ARR is set to 0 and DAS has elapsed
- **THEN** the piece moves all the way to the wall in a single frame without looping indefinitely

#### Scenario: Player enters exact DAS value via SpinBox
- **WHEN** the player types 150 into the DAS SpinBox
- **THEN** DAS is set to exactly 150ms, the slider moves to match, and the value is saved to config

#### Scenario: Slider and SpinBox stay in sync
- **WHEN** the player drags the DAS slider
- **THEN** the DAS SpinBox updates to show the same integer value

#### Scenario: DAS value is clamped to valid range
- **WHEN** the player enters a value outside 50–500ms in the DAS SpinBox
- **THEN** the value is clamped to the nearest valid boundary automatically
