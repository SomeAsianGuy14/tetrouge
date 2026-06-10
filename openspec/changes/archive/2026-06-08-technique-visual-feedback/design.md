## Context

`TechniqueEvaluator.evaluate()` currently returns `{"attack_delta": int, "coins_delta": int, "flags": Array}` — totals only, no per-technique breakdown. `RunManager._on_attack_generated()` calls it once per clear event and applies the totals silently. The HUD shows technique/keystone icons as static single-letter labels with tooltips. `TechniqueRoundState` holds a set of boolean pending flags (`escalation_pending`, `follow_up_pending`, etc.) that are never surfaced to the player.

This change adds three layers of visual feedback on top of the existing system without altering the core attack pipeline.

## Goals / Non-Goals

**Goals:**
- Per-technique floating popups when techniques contribute non-zero attack or coins
- Per-keystone floating popups when a keystone flat bonus or multiplier contributes a non-zero amount
- Economy-only popups (coins, no attack) render in gold; attack popups render in white; keystone popups render in blue
- HUD icon pulse/glow when a technique's pending flag is active or a keystone bonus just fired
- Staggered popup scheduling during the line clear delay window (requires `line-clear-delay`)
- Extend `TechniqueEvaluator.evaluate()` return dict with an `"events"` array while keeping totals unchanged

**Non-Goals:**
- Animating the board cells differently based on technique type
- Persisting feedback across rounds or to a log

## Decisions

### 1. TechniqueEvaluator returns an events array alongside existing totals

**Decision:** Add an `"events"` key to the return dict: `Array[Dictionary]` where each entry is `{name: String, attack: int, coins: int}` for techniques that contributed a non-zero result.

**Rationale:** Backwards-compatible — `RunManager` and tests that only read `"attack_delta"` / `"coins_delta"` are unaffected. The events array is simply ignored until the popup system consumes it. Building the array is cheap (one pass, same loop that already exists in `compute_attack_bonus` / `compute_economy_bonus`).

**Alternative considered:** Separate `evaluate_with_events()` method. Rejected — adds maintenance surface; the dict extension is cleaner.

### 2. Floating popups are lightweight inline Controls, not a separate scene

**Decision:** `RunManager` spawns a `Label` (or minimal `Control` subclass) directly as a child of itself, drives it with a `Tween`, and frees it on completion. No separate `.tscn` file.

**Rationale:** The popup is visually trivial (text, move up, fade out). A full scene would be over-engineered. Inline script with `create_tween()` is idiomatic Godot 4 and keeps the footprint small. If more visual complexity is needed later, it can be extracted then.

**Popup content and color:**
- Technique with attack: `"+N Name"`, **white** (e.g. "+2 Escalation")
- Technique economy-only (coins > 0, attack == 0): `"+N coin Name"`, **gold** `Color(1.0, 0.85, 0.0)` (e.g. "+1 coin Economy")
- Technique with both attack and coins: show attack only, white
- Keystone flat bonus: `"+N Name"`, **blue** `Color(0.5, 0.8, 1.0)` (e.g. "+1 Great Sword")
- Keystone multiplier: `"+N Name"`, **blue** — N is the added amount (`result - pre_mult_attack`)

Position: centred above the board, offset per-index to prevent stacking. There is no cap — all firing techniques and keystones get a popup. With the stagger timing, many events cascade rapidly in succession, which is the intended feel.

### 3. Staggered scheduling uses a timer array in RunManager, not Tweens

**Decision:** When the line clear delay is active (`config.line_clear_delay > 0.0`), RunManager stores the events list and a `_popup_schedule: Array[Dictionary]` of `{time: float, event: Dictionary}` entries spread across the delay duration. These are drained in `_process()` by comparing against a `_popup_elapsed` counter that only runs during the delay.

**Rationale:** Tweens with `tween_callback` are also viable but less transparent — a drain loop in `_process` is easy to follow and easy to test. The schedule is simply discarded if the round ends before it drains.

**Timing formula:** `time = (index / max(1, events.size())) * config.line_clear_delay`

