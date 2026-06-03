## Context

The round timer currently serves three distinct roles: a failure condition (timeout = run ends), a speed reward signal (speed bonus coins), and a UI element showing time pressure. This change separates those concerns: the timer still exists internally but is hidden from the player and stripped of its kill condition. The Blitz is the single exception where both visibility and the kill condition are preserved because its identity depends on them.

Key files: `RunManager._tick_timer()`, `HUD.update_timer()`, `Economy.calculate_speed_bonus()`, `round_success.gd`, `golden_watch.tres`, `the_blitz.tres`, `time_shard.tres`.

## Goals / Non-Goals

**Goals:**
- Remove topout as the sole round failure condition (timeout no longer kills)
- Hide the timer label in the HUD by default; show it when Golden Watch is held or The Blitz is active
- Raise base time limit to 180s; Blitz to 120s
- Remove speed bonus from economy and round payout UI
- Remove technique income from round payout UI (income still earned mid-round; just not broken out)
- Remove Time Shard from the consumable pool
- Update Golden Watch and Blessed Stone data + descriptions

**Non-Goals:**
- Changing how technique coins are earned mid-round (only the payout screen display changes)
- Modifying any other boss modifiers
- Rebalancing base payout amounts

## Decisions

### 1. Timer visibility driven by `RoundConfig` flag, set at round start

A new `bool show_timer` field on `RoundConfig` is set to `true` only when Golden Watch is held (`RunState.has_keystone("golden_watch")`) or the boss modifier is The Blitz (`cfg.boss_modifier.id == "the_blitz"`). `HUD.setup(config)` reads this flag and shows/hides `timer_label`. `HUD.update_timer()` early-returns when hidden.

**Alternative considered:** Check keystones/modifier at every `update_timer()` call. Rejected — unnecessary per-frame check; visibility is stable for an entire round.

### 2. `_tick_timer()` stops at 0 but only calls `_end_round(false)` when Blitz is active

Add `if round_timer <= 0.0` guard: if `current_config.boss_modifier` is The Blitz, call `_end_round(false)` as before. Otherwise clamp `round_timer` to 0 and do nothing — the round continues. This keeps Blessed Stone's timeout path relevant only for Blitz.

**Blessed Stone**: timeout trigger in `_tick_timer()` removed entirely. Blessed Stone only fires from `_on_game_over()` (topout). The description is updated to reflect topout-only.

### 3. Speed bonus removed — `Economy.pay_round()` simplified

`Economy.calculate_speed_bonus()` is removed. `Economy.pay_round(base, speed_bonus, technique_income)` becomes `Economy.pay_round(base)`, paying only the base payout. `speed_bonus_multiplier` (used by the Bonus Round voucher) also becomes unused and can be removed. Technique coins still flow during the round via `technique_income_this_round` but are silently added to `Economy.coins` at round end rather than displayed separately.

**Alternative considered:** Keep speed bonus, just hide it. Rejected — hidden rewards that players can't see or influence aren't meaningful.

### 4. Round success screen simplified to one line

`round_success.gd` currently shows base + speed + technique rows. After this change it shows base payout only. The scene's `speed_label` and `technique_label` nodes are hidden or removed, and `setup()` takes only `base_payout: int`.

### 5. Time Shard removed via registry and file deletion

`time_shard.tres` is deleted. The preload entry is removed from `ResourceRegistry.all_consumables`. No code references it by id; removal is clean.

## Risks / Trade-offs

- **Golden Watch value perception** — Without a speed bonus, Golden Watch is the only timer-adjacent reward. Its coin yield may feel weaker than before. Accepted for now; tune coin-per-second if playtesting shows it's undervalued.
- **Blitz kill condition now exceptional** — The Blitz is the only place timeout kills. This inconsistency may confuse players encountering it for the first time. Mitigated by making the timer always visible and the description explicit.
- **Technique income silently added** — Coins from techniques still arrive at round end but with no UI signal. Players may not notice them. Acceptable trade-off for a cleaner payout screen.
