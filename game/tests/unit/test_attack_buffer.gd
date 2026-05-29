extends GutTest

# Tests cover the packet queue helpers on RunManager.
# RunManager is instantiated without a scene tree so @onready vars are null;
# the implementation guards all scene-dependent calls with null checks.

var _saved_techniques: Array
var _managers: Array = []

func before_each() -> void:
	_saved_techniques = RunState.techniques.duplicate()
	RunState.techniques = []
	_managers = []

func after_each() -> void:
	RunState.techniques = _saved_techniques
	for m in _managers:
		m.free()
	_managers = []

func _make_manager(interval: float = 10.0, quota: int = 999) -> RunManager:
	var rm := RunManager.new()
	var cfg := RoundConfig.new()
	cfg.garbage_interval_min = interval
	cfg.garbage_interval_max = interval
	cfg.garbage_lines_min = 1
	cfg.garbage_lines_max = 1
	cfg.quota = quota
	rm.current_config = cfg
	rm._next_garbage_interval = interval
	_managers.append(rm)
	return rm

# ── Buffer accumulation ───────────────────────────────────────────────────

func test_garbage_timer_fire_appends_packet() -> void:
	var rm := _make_manager(5.0)
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm._garbage_packets.size(), 1, "One packet appended on timer fire")

func test_garbage_timer_fire_packet_has_correct_lines() -> void:
	var rm := _make_manager(5.0)
	rm.current_config.garbage_lines_min = 3
	rm.current_config.garbage_lines_max = 3
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm._garbage_packets[0].lines, 3)
	assert_false(rm._garbage_packets[0].is_filth)

func test_three_timer_fires_accumulate_three_packets() -> void:
	var rm := _make_manager(5.0)
	rm._tick_enemy_garbage(5.1)
	rm._tick_enemy_garbage(5.1)
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm._garbage_packets.size(), 3)

func test_filth_modifier_appends_individual_packets() -> void:
	var rm := _make_manager(5.0)
	rm.current_config.garbage_individual_lines = true
	rm.current_config.garbage_lines_min = 3
	rm.current_config.garbage_lines_max = 3
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm._garbage_packets.size(), 3, "3 individual filth packets")
	assert_true(rm._garbage_packets[0].is_filth)
	assert_eq(rm._garbage_packets[0].lines, 1)

func test_reflection_modifier_does_not_append_on_timer_fire() -> void:
	var rm := _make_manager(5.0)
	rm.current_config.reflect_ratio = 0.5
	rm._tick_enemy_garbage(5.1)
	assert_true(rm._garbage_packets.is_empty(), "Reflection boss sends no garbage on timer")

# ── Counter-attack drain ──────────────────────────────────────────────────

func test_drain_fully_cancels_packet_when_attack_exceeds_buffer() -> void:
	var rm := _make_manager()
	rm._garbage_packets = [{lines = 2, is_filth = false}]
	var to_quota := rm._drain_attack(3)
	assert_eq(to_quota, 1, "1 line should reach quota")
	assert_true(rm._garbage_packets.is_empty(), "packet fully consumed")

func test_drain_partial_when_attack_less_than_packet_lines() -> void:
	var rm := _make_manager()
	rm._garbage_packets = [{lines = 4, is_filth = false}]
	var to_quota := rm._drain_attack(2)
	assert_eq(to_quota, 0, "No lines reach quota")
	assert_eq(rm._garbage_packets[0].lines, 2, "2 lines remain in packet")

func test_drain_zero_buffer_full_attack_goes_to_quota() -> void:
	var rm := _make_manager()
	rm._garbage_packets = []
	var to_quota := rm._drain_attack(3)
	assert_eq(to_quota, 3, "All 3 lines reach quota")
	assert_true(rm._garbage_packets.is_empty())

# ── Round-end reset ───────────────────────────────────────────────────────

func test_packet_queue_cleared_on_round_end() -> void:
	var rm := _make_manager()
	rm._garbage_packets = [{lines = 7, is_filth = false}]
	rm._garbage_packets = []
	assert_true(rm._garbage_packets.is_empty(), "Queue cleared on round end")