**Fallback (no delay):** If `config.line_clear_delay == 0.0` (e.g. Full Potential), all popups spawn simultaneously.

### 4. HUD pending indicators use modulate + a looping Tween per icon

**Decision:** `HUD._refresh_technique_icons()` creates each icon label as before. A new `update_technique_states(states: Dictionary)` method on HUD accepts a dict of `{technique_id: bool}` (pending or not). For each icon, if pending: start a looping modulate tween (pulse to a highlight color). If not pending: kill the tween, restore modulate.

**Rationale:** Modulate tweens are cheap, self-contained per icon, and trivially killed when state clears. This avoids any per-frame polling in HUD.

**RunManager trigger:** After `_update_round_state_after_eval()`, RunManager calls `hud.update_technique_states(_build_technique_states())` where `_build_technique_states()` maps each technique's `effect_type` to the relevant pending flag.

### 4b. Icon scale pop on activation

**Decision:** When a technique or keystone fires (i.e. its popup is spawned), its HUD icon plays a brief scale pop: `scale` punches from `Vector2(1.0, 1.0)` to `Vector2(1.35, 1.35)` over ~0.08s, then eases back to `Vector2(1.0, 1.0)` over ~0.18s. The pop is triggered by a new `pop_icon(id: String)` method on HUD (one method serves both technique and keystone icons). RunManager calls `hud.pop_icon(event_id)` at the moment each popup is spawned from the schedule — so the icon pop and the floating label appear simultaneously.

**Rationale:** Tying the icon pop to the popup spawn moment (not to evaluate() time) means it automatically inherits the stagger timing: each technique/keystone pops its icon when its popup floats up, creating a readable cause-and-effect. The scale tween is independent of the pending-state modulate tween — both can run on the same icon simultaneously without conflict (Godot Tweens animate different properties).

### 5. Keystone "just fired" highlight is a one-shot flash, not a persistent state

**Decision:** When `_apply_keystone_flat_bonuses` or `_apply_keystone_multipliers` adds a non-zero bonus, RunManager emits or directly calls `hud.flash_keystone(keystone_id)` — HUD runs a single short Tween on that icon (flash white then back).

**Rationale:** Keystone bonuses are instantaneous events, not persistent states, so a one-shot flash is more accurate than a pulse. Persistent state tracking for keystones would require new fields with no clear benefit.

### 6. Keystone events are collected via a RunManager-level accumulator

**Decision:** Add `_pending_keystone_events: Array` to RunManager. During `_apply_keystone_flat_bonuses()`, when a keystone contributes `bonus > 0`, append `{name: ks.display_name, bonus: bonus, color: blue}`. During `_apply_keystone_multipliers()`, compute the added amount as `result - pre_mult_attack` and append similarly if non-zero. After all modifiers are applied in `_on_attack_generated()`, merge `_pending_keystone_events` into the event list passed to `_schedule_popups()`, then clear the accumulator.

**Rationale:** Keystone bonuses are computed outside `TechniqueEvaluator` so they can't be returned via the `"events"` key. A RunManager-level accumulator is the simplest approach: no API changes to the apply functions, no separate return values. The accumulator is drained once per clear event and never persists between calls.

**No cap:** all technique and keystone events are scheduled. With many techniques active, the rapid cascade of popups and icon pops is intentional.

## Risks / Trade-offs

- **Many popups at once** — a fully stacked build could fire 6–8 technique/keystone events per clear. With stagger timing these cascade in rapid succession rather than overlapping; with zero delay (Full Potential) they spawn simultaneously. The offset positioning prevents exact overlap in either case.
- **Stagger scheduling interacts with delay length** — if `line_clear_delay` is very short (or 0), stagger collapses gracefully. If a future keystone lengthens the delay, stagger spreads naturally.
- **HUD icon count** — players with many techniques could have many pulsing icons simultaneously. Mitigation: the pulse is subtle (brightness only), not distracting.
- **TechniqueEvaluator test coverage** — the events array adds surface area. Existing tests remain valid; new tests cover the events output format.

## Open Questions

*(none — all questions resolved)*
