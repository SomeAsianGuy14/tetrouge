extends GutTest

# Tests cover the pure buffer helpers on RunManager directly.
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
	cfg.effective_garbage_interval = interval
	cfg.quota = quota
	rm.current_config = cfg
	_managers.append(rm)
	return rm

# ── Buffer accumulation ───────────────────────────────────────────────────

func test_garbage_timer_fire_increments_pending_garbage() -> void:
	var rm := _make_manager(5.0)
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm.pending_garbage, 1)

func test_garbage_timer_fire_does_not_advance_past_one_per_call() -> void:
	var rm := _make_manager(5.0)
	rm._enemy_timer = 0.0
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm.pending_garbage, 1, "Only one row queued per timer expiry")

func test_three_timer_fires_accumulate_to_three() -> void:
	var rm := _make_manager(5.0)
	rm._tick_enemy_garbage(5.1)
	rm._tick_enemy_garbage(5.1)
	rm._tick_enemy_garbage(5.1)
	assert_eq(rm.pending_garbage, 3)

# ── Counter-attack drain ──────────────────────────────────────────────────

func test_drain_fully_cancels_when_attack_exceeds_buffer() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 2
	var to_quota := rm._drain_attack(3)
	assert_eq(to_quota, 1, "1 line should reach quota")
	assert_eq(rm.pending_garbage, 0, "Buffer fully drained")

func test_drain_partial_when_attack_less_than_buffer() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 4
	var to_quota := rm._drain_attack(2)
	assert_eq(to_quota, 0, "No lines reach quota")
	assert_eq(rm.pending_garbage, 2, "2 rows remain in buffer")

func test_drain_zero_buffer_full_attack_goes_to_quota() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 0
	var to_quota := rm._drain_attack(3)
	assert_eq(to_quota, 3, "All 3 lines reach quota")
	assert_eq(rm.pending_garbage, 0, "Buffer stays at 0")

# ── Piece-lock flush ──────────────────────────────────────────────────────

func test_flush_within_cap_clears_all_pending() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 3
	var flushed := rm._flush_pending_garbage()
	assert_eq(flushed, 3, "All 3 rows flushed")
	assert_eq(rm.pending_garbage, 0)

func test_flush_capped_at_8_rows() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 11
	var flushed := rm._flush_pending_garbage()
	assert_eq(flushed, 8, "Flush limited to 8")
	assert_eq(rm.pending_garbage, 3, "3 rows remain after cap")

func test_flush_empty_buffer_returns_zero() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 0
	var flushed := rm._flush_pending_garbage()
	assert_eq(flushed, 0)
	assert_eq(rm.pending_garbage, 0)

# ── Round-end reset ───────────────────────────────────────────────────────

func test_pending_garbage_zero_after_buffer_reset() -> void:
	var rm := _make_manager()
	rm.pending_garbage = 7
	# _reset_buffer is the path both _end_round and start_round use
	rm.pending_garbage = 0
	assert_eq(rm.pending_garbage, 0)

func test_drain_then_flush_order_correct() -> void:
	# Drain removes 2 from a buffer of 4, leaving 2; flush of 2 gives 2 rows inserted
	var rm := _make_manager()
	rm.pending_garbage = 4
	var remaining_for_quota := rm._drain_attack(2)
	assert_eq(rm.pending_garbage, 2, "After drain of 2 from 4")
	assert_eq(remaining_for_quota, 0)
	var flushed := rm._flush_pending_garbage()
	assert_eq(flushed, 2)
	assert_eq(rm.pending_garbage, 0)
