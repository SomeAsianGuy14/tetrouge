extends GutTest

# ── Shared state ──────────────────────────────────────────────────────────────

var _rm: RunManager
var _saved_keystones: Array
var _saved_techniques: Array
var _saved_coins: int

func before_each() -> void:
	_saved_keystones = RunState.keystones.duplicate()
	_saved_techniques = RunState.techniques.duplicate()
	_saved_coins = Economy.coins
	RunState.keystones = []
	RunState.techniques = []
	Economy.coins = 0
	_rm = RunManager.new()
	_rm.current_config = RoundConfig.new()

func after_each() -> void:
	_rm.free()
	RunState.keystones = _saved_keystones
	RunState.techniques = _saved_techniques
	Economy.coins = _saved_coins

# ── _schedule_popups ──────────────────────────────────────────────────────────

func _make_technique_event(name: String, atk: int, coins: int = 0) -> Dictionary:
	return {"name": name, "id": name.to_lower(), "attack": atk, "coins": coins}

func test_schedule_popups_zero_delay_all_entries_at_time_zero() -> void:
	var events := [
		_make_technique_event("Escalation", 2),
		_make_technique_event("Follow Up", 1),
	]
	_rm._schedule_popups(events, 0.0)
	assert_eq(_rm._popup_schedule.size(), 2, "Both events scheduled")
	for entry in _rm._popup_schedule:
		assert_eq(entry.time, 0.0, "Zero delay: all entries at t=0")

func test_schedule_popups_with_delay_spreads_entries() -> void:
	var events := [
		_make_technique_event("A", 1),
		_make_technique_event("B", 2),
		_make_technique_event("C", 3),
	]
	_rm._schedule_popups(events, 0.6)
	assert_eq(_rm._popup_schedule.size(), 3)
	assert_eq(_rm._popup_schedule[0].time, 0.0, "First entry at t=0")
	assert_gt(_rm._popup_schedule[1].time, 0.0, "Second entry after t=0")
	assert_gt(_rm._popup_schedule[2].time, _rm._popup_schedule[1].time, "Third after second")

func test_schedule_popups_no_cap_six_events_produce_six_entries() -> void:
	var events: Array = []
	for i in range(6):
		events.append(_make_technique_event("Technique%d" % i, i + 1))
	_rm._schedule_popups(events, 0.5)
	assert_eq(_rm._popup_schedule.size(), 6, "All 6 events scheduled (no cap)")

func test_schedule_popups_technique_attack_uses_white_color() -> void:
	var events := [_make_technique_event("Escalation", 2)]
	_rm._schedule_popups(events, 0.0)
	assert_eq(_rm._popup_schedule[0].color, Color.WHITE)

func test_schedule_popups_economy_only_uses_gold_color() -> void:
	var events := [{"name": "Economy", "id": "economy", "attack": 0, "coins": 1}]
	_rm._schedule_popups(events, 0.0)
	assert_eq(_rm._popup_schedule[0].color, Color(1.0, 0.85, 0.0))

func test_schedule_popups_keystone_event_uses_blue_color() -> void:
	var events := [{"name": "Great Sword", "id": "great_sword", "bonus": 2}]
	_rm._schedule_popups(events, 0.0)
	assert_eq(_rm._popup_schedule[0].color, Color(0.5, 0.8, 1.0))

func test_end_round_clears_popup_schedule() -> void:
	_rm._popup_schedule = [{"time": 0.0, "text": "test", "color": Color.WHITE, "id": "", "index": 0, "total": 1}]
	_rm._popup_elapsed = 0.3
	_rm._round_ended = false
	_rm._end_round(false)
	assert_eq(_rm._popup_schedule.size(), 0, "Schedule cleared on round end")
	assert_eq(_rm._popup_elapsed, 0.0, "Elapsed reset on round end")
