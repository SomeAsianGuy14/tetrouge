## ADDED Requirements

### Requirement: Held pieces render their enhancement styling
The `HoldDisplay` SHALL read `TetrisBoard.held_enhancements` alongside `held_pieces` and render the same per-type styling used for board cells and the falling piece (Decision 8 of the piece-enhancements design) for each held piece that carries an enhancement.

#### Scenario: Held enhanced piece shows its styling
- **WHEN** `held_pieces[0]` is enhanced with `reinforced`
- **THEN** the hold panel renders the reinforced styling (solid brown fill with a silver border) over the displayed piece

#### Scenario: Held unenhanced piece renders unchanged
- **WHEN** `held_enhancements[0]` is `""`
- **THEN** the hold panel renders the held piece with no enhancement styling

#### Scenario: Styling follows the piece through a hold swap
- **WHEN** the player swaps an enhanced held piece back into play
- **THEN** the hold panel's styling for that slot updates to match the newly held piece's enhancement (if any) within the same frame
