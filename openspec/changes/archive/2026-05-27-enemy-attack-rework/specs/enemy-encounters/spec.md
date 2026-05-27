## MODIFIED Requirements

### Requirement: Garbage attacks occur every round
Every round SHALL have periodic garbage attacks driven by the assigned enemy's tier and the current stage. Each attack fires after a randomised interval drawn from a tier-specific range, and delivers a randomised number of garbage rows drawn from a tier-specific lines range. Both ranges scale with stage. The next interval and line count are re-rolled independently after every attack.

Tier base ranges (before stage scaling):

| Tier   | Interval range | Lines range |
|--------|---------------|-------------|
| Normal (Small / Big / Elite) | 15 – 25s | 1 – 3 |
| Boss   | 10 – 16s      | 2 – 4       |

Stage scaling:
- **Interval**: both min and max are multiplied by `max(0.5, 1.0 - (stage - 1) × 0.1)`, making attacks progressively faster with a floor at 50% of the base rate.
- **Lines**: both min and max receive an additive bonus of `floor((stage - 1) / 2)`, adding +1 at stages 3–4 and +2 at stage 5.

All garbage rows from a single attack SHALL share the same hole column, chosen randomly at attack fire time.

Garbage rows are added to the attack buffer (`pending_garbage`) rather than inserted directly. The buffer is flushed to the board when the player locks a piece (see attack-buffer spec).

#### Scenario: Attack fires within the randomised interval window
- **WHEN** the enemy attack timer reaches the current target interval
- **THEN** the attack fires, `pending_garbage` is increased by the rolled line count, and a new target interval is drawn from the tier range

#### Scenario: Multi-row attack delivers aligned garbage
- **WHEN** an attack delivers more than one garbage row
- **THEN** all rows share the same hole column so the player can clear them with a single well-placed piece

#### Scenario: Interval re-rolled independently after each attack
- **WHEN** an attack fires
- **THEN** the next target interval is a new independent random draw from the tier range (not the same value as the previous attack)

#### Scenario: Line count scales up at higher stages
- **WHEN** the same enemy tier appears in Stage 1 and Stage 5
- **THEN** the Stage 5 minimum and maximum line counts are each 2 higher than the Stage 1 values

#### Scenario: Interval scales faster at higher stages
- **WHEN** the same enemy tier appears in Stage 1 and Stage 5
- **THEN** the Stage 5 effective interval range is 60% of the Stage 1 range

#### Scenario: Buffered garbage delivers on piece lock
- **WHEN** garbage rows have been added to the buffer and the player locks a piece
- **THEN** they are inserted into the board during the lock flush (assuming no player counter-attack cancelled them)
