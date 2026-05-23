## Context

GDScript's global `randi()` / `randf()` and `Array.shuffle()` use Godot's shared random state, which reseeds on every engine restart. This means closing and reopening the game produces different outcomes for piece bags, boss modifier selection, shop inventory, and augment offerings — allowing players to reroll unfavorable results by exiting.

Current RNG call sites:
- `bag_randomizer.gd` — `pieces.shuffle()` (2 paths: standard 7-bag + overflow bag)
- `tetris_board.gd:507` — `randi() % board_width` (garbage row gap position)
- `run_manager.gd:142` — `available.shuffle()` for boss modifier selection
- `keystone_selection.gd:28` — `all_keystones.shuffle()` for augment pool draw
- `shop.gd:55,66,70,77` — `available.shuffle()` and `randf()` for shop inventory

`RunState` is an autoload that holds run-wide data. `RunSave` serializes it to `user://save.cfg`.

## Goals / Non-Goals

**Goals:**
- All random decisions within a run are reproducible from a single integer seed stored in `RunState`.
- Resuming a saved run produces the same future sequence as if the run had never been interrupted.
- Two different runs are statistically independent (each gets a fresh random seed).

**Non-Goals:**
- Exposing the seed to players or supporting seed-entry for challenge runs (future feature).
- Reseeding mid-run for any reason.
- Changing what is randomized — only the source of randomness changes.

## Decisions

### 1. Use Godot's `RandomNumberGenerator` class, not global functions

**Decision:** Add a `RandomNumberGenerator` instance (`_rng`) to `RunState`. All seeded calls use `_rng.randi()`, `_rng.randf()`, and a helper `seeded_shuffle(arr)` method on `RunState`.

**Why over alternatives:**
- Godot's `RandomNumberGenerator` has built-in `seed` and `state` properties. `state` captures the full PRNG position mid-sequence and round-trips through `ConfigFile` as an integer — exactly what is needed for save/restore.
- Replacing global `randi()`/`randf()` with method calls on a single object requires minimal invasive changes.
- A helper `seeded_shuffle(arr)` on `RunState` (Fisher-Yates using `_rng`) means call sites only change `arr.shuffle()` → `RunState.seeded_shuffle(arr)`, keeping diffs small.

**Alternative considered:** A standalone `RunRng` autoload. Rejected because `RunState` already owns all run-lifecycle concerns (reset, save, load); adding a second autoload that must stay synchronized with `RunState.reset()` introduces coupling risk.

### 2. Save `state` (not `seed`) to persist mid-run position

**Decision:** `RunSave` stores `_rng.state` (the counter), not just `_rng.seed`. On load, set both `seed` and `state`.

**Why:** Storing only the seed would replay the entire sequence from the beginning, but the number of RNG draws already consumed is not tracked separately. Storing `state` directly restores the exact PRNG position without needing a draw counter.

**Note:** Godot's `RandomNumberGenerator.state` is the full internal state of the xorshift generator. Setting `seed` resets it; setting `state` after `seed` positions it mid-sequence. Both must be saved.

### 3. Garbage row gap remains seeded via `_rng`

**Decision:** `tetris_board.gd`'s `randi() % board_width` for garbage gaps also routes through the run PRNG.

**Why:** Garbage row patterns are a meaningful gameplay outcome. Using the global random would leave a single un-seeded decision in the run. The board receives the PRNG reference at `setup()` time.

**Alternative considered:** Leave garbage gaps using global `randi()` since they're a real-time reaction event. Rejected because consistency is simpler to reason about and it closes the re-roll vector entirely.

## Risks / Trade-offs

- **Existing saves are incompatible** — saves written before this change have no `rng_seed` / `rng_state` fields. On load, `RunSave` will fall back to a freshly-seeded RNG (treat as if starting a new session). This gracefully degrades rather than crashes. → No migration needed; old saves just lose determinism for the remainder of that run.
- **PRNG draw-count coupling** — if a future feature inserts a new RNG call between two existing ones, the sequence for all downstream calls shifts. This is expected behavior for seeded systems and matches roguelite norms. → Document in code; accept the trade-off.
- **`TetrisBoard` needs a reference to `RunState._rng`** — this introduces a dependency from the board into the run-level autoload. The board currently has no such dependency. → Pass the `RandomNumberGenerator` instance into `board.setup()` via `RoundConfig`, keeping the board decoupled from the autoload.

## Migration Plan

1. Add `_rng: RandomNumberGenerator`, `run_seed: int`, and `seeded_shuffle(arr)` to `RunState`. Initialize and seed in `reset()`.
2. Update `RunSave.save()` to write `rng_seed` and `rng_state`; update `load_into_state()` to read them back and restore `_rng`.
3. Add `rng: RandomNumberGenerator` field to `RoundConfig`. Populate it in `RunManager._build_round_config()`.
4. Update `BagRandomizer` to accept a `RandomNumberGenerator` parameter and use it for all `shuffle()` calls.
5. Update `TetrisBoard.setup()` to receive the RNG from `RoundConfig` and store it; replace `randi()` calls with `_rng.randi()`.
6. Update `RunManager._select_boss_modifier()` to call `RunState.seeded_shuffle(available)`.
7. Update `KeystoneSelection._draw_three_keystones()` to call `RunState.seeded_shuffle(all_keystones)`.
8. Update `Shop` item generation to call `RunState.seeded_shuffle(available)` and `RunState._rng.randf()`.

No rollback strategy needed — the change is self-contained and old saves fall back gracefully.

## Open Questions

- None. The scope is well-defined and all call sites are identified.
