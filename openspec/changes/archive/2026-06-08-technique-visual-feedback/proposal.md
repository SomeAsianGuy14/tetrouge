## Why

Techniques and keystones currently fire as silent arithmetic — players see a damage number go up but have no way to know which technique caused it, which techniques are primed and ready, or what just resolved. Adding layered visual feedback makes the build feel alive: techniques announce themselves, pending states are visible, and the line clear delay (from `line-clear-delay`) becomes a genuine resolution window rather than dead time.

## What Changes

- **Floating popups**: When a technique contributes a non-zero attack or coin delta, a label animates upward from the board and fades out showing the technique name and delta (e.g. "+2 Escalation", "+1 coin Economy").
- **HUD pending indicators**: Technique icons in the HUD glow or pulse when their corresponding `TechniqueRoundState` pending flag is active (`escalation_pending`, `follow_up_pending`, `patience_pending`, `constant_pressure_pending`, `flow_step_pending`, `good_planning_pending`). Keystone icons briefly highlight when their bonus just fired.
- **Staggered resolution window**: During the line clear delay, popup events are spread across the delay duration rather than all spawning at once — each technique "resolves" in sequence, making the delay feel like a card-game stack.
- **TechniqueEvaluator extended**: `evaluate()` adds an `"events"` key to its return dict — an `Array` of `{name, attack, coins}` entries for each technique that contributed a non-zero result. Existing `"attack_delta"` and `"coins_delta"` totals are unchanged.
- RunManager gains a `technique_state_changed` signal (or equivalent method) so HUD can react to pending flag changes without polling.

**Depends on**: `line-clear-delay` must be implemented first (the resolution window requires the delay state to exist in TetrisBoard).

## Capabilities

### New Capabilities

- `technique-popups`: Floating labels that animate and fade when a technique fires, showing name and delta
- `technique-hud-indicators`: Per-technique and per-keystone HUD icon states that reflect armed/firing status in real time

### Modified Capabilities

- `technique-evaluator`: `evaluate()` return contract gains an `"events"` array of per-technique contributions alongside the existing totals

## Impact

- `game/scenes/game/technique_evaluator.gd` — extend return dict with `"events"` array
- `game/scenes/game/run_manager.gd` — spawn popups, expose pending state, schedule staggered events during line clear delay
- `game/scenes/game/hud.gd` — animate technique/keystone icons based on pending state and fire events
- New scene/script: `game/scenes/game/technique_popup.gd` (or inline Control) for the floating label
- `game/tests/unit/` — tests for the extended TechniqueEvaluator return format
