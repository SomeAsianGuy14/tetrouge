## Context

After the balance pass, there are 26 common, 19 rare, and 8 epic techniques, plus ~37 keystones. The existing infrastructure supports flat damage bonuses, shield grants via flags, piece enhancement grants, economy effects, and various conditional triggers. This change adds new items that mostly map to existing patterns, with a few requiring new effect types or keystone properties.

## Goals / Non-Goals

**Goals:**
- Add 11 new techniques and 8 new keystones
- Use existing effect patterns where possible (flat bonuses, flags, economy)
- Add new effect types only where the existing system can't express the behavior
- Keep all tests passing with updated count assertions

**Non-Goals:**
- Engine-level systems like DoT, persistent technique state, or garbage-received triggers (those are in the new-mechanics change)
- UI changes beyond the existing technique/keystone display patterns

## Decisions

### 1. Techniques using existing patterns (data-only)

These need only a `.tres` file — no new code:
- **Perfect Placement**: `effect_type = "flat"`, `params = {"on": "perfect_clear", "bonus": 8}` — identical to Perfect Spark pattern
- **Double Barrel**: `effect_type = "flat"`, `params = {"on": "tspin", "require_consecutive_tspin": true, "bonus": 6}` — needs a consecutive tspin check, but can use `last_clear_type` from round state

### 2. Techniques needing new effect types

- **Guard** / **Staff Spin**: Shield-on-clear. New effect type `shield_on_clear` — returns 0 attack but emits a `shield_per_clear:N` flag when the matching clear type fires. Params: `{"on": "quad"/"tspin", "shield": 2}`.
- **Brace**: Round-start shield. New effect type `round_start_shield` — handled outside the evaluator in `start_round()`, adds shield at round start. Params: `{"shield": 2}`.
- **Volley**: First-N-attacks bonus. New effect type `first_n_attacks` — grants bonus on the first N clears each round. Params: `{"max_attacks": 3, "bonus": 2}`. Uses `attack_events_this_round` counter.
- **Slow and Steady**: Time-since-last-clear bonus. New effect type `slow_clear_bonus` — grants bonus if the time since the previous piece lock exceeds a threshold. Needs a timer tracked in round state. Params: `{"seconds": 5, "bonus": 4}`.
- **Safe Distance**: Shield during enemy attack cooldown. New effect type `safe_distance_shield` — grants shield if enemy attack bar is in the last N seconds of its interval. Params: `{"seconds": 10, "shield": 4}`. Checked via RunManager's `_enemy_timer` vs garbage interval.
- **Concentrate**: No-garbage-received bonus. New effect type `concentrate` — flat bonus on all clears if no garbage has been received this combat. Params: `{"bonus": 2}`. Needs a `garbage_received_this_round: bool` flag on round state.
- **Whirlwind**: Per-quad-technique scaling. New effect type `per_quad_technique` — counts techniques with "quad" tag and multiplies by bonus. Params: `{"bonus_per_technique": 3}`. Only fires on quads. Same pattern as Enchant's `per_tspin_technique`.
- **Charging Up (technique)**: Combo-triggered enhancement grant. Effect type `post_combo_enhance` already exists (was Backpedaling's old type, still in the evaluator). Params: `{"enhancement": "amplified", "combo_threshold": 5}`.

### 3. Keystones needing new properties

- **Investment**: New economy property `coins_per_10_held: int`. Applied in `_apply_keystone_economy()`: grants `floor(Economy.coins / 10) * coins_per_10_held`.
- **Hardened Steel**: New property `shield_multiplier: float = 1.0`. Applied wherever `_garbage_shield` is increased — multiply the gain amount. Default 1.0 (no change).
- **Shield Bash**: New property `shield_to_damage: bool = false`. When shield is gained, the gain amount is also added to `quota_accumulated`.
- **Cripple**: New property `enemy_interval_bonus: float = 0.0`. Applied in `_build_round_config()` — added to garbage interval min/max.
- **Nothing to Waste**: New property `kill_coins: int = 0`. Applied when a combat is won — grants bonus coins.
- **Equivalent Exchange**: New property `technique_trade: bool = false`. The shop checks for this flag — if set, shows a "Trade" option on owned techniques that swaps for a same-rarity technique from the pool.
- **Big Brain**: New property `technique_capacity_bonus: int = 0`. Applied in `start_run()` after ascension modifiers.
- **Ramping Rhythm**: New property `ramping_rhythm: bool = false` + `ramping_rhythm_bonus: int = 1` + `ramping_rhythm_interval: float = 3.0`. RunManager tracks a timer and incrementing bonus. Applied as a flat bonus in the keystone flat bonus path.

### 4. Shield multiplier (Hardened Steel) is applied at the gain site, not the spend site

Every place that adds to `_garbage_shield` checks for keystones with `shield_multiplier > 1.0` and multiplies the gain. This covers: start_shield, shield_per_clear flags, enhancement shield, Best Defense shield, Last Stand shield. Shield Bash hooks into the same sites — after the multiplied gain is computed, it adds the gain to quota.

## Risks / Trade-offs

**Shield Bash + Hardened Steel combo** → Hardened Steel doubles the shield gain, Shield Bash converts gain to damage. Together: gain 2 shield → Hardened Steel makes it 4 → Shield Bash deals 4 damage. This is strong but requires two keystone slots, which limits other build options.

**Ramping Rhythm timer** → Another per-tick timer in RunManager. Low cost since it's just a float increment and integer division.

**Equivalent Exchange shop integration** → The shop needs a new trade flow: select owned technique → show pool of same-rarity techniques → swap. This is the most complex UI work in this batch.
