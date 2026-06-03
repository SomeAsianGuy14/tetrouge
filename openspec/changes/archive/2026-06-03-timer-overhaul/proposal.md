## Why

The visible countdown timer creates a barrier for new players who can't yet clear fast enough to win on time, while not meaningfully differentiating skilled play beyond the speed bonus. Decoupling the timer from the failure condition lowers the floor for beginners while keeping fast-play rewards for experienced players.

## What Changes

- **Timer hidden by default** — The round timer is no longer visible in the HUD. Topout is now the sole failure condition for all rounds.
- **Base time limit raised** — 120s → 180s, giving all players more room without removing the concept of time.
- **Speed bonus removed** — No coins awarded for finishing early. The round payout screen shows base payout only.
- **Technique income section removed from payout screen** — Round success screen simplified to base payout only.
- **Golden Watch reworked** — Description: "Gain a 3-minute timer. At round end, earn 1 coin for every 5 seconds remaining on the timer." Holding this keystone reveals the round timer in the HUD.
- **The Blitz reworked** — Time limit 60s → 120s. Timer is always visible during a Blitz round. Failing to clear the enemy before time runs out still ends the run.
- **Blessed Stone** — Timeout no longer triggers it; topout only.
- **Time Shard consumable removed** — No longer meaningful without the timer as a threat.

## Capabilities

### New Capabilities

- `timer-visibility`: Rules governing when the HUD timer is shown — hidden by default, revealed by Golden Watch or The Blitz modifier

### Modified Capabilities

- `run-structure`: Timeout is no longer a failure condition in standard rounds; only topout ends the run in failure
- `keystones`: Golden Watch reworked (new description, timer-reveal behaviour); Blessed Stone timeout trigger removed
- `consumables`: Time Shard removed from the pool
- `economy`: Speed bonus removed from round payout; round success screen simplified

## Impact

- `game/scenes/game/run_manager.gd` — `_tick_timer()` no longer calls `_end_round(false)`; speed bonus removed from `_end_round(true)` path; Blessed Stone check removed from `_tick_timer()`
- `game/scenes/game/hud.gd` — Timer label hidden by default; shown when Golden Watch is held or Blitz is active
- `game/autoloads/run_state.gd` — `calculate_time_limit()` returns 180s
- `game/resources/data/keystones/golden_watch.tres` — New description
- `game/resources/data/boss_modifiers/the_blitz.tres` — `time_limit_override` 60 → 120
- `game/resources/data/consumables/time_shard.tres` — Removed; registry entry removed
- `game/scenes/screens/round_success.gd` — Simplified payout display
- `game/autoloads/economy.gd` — `calculate_speed_bonus()` removed or unused
- `game/tests/unit/` — Tests updated
