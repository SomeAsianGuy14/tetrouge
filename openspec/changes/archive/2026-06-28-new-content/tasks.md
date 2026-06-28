## 1. New technique effect types (code)

- [x] 1.1 Add `shield_on_clear` effect type to TechniqueEvaluator — returns 0 attack, emits `shield_per_clear:N` flag when matching clear type fires. Params: `on` (quad/tspin), `shield`
- [x] 1.2 Add `round_start_shield` to the no-op effect type list in TechniqueEvaluator. In RunManager `start_round()`, iterate techniques and add shield for any with `effect_type == "round_start_shield"`
- [x] 1.3 Add `first_n_attacks` effect type to TechniqueEvaluator — grants bonus when `attack_events_this_round < max_attacks`. Params: `max_attacks`, `bonus`
- [x] 1.4 Add `slow_clear_bonus` effect type to TechniqueEvaluator. Add `time_since_last_clear: float` to TechniqueRoundState (reset on clear, updated via delta in RunManager). Grant bonus when time exceeds threshold. Params: `seconds`, `bonus`
- [x] 1.5 Add `safe_distance_shield` effect type — emits shield flag when enemy timer is within the last N seconds of the interval. Needs enemy timer info on AttackContext or a new context field. Params: `seconds`, `shield`
- [x] 1.6 Add `concentrate` effect type to TechniqueEvaluator — flat bonus on all clears when `garbage_received_this_round == false`. Add `garbage_received_this_round: bool` to TechniqueRoundState, set true when garbage is received. Params: `bonus`
- [x] 1.7 Add `per_quad_technique` effect type to TechniqueEvaluator — count techniques with "quad" tag, multiply by bonus, only fire on quads. Params: `bonus_per_technique`. Same pattern as `per_tspin_technique`
- [x] 1.8 Add `double_barrel` effect type to TechniqueEvaluator — check if `last_clear_type` starts with "tspin" and current clear is also tspin. Params: `bonus`

## 2. New technique resources

- [x] 2.1 Create `guard.tres`: common, tags ["quad"], effect_type "shield_on_clear", params {"on": "quad", "shield": 2}
- [x] 2.2 Create `staff_spin.tres`: common, tags ["tspin"], effect_type "shield_on_clear", params {"on": "tspin", "shield": 2}
- [x] 2.3 Create `brace.tres`: common, tags ["general"], effect_type "round_start_shield", params {"shield": 2}
- [x] 2.4 Create `volley.tres`: common, tags ["general"], effect_type "first_n_attacks", params {"max_attacks": 3, "bonus": 2}
- [x] 2.5 Create `perfect_placement.tres`: common, tags ["precision"], effect_type "flat", params {"on": "perfect_clear", "bonus": 8}
- [x] 2.6 Create `slow_and_steady.tres`: rare, tags ["precision"], effect_type "slow_clear_bonus", params {"seconds": 5, "bonus": 4}
- [x] 2.7 Create `safe_distance.tres`: rare, tags ["general"], effect_type "safe_distance_shield", params {"seconds": 10, "shield": 4}
- [x] 2.8 Create `double_barrel.tres`: rare, tags ["tspin"], effect_type "double_barrel", params {"bonus": 6}
- [x] 2.9 Create `concentrate.tres`: rare, tags ["precision"], effect_type "concentrate", params {"bonus": 2}
- [x] 2.10 Create `whirlwind.tres`: rare, tags ["quad"], effect_type "per_quad_technique", params {"bonus_per_technique": 3}
- [x] 2.11 Create `charging_up_technique.tres`: epic, tags ["combo", "enhancement"], effect_type "post_combo_enhance", params {"enhancement": "amplified", "combo_threshold": 5}
- [x] 2.12 Add all 11 technique `.tres` files to ResourceRegistry preload list

## 3. New keystone properties (code)

