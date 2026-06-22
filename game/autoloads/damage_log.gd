extends Node

var _enabled: bool = false
var _file: FileAccess = null

var _round_sum_base: int = 0
var _round_sum_technique: int = 0
var _round_sum_mastery: int = 0
var _round_sum_honed: int = 0
var _round_sum_keystone_flat: int = 0
var _round_sum_consumable_flat: int = 0
var _round_sum_tag_bonus: int = 0
var _round_sum_final: int = 0
var _run_total_damage: int = 0

func _ready() -> void:
	_enabled = OS.is_debug_build()
	if _enabled:
		RunState.build_changed.connect(log_build)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if _file != null:
			_file.close()
			_file = null

func start_run(seed_val: int, ascension: int) -> void:
	if not _enabled:
		return
	if _file != null:
		_file.close()
		_file = null
	if not DirAccess.dir_exists_absolute("user://damage_logs"):
		DirAccess.make_dir_absolute("user://damage_logs")
	var ts := Time.get_datetime_string_from_system().replace("-", "").replace(":", "").replace("T", "_")
	var path := "user://damage_logs/run_%s.csv" % ts
	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		return
	_file.store_csv_line(PackedStringArray([
		"row_type", "floor", "room_tier", "event_type",
		"base", "technique", "mastery", "honed",
		"keystone_flat", "consumable_flat", "surge_mult", "keystone_mult",
		"amplified_mult", "tag_bonus", "final",
		"quota", "time_elapsed", "pieces_placed",
		"result", "total_damage",
		"seed", "ascension", "timestamp",
		"keystones", "techniques", "consumables",
	]))
	_file.store_csv_line(_make_row("RUN_START", {"seed": seed_val, "ascension": ascension, "timestamp": Time.get_datetime_string_from_system()}))
	_reset_accumulators()

func log_build() -> void:
	if not _enabled or _file == null:
		return
	var ks_ids: PackedStringArray = []
	for ks in RunState.keystones:
		ks_ids.append(ks.id)
	var tech_ids: PackedStringArray = []
	for t in RunState.techniques:
		tech_ids.append(t.id)
	var con_ids: PackedStringArray = []
	for c in RunState.consumables:
		con_ids.append(c.id)
	_file.store_csv_line(_make_row("BUILD", {
		"keystones": ";".join(ks_ids),
		"techniques": ";".join(tech_ids),
		"consumables": ";".join(con_ids),
	}))

func log_attack(p_floor: int, room_tier: String, event_type: String,
		base: int, technique: int, mastery: int, honed: int,
		keystone_flat: int, consumable_flat: int,
		surge_mult: float, keystone_mult: float, amplified_mult: float,
		tag_bonus: int, final_dmg: int) -> void:
	if not _enabled or _file == null:
		return
	_file.store_csv_line(_make_row("ATTACK", {
		"floor": p_floor, "room_tier": room_tier, "event_type": event_type,
		"base": base, "technique": technique, "mastery": mastery, "honed": honed,
		"keystone_flat": keystone_flat, "consumable_flat": consumable_flat,
		"surge_mult": surge_mult, "keystone_mult": keystone_mult,
		"amplified_mult": amplified_mult, "tag_bonus": tag_bonus, "final": final_dmg,
	}))
	_round_sum_base += base
	_round_sum_technique += technique
	_round_sum_mastery += mastery
	_round_sum_honed += honed
	_round_sum_keystone_flat += keystone_flat
	_round_sum_consumable_flat += consumable_flat
	_round_sum_tag_bonus += tag_bonus
	_round_sum_final += final_dmg

func log_round_end(p_floor: int, room_tier: String, quota: int,
		time_elapsed: float, pieces_placed: int) -> void:
	if not _enabled or _file == null:
		return
	_file.store_csv_line(_make_row("ROUND_END", {
		"floor": p_floor, "room_tier": room_tier, "quota": quota,
		"base": _round_sum_base, "technique": _round_sum_technique,
		"mastery": _round_sum_mastery, "honed": _round_sum_honed,
		"keystone_flat": _round_sum_keystone_flat,
		"consumable_flat": _round_sum_consumable_flat,
		"tag_bonus": _round_sum_tag_bonus, "final": _round_sum_final,
		"time_elapsed": time_elapsed, "pieces_placed": pieces_placed,
	}))
	_run_total_damage += _round_sum_final
	_reset_round_accumulators()

func log_run_end(result: String) -> void:
	if not _enabled or _file == null:
		return
	_file.store_csv_line(_make_row("RUN_END", {
		"result": result, "total_damage": _run_total_damage,
	}))
	_file.close()
	_file = null

func _reset_accumulators() -> void:
	_run_total_damage = 0
	_reset_round_accumulators()

func _reset_round_accumulators() -> void:
	_round_sum_base = 0
	_round_sum_technique = 0
	_round_sum_mastery = 0
	_round_sum_honed = 0
	_round_sum_keystone_flat = 0
	_round_sum_consumable_flat = 0
	_round_sum_tag_bonus = 0
	_round_sum_final = 0

const _COLUMNS := [
	"row_type", "floor", "room_tier", "event_type",
	"base", "technique", "mastery", "honed",
	"keystone_flat", "consumable_flat", "surge_mult", "keystone_mult",
	"amplified_mult", "tag_bonus", "final",
	"quota", "time_elapsed", "pieces_placed",
	"result", "total_damage",
	"seed", "ascension", "timestamp",
	"keystones", "techniques", "consumables",
]

func _make_row(row_type: String, data: Dictionary) -> PackedStringArray:
	var row: PackedStringArray = []
	for col in _COLUMNS:
		if col == "row_type":
			row.append(row_type)
		elif data.has(col):
			row.append(str(data[col]))
		else:
			row.append("")
	return row
