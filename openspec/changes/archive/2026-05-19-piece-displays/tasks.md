## 1. Hold Display

- [x] 1.1 Create `game/scenes/game/hold_display.gd` as a `Node2D` with a `setup(board: TetrisBoard)` method that stores the board reference and connects to `board_updated`
- [x] 1.2 Implement `_draw()`: draw a dark background panel sized for `config.hold_slots` slots (each slot is a 4×4 mini-cell grid at 28px per cell)
- [x] 1.3 When `config.hold_disabled` is true, draw the background at alpha 0.3 and return without drawing any piece
- [x] 1.4 For each occupied slot in `held_pieces`, call a helper `_draw_mini_piece(piece_type, slot_origin)` that renders the piece centred in a 4×4 grid
- [x] 1.5 Implement `_draw_mini_piece(piece_type: String, origin: Vector2)`: get cells from `PieceData.get_cells(piece_type, 0)`, offset each by `+Vector2i(2, 2)` to centre in the 4×4 box, draw each as a filled rect using `TetrisBoard.PIECE_COLORS`
- [x] 1.6 Connect `board_updated` signal in `setup()` to call `queue_redraw()`
- [x] 1.7 Create `game/scenes/game/hold_display.tscn` referencing the script

## 2. Queue Display

- [x] 2.1 Create `game/scenes/game/queue_display.gd` as a `Node2D` with a `setup(board: TetrisBoard)` method that stores the board reference and connects to `board_updated`
- [x] 2.2 Implement `_draw()`: read `board.config.preview_count` and `board.get_preview_types()`, then draw one slot per piece top-to-bottom
- [x] 2.3 Each slot is a 4×4 mini-cell grid at 28px per cell with a dark background; draw the piece centred using the same `_draw_mini_piece` logic as the hold display
- [x] 2.4 Connect `board_updated` signal in `setup()` to call `queue_redraw()`
- [x] 2.5 Create `game/scenes/game/queue_display.tscn` referencing the script

## 3. RunManager Integration

- [x] 3.1 Add constants `SCENE_HOLD_DISPLAY` and `SCENE_QUEUE_DISPLAY` to `run_manager.gd`
- [x] 3.2 Add instance variables `_hold_display` and `_queue_display` to `RunManager`
- [x] 3.3 In `start_round()`, after the board is set up, instantiate `hold_display.tscn` and `queue_display.tscn`, call `setup(current_board)` on each, and add them as children of `board_container`
- [x] 3.4 Position `_hold_display` to the left of the board: `x = -(4 * 28 + 16)`, `y = 0` relative to `board_container`
- [x] 3.5 Position `_queue_display` to the right of the board: `x = TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16`, `y = 0` relative to `board_container`
- [x] 3.6 Free any existing display instances at the start of `start_round()` before creating new ones (same pattern as `current_board`)
- [x] 3.7 Update `run_manager.tscn`: shift `BoardContainer` position right by ~140px (from x=320 to x=460) to leave room for the hold panel on the left without clipping the window edge

## 4. Visual Verification

- [ ] 4.1 Run the game, start a round, and verify the hold panel appears to the left of the board and the queue panel to the right
- [ ] 4.2 Hold a piece and verify the hold display updates immediately to show the correct coloured piece
- [ ] 4.3 Verify the queue shows the correct number of upcoming pieces and updates as pieces are placed
- [ ] 4.4 Start a boss round with The Void modifier and verify the hold display dims correctly
- [ ] 4.5 Start a boss round with The Blinder modifier and verify the queue display shows only 1 piece
