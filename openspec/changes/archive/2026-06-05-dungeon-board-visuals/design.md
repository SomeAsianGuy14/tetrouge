## Context

`TetrisBoard` renders entirely via Godot's `_draw()` / `_draw_cell()` API — no sprites, no shaders, no textures. Every cell is a single `draw_rect` call with a 1 px margin. The board is a `Node2D` so all drawing is immediate-mode and re-runs every `queue_redraw()`.

Current rendering pipeline (tetris_board.gd):
```
_draw()
  draw_rect  — board background  Color(0.1, 0.1, 0.1)
  _draw_cell — each filled cell  flat fill, 1 px margin
  _draw_cell — ghost cells       solid grey or solid near-white
  _draw_cell — current piece     flat fill
  draw_line  — grid lines        Color(0.2, 0.2, 0.2)

_draw_cell(col, screen_row, color)
  draw_rect(rect, color)         ← single call
```

`CELL_SIZE` is 36 px. The inner rect used by `_draw_cell` is 34×34 (1 px margin on all sides).

## Goals / Non-Goals

**Goals:**
- Bevelled stone-block appearance on all placed cells (active piece + locked grid)
- Position-seeded crack pattern drawn over garbage cells (colour ID 9)
- Ghost piece rendered as dark void fill + piece-coloured outline (Option C); outline turns white while `soft_dropping`
- Board background colour shifted to `Color(0.08, 0.07, 0.10)`
- All changes confined to `tetris_board.gd`

**Non-Goals:**
- Palette changes to piece colours
- Animations or particles (line-clear effects, etc.)
- Shader-based effects
- Changes to any scene, UI, or other script

## Decisions

### D1 — Bevel via four draw_rect strips (not draw_polygon or shader)

The bevel is drawn as four axis-aligned strips inside the existing inner rect:

```
top strip    (x+0,  y+0,  w,   2)  color.lightened(0.40)
left strip   (x+0,  y+2,  2,   h-4) color.lightened(0.25)
right strip  (x+w-2,y+2,  2,   h-4) color.darkened(0.40)
bottom strip (x+0,  y+h-2,w,   2)  color.darkened(0.55)
```

The main fill is drawn first; strips are drawn on top. This keeps `_draw_cell` as a pure GDScript function with no dependencies — no atlas, no theme, no shader.

**Alternatives considered:**
- `draw_polygon` with per-vertex colours — more flexible but harder to read and overkill for a rect
- Godot `StyleBoxFlat` with border — only works for Control nodes, not Node2D

### D2 — Garbage cracks: position-seeded pattern index, fixed line coords

Four crack patterns are stored as `const` arrays of normalised (0.0–1.0) Vector2 pairs. The pattern for a cell is `(col * 7 + screen_row * 13) % 4`. At 36 px cells the lines are multiplied by 34 (inner size) and offset by the cell's top-left.

```
CRACK_PATTERNS = [
  # 0: diagonal + branch
  [[0.25,0.10, 0.55,0.90], [0.55,0.50, 0.82,0.35]],
  # 1: Z-crack (three segments)
  [[0.15,0.20, 0.65,0.35], [0.65,0.35, 0.35,0.70], [0.35,0.70, 0.85,0.82]],
  # 2: Y-fork
  [[0.50,0.10, 0.50,0.55], [0.50,0.55, 0.20,0.90], [0.50,0.55, 0.80,0.90]],
  # 3: corner crack + branch
  [[0.10,0.10, 0.45,0.52], [0.45,0.52, 0.72,0.40], [0.45,0.52, 0.55,0.87]],
]
```

Crack colour: `Color(0, 0, 0, 0.70)` (near-black, semi-transparent), 1 px width.

**Alternatives considered:**
- Random crack per placement using `RunState` RNG — varied but requires storing per-cell state; not worth the complexity for a cosmetic effect
- Texture overlay — requires an asset import pipeline we don't have

### D3 — Ghost: separate `_draw_ghost_cell` function

The ghost section in `_draw()` already knows `current_type`, so piece colour is accessible via `PIECE_COLORS.get(PieceData.get_color_id(current_type))`. A new `_draw_ghost_cell(col, row, piece_color, is_soft_drop)` replaces the existing `_draw_cell` call.

```
void fill:    Color(0.05, 0.04, 0.08)       # dark void, slight violet
outline:      piece_color with alpha 0.75   # normal
              Color(1, 1, 1, 0.85)          # when soft_dropping
outline width: 2 px (four draw_rect strips, same pattern as bevel)
```

The `COLOR_GHOST` entry in `PIECE_COLORS` is left unchanged (other code may read it).

### D4 — Distinguish garbage in the draw loop via cell_val == 9

The existing loop already has `cell_val` available. A single `if cell_val == 9` branch routes to `_draw_garbage_cell(col, screen_row)` which calls `_draw_cell` then overlays the crack. No signature changes to `_draw_cell`.

## Risks / Trade-offs

- **Bevel readability at small viewport scales** — at 36 px cells the 2 px bevel is ~5.5% of cell size; should be visible. If the board is ever scaled down significantly the bevel may merge. Mitigation: acceptable for current fixed 1024×600 resolution; revisit if resolution scaling is added.
- **Crack pattern repetition** — with 4 patterns and a simple hash, some adjacent garbage cells will share a pattern. This is unlikely to be noticeable in practice (garbage fills row by row) but could feel repetitive in a fully garbage-filled board. Mitigation: 4 patterns with differing orientations minimise the visual repetition adequately.

## Open Questions

_(none — all decisions resolved in explore session)_
