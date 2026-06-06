## Context

The project currently has no window management. `project.godot` sets a fixed 1440×900 viewport with `canvas_items` stretch and `expand` aspect — the canvas scales to whatever window the OS provides, but there is no in-game control over that window.

The Settings screen (`settings.gd` / `settings.tscn`) already has an established pattern for persisted options:
- Const preset arrays → `_build_preset_buttons` → `_load_settings` / `_save_settings` → static `load_*` helpers
- All settings stored in `user://settings.cfg` via `ConfigFile`
- `Settings.apply_saved_bindings()` is called from `RunState._ready()` at autoload startup

Display settings will follow this exact pattern. The only structural addition is a `apply_saved_display()` static method called alongside `apply_saved_bindings()` in `RunState._ready()`.

## Goals / Non-Goals

**Goals:**
- Change base viewport from 1440×900 to 1600×900
- Add Windowed / Fullscreen toggle to Settings
- Add Small / Medium / Large window size presets to Settings (windowed mode only)
- Persist display preferences to `user://settings.cfg` under `[display]`
- Apply saved display settings at startup via a static helper

**Non-Goals:**
- Per-platform conditional UI (size buttons shown on web even though they are no-ops)
- Custom resolution input (free-form width/height)
- Content scale / DPI scaling
- Borderless windowed mode (fullscreen uses OS fullscreen only)
- Layout repositioning of any game scene (the 1600×900 change is height-neutral)

## Decisions

### D1 — Base resolution: 1600×900, not 1920×1080

The existing board is positioned at `Vector2(340, 64)` and is 360×720 px. The board bottom reaches y=784. At 900px height this fits with 116px to spare and requires **zero layout changes**. Moving to 1920×1080 would add +180px height and +480px width — the board would sit noticeably left-skewed and the layout would need repositioning. 1600×900 gives 16:9 with no layout disruption.

Window presets are exact multiples of the 1600×900 base:
```
Small   1280 × 720   = 1600×900 × 0.8   (16:9 ✓, clean ✓)
Medium  1600 × 900   = 1600×900 × 1.0   (16:9 ✓, native)
Large   1920 × 1080  = 1600×900 × 1.2   (16:9 ✓, clean ✓)
```

### D2 — Stretch mode stays `canvas_items + expand`

`canvas_items` scales UI elements at the window level — the game renders at 1600×900 internally and the OS scales up or down. `expand` means on a wider-than-16:9 display more canvas is revealed rather than letterboxing. This is the correct choice for a Tetris game: extra horizontal space just reveals more of the HUD area rather than stretching content.

**Alternative considered:** Switch to `keep` aspect for black bars. Rejected — `expand` is already working well and letterboxing adds visual clutter for no gameplay benefit.

### D3 — Window mode stored as a string enum, not an integer

`settings.cfg` stores `window_mode = "windowed"` or `"fullscreen"`. String values are self-documenting and safe to add new modes to later (e.g., `"borderless"`). Integer indices would require knowing the enum order.

### D4 — Window size applied via DisplayServer, not ProjectSettings

`DisplayServer.window_set_size(Vector2i)` and `DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)` apply immediately at runtime. `ProjectSettings.set()` changes the project config, not the live window. `DisplayServer` is the correct API.

In HTML5, `window_set_size` is silently ignored — no guard is needed. Fullscreen triggers the browser's Fullscreen API via the same `DisplayServer.window_set_mode` call.

### D5 — apply_saved_display() called from RunState._ready()

`RunState` is the first autoload in `project.godot`. Calling `apply_saved_display()` there ensures display settings are applied before any scene renders. This mirrors how `apply_saved_bindings()` is already handled in the same file.

## Risks / Trade-offs

- **1600→1440px edge case** — Any UI element currently positioned with a fixed offset near x=1440 will now have 160px more canvas to its right. The `ModifierBigLabel` in `run_manager.tscn` is at `offset_left=876`, well within 1600px. A full audit of fixed pixel offsets in all `.tscn` files is a task step.
- **Fullscreen on web** — `DisplayServer.window_set_mode(WINDOW_MODE_FULLSCREEN)` in HTML5 requires a user gesture (button press). The Settings screen is only reachable via a button press, so this is satisfied naturally.
- **Saved "Large" on a small monitor** — A player who saves Large (1920×1080) and later runs the game on a 1366×768 monitor will get a window that overflows. Godot does not auto-clamp window size. Mitigation: acceptable for now; could add a screen-size guard in a future pass.

## Migration Plan

1. Change `viewport_width` in `project.godot` — immediate effect; Godot Editor will reopen at the new canvas size
2. Audit `.tscn` files for any fixed offsets that assumed 1440px width — fix any that break
3. Implement settings UI and persistence
4. Test windowed presets and fullscreen on desktop; verify size buttons are harmless no-ops in a web build

## Open Questions

_(none)_
