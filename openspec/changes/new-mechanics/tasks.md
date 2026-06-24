## 1. Garbage-received trigger system

- [ ] 1.1 Add `_on_garbage_received(lines: int)` method to RunManager. Call it in `_tick_enemy_attacks()` after garbage packets are generated (after the packet append block, before `_notify_attack_bar()`)
- [ ] 1.2 In `_on_garbage_received()`, iterate RunState.techniques and handle `on_garbage_damage` and `on_garbage_buff` effect types
- [ ] 1.3 Add `retribution_pending: bool` and `retribution_bonus: int` to TechniqueRoundState. Set in garbage handler, consumed on next clear
- [ ] 1.4 Add `on_garbage_damage` effect type to TechniqueEvaluator no-op list. Handle in RunManager: add `lines * bonus` directly to `quota_accumulated`
- [ ] 1.5 Add `on_garbage_buff` to TechniqueEvaluator. In evaluator, check `rs.retribution_pending` and return bonus on clear. Reset pending after use

## 2. Garbage-reactive technique resources

- [ ] 2.1 Create `thrash.tres`: common, tags ["garbage"], effect_type "on_garbage_damage", params {"bonus": 1}
- [ ] 2.2 Create `retribution.tres`: common, tags ["garbage"], effect_type "on_garbage_buff", params {"bonus": 3}
- [ ] 2.3 Add both to ResourceRegistry preload list

## 3. Per-technique persistent state

- [ ] 3.1 Add `technique_state: Dictionary = {}` to RunState, reset in `RunState.reset()`
- [ ] 3.2 Add `blood_offering` effect type to TechniqueEvaluator — read bonus from `RunState.technique_state.get(t.id, {}).get("bonus", params.get("base_bonus", 3))`, return on all clears
- [ ] 3.3 In RunManager round-end success path, iterate techniques with `blood_offering` effect_type and increment their `technique_state[t.id].bonus` by `params.get("kill_bonus", 2)`
- [ ] 3.4 Create `blood_offering.tres`: epic, tags ["risk"], effect_type "blood_offering", params {"base_bonus": 3, "kill_bonus": 2}
- [ ] 3.5 Add to ResourceRegistry preload list

## 4. Enemy-action-reset counter

- [ ] 4.1 Add `relentless_counter: int = 0` to TechniqueRoundState
- [ ] 4.2 In `_on_garbage_received()`, reset `relentless_counter` to 0
- [ ] 4.3 Add `relentless_assault` effect type to TechniqueEvaluator — return `params.get("base", 1) + rs.relentless_counter` on all clears
- [ ] 4.4 In `_update_round_state_after_eval()`, increment `relentless_counter` when a clear happens and player has a relentless_assault technique
- [ ] 4.5 Create `relentless_assault.tres`: epic, tags ["risk"], effect_type "relentless_assault", params {"base": 1}
- [ ] 4.6 Add to ResourceRegistry preload list

## 5. Damage-over-time (burn) system

- [ ] 5.1 Add `burn_duration: float = 0.0` property to keystone.gd
- [ ] 5.2 Add `_burn_pool: float = 0.0` and `_burn_active: bool = false` to RunManager
- [ ] 5.3 In `_build_round_config()`, detect Ignition keystone (burn_duration > 0) and set `_burn_active = true`
- [ ] 5.4 In `_on_attack_generated()`, when `_burn_active` is true, redirect `to_quota` to `_burn_pool` instead of `quota_accumulated`
- [ ] 5.5 Add `_tick_burn(delta: float)` to RunManager `_process()` — drain `_burn_pool` at `pool / burn_duration` per second, add drained amount to `quota_accumulated`, update enemy display, check for round end
- [ ] 5.6 Create `ignition.tres` keystone: all_attack_multiplier = 1.5, burn_duration = 5.0, category "Risk"
- [ ] 5.7 Add to ResourceRegistry preload list

## 6. Mastery keystones

- [ ] 6.1 Add `mastery_xp_multiplier: int = 1` to RunState, reset to 1 in `RunState.reset()`
- [ ] 6.2 Modify `RunState.grant_mastery_xp()` to multiply XP gain by `mastery_xp_multiplier`
- [ ] 6.3 Add `master_of_none: bool = false` and `master_of_one: bool = false` properties to keystone.gd
- [ ] 6.4 In RunManager `start_run()`, if any keystone has `master_of_none`: clear all techniques, set `RunState.technique_capacity = 0`, set `RunState.mastery_xp_multiplier = 2`
- [ ] 6.5 In RunManager `_is_attack_suppressed()`, if any keystone has `master_of_one`: find highest mastery track(s), suppress event types that don't match
- [ ] 6.6 In RunManager `_apply_keystone_multipliers()`, if `master_of_one` is active and event matches highest mastery track, multiply by 3.0
- [ ] 6.7 Create `master_of_none.tres` keystone: master_of_none = true, category "Mastery"
- [ ] 6.8 Create `master_of_one.tres` keystone: master_of_one = true, category "Mastery"
- [ ] 6.9 Add both to ResourceRegistry preload list

## 7. Testing

- [ ] 7.1 Add test: Thrash deals damage equal to garbage lines received
- [ ] 7.2 Add test: Retribution buffs next attack by +3 after garbage, does not stack
- [ ] 7.3 Add test: Blood Offering base bonus is 3, increases by 2 after kill
- [ ] 7.4 Add test: Blood Offering bonus persists across rounds
- [ ] 7.5 Add test: Relentless Assault counter increments per clear, resets on garbage
- [ ] 7.6 Add test: Ignition redirects damage to burn pool, burn drains over time
- [ ] 7.7 Add test: Master of None removes techniques and doubles mastery XP
- [ ] 7.8 Add test: Master of One suppresses non-highest mastery clears and triples highest
- [ ] 7.9 Add test: mastery_xp_multiplier of 2 grants 2 XP per clear
- [ ] 7.10 Update `test_technique_rarity.gd` counts for new techniques (common +2, epic +2)
- [ ] 7.11 Run full test suite and fix any remaining failures
