## 1. Data Model — RunStats

- [x] 1.1 Add `quads: int`, `tspins: int`, `perfect_clears: int`, `run_time: float`, `clear_counts: Dictionary` fields to `game/scripts/run_stats.gd`

## 2. Data Model — ProfileSave

- [x] 2.1 Add `victories: int`, `best_single_run_damage: int`, `total_quads: int`, `total_tspins: int`, `total_perfect_clears: int`, `total_play_time: float` fields to `game/scripts/profile_save.gd`
- [x] 2.2 Load new fields in `load_profile()` with default `0` for each
- [x] 2.3 Save new fields in `save_profile()`
- [x] 2.4 Update `accumulate_stats(run_stats)` to accumulate `total_quads`, `total_tspins`, `total_perfect_clears`, `total_play_time`, update `best_single_run_damage` as a lifetime max, and increment `victories`

## 3. RunManager — Counter Wiring

- [x] 3.1 In `_on_attack_event()` (or equivalent clear handler), increment `_run_stats.quads` on `"quad"` clear type
- [x] 3.2 Increment `_run_stats.tspins` on any T-spin clear type (`"tspin_mini"`, `"tspin_single"`, `"tspin_double"`, `"tspin_triple"`)
- [x] 3.3 Increment `_run_stats.perfect_clears` on `"perfect_clear"` clear type
- [x] 3.4 Increment `_run_stats.clear_counts[clear_type]` by 1 on every clear event (all types)
- [x] 3.5 Accumulate `round_timer` into `_run_stats.run_time` at the end of each round (both success and failure/topout), before showing any end screen

## 4. RunManager — PB Comparison and Screen Setup Order

- [x] 4.1 Extract a `_compute_pbs(run_stats) -> Dictionary` helper in `RunManager` that returns a dict of field names that are new personal bests (compare against current ProfileSave values before accumulation)
- [x] 4.2 In `_show_victory()`: call `_compute_pbs()` first, then show the victory screen passing `_run_stats` and PB dict, then call `ProfileSave.record_victory()`, `ProfileSave.accumulate_stats()`, and `UnlockChecker.check_all()`
- [x] 4.3 In `_show_failure()`: call `_compute_pbs()` first, then show the failure screen passing `_run_stats`, PB dict, ante, and round index (do not call accumulate_stats)

## 5. Run-End Screens — Victory

- [x] 5.1 Update `RunVictory.setup()` signature to accept `run_stats: RunStats`, `pbs: Dictionary`, `final_coins: int`, `beaten_level: int`
- [x] 5.2 Add stat rows to the victory scene layout: Total Damage, Best Combo, Best B2B, Quads, T-Spins, Perfect Clears, Run Time, Most Common Clear
- [x] 5.3 Populate each stat row from `run_stats`; append "★ PB" to label text when `pbs.has(field_name)`; format `run_time` as MM:SS; derive most common clear from `clear_counts` using tie-break priority order
- [x] 5.4 Add build summary section: list keystone names from `RunState.keystones` and technique names from `RunState.techniques`; hide section if both arrays are empty

## 6. Run-End Screens — Failure

- [x] 6.1 Update `RunFailure.setup()` signature to accept `run_stats: RunStats`, `pbs: Dictionary`, `ante: int`, `round_index: int`
- [x] 6.2 Add the same stat rows as the victory screen to the failure scene layout (including Run Time and Most Common Clear)
- [x] 6.3 Populate stat rows and PB markers identically to the victory screen
- [x] 6.4 Add build summary section with the same logic as victory

## 7. Stats Screen — Scene and Logic

- [x] 7.1 Create `game/scenes/screens/stats_screen.tscn` with three labelled sections: Career, Personal Bests, Lifetime Totals
- [x] 7.2 Create `game/scenes/screens/stats_screen.gd` with a `setup()` method that reads `ProfileSave` fields and populates all labels
- [x] 7.3 Career section: Runs Played, Victories, Best Ascension (display "—" when `highest_beaten == -1`, otherwise "A{n}")
- [x] 7.4 Personal Bests section: Best Damage (single run), Longest Combo, Longest B2B
- [x] 7.5 Lifetime Totals section: Total Damage, Total Quads, Total T-Spins, Total Play Time (formatted as H:MM:SS)
- [x] 7.6 Add a "Close" button that calls `queue_free()`

## 8. Main Menu — Stats Button

- [x] 8.1 Add a "Stats" button to the main menu scene layout
- [x] 8.2 Wire button in `main_menu.gd`: on press, instantiate and add `stats_screen.tscn` as a child (matching the pattern used for the settings screen)

## 9. Testing

- [x] 9.1 Add tests for `_compute_pbs()`: verify PB flag set when run value exceeds stored best for `total_damage`, `highest_combo_chain`, `highest_b2b`
- [x] 9.2 Add test: PB flag NOT set when run value equals stored best
- [x] 9.3 Add test: PB flag NOT set when run value is lower than stored best
- [x] 9.4 Add tests for `ProfileSave.accumulate_stats()`: verify new fields (`total_quads`, `total_tspins`, `total_perfect_clears`, `victories`, `best_single_run_damage`) accumulate/update correctly
- [x] 9.5 Add test: `best_single_run_damage` takes max (does not decrease when run damage is lower)
- [x] 9.6 Add test: new ProfileSave fields default to `0` when keys are absent from the config file
- [x] 9.7 Add test: `_run_stats.quads` increments on quad clear, `tspins` on any T-spin type, `perfect_clears` on perfect clear
- [x] 9.8 Add test: `clear_counts` increments the correct key for each clear type
- [x] 9.9 Add test: most-common-clear derivation returns correct type; tie broken by priority order; returns "—" on empty dict
- [x] 9.10 Add test: run_time MM:SS formatting (e.g. 754s → "12:34", 60s → "1:00", 3661s → "61:01")
- [x] 9.11 Add test: `total_play_time` accumulates across runs in ProfileSave
