## Context

Keystones are run-defining passive bonuses picked at run start and after boss rounds. They are defined as `.tres` resource files (`Keystone extends Resource`), applied to `RoundConfig` via `apply_to_config()`, and evaluated during attack events in `RunManager._on_attack_generated()`. `RunState.add_keystone()` is the single entry point for acquiring a keystone.

The current system has no upgrade/replacement concept — `requires_keystone_id` is a filter for the selection screen only, the base keystone stays. New mechanics (Blessed Stone death hook, Reflect flush hook, Hybrid Reactor attack hook) each need a dedicated injection point in `RunManager`.

## Goals / Non-Goals

**Goals:**
- Add `replaces_keystone_id` to Keystone and wire removal into `RunState.add_keystone()`
- Implement Blessed Stone (topout/timeout interception), Hybrid Reactor (attack bonus), and Reflect (flush hook) as new keystone mechanics
- Add `flavor_text` field to both Keystone and Technique resources
- Update death screen text; remove "quota" from player-facing strings
- Tune data on six existing keystones

**Non-Goals:**
- UI changes to display `flavor_text` (field is added but rendering is future work)
- Changing the keystone selection screen layout
- Re-tagging existing techniques for Hybrid Reactor (can happen in a follow-up)

## Decisions

### 1. `replaces_keystone_id` on Keystone; removal in `RunState.add_keystone()`

`RunState.add_keystone()` already owns all keystone state mutations. Adding the removal there keeps replacement logic in one place. The replaced keystone's id stays in `used_keystone_ids` so it can never be re-offered even after being removed from `keystones`.

**Alternative considered:** filter at the selection screen instead. Rejected — doesn't actually remove the keystone's effects from `apply_to_config` calls already processed, and splits logic across two places.

### 2. Blessed Stone hooks into `_on_game_over()` and `_tick_timer()`

Both death paths ultimately come from these two spots. Each checks a new `_blessed_stone_spent: bool` flag in RunManager before proceeding to `_end_round(false)`. When the stone triggers: add 120 seconds to `round_timer`, call `current_board.clear_board()` to reset the grid (see Open Questions), and set `_blessed_stone_spent = true`.

**Alternative considered:** a single `_check_blessed_stone()` helper called from both. Preferred approach — cleaner than duplicating the guard.

### 3. Hybrid Reactor bonus injected after `_apply_keystone_multipliers`, before `_drain_attack()`

The instruction "only clears that already send attacks" maps to `modified > 0` at that point in `_on_attack_generated()`. Computing `+3 × count(techniques where tags.size() >= 2)` there is cheap (small array) and fits the existing bonus pipeline. No changes to `TechniqueEvaluator` needed — this is a keystone bonus, not a technique effect.

The field on Keystone is `per_attack_tag_bonus: int`. If multiple Hybrid Reactor keystones existed (not currently possible), they would stack additively, which is fine.

### 4. Reflect keystone hooks into `_flush_pending_garbage()`

The user-defined Reflect (50% of flushed lines → enemy damage) is distinct from the boss Reflect modifier (which stops garbage entirely and turns player attacks against themselves). The new field `reflect_on_flush: float` on Keystone triggers inside the flush loop: after `to_flush` lines are sent to the board, `floor(to_flush * reflect_ratio)` is added directly to `quota_accumulated` and the HUD is updated.

These two Reflect types do not conflict: the boss modifier prevents garbage from being queued; the keystone acts on lines that actually reach the board. If both are active (boss Reflection + player Reflect keystone), the boss modifier blocks all incoming so the keystone never triggers — acceptable edge case.

### 5. `flavor_text: String = ""` added to both resources; no rendering this change

Adding the field now lets `.tres` files be authored with flavor text immediately. Rendering it in the shop/selection UI is deferred to avoid scope creep.

### 6. "Quota" language: variable names unchanged, UI strings updated

Internal variable `quota_accumulated` stays (renaming it is high-churn with no player-facing benefit). All player-visible strings are updated: death screen, `hud.update_quota()` call sites that format text, any label referencing "quota."

## Risks / Trade-offs

- **Board clear method unknown** → `TetrisBoard` may not expose a `clear_board()` or equivalent. If not, Blessed Stone will need to call `setup(current_config)` again, which re-connects signals — must guard against duplicate signal connections. See Open Questions.
- **Hybrid Reactor tag sparsity** → Most current techniques have 0–1 tags, so the bonus starts weak. Intentional for now; technique re-tagging is out of scope.
- **Reflect + garbage_flush_reduction interaction** → `_flush_pending_garbage()` already applies `garbage_flush_reduction` before deciding how many lines reach the board. Reflect fires on the lines that *do* reach the board (post-reduction), which is the correct behaviour — the player reflects what actually hits them.
- **ResourceRegistry must be updated** → New keystones must be added to `all_keystones` in `resource_registry.gd` or they'll be invisible in web builds.

## Open Questions

- **Does `TetrisBoard` expose a `clear_board()` or `reset()` method?** If not, the safest Blessed Stone implementation is to re-instantiate the board (same as `_start_round()`) and reconnect signals. Needs investigation before implementing that task.
