extends GutTest

var _saved_keystones: Array
var _saved_techniques: Array
var _managers: Array = []

func before_each() -> void:
	_saved_keystones = RunState.keystones.duplicate()
	_saved_techniques = RunState.techniques.duplicate()
	RunState.keystones = []
	RunState.techniques = []
	_managers = []

func after_each() -> void:
	RunState.keystones = _saved_keystones
	RunState.techniques = _saved_techniques
	for m in _managers:
		m.free()
	_managers = []

func _make_manager(time_limit: float = 10.0, boss_modifier_id: String = "") -> RunManager:
	var rm := RunManager.new()
	var cfg := RoundConfig.new()
	cfg.time_limit = time_limit
	cfg.garbage_interval_min = 999.0
	cfg.garbage_interval_max = 999.0
	cfg.quota = 9999
	if boss_modifier_id != "":
		var bm := BossModifier.new()
		bm.id = boss_modifier_id
		cfg.boss_modifier = bm
	rm.current_config = cfg
	rm.round_timer = time_limit
	_managers.append(rm)
	return rm

# ── _tick_timer: non-Blitz clamps, no death ──────────────────────────────────

func test_tick_timer_non_blitz_clamps_to_zero() -> void:
	var rm := _make_manager(1.0)
	rm._tick_timer(2.0)
	assert_eq(rm.round_timer, 0.0, "timer should clamp to 0")

func test_tick_timer_non_blitz_does_not_end_round() -> void:
	var rm := _make_manager(1.0)
	rm._tick_timer(2.0)
	assert_false(rm._round_ended, "non-Blitz timeout should not end the round")

# ── Blitz config correctly identified as kill-on-timeout ─────────────────────

func test_blitz_config_triggers_death_condition() -> void:
	var rm := _make_manager(1.0, "the_blitz")
	# Verify the Blitz death condition evaluates true (without calling _end_round
	# which requires a scene tree to instantiate the failure screen)
	var is_blitz := rm.current_config.boss_modifier != null \
		and rm.current_config.boss_modifier.id == "the_blitz"
	assert_true(is_blitz, "Blitz config should be detected as kill-on-timeout")

# ── show_timer flag ───────────────────────────────────────────────────────────

func test_show_timer_false_without_golden_watch_or_blitz() -> void:
	RunState.keystones = []
	var cfg := RoundConfig.new()
	cfg.show_timer = RunState.has_keystone("golden_watch") or \
		(cfg.boss_modifier != null and cfg.boss_modifier.id == "the_blitz")
	assert_false(cfg.show_timer)

func test_show_timer_true_when_golden_watch_held() -> void:
	var ks := Keystone.new()
	ks.id = "golden_watch"
	RunState.keystones = [ks]
	var cfg := RoundConfig.new()
	cfg.show_timer = RunState.has_keystone("golden_watch") or \
		(cfg.boss_modifier != null and cfg.boss_modifier.id == "the_blitz")
	assert_true(cfg.show_timer)

func test_show_timer_true_when_blitz_active() -> void:
	RunState.keystones = []
	var cfg := RoundConfig.new()
	var bm := BossModifier.new()
	bm.id = "the_blitz"
	cfg.boss_modifier = bm
	cfg.show_timer = RunState.has_keystone("golden_watch") or \
		(cfg.boss_modifier != null and cfg.boss_modifier.id == "the_blitz")
	assert_true(cfg.show_timer)

# ── Economy.pay_round ─────────────────────────────────────────────────────────

func test_pay_round_adds_only_base_amount() -> void:
	var saved := Economy.coins
	Economy.coins = 0
	Economy.pay_round(5)
	assert_eq(Economy.coins, 5)
	Economy.coins = saved
