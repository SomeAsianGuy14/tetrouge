## 1. RunManager — constants and state

- [x] 1.1 Add `CLEAR_TYPE_DISPLAY` dictionary constant to RunManager mapping each clear type string to `[display_name, color]`
- [x] 1.2 Add `_clear_popup_shown_this_piece: bool` instance variable to RunManager (guards against double-spawn on delay > 0 path)

## 2. Popup spawn logic

- [x] 2.1 Add `_spawn_clear_type_popup(clear_type: String, duration: float)` to RunManager: instantiates a Label, sets text/color/font-size from `CLEAR_TYPE_DISPLAY`, positions it below the hold display using `_hold_display.get_global_transform_with_canvas().origin` plus computed panel height
- [x] 2.2 Implement plain-tier fade: tween `modulate.a` from 1.0 → 0.0 over `duration`, then `queue_free`
- [x] 2.3 Implement pop-tier animation: for non-white-color entries, tween `scale` from `Vector2(0.8, 0.8)` → `Vector2(1.15, 1.15)` in 0.12s with `TRANS_BACK` in parallel with the fade
- [x] 2.4 Add null guard: if `_hold_display` is null, skip silently; if `current_board.config` is null, use a fallback Y offset of 120px for panel height

## 3. Signal hookup

- [x] 3.1 In `_on_line_clear_delay_started(clear_type)`: call `_spawn_clear_type_popup(clear_type, current_config.line_clear_delay)` and set `_clear_popup_shown_this_piece = true`
- [x] 3.2 Connect `current_board.lines_cleared` to a new `_on_lines_cleared(count, clear_type)` handler in RunManager (alongside the existing signal connections in `_setup_board`)
- [x] 3.3 Implement `_on_lines_cleared`: if `_clear_popup_shown_this_piece` is true, reset the flag and return; otherwise call `_spawn_clear_type_popup(clear_type, 0.5)`
- [x] 3.4 Reset `_clear_popup_shown_this_piece = false` in `_on_lock_processed` (or wherever per-piece state is cleared) so the flag doesn't persist across pieces

## 4. Testing

- [x] 4.1 Add test: `CLEAR_TYPE_DISPLAY` contains all 9 expected keys ("single", "double", "triple", "quad", "tspin_mini", "tspin_single", "tspin_double", "tspin_triple", "perfect_clear")
- [x] 4.2 Add test: plain-tier entries (single/double/triple) have `Color.WHITE` as their color value
- [x] 4.3 Add test: all T-spin variants ("tspin_mini", "tspin_single", "tspin_double", "tspin_triple") map to the same purple color
- [x] 4.4 Add test: "quad" maps to cyan, "perfect_clear" maps to gold
- [x] 4.5 Add test: double-spawn guard — flag logic correctly suppresses the zero-delay handler when delay > 0 path has already fired

## 5. Verify

- [x] 5.1 Run the full GUT test suite and fix any failures
