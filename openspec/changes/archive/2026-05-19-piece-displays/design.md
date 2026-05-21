## Context

`TetrisBoard` already tracks all the data needed: `held_pieces` (array of piece type strings), `piece_queue` (array of upcoming types), `config.preview_count`, and `config.hold_disabled`. It emits `board_updated` whenever any of this changes. The board renders itself via `_draw()` at pixel position set by `BoardContainer` in the `RunManager` scene.

The current layout places the board at `BoardContainer` position `(320, 64)`, giving a board pixel size of `10 × 32 = 320px` wide and `20 × 32 = 640px` tall. The window is `1280 × 720`, leaving significant space on either side.

## Goals / Non-Goals

**Goals:**
- Render the held piece to the left of the board, updating on every `board_updated`
- Render the next-piece queue to the right of the board, sized to `config.preview_count`
- Visually dim the hold display when hold is disabled (`config.hold_disabled = true`)
- Support Extended Buffer keystone (up to 2 hold slots)
- Support Foresight keystone (up to 7 preview slots) and The Blinder (1 slot)

**Non-Goals:**
- Animated transitions between piece changes
- Piece label text ("HOLD", "NEXT") beyond simple static labels in the scene
- Touch-friendly sizing or mobile layout

## Decisions

### D1: Two separate Node2D scenes, each with their own `_draw()`

`HoldDisplay` and `QueueDisplay` are both `Node2D` scenes with a `_draw()` method that draws piece cells directly using `draw_rect`, matching the board's visual style. They are not `Control` nodes — `_draw()` on `Node2D` is simpler for grid-based rendering and consistent with how `TetrisBoard` renders.

**Why not extend TetrisBoard's `_draw()`:** The board scene is self-contained by design. Extending it would couple the board to layout concerns.

**Why not use Label/TextureRect nodes:** Piece rendering requires drawing arbitrary coloured cells at exact positions. Canvas drawing is more flexible and consistent with the board.

### D2: Shared mini-cell size of 28px

Both displays use `MINI_CELL = 28` (vs the board's `CELL_SIZE = 32`). This fits the side panels comfortably within the 1280px window without overlapping the board or the HUD.

```
Window: 1280px wide
  Left margin:   ~60px
  HoldDisplay:   ~130px  (4 cells × 28px + padding, left of board)
  Gap:           ~20px
  Board:         320px   (10 × 32)
  Gap:           ~20px
  QueueDisplay:  ~130px  (4 cells × 28px + padding, right of board)
  Remaining:     ~600px  (HUD, keystone list, etc.)
```

### D3: RunManager positions displays relative to BoardContainer

`RunManager` already knows `BoardContainer`'s position. After instantiating the board each round, it also instantiates `HoldDisplay` and `QueueDisplay`, positions them flanking `BoardContainer`, and calls `display.setup(board)` to give them a reference to the board and connect to `board_updated`.

### D4: Piece rendering uses a 4×4 mini-grid centred in the panel

Each piece preview cell draws into a 4×4 bounding box (matching the widest piece, the I). The piece cells from `PieceData.get_cells()` are offset by `+2` in each axis to centre them within the 4×4 grid. This handles all 7 piece types without special-casing.

### D5: Hold disabled state shown by drawing the panel background with reduced alpha

When `config.hold_disabled` is true, `HoldDisplay` draws the background at `alpha = 0.3` and skips drawing any piece cells, making the panel visually grayed out without needing a separate node or texture.

## Risks / Trade-offs

**`board_updated` fires every frame during active play** → `queue_redraw()` on each signal is cheap for two small panels. No performance concern.

**Preview count changes mid-run** (Foresight keystone acquired in shop) → `QueueDisplay` reads `board.config.preview_count` on every `_draw()` call, so it always reflects the current config without any explicit update needed.

**Extended Buffer gives 2 hold slots** → `HoldDisplay` iterates `board.held_pieces` and draws each slot vertically. Panel height is fixed at 2 slots (2 × 4 cells × 28px) and the second slot shows empty if only one piece is held.
