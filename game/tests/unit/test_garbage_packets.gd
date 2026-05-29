extends GutTest

# Helpers that mirror RunManager's _drain_attack and _flush_pending_garbage logic

func _drain(packets: Array, attack: int) -> int:
	var remaining := attack
	while remaining > 0 and not packets.is_empty():
		var packet = packets[0]
		var d := mini(remaining, packet.lines)
		packet.lines -= d
		remaining -= d
		if packet.lines == 0:
			packets.remove_at(0)
	return remaining  # lines that reach quota after drain

func _flush(packets: Array, capacity: int) -> int:
	var remaining := capacity
	while remaining > 0 and not packets.is_empty():
		var packet = packets[0]
		var f := mini(remaining, packet.lines)
		packet.lines -= f
		remaining -= f
		if packet.lines == 0:
			packets.remove_at(0)
	return capacity - remaining  # lines actually flushed

# ── Drain ─────────────────────────────────────────────────────────────────

func test_drain_fully_removes_packet_when_attack_exceeds_lines() -> void:
	var packets := [{lines = 2, is_filth = false}]
	var to_quota := _drain(packets, 3)
	assert_eq(to_quota, 1, "1 line should reach quota after draining 2")
	assert_true(packets.is_empty(), "packet should be removed after full drain")

func test_drain_partially_reduces_packet_in_place() -> void:
	var packets := [{lines = 4, is_filth = false}]
	var to_quota := _drain(packets, 2)
	assert_eq(to_quota, 0, "no lines should reach quota when attack is less than buffer")
	assert_eq(packets.size(), 1, "packet should remain")
	assert_eq(packets[0].lines, 2, "packet lines should be reduced by 2")

func test_drain_chains_across_multiple_packets() -> void:
	var packets := [{lines = 1, is_filth = false}, {lines = 3, is_filth = false}]
	var to_quota := _drain(packets, 3)
	assert_eq(to_quota, 0, "all attack consumed draining 2 packets; nothing reaches quota")
	assert_eq(packets.size(), 1, "first packet consumed, one remains")
	assert_eq(packets[0].lines, 1, "second packet reduced from 3 to 1")

func test_drain_empty_queue_full_attack_goes_to_quota() -> void:
	var packets: Array = []
	var to_quota := _drain(packets, 5)
	assert_eq(to_quota, 5, "all 5 lines go to quota when queue is empty")

# ── Flush ─────────────────────────────────────────────────────────────────

func test_flush_consumes_all_lines_within_cap() -> void:
	var packets := [{lines = 3, is_filth = false}]
	var flushed := _flush(packets, 8)
	assert_eq(flushed, 3, "3 lines flushed")
	assert_true(packets.is_empty(), "packet fully consumed")

func test_flush_caps_at_8_lines_leaving_remainder() -> void:
	var packets := [{lines = 11, is_filth = false}]
	var flushed := _flush(packets, 8)
	assert_eq(flushed, 8, "only 8 lines flushed")
	assert_eq(packets.size(), 1, "packet partially consumed")
	assert_eq(packets[0].lines, 3, "3 lines remain in packet")

func test_flush_does_nothing_on_empty_queue() -> void:
	var packets: Array = []
	var flushed := _flush(packets, 8)
	assert_eq(flushed, 0, "0 lines flushed from empty queue")

func test_flush_drains_across_packets_up_to_cap() -> void:
	var packets := [{lines = 5, is_filth = false}, {lines = 5, is_filth = false}]
	var flushed := _flush(packets, 8)
	assert_eq(flushed, 8, "8 lines flushed across two packets")
	assert_eq(packets.size(), 1, "first packet consumed, second partially consumed")
	assert_eq(packets[0].lines, 2, "2 lines remain in second packet")

# ── Reflection ────────────────────────────────────────────────────────────

func test_reflection_half_of_4_is_2() -> void:
	var to_quota := 4
	var reflect_lines := floori(to_quota * 0.5)
	assert_eq(reflect_lines, 2, "floor(4 * 0.5) = 2")

func test_reflection_odd_damage_floors_down() -> void:
	var to_quota := 3
	var reflect_lines := floori(to_quota * 0.5)
	assert_eq(reflect_lines, 1, "floor(3 * 0.5) = 1")

func test_reflection_zero_damage_does_not_produce_packet() -> void:
	var to_quota := 0
	var reflect_lines := floori(to_quota * 0.5)
	assert_eq(reflect_lines, 0, "floor(0 * 0.5) = 0; no packet should be appended")

# ── Round-end reset ───────────────────────────────────────────────────────

func test_clearing_packets_array_empties_queue() -> void:
	var packets := [{lines = 3, is_filth = false}, {lines = 1, is_filth = true}]
	packets = []
	assert_true(packets.is_empty(), "queue cleared on round end")
