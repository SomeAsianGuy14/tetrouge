## ADDED Requirements

### Requirement: Each run is driven by a single deterministic seed
When a new run starts, the game SHALL generate one random integer seed and store it in `RunState`. All random draws within the run SHALL derive from a single `RandomNumberGenerator` instance initialised with that seed. The seed SHALL NOT change for the lifetime of the run.

#### Scenario: Seed is generated at run start
- **WHEN** a new run begins
- **THEN** `RunState` holds a non-zero integer seed and a seeded `RandomNumberGenerator` instance ready for use

#### Scenario: Seed is not regenerated mid-run
- **WHEN** any round begins after the first
- **THEN** the same `RandomNumberGenerator` instance continues from where it left off; no new seed is generated

### Requirement: Restarting the game does not change future outcomes for a saved run
If a run is saved and the game is closed and reopened, the PRNG state SHALL be restored so that all future random draws produce the same results as if the session had never been interrupted.

#### Scenario: Resumed run produces same sequence
- **WHEN** a run is saved mid-run, the game is closed, and the player continues
- **THEN** shop inventory, augment offerings, boss modifiers, and piece bags match what they would have been in an uninterrupted session

### Requirement: RunState exposes a seeded shuffle helper
`RunState` SHALL expose a `seeded_shuffle(arr: Array) -> void` method that shuffles an array in-place using the run PRNG. All systems that need a random ordering SHALL call this method rather than `Array.shuffle()`.

#### Scenario: seeded_shuffle advances PRNG state
- **WHEN** `RunState.seeded_shuffle(arr)` is called
- **THEN** the array is shuffled and the internal PRNG counter advances by the number of elements in the array
