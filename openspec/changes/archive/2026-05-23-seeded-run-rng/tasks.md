## 1. RunState — PRNG Infrastructure

- [x] 1.1 In `run_state.gd`, add `var rng: RandomNumberGenerator = RandomNumberGenerator.new()` and `var run_seed: int = 0` as instance variables
- [x] 1.2 In `RunState.reset()`, generate a fresh seed with `run_seed = randi()`, then call `rng.seed = run_seed` so every new run starts with a unique deterministic sequence
- [x] 1.3 In `run_state.gd`, add `func seeded_shuffle(arr: Array) -> void` that performs a Fisher-Yates shuffle in-place using `rng.randi_range(0, i)` for each index `i` from `arr.size() - 1` down to `1`
- [x] 1.4 In `run_state.gd`, add `func seeded_randf() -> float` that returns `rng.randf()` — convenience wrapper for systems that need a float draw

## 2. RunSave — Persist PRNG State

- [x] 2.1 In `RunSave.save()`, write two new values: `cfg.set_value("rng", "seed", RunState.run_seed)` and `cfg.set_value("rng", "state", RunState.rng.state)`
- [x] 2.2 In `RunSave.load_into_state()`, read them back: set `RunState.run_seed` from the saved seed, then restore `RunState.rng.seed = RunState.run_seed` followed by `RunState.rng.state = <saved state>` (use `0` as fallback for `state` so old saves seed fresh without crashing)

## 3. RoundConfig — Plumb RNG Reference

- [x] 3.1 In `round_config.gd`, add `var rng: RandomNumberGenerator = null` (not `@export`; assigned at runtime)
- [x] 3.2 In `RunManager._build_round_config()`, after creating `cfg`, assign `cfg.rng = RunState.rng`

## 4. BagRandomizer — Use Run RNG

- [x] 4.1 In `bag_randomizer.gd`, add `var _rng: RandomNumberGenerator = null` and update `_init()` to accept an optional second parameter `rng: RandomNumberGenerator = null`, storing it as `_rng`
- [x] 4.2 Replace all three `pieces.shuffle()` calls in `bag_randomizer.gd` with calls to a local helper `_seeded_shuffle(pieces)` that uses `_rng.randi_range` if `_rng` is set, or falls back to `pieces.shuffle()` otherwise (fallback keeps non-run contexts working)
- [x] 4.3 In `TetrisBoard.setup()` (where `BagRandomizer` is instantiated), pass `config.rng` as the second argument so the bag uses the run RNG

## 5. TetrisBoard — Use Run RNG for Garbage Gaps

- [x] 5.1 In `tetris_board.gd`, add `var _rng: RandomNumberGenerator = null` and in `setup()`, assign `_rng = config.rng`
- [x] 5.2 Replace `randi() % config.board_width` on line 507 with `(_rng.randi() if _rng else randi()) % config.board_width`

## 6. Boss Modifier and Augment Selection — seeded_shuffle

- [x] 6.1 In `RunManager._select_boss_modifier()`, replace `available.shuffle()` with `RunState.seeded_shuffle(available)`
- [x] 6.2 In `KeystoneSelection._draw_three_keystones()`, replace `all_keystones.shuffle()` with `RunState.seeded_shuffle(all_keystones)`

## 7. Shop — seeded_shuffle and seeded_randf

- [x] 7.1 In `Shop._populate_technique_slots()`, replace `available.shuffle()` with `RunState.seeded_shuffle(available)`
- [x] 7.2 In `Shop._populate_voucher_slot()`, replace `randf()` with `RunState.seeded_randf()` and replace `available.shuffle()` with `RunState.seeded_shuffle(available)`
- [x] 7.3 In `Shop._pick_one()`, replace `available.shuffle()` with `RunState.seeded_shuffle(available)`

## 8. Verification

- [x] 8.1 Start a new run, note the first few pieces and the first shop inventory; quit to main menu; start a new run — confirm the piece sequence and shop differ (different seeds)
- [x] 8.2 Start a run, reach the shop, quit via pause → Main Menu before the shop saves; continue; confirm the shop shows the same inventory as before the quit (same PRNG position)
- [x] 8.3 Complete a round, close the shop (triggering a save), quit the game entirely, continue the run — confirm the next shop inventory and augment offerings match what they would have been without the quit
- [x] 8.4 Trigger a Boss Blind, quit before the boss ends, continue — confirm the same boss modifier applies

