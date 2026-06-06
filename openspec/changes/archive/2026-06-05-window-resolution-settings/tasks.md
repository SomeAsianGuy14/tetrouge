## 1. Viewport Base Change

- [x] 1.1 In `game/project.godot`, change `window/size/viewport_width` from `1440` to `1600`
- [x] 1.2 Audit all `.tscn` files for fixed pixel offsets that assumed a 1440px-wide canvas — fix any elements that sit outside the new 1600px width or look broken in the Godot Editor

## 2. Settings Script — Display Logic

- [x] 2.1 Add `WINDOW_SIZE_PRESETS` const to `settings.gd`: `[Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]` with display labels `["Small", "Medium", "Large"]`
- [x] 2.2 Add `_window_mode: String` (`"windowed"` or `"fullscreen"`) and `_window_size: Vector2i` instance variables
- [x] 2.3 Add `_on_window_mode_changed(mode: String)` — calls `DisplayServer.window_set_mode`, saves, and shows/hides the size row
- [x] 2.4 Add `_on_window_size_preset(size: Vector2i)` — calls `DisplayServer.window_set_size`, saves
- [x] 2.5 Extend `_load_settings()` to read `[display]` section: `window_mode` (default `"windowed"`) and `window_size` width/height (default 1600×900); call `_select_window_preset` to highlight the active button
- [x] 2.6 Extend `_save_settings()` to write `window_mode`, `window_width`, `window_height` to the `[display]` section
- [x] 2.7 Add `static func apply_saved_display() -> void` — loads `[display]` from `user://settings.cfg` and calls `DisplayServer` APIs to apply mode and size (windowed size only applied when mode is `"windowed"`)

## 3. Startup Hook

- [x] 3.1 In `game/autoloads/run_state.gd` `_ready()`, call `Settings.apply_saved_display()` alongside the existing `Settings.apply_saved_bindings()` call

## 4. Settings Scene — UI Rows

- [x] 4.1 Add a `WindowModeRow` (`HBoxContainer`) to `settings.tscn` with a `Label` ("Window") and two toggle `Button`s ("Windowed", "Fullscreen") — insert above the DAS row
- [x] 4.2 Add a `WindowSizeRow` (`HBoxContainer`) to `settings.tscn` with a `Label` ("Size") and three `Button`s ("Small", "Medium", "Large") using the same `ButtonGroup` / `toggle_mode` pattern as DAS/ARR/SDF — insert below `WindowModeRow`
- [x] 4.3 Wire `WindowModeRow` buttons to `_on_window_mode_changed` and `WindowSizeRow` buttons to `_on_window_size_preset` in `settings.gd` `_ready()`
- [x] 4.4 Ensure `WindowSizeRow` visibility is toggled off when fullscreen is active and on when windowed

## 5. Testing

- [x] 5.1 Add test `test_apply_saved_display_defaults_to_windowed_medium`: verify that when no `[display]` section exists in settings, `apply_saved_display` resolves to windowed mode at 1600×900
- [x] 5.2 Add test `test_window_size_preset_selection`: verify that `_select_window_preset` highlights the correct button for each of the three preset sizes
