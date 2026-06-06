## Why

The game has no way to control window size or go fullscreen, which limits playability across different monitor sizes and is a basic expectation for a desktop game. The base viewport is also 1440×900 (8:5), which is not a standard aspect ratio — switching to 1600×900 (16:9) aligns with the most common modern display standard and provides clean window size presets.

## What Changes

- **BREAKING**: Base viewport changes from 1440×900 to 1600×900 in `project.godot` — any UI elements with fixed pixel offsets close to the right edge of the 1440px canvas may shift (audit required)
- Window mode toggle added to Settings: Windowed / Fullscreen
- Window size presets added to Settings (windowed only): Small (1280×720), Medium (1600×900), Large (1920×1080)
- Display settings persisted to `user://settings.cfg` under a `[display]` section
- `Settings.apply_saved_display()` static method added, called at startup from `RunState._ready()`
- Window size buttons are present on all platforms but are a no-op in web builds (HTML5 ignores `DisplayServer.window_set_size`)

## Capabilities

### New Capabilities

- `display-settings`: Player-controlled window mode and window size, persisted across sessions and applied at startup

### Modified Capabilities

_(none — no existing specs changed)_

## Impact

- `game/project.godot` — viewport width 1440 → 1600
- `game/scenes/screens/settings.gd` — new window mode/size rows, load/save, static apply helper
- `game/scenes/screens/settings.tscn` — two new UI rows
- `game/autoloads/run_state.gd` — one new call in `_ready()`
- No board, layout, or gameplay files touched (1600×900 same height as 1440×900, board at Vector2(340, 64) fits without changes)
