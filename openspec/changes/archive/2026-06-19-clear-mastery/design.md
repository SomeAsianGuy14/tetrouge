## Context

Combat rooms currently give gold but no direct power. The main power sources (techniques, keystones) are gated behind shops (which appear only twice per floor at 40-60 coin prices) and boss clears. Clear mastery introduces a combat-driven progression system where performing clears earns XP toward permanent attack bonuses on 7 clear types, creating a reward loop where winning fights directly makes you stronger.

The existing attack pipeline in `_on_attack_generated()` computes: `raw_attack + technique_atk + honed_bonus`, then applies keystone flat bonuses, consumable bonuses, keystone multipliers, and amplified multiplier. Mastery's flat bonus slots naturally alongside `technique_atk`.

## Goals / Non-Goals

**Goals:**
- Add 7 mastery tracks that grant +1 flat attack per level on their respective clear type
- Amplify matching technique bonuses based on mastery level (+1 per 2 mastery levels)
- Persist mastery across floors within a run, reset between runs
- Display mastery in a collapsible HUD panel with level-up popups
- Keep the system simple — flat bonuses, no complex interactions

**Non-Goals:**
- Mastery affecting B2B, combo, or perfect clear mechanics
- Technique upgrading as a separate system (future consideration)
- Mastery persisting across runs (meta-progression)
- Mastery interacting with enhancements (honed, gilded, etc.)

## Decisions

### 1. Mastery data structure on RunState

A Dictionary mapping track name to `{xp: int, level: int}`. Track names match the `event_type` strings already used in the attack system: `"single"`, `"double"`, `"triple"`, `"quad"`, `"tspin_single"`, `"tspin_double"`, `"tspin_triple"`.

The XP threshold escalates with level. Base thresholds and increments: `{single: {base: 10, inc: 2}, double: {base: 10, inc: 2}, triple: {base: 5, inc: 1}, quad: {base: 5, inc: 1}, tspin_single: {base: 10, inc: 2}, tspin_double: {base: 10, inc: 2}, tspin_triple: {base: 5, inc: 1}}`. The threshold for level N is `base + inc * (N - 1)` (e.g., quad level 1 needs 5, level 2 needs 6, level 3 needs 7).

**Alternative considered:** Separate arrays or a custom Resource. Rejected because a Dictionary is simpler, easily serialized by RunSave, and the track names already exist as event_type strings.

### 2. Where mastery XP is granted

In `_on_attack_generated()`, right after the run_stats tracking block (line ~935). The event_type is already available and the is_bonus_event flag already excludes B2B/combo. Perfect clears are excluded by checking `event_type != "perfect_clear"`.

### 3. Where mastery flat bonus is applied

In `_on_attack_generated()`, added to `modified` alongside `technique_atk` at line ~911. The mastery bonus is a simple lookup: `RunState.mastery[event_type].level` (or 0 if not a tracked type). This runs before keystone multipliers and amplified, so mastery benefits from those multipliers — intentional, since it mirrors how technique flat bonuses work.

### 4. How technique amplification works

In `TechniqueEvaluator._eval_flat()`, after computing the base `bonus` from params, add the mastery amplification. The mastery data is passed into the evaluator via a new parameter or via RunState (which is already an autoload accessible everywhere).

For specific techniques (`on="quad"`, `on="tspin_double"`, etc.): `bonus += floor(RunState.get_mastery_level(on) / 2)`

For broad techniques (`on="all_clear"`, `on="tspin"`, `on="multiline"`): `bonus += floor(RunState.get_highest_mastery_for(on) / 2)`

The `get_highest_mastery_for()` helper maps broad categories to their constituent tracks:
- `"all_clear"` → max of all 7 tracks
- `"tspin"` → max of tspin_single, tspin_double, tspin_triple
- `"multiline"` → max of double, triple, quad

B2B-gated techniques (`require_b2b: true`) and perfect clear techniques are not amplified — the mastery amplification runs only if the `on` field maps to a tracked mastery type.

### 5. Collapsible mastery panel in HUD

A new `MasteryPanel` VBoxContainer added above the InventoryPanel in the HUD scene. Contains a clickable header label ("▼ Mastery" / "▶ Mastery") and 7 track labels showing level and XP progress (e.g., "Quads  Lv 3 (2/7)"). Toggling the header shows/hides the track labels. Default state: collapsed.

Follows the same visibility pattern as InventoryPanel — visible during combat/encounters/map, hidden during shop.

### 6. Level-up popup

When XP is granted and the level increases, spawn a popup using the same `_spawn_event_popup` pattern. Text: "Singles Lv 3!" with a distinct color (e.g., light green). Spawned from the mastery panel's position rather than the keystone icons position.

### 7. RunSave serialization

Mastery is serialized as a Dictionary of `{track_name: {xp: int, level: int}}` under a `"mastery"` section in the save config. On load, missing mastery data defaults to empty (all tracks at 0).

## Risks / Trade-offs

- **Power creep**: A quad specialist reaching mastery level 20 gets +20 base attack on quads plus +10 from Hone's amplification. This is significant but spread across a full 4-floor run, and the player earned it through consistent play. → Acceptable; values are tunable via XP thresholds.

- **T-spin mastery levels slowly**: T-spins are harder to execute consistently. At 10 XP per level for T-Spin Doubles, a player landing 40 T-Spin Doubles gets mastery 4. → This is intentional — T-spins already have high base attack, so lower mastery levels are proportionally less impactful.

- **Broad technique scaling with highest track**: A quad specialist gets their "all_clear" techniques amplified by quad mastery even for singles. → Accepted per design decision. The player invested in a specialization and broad techniques reflecting that feels natural.
