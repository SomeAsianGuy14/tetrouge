## Context

`RunManager._on_attack_generated` is called once per `attack_generated` signal. A single line clear can fire up to three signals: the primary event (`"single"`, `"quad"`, etc.), an optional `"b2b"` bonus event, and an optional `"combo"` bonus event. The `is_bonus_event` flag already gates technique evaluation and boss-modifier quota checks to primary events only, but the `hybrid_reactor` tag bonus block has no such guard and runs for all three signals.

The `every_nth_clear` evaluator reads `rs.clears_this_round` before it is incremented (the increment happens in `_update_round_state_after_eval`, after evaluation). This means the Nth clear is evaluated when the counter is N−1, so the modulo check `(N−1) % n == 0` fires at N=n+1 instead of N=n.

## Goals / Non-Goals

**Goals:**
- `hybrid_reactor` tag bonus fires exactly once per line-clear event (primary signal only).
- `every_nth_clear` fires on clear N, N×2, N×3… as the technique description states.
- Existing tests continue to pass; new tests cover the corrected behaviour.

**Non-Goals:**
- Refactoring the multi-signal architecture (b2b/combo as separate signals). That is a broader change deferred to a future proposal.
- Changing any damage numbers or game-balance tuning.
- Fixing any other technique timing issues identified during exploration (e.g. `combo_spark` semantics).

## Decisions

**Fix 1 — Guard the tag bonus block with `is_bonus_event`**

Add `and not is_bonus_event` to the `if modified > 0` condition at `run_manager.gd:513`. This is the same pattern already used for technique evaluation (`if not is_bonus_event and _technique_round_state`) and the boss-modifier filter. It is the minimal, surgical fix.

Alternative considered: Add the guard inside the tag bonus loop. Rejected — the outer condition is cleaner and consistent with existing guards.

**Fix 2 — Pre-increment `clears_this_round` before evaluation, OR adjust the condition**

Two options:
- **A** Move `rs.clears_this_round += 1` before the `TechniqueEvaluator.evaluate` call. This makes the counter reflect the current clear at eval time. Requires no change to `technique_evaluator.gd`.
- **B** Change the condition in `technique_evaluator.gd` from `rs.clears_this_round % n == 0` to `(rs.clears_this_round + 1) % n == 0`. Localises the fix to the evaluator; the counter stays post-increment everywhere else.

**Decision: Option B** — The post-increment convention is used consistently for all other round-state counters (`tetris_count`, `clears_this_round`). Changing just the evaluator condition is less invasive and keeps the update ordering consistent. The `> 0` guard becomes `>= 0` (or can be dropped, since `(0 + 1) % n` is never 0 for any reasonable n ≥ 2).

## Risks / Trade-offs

- **Balance impact of `every_nth_clear` fix**: The bonus now fires one clear earlier per cycle (4th instead of 5th). For `attack_battery` (+3 every 4 clears) this is a modest buff — players who do many clears per round get roughly one extra trigger. Acceptable; the previous behaviour was a bug.
- **Test coverage gap**: The existing `test_hybrid_reactor_*` tests exercise the calculation inline, not through `_on_attack_generated`. The new test should exercise the full handler path or at least assert the guard is in place at the signal level.
