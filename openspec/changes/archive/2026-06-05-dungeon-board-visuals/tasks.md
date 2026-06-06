## 1. Board Background

- [x] 1.1 Change the board background `draw_rect` colour from `Color(0.1, 0.1, 0.1)` to `Color(0.08, 0.07, 0.10)`

## 2. Bevelled Cell Rendering

- [x] 2.1 Add bevel constants to `tetris_board.gd`: `BEVEL_SIZE := 2`, highlight multipliers (`lightened(0.40)` top, `lightened(0.25)` left, `darkened(0.40)` right, `darkened(0.55)` bottom)
- [x] 2.2 Rewrite `_draw_cell` to draw the base fill first, then the four bevel strips on top

## 3. Garbage Crack Patterns

- [x] 3.1 Add `CRACK_PATTERNS` const — four patterns, each an array of normalised Vector2 segment pairs (see design.md for exact coords)
- [x] 3.2 Add `_draw_garbage_cell(col: int, screen_row: int)` — calls `_draw_cell` with the garbage colour then draws crack lines using `(col * 7 + screen_row * 13) % 4` to select the pattern
- [x] 3.3 In the `_draw()` grid cell loop, branch on `cell_val == 9` to call `_draw_garbage_cell` instead of `_draw_cell`

## 4. Ghost Piece Rune Outline

- [x] 4.1 Add `_draw_ghost_cell(col: int, screen_row: int, piece_color: Color, is_soft_drop: bool)` — draws the dark void fill (`Color(0.05, 0.04, 0.08)`) and a 2 px outline in `piece_color` at alpha 0.75 (or white at 0.85 when `is_soft_drop`)
- [x] 4.2 In `_draw()`, replace the ghost `_draw_cell` call with `_draw_ghost_cell(cell.x, screen_row, PIECE_COLORS.get(PieceData.get_color_id(current_type), Color.WHITE), soft_dropping)`

## 5. Testing

- [x] 5.1 Add test `test_crack_pattern_is_deterministic`: verify that the same (col, row) input always selects the same pattern index
- [x] 5.2 Add test `test_crack_pattern_varies_by_position`: verify that at least two different (col, row) pairs produce different pattern indices across the four patterns
