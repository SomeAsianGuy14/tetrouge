## Why

With the economy rebalance, techniques cost 40-60 coins and shops appear only twice per floor. Combat rooms give gold but no direct power — winning fights doesn't make you stronger for the next one. Clear mastery fills this gap by rewarding skilled play with permanent attack bonuses that grow throughout a run, independent of shops and gold.

## What Changes

- **Add 7 mastery tracks** — Singles, Doubles, Triples, Quads, T-Spin Single, T-Spin Double, T-Spin Triple. Each clear of that type earns 1 XP toward the track. Each level grants +1 flat attack on that clear type.
- **XP thresholds scale by clear difficulty and escalate with level** — Singles/Doubles/T-Spin Singles/T-Spin Doubles start at 10 XP for level 1, increasing by 2 per level (10, 12, 14, 16...). Triples/Quads/T-Spin Triples start at 5, increasing by 1 per level (5, 6, 7, 8...).
- **Mastery amplifies matching techniques** — Specific techniques (e.g., on="quad") gain +1 bonus per 2 mastery levels in the matching track. Broad techniques (on="all_clear", "tspin", "multiline") use the highest matching track.
- **Mastery persists for the entire run**, resets between runs
- **Collapsible mastery panel** above the InventoryPanel in the HUD, showing all 7 tracks with current level and XP progress to next level. Follows the same visibility pattern as InventoryPanel (visible during combat/encounters/map, hidden during shop).
- **Level-up popup** when a mastery track crosses a threshold, similar to technique activation popups
- **Mastery state saved/loaded** via RunSave for mid-run persistence
- **NOT tracked**: B2B streak bonus, combo bonus, perfect clear

## Capabilities

### New Capabilities
- `clear-mastery`: Core mastery system — 7 XP tracks, level progression, flat attack bonuses per level, run-scoped persistence
- `mastery-technique-amplification`: Mastery levels amplify matching technique bonuses — specific tracks for targeted techniques, highest-track rule for broad techniques
- `mastery-hud`: Collapsible mastery panel in the HUD with level display and level-up popup notifications

### Modified Capabilities
- `techniques`: TechniqueEvaluator's flat bonus calculation incorporates mastery amplification for matching clear types
- `run-persistence`: RunSave serializes/deserializes mastery XP and levels

## Impact

- **RunState** (`run_state.gd`): New mastery data structure (7 tracks with XP and level), reset on new run
- **RunSave** (`run_save.gd`): Serialize/deserialize mastery state
- **TechniqueEvaluator** (`technique_evaluator.gd`): `_eval_flat()` incorporates mastery bonus; mastery amplification added to matching techniques
- **RunManager** (`run_manager.gd`): Grant XP on line clears, trigger level-up popups
- **HUD** (`hud.gd`, `run_manager.tscn`): New collapsible mastery panel above InventoryPanel, level-up popup display
- **AttackSystem or RunManager**: Apply mastery flat bonus to attack calculation on each clear
