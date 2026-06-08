## Why

Two damage calculation bugs cause techniques to deal incorrect attack values: the `hybrid_reactor` keystone fires its tag bonus on b2b and combo bonus signals (up to 3× the intended bonus per clear), and the `every_nth_clear` evaluator fires one clear too late due to an off-by-one in the counter check. Both produce observable, reproducible misbehaviour during normal play.

## What Changes

- **`hybrid_reactor` tag bonus**: Restrict the per-attack tag bonus to primary clear events only (not b2b/combo bonus events). A B2B quad with an active combo currently fires the tag bonus three times per clear; it should fire once.
- **`every_nth_clear` counter check**: Fix off-by-one so the bonus fires on the Nth clear (e.g. 4th, 8th, 12th) rather than the (N+1)th (5th, 9th, 13th). The counter is incremented after evaluation, so the check must account for that.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hybrid-reactor`: Tag bonus now fires once per primary clear event, not once per `attack_generated` signal (which includes b2b and combo bonus signals).
- `technique-evaluator`: `every_nth_clear` fires on clear N (4, 8, 12…) instead of clear N+1 (5, 9, 13…).

## Impact

- `game/scenes/game/run_manager.gd` — add `is_bonus_event` guard to the tag bonus block
- `game/scenes/game/technique_evaluator.gd` — fix `every_nth_clear` condition
- `game/tests/unit/test_keystones.gd` — update/add hybrid_reactor multi-signal test
- `game/tests/unit/test_technique_system.gd` — add `every_nth_clear` timing test
