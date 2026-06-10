## 1. TechniqueEvaluator — Events Array

- [x] 1.1 In `TechniqueEvaluator.evaluate()`, add an `"events"` key to the return dict initialised as an empty Array
- [x] 1.2 In the attack and economy evaluation loops, after computing each technique's non-zero delta, append `{name: t.display_name, attack: attack_delta, coins: coins_delta}` to the events array
- [x] 1.3 Verify existing callers of `evaluate()` that only read `"attack_delta"` / `"coins_delta"` / `"flags"` are unaffected (no code changes needed, just confirm)

## 2. Floating Popups — Core

- [x] 2.1 Add a `_spawn_event_popup(text: String, color: Color, index: int, total: int)` helper to `RunManager`: creates a Label with the given color modulate, positions it above the board (offset by index to avoid stacking), adds it as a child, and drives a Tween that moves it upward and fades alpha to 0, then queue_free
- [x] 2.2 Add `_popup_schedule: Array` and `_popup_elapsed: float` fields to RunManager for staggered scheduling
- [x] 2.3 Add `_schedule_popups(events: Array, delay: float)` to RunManager: builds `_popup_schedule` entries as `{time: float, text: String, color: Color, id: String, index: int, total: int}` spread across the delay; if delay == 0.0, spawns all immediately
- [x] 2.4 No cap — pass all events to the schedule unchanged

## 3. Floating Popups — Technique color

- [x] 3.1 When building technique event entries for the schedule, assign color: `Color.WHITE` if `attack > 0`, `Color(1.0, 0.85, 0.0)` (gold) if `attack == 0` and `coins > 0`

## 4. Floating Popups — Keystone events

- [x] 4.1 Add `_pending_keystone_events: Array` field to RunManager, cleared at the start of each `_on_attack_generated()` call
- [x] 4.2 In `_apply_keystone_flat_bonuses()`, when a keystone contributes `bonus > 0`, append `{name: ks.display_name, bonus: bonus, color: Color(0.5, 0.8, 1.0)}` to `_pending_keystone_events`
- [x] 4.3 In `_apply_keystone_multipliers()`, compute `added = result - pre_mult_attack`; if `added > 0`, append `{name: ks.display_name, bonus: added, color: Color(0.5, 0.8, 1.0)}` to `_pending_keystone_events`; requires saving `pre_mult_attack` before the multiplier loop
- [x] 4.4 In `_on_attack_generated()`, after all modifier steps, convert `_pending_keystone_events` to popup-format dicts and merge with technique events before calling `_schedule_popups()`

## 5. Floating Popups — Integration

- [x] 5.1 In `RunManager._on_attack_generated()`, after `TechniqueEvaluator.evaluate()` and keystone event collection, call `_schedule_popups(combined_events, current_config.line_clear_delay)` (pass 0.0 if no config)
- [x] 5.2 In `RunManager._process()`, drain `_popup_schedule`: increment `_popup_elapsed` when board is active; for each entry where `_popup_elapsed >= entry.time`, spawn the popup and remove the entry
- [x] 5.3 In `RunManager._end_round()`, clear `_popup_schedule`, `_pending_keystone_events`, and reset `_popup_elapsed` to prevent stale popups after round end

## 6. HUD — Icon Scale Pop

- [x] 6.1 Add `pop_icon(id: String)` to `HUD`: searches both `keystone_icons` and `technique_icons` children for a node with metadata key `"id"` matching the given id; if found, runs a Tween that scales the node to `Vector2(1.35, 1.35)` over 0.08s then back to `Vector2(1.0, 1.0)` over 0.18s; no-op if not found
- [x] 6.2 In `RunManager._spawn_event_popup()`, after spawning the popup Label, call `hud.pop_icon(event.id)` if hud is not null (event dict must carry the originating technique or keystone id)
- [x] 6.3 Ensure the event dicts in `_popup_schedule` carry an `id` field (technique id or keystone id) so `_spawn_event_popup` can pass it to `hud.pop_icon`

## 7. HUD — Technique Pending Indicators

- [x] 6.1 Add `update_technique_states(states: Dictionary)` to `HUD`: for each technique icon, if `states[technique.id]` is true start a looping modulate pulse tween; if false kill any active tween and restore modulate to `Color.WHITE`
- [x] 6.2 Store a `_technique_tweens: Dictionary` (id → Tween) in HUD to track active pulse tweens so they can be killed individually
- [x] 6.3 Add `_build_technique_states() -> Dictionary` to `RunManager`: maps each technique's id to its corresponding TechniqueRoundState pending flag (escalation → escalation_pending, follow_up → follow_up_pending, patience → patience_pending, constant_pressure → constant_pressure_pending, flow_step → flow_step_pending, good_planning → good_planning_pending); returns false for techniques with no corresponding flag
- [x] 6.4 In `RunManager._update_round_state_after_eval()`, call `hud.update_technique_states(_build_technique_states())` after all state updates

## 7. HUD — Keystone Flash

- [x] 7.1 Add `flash_keystone(keystone_id: String)` to `HUD`: finds the icon label for the given id and runs a one-shot Tween that modulates to blue (`Color(0.5, 0.8, 1.0)`) then back to normal over ~0.2s; no-op if id not found
- [x] 7.2 Store keystone id on each icon label (e.g. as metadata) so `flash_keystone` can look it up
- [x] 7.3 In `RunManager._apply_keystone_flat_bonuses()`, when a keystone contributes `bonus > 0`, call `hud.flash_keystone(ks.id)` if hud is not null
- [x] 7.4 In `RunManager._apply_keystone_multipliers()`, when `mult != 1.0` for a keystone, call `hud.flash_keystone(ks.id)` if hud is not null

## 8. Testing

- [x] 8.1 Add test: `evaluate()` returns `"events"` array with one entry when one technique contributes non-zero attack
- [x] 8.2 Add test: `evaluate()` returns empty `"events"` array when no techniques contribute
- [x] 8.3 Add test: `evaluate()` excludes zero-contribution techniques from `"events"` when mixed with non-zero ones
- [x] 8.4 Add test: `evaluate()` existing `"attack_delta"` and `"coins_delta"` values are unchanged by the events addition (regression check)
- [x] 8.5 Add test: `_schedule_popups` with 0.0 delay produces entries all at time 0.0
- [x] 8.6 Add test: `_schedule_popups` with 6 events produces 6 schedule entries (no cap)

## 9. Run Tests

- [x] 9.1 Run the full GUT test suite (`game/tests/run_tests.tscn`) and confirm all tests pass
