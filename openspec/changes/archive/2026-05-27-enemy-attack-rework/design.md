## Context

Enemy attacks are currently driven by a single `effective_garbage_interval` float on `RoundConfig`, computed once at round start from `enemy.garbage_interval * stage_scalar`. Each timer expiry increments `pending_garbage` by exactly 1. The windup bar in `EnemyDisplay` fills from 0 to 1 over this fixed interval. Every enemy attack is therefore identical in size and timing pattern.

`insert_garbage_row()` on `TetrisBoard` independently randomises the hole column for each row, meaning multi-row attacks (if they were to exist) would scatter holes across the stack with no pattern, making them extremely hard to clear.

## Goals / Non-Goals

**Goals:**
- Attacks fire within a randomised interval window, re-rolled after each attack.
- Each attack sends a randomised number of garbage rows, both re-rolled per attack.
- Both ranges scale with stage (faster interval, more lines at higher stages).
- All rows from one attack share a single hole column so the player can respond with one piece.
- Each enemy tier (Small, Big, Elite, Boss) has distinct constants so difficulty ramps within a stage.

**Non-Goals:**
- Per-enemy tuning of attack ranges.
- Seeded/reproducible attack timing.
- New garbage row visual styles or content types.
- Changes to how the attack buffer (`pending_garbage`) is flushed.

## Decisions

**Per-tier constants in RunManager, not new Enemy fields**

Chosen: Eight constant groups live in `run_manager.gd`, one pair (interval min/max, lines min/max) per tier: `SMALL_*`, `BIG_*`, `ELITE_*`, `BOSS_*`. At round start, `_build_round_config()` matches on `enemy.tier` to select the correct group. This preserves the original data's intent (Small=20s, Big=17s, Elite=15s base intervals) while adding variability, and keeps all tuning in one place.

Base ranges (before stage scaling):

| Tier  | Interval range | Lines range |
|-------|---------------|-------------|
| Small | 18 – 28s      | 1 – 2       |
| Big   | 14 – 22s      | 1 – 3       |
| Elite | 11 – 18s      | 2 – 4       |
| Boss  | 10 – 16s      | 2 – 4       |

Alternative: Add min/max fields directly to `enemy.gd` and set them per .tres file. Rejected — requires updating 16 .tres files and makes tuning harder (changes are scattered). The centralised constant approach is easier to tune.

**Stage scaling: multiplicative for interval, additive for lines**

Interval uses the existing multiplicative scalar (`× max(0.5, 1.0 − (stage−1) × 0.1)`) applied to both min and max — consistent with current behaviour and produces a sensible floor.

Lines use an additive bonus (`+floor((stage−1)/2)`) added to both min and max, giving:
- Stage 1–2: base range
- Stage 3–4: +1 line
- Stage 5: +2 lines

A multiplicative approach for lines would fractionally scale integer values oddly. Additive is predictable and easy to read in code.

**`_next_garbage_interval` runtime variable on RunManager**

The current `effective_garbage_interval` on `RoundConfig` was a single computed value used as both the tick threshold and the windup bar denominator. With randomised intervals, the "current window" changes after every attack. It belongs on RunManager as `_next_garbage_interval: float`, initialised at round start and re-rolled on each attack. `RoundConfig` keeps `garbage_interval_min/max` as the source of truth for rolling. `effective_garbage_interval` is removed from `RoundConfig`.

**`insert_garbage_rows(count, col)` on TetrisBoard**

Chosen: A new method that accepts a pre-chosen column and inserts `count` rows all sharing that hole. The existing `insert_garbage_row()` is kept for single-row callers (dev console `insert_garbage` command). RunManager's flush loop is updated to: pick a column once, call `insert_garbage_rows(flush, col)`.

Alternative: Pass `col` as an optional parameter to `insert_garbage_row()`. Rejected — optional parameters with default randomisation are harder to read and test than a dedicated method.

## Risks / Trade-offs

- [Daze keystone extends `_enemy_timer`; must still work against variable `_next_garbage_interval`] → No change needed — the Daze stun subtracts from `_enemy_timer`, which is still compared against `_next_garbage_interval`. Behaviour is identical.
- [Higher line counts (up to 7 at stage 5) may outpace the flush cap of 8 rows per lock] → Pending garbage accumulates over multiple locks, which is the intended pressure mechanic. The cap prevents a single lock from being overwhelming.
- [`effective_garbage_interval` removal breaks any future callers] → Only RunManager and EnemyDisplay reference it. Both are updated in this change. No external API concern.
