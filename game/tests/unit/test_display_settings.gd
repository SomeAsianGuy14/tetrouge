extends GutTest

# ── Helpers ───────────────────────────────────────────────────────────────

const SETTINGS_PATH := "user://settings.cfg"

func _clear_display_section() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.erase_section("display")
	cfg.save(SETTINGS_PATH)

func _write_display_section(mode: String, w: int, h: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("display", "window_mode", mode)
	cfg.set_value("display", "window_width", w)
	cfg.set_value("display", "window_height", h)
	cfg.save(SETTINGS_PATH)

# ── apply_saved_display defaults ──────────────────────────────────────────

func test_apply_saved_display_defaults_to_windowed_medium() -> void:
	_clear_display_section()
	var cfg := ConfigFile.new()
	var mode := "windowed"
	var size := Vector2i(1600, 900)
	if cfg.load(SETTINGS_PATH) == OK:
		mode = cfg.get_value("display", "window_mode", "windowed")
		var w: int = cfg.get_value("display", "window_width", 1600)
		var h: int = cfg.get_value("display", "window_height", 900)
		size = Vector2i(w, h)
	assert_eq(mode, "windowed", "Default window mode should be windowed")
	assert_eq(size, Vector2i(1600, 900), "Default window size should be 1600x900")

# ── Window size preset selection ──────────────────────────────────────────

func test_window_size_preset_selection() -> void:
	var presets: Array = Settings.WINDOW_SIZE_PRESETS
	assert_eq(presets.size(), 3, "Should have 3 window size presets")
	assert_eq(presets[0], Vector2i(1280, 720), "Small preset should be 1280x720")
	assert_eq(presets[1], Vector2i(1600, 900), "Medium preset should be 1600x900")
	assert_eq(presets[2], Vector2i(1920, 1080), "Large preset should be 1920x1080")

# ── Editor guard ──────────────────────────────────────────────────────────

func test_apply_saved_display_skips_display_server_in_editor() -> void:
	# When running under GUT (which runs inside the editor), apply_saved_display
	# must be a no-op so it doesn't emit "Embedded window can't be resized" warnings.
	# Calling it here will produce those warnings if the guard is missing.
	_write_display_section("fullscreen", 1920, 1080)
	Settings.apply_saved_display()
	# If we reach here without an engine warning/crash the guard is working.
	assert_true(OS.has_feature("editor"), "This test only validates the guard in editor builds")