- [x] 3.1 Add `coins_per_10_held: int = 0` to keystone.gd. In RunManager `_apply_keystone_economy()`, add `floor(Economy.coins / 10) * ks.coins_per_10_held` when nonzero
- [x] 3.2 Add `shield_multiplier: float = 1.0` to keystone.gd. At every site that increases `_garbage_shield`, apply `shield_gain = int(shield_gain * ks.shield_multiplier)` for keystones with multiplier > 1.0. Centralize in a helper `_apply_shield_gain(amount: int)`
- [x] 3.3 Add `shield_to_damage: bool = false` to keystone.gd. In the `_apply_shield_gain()` helper, when shield_to_damage is true, add the gain amount to `quota_accumulated`
- [x] 3.4 Add `enemy_interval_bonus: float = 0.0` to keystone.gd. In `_build_round_config()`, add this to `garbage_interval_min` and `garbage_interval_max`
- [x] 3.5 Add `kill_coins: int = 0` to keystone.gd. In RunManager round-end success path, credit coins for keystones with `kill_coins > 0`
- [x] 3.6 Add `technique_trade: bool = false` to keystone.gd. In Shop, when this flag is set, add a "Trade" button next to owned techniques that swaps for a same-rarity technique from the pool
- [x] 3.7 Add `technique_capacity_bonus: int = 0` to keystone.gd. In RunManager `start_run()`, add to `RunState.technique_capacity` after ascension modifiers
- [x] 3.8 Add `ramping_rhythm: bool = false` to keystone.gd. In RunManager, track `_ramping_rhythm_timer: float` (reset each round), increment by delta each tick, compute bonus as `1 + int(_ramping_rhythm_timer / 3.0)`. Apply in `compute_keystone_flat_bonus()` for all clear events when flag is set

## 4. New keystone resources

- [x] 4.1 Create `investment.tres`: category "Economic", coins_per_10_held = 1
- [x] 4.2 Create `hardened_steel.tres`: category "Defense", shield_multiplier = 2.0
- [x] 4.3 Create `shield_bash.tres`: category "Defense", shield_to_damage = true
- [x] 4.4 Create `cripple.tres`: category "Utility", enemy_interval_bonus = 5.0
- [x] 4.5 Create `nothing_to_waste.tres`: category "Economic", kill_coins = 20
- [x] 4.6 Create `equivalent_exchange.tres`: category "Utility", technique_trade = true
- [x] 4.7 Create `big_brain.tres`: category "Utility", technique_capacity_bonus = 2
- [x] 4.8 Create `ramping_rhythm.tres`: category "Risk", ramping_rhythm = true
- [x] 4.9 Add all 8 keystone `.tres` files to ResourceRegistry preload list

## 5. Shield gain centralization

- [x] 5.1 Create `_apply_shield_gain(amount: int)` helper in RunManager that: applies Hardened Steel multiplier, adds to `_garbage_shield`, updates shield bar, and triggers Shield Bash damage
- [x] 5.2 Replace all direct `_garbage_shield += N` sites with `_apply_shield_gain(N)` calls (start_shield, shield_per_clear flags, Best Defense, Last Stand, enhancement shield)

## 6. Testing

- [x] 6.1 Update `test_technique_rarity.gd` counts for new techniques (common +5, rare +5, epic +1)
- [x] 6.2 Add test: Guard grants 2 shield on quad, no shield on double
- [x] 6.3 Add test: Brace grants 2 shield at round start
- [x] 6.4 Add test: Volley grants +2 on first 3 attacks, 0 on 4th
- [x] 6.5 Add test: Perfect Placement grants +8 on perfect clear
- [x] 6.6 Add test: Double Barrel grants +6 on consecutive tspin, 0 on first tspin
- [x] 6.7 Add test: Concentrate grants +2 when no garbage received, 0 after garbage
- [x] 6.8 Add test: Whirlwind grants +3 per quad technique on quad
- [x] 6.9 Add test: Hardened Steel doubles shield gain
- [x] 6.10 Add test: Shield Bash deals damage equal to shield gained
- [x] 6.11 Add test: Cripple adds 5.0 to enemy garbage intervals
- [x] 6.12 Add test: Big Brain adds 2 to technique capacity
- [x] 6.13 Add test: Investment grants floor(coins/10) extra coins
- [x] 6.14 Run full test suite and fix any remaining failures
