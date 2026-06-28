## Context

The existing damage pipeline is: raw_attack → technique bonuses → mastery → honed → keystone flat → consumable flat → surge → keystone multipliers → amplified. Garbage arrives via the enemy timer in `_tick_enemy_attacks()`, which generates packets and sets `after_receive_pending` for Counter Strike. There is no mechanism for techniques to fire reactively when garbage arrives, no per-technique persistent state, no damage-over-time, and no mastery XP modifiers.

## Goals / Non-Goals

**Goals:**
- Add a garbage-received callback system for techniques (Thrash, Retribution)
- Add per-technique persistent state that survives across rounds within a run (Blood Offering)
- Add an attack counter that resets when the enemy fires garbage (Relentless Assault)
- Add a damage-over-time (burn) system for enemies (Ignition)
- Add mastery XP multiplier and dynamic clear-type suppression (Master of None, Master of One)

**Non-Goals:**
- Visual effects for burn (simple number popups are sufficient)
- Multiple simultaneous DoT sources (only Ignition uses it)
- Persisting technique state across runs (run-scoped only)

## Decisions

### 1. Garbage-received signal on RunManager

A new signal `garbage_received(lines: int)` is emitted in `_tick_enemy_attacks()` after garbage packets are added (line ~615). Techniques connect via a new evaluation path: `_on_garbage_received(lines)` iterates techniques and fires effects.

- **Thrash**: effect_type `on_garbage_damage`. When garbage is received, immediately add `lines * bonus` to `quota_accumulated`. This is direct damage, not an attack event — it bypasses the normal pipeline.
- **Retribution**: effect_type `on_garbage_buff`. When garbage is received, set a pending flag with the bonus amount. Next clear adds that bonus and clears the flag. Reuses the `after_receive_pending` pattern from Counter Strike but with a configurable bonus.

### 2. Per-technique persistent state via RunState dictionary

`RunState` gets a new `technique_state: Dictionary` (keyed by technique ID, values are dictionaries). Reset on `RunState.reset()`. Blood Offering stores `{"bonus": 3}` initially; on enemy defeat, `bonus += 2`.

The evaluator reads `RunState.technique_state.get(t.id, {}).get("bonus", default)` for the attack value. The increment happens in RunManager's round-end success path.

### 3. Relentless Assault: attack counter with enemy-reset

A new field `relentless_counter: int` on `TechniqueRoundState`. Increments on each non-bonus clear. Resets to 0 when garbage is received (in the garbage-received handler). The technique's bonus is `base + relentless_counter`.

This is different from escalation — escalation fires every Nth attack, while relentless continuously scales and resets on enemy action.

### 4. Damage-over-time (Ignition)

When Ignition is active, damage from `_on_attack_generated()` is not applied instantly to `quota_accumulated`. Instead it is added to a `_burn_pool: float`. A timer ticks in `_process()` and drains the burn pool at a rate of `pool / 5.0` per second (linear drain over 5 seconds).

Implementation: `_burn_pool` is a float on RunManager. When Ignition is present, the normal `to_quota` from `_drain_attack()` is redirected to `_burn_pool` instead of `quota_accumulated`. A tick function `_tick_burn()` drains `_burn_pool` at the configured rate and applies the drained amount to `quota_accumulated`.

The ×1.5 multiplier is already handled by Burning Board's `all_attack_multiplier` on the keystone. Wait — Ignition is a separate keystone from Burning Board. Ignition needs its own `all_attack_multiplier = 1.5` plus a new `burn_duration: float = 5.0` property. The `all_attack_multiplier` handles the damage boost; `burn_duration` redirects the final damage to the burn pool.

### 5. Master of None: technique suppression + XP multiplier

`keystone.gd` gets `master_of_none: bool = false`. When set:
- At run start (in `start_run()`), all techniques are removed and `RunState.technique_capacity` is set to 0.
- `RunState` gets a `mastery_xp_multiplier: int = 1` field. Master of None sets it to 2. `grant_mastery_xp()` multiplies XP gain by this value.

### 6. Master of One: dynamic suppression

`keystone.gd` gets `master_of_one: bool = false`. When set, RunManager's `_is_attack_suppressed()` checks: find the mastery track with the highest level. If the current event_type does not match that track, suppress it. The ×3 multiplier is applied via a new check in `_apply_keystone_multipliers()` — if Master of One is active and the event matches the highest mastery track, multiply by 3.0.

## Risks / Trade-offs

**Burn pool visual feedback** → The enemy HP bar won't show damage instantly — it ticks down over 5 seconds. This might feel unresponsive. Mitigation: show a burn indicator (number or bar) near the enemy. Start simple with a label showing pending burn damage.

**Master of One + Master of None conflict** → If both are equipped, Master of None removes techniques (pointless with Master of One which wants mastery). This is a build trap but not a crash — both effects apply independently. No special handling needed.

**Blood Offering scaling** → +2 per kill could become very strong in long runs (10+ kills = +20+ base). The exponential HP scaling should counterbalance this, but worth monitoring via the damage log.

**Relentless Assault reset timing** → Resets when garbage packets are *generated*, not when they hit the board. This means the counter resets before the garbage is flushed, which is consistent with how `after_receive_pending` works.
