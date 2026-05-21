## 1. Input Bindings (project.godot)

- [x] 1.1 Open the Godot editor, go to Project → Project Settings → Input Map, find `rotate_cw`, click the + button, and add X key as a second event. Save the project.
- [x] 1.2 In the same Input Map, find `soft_drop`, click the + button, and add S key as a second event. Save the project.
- [ ] 1.3 Verify in-game: pressing X rotates the piece clockwise; pressing S while held accelerates the piece downward.

## 2. Soft Drop Visual Feedback

- [x] 2.1 In `game/scenes/tetris/tetris_board.gd`, locate the `_draw()` method where the ghost piece cells are drawn using `PIECE_COLORS[PieceData.COLOR_GHOST]`
- [x] 2.2 Replace the static ghost colour lookup with a conditional: use `Color(0.85, 0.85, 0.85)` when `soft_dropping` is true, and `PIECE_COLORS[PieceData.COLOR_GHOST]` (`Color(0.5, 0.5, 0.5)`) otherwise
- [ ] 2.3 Verify in-game: ghost piece is noticeably brighter while Down or S is held
