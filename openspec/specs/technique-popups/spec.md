## ADDED Requirements

### Requirement: Floating popup spawns when a technique contributes a non-zero result
When `TechniqueEvaluator.evaluate()` returns an `"events"` entry with a non-zero attack or coins delta, RunManager SHALL spawn a floating label near the board that animates upward and fades out.

#### Scenario: Popup shows technique name and attack delta
- **WHEN** a technique contributes +2 attack during a clear
- **THEN** a popup appears showing "+2 [TechniqueName]" and animates upward before fading out

#### Scenario: Popup shows technique name and coins delta
- **WHEN** a technique contributes +1 coin during a clear (and zero attack)
- **THEN** a popup appears showing "+1 coin [TechniqueName]" and animates upward before fading out

#### Scenario: Techniques with zero contribution produce no popup
- **WHEN** a technique evaluates to zero attack and zero coins for a given clear
- **THEN** no popup is spawned for that technique

### Requirement: Popups are positioned to avoid stacking
When multiple techniques fire in the same clear event, their popups SHALL be offset from each other so they are individually readable.

#### Scenario: Multiple technique popups offset vertically or horizontally
- **WHEN** two or more techniques contribute non-zero results in the same clear
- **THEN** each popup spawns at a distinct position (staggered offset) so they do not fully overlap

### Requirement: All firing events produce popups
RunManager SHALL spawn a popup for every technique and keystone that contributes a non-zero result. There is no cap.

#### Scenario: Many techniques fire
- **WHEN** 6 or more techniques contribute non-zero results in a single clear
- **THEN** a popup is spawned for each contributing technique and no error occurs

### Requirement: Popups spawn immediately when there is no line clear delay
When `RoundConfig.line_clear_delay` is 0.0, all popups for a clear event SHALL spawn simultaneously at the moment the clear resolves.

#### Scenario: Simultaneous popups with zero delay
- **WHEN** `line_clear_delay` is 0.0 and two techniques fire
- **THEN** both popups spawn in the same frame the clear completes

### Requirement: Popups are staggered across the line clear delay window
When `RoundConfig.line_clear_delay > 0.0`, popups SHALL be spread across the delay duration, with each popup spawning at `(index / count) * line_clear_delay` seconds after the delay begins.

#### Scenario: First popup spawns at the start of the delay
- **WHEN** `line_clear_delay` is 0.5s and there are 3 technique events
- **THEN** the first popup spawns immediately when the delay begins (t=0), the second at ~0.17s, the third at ~0.33s

#### Scenario: Schedule is discarded if round ends during delay
- **WHEN** the round ends (success or failure) while a popup schedule is pending
- **THEN** no further popups are spawned and no error occurs
