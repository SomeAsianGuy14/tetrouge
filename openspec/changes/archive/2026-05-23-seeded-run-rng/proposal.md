## Why

Players can currently exit and reload a run to reroll piece bags, boss modifiers, shop inventories, and augment offerings — defeating the roguelite design intent of living with your choices. Binding all random decisions for a run to a single deterministic seed makes outcomes reproducible and eliminates re-roll abuse.

## What Changes

- A random integer seed is generated once when a new run starts and stored in `RunState`.
- All RNG within a run (piece bag shuffles, boss modifier selection, augment pool draws, shop item generation) derives from this seed via a deterministic PRNG seeded from it.
- The PRNG counter position is saved alongside the run so that resuming a saved run produces the same sequence as if the run had never been interrupted.
- Restarting the game and continuing a run yields identical future outcomes to staying in-session.
- Starting a new run always generates a fresh seed, so no two runs play identically by default.

## Capabilities

### New Capabilities

- `seeded-rng`: A per-run deterministic PRNG. Covers seed generation at run start, counter-based advancement, and save/restore of PRNG state.

### Modified Capabilities

- `run-structure`: Boss modifier selection and augment pool draws must use the seeded PRNG instead of `Array.shuffle()`.
- `tetris-core`: The 7-bag piece randomizer must use the seeded PRNG instead of GDScript's global `randi()`.
- `shop-system`: Shop inventory generation must use the seeded PRNG instead of uncontrolled random draws.
- `run-persistence`: The saved run file must include PRNG state (seed + counter) so it is restored on continue.

## Impact

- `RunState` — gains `run_seed: int` and a PRNG wrapper object (counter + next-value helper).
- `TetrisBoard` / bag logic — replace `arr.shuffle()` with seeded shuffle.
- `RunManager._select_boss_modifier()` — replace `available.shuffle()` with seeded shuffle.
- `KeystoneSelection._draw_three_keystones()` — replace `all_keystones.shuffle()` with seeded shuffle.
- `Shop` item generation — replace random draw with seeded draw.
- `RunSave` — serialize and deserialize PRNG state alongside existing run fields.
