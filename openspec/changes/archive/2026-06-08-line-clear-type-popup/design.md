## Context

RunManager already maintains a technique/keystone popup system (`_spawn_event_popup`, `_schedule_popups`) that creates dynamically-spawned `Label` nodes attached to the RunManager tree, positioned relative to the board using `get_global_transform_with_canvas().origin`. The hold display (`_hold_display: HoldDisplay`) is a `Node2D` child of `board_container` at a fixed offset left of the board. The `TetrisBoard` emits `line_clear_delay_started(clear_type)` at the start of the clear delay and `lines_cleared(count, clear_type)` after the clear resolves.

The clear-type popup is a distinct visual layer from technique events: it names what happened (e.g. "T-Spin Double"), whereas technique events name what was earned (e.g. "+3 Overload"). They should coexist without interfering.

## Goals / Non-Goals

**Goals:**
- Show a transient label below the hold display naming every line clear type
- Match popup lifetime to the line clear delay duration
- Apply tier-appropriate color and animation (scale pop for quad/T-spin/perfect clear)
- Handle both the delay > 0 path (`line_clear_delay_started`) and the delay = 0 path (`lines_cleared`)

**Non-Goals:**
- Modifying the existing technique/keystone popup system
- Adding any new scene nodes, exported scenes, or HUD scene changes
- Persisting or logging clear-type history
- Showing B2B or combo state in the popup (those remain in the existing HUD labels)

## Decisions

### D1: Position — hold display screen coordinates, not fixed pixel offset

The label is positioned using `_hold_display.get_global_transform_with_canvas().origin` plus a computed Y offset equal to the hold panel's drawn height (`hold_slots * 96 + (hold_slots - 1) * 6 + 16`) plus a small gap (8px). This keeps the popup anchored to the hold panel regardless of screen layout or hold slot count, matching how `_spawn_event_popup` already computes board position.

**Alternative considered**: hardcoded screen position. Rejected — fragile if layout changes.

### D2: Dual signal hookup — `line_clear_delay_started` + `lines_cleared`

- Delay > 0 path: `_on_line_clear_delay_started` already fires with `clear_type`; the popup is spawned here and fades over `line_clear_delay` seconds.
- Delay = 0 path: `lines_cleared` is connected; if `current_config.line_clear_delay == 0.0`, spawn with a fallback duration of 0.5s.
- A boolean `_clear_popup_shown_this_piece` is set in `line_clear_delay_started` and cleared on `lock_processed` to prevent the zero-delay handler from double-spawning when delay > 0.

**Alternative considered**: connect only to `lines_cleared` always and use a fixed duration. Rejected — breaks the design intent of fading during the line lock window.

### D3: Animation — two-tier via Tween

- **Plain tier** (single/double/triple): `modulate.a` tweens from 1.0 → 0.0 over the full duration. No scale change.
- **Pop tier** (quad, tspin_*, perfect_clear): scale tweens 0.8 → 1.15 (0.12s, TRANS_BACK) in parallel with the fade. This mirrors the `pop_icon` pattern in `HUD` and produces a satisfying overshoot without extra complexity.

### D4: Label as RunManager child — no new scene nodes

The popup `Label` is dynamically instantiated and added to RunManager (same pattern as technique events). Its canvas position is set manually. This avoids any scene file changes.

### D5: Clear type display names and colors — lookup dictionary constant

```
CLEAR_TYPE_DISPLAY := {
    "single":        ["Single",       Color.WHITE],
    "double":        ["Double",       Color.WHITE],
    "triple":        ["Triple",       Color.WHITE],
    "quad":          ["Quad",         Color(0.3, 0.9, 1.0)],   # cyan
    "tspin_mini":    ["T-Spin Mini",  Color(0.7, 0.4, 1.0)],   # purple
    "tspin_single":  ["T-Spin",       Color(0.7, 0.4, 1.0)],
    "tspin_double":  ["T-Spin Double",Color(0.7, 0.4, 1.0)],
    "tspin_triple":  ["T-Spin Triple",Color(0.7, 0.4, 1.0)],
    "perfect_clear": ["Perfect Clear",Color(1.0, 0.85, 0.1)],  # gold
}
```

Pop-tier = any entry with color != `Color.WHITE`.

## Risks / Trade-offs

- **Hold display unavailable**: If `_hold_display` is null (round not started yet), the popup silently skips. Guarded with a null check. → Low risk; delay signal only fires during active play.
- **Zero-delay double-spawn**: Without the guard flag, both `line_clear_delay_started` and `lines_cleared` would fire for the same clear. The `_clear_popup_shown_this_piece` flag prevents this. → Needs a test or careful manual verification.
- **Label position on non-standard hold slot counts**: Panel height formula assumes `hold_slots` from `current_board.config`. If config is null the label falls back to a fixed Y offset of 120px. → Edge case only; config is always set during active play.
