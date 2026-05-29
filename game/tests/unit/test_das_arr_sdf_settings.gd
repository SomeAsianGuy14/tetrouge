extends GutTest

# ── Shared state ──────────────────────────────────────────────────────────

const SettingsScript = preload("res://scenes/screens/settings.gd")
const SETTINGS_PATH := "user://settings.cfg"

var _settings_existed: bool = false
var _saved_settings: String = ""

func before_each() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		_settings_existed = true
		_saved_settings = FileAccess.get_file_as_string(SETTINGS_PATH)
		DirAccess.remove_absolute(SETTINGS_PATH)
	else:
		_settings_existed = false
		_saved_settings = ""

func after_each() -> void:
	DirAccess.remove_absolute(SETTINGS_PATH)
	if _settings_existed:
		var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		if f:
			f.store_string(_saved_settings)
			f.close()

# ── snap_to_nearest ───────────────────────────────────────────────────────

func test_snap_to_nearest_returns_exact_match() -> void:
	assert_eq(SettingsScript.snap_to_nearest(130, SettingsScript.DAS_PRESETS), 130)

func test_snap_to_nearest_rounds_to_closest() -> void:
	assert_eq(SettingsScript.snap_to_nearest(167, SettingsScript.DAS_PRESETS), 160)

func test_snap_to_nearest_clamps_below_min() -> void:
	assert_eq(SettingsScript.snap_to_nearest(0, SettingsScript.ARR_PRESETS), 20)

# ── Static load helpers — defaults ────────────────────────────────────────

func test_load_das_default_when_no_config() -> void:
	assert_almost_eq(SettingsScript.load_das(), 0.130, 0.0001)

func test_load_arr_default_when_no_config() -> void:
	assert_almost_eq(SettingsScript.load_arr(), 0.040, 0.0001)

func test_load_sdf_default_when_no_config() -> void:
	assert_eq(SettingsScript.load_sdf(), 10)

# ── Static load helpers — snap behaviour ─────────────────────────────────

func test_load_sdf_snaps_legacy_value() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("timing", "sdf_x", 20)
	cfg.save(SETTINGS_PATH)
	assert_eq(SettingsScript.load_sdf(), 20)

# ── Board SDF wiring ──────────────────────────────────────────────────────

func test_board_uses_sdf_multiplier_for_soft_drop() -> void:
	var board := TetrisBoard.new()
	var cfg := RoundConfig.new()
	cfg.instant_soft_drop = false
	board.config = cfg
	board.sdf_multiplier = 5
	board.soft_dropping = true
	# delta = 0.1 → accumulator = 5 * 0.1 = 0.5; stays below 1.0 so no move is attempted
	board._handle_gravity(0.1)
	assert_almost_eq(board.gravity_accumulator, 0.5, 0.001)
	board.free()
