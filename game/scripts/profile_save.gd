extends Node

const SAVE_PATH := "user://profile.cfg"

func _ready() -> void:
	load_profile()

var highest_beaten: int = -1
var unlocked_ids: Array = []

# Additive stats
var runs_completed: int = 0
var total_damage: int = 0
var total_quad_damage: int = 0
var total_tspin_damage: int = 0
var total_singles: int = 0
var total_doubles: int = 0
var total_triples: int = 0
var total_quads: int = 0
var total_tspin_singles: int = 0
var total_tspin_doubles: int = 0
var total_tspin_triples: int = 0
var total_perfect_clears: int = 0
var victories: int = 0
var total_play_time: float = 0.0

# Lifetime maximums
var highest_combo_chain: int = 0
var highest_b2b: int = 0
var best_single_run_damage: int = 0
var best_mastery: Dictionary = {}

func load_profile() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	highest_beaten = cfg.get_value("ascension", "highest_beaten", -1)
	unlocked_ids = cfg.get_value("unlocks", "unlocked_ids", [])
	runs_completed = cfg.get_value("stats", "runs_completed", 0)
	total_damage = cfg.get_value("stats", "total_damage", 0)
	total_quad_damage = cfg.get_value("stats", "total_quad_damage", 0)
	total_tspin_damage = cfg.get_value("stats", "total_tspin_damage", 0)
	total_singles = cfg.get_value("stats", "total_singles", 0)
	total_doubles = cfg.get_value("stats", "total_doubles", 0)
	total_triples = cfg.get_value("stats", "total_triples", 0)
	total_quads = cfg.get_value("stats", "total_quads", 0)
	total_tspin_singles = cfg.get_value("stats", "total_tspin_singles", 0)
	total_tspin_doubles = cfg.get_value("stats", "total_tspin_doubles", 0)
	total_tspin_triples = cfg.get_value("stats", "total_tspin_triples", 0)
	total_perfect_clears = cfg.get_value("stats", "total_perfect_clears", 0)
	victories = cfg.get_value("stats", "victories", 0)
	total_play_time = cfg.get_value("stats", "total_play_time", 0.0)
	highest_combo_chain = cfg.get_value("stats", "highest_combo_chain", 0)
	highest_b2b = cfg.get_value("stats", "highest_b2b", 0)
	best_single_run_damage = cfg.get_value("stats", "best_single_run_damage", 0)
	best_mastery = cfg.get_value("stats", "best_mastery", {})

func save_profile() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ascension", "highest_beaten", highest_beaten)
	cfg.set_value("unlocks", "unlocked_ids", unlocked_ids)
	cfg.set_value("stats", "runs_completed", runs_completed)
	cfg.set_value("stats", "total_damage", total_damage)
	cfg.set_value("stats", "total_quad_damage", total_quad_damage)
	cfg.set_value("stats", "total_tspin_damage", total_tspin_damage)
	cfg.set_value("stats", "total_singles", total_singles)
	cfg.set_value("stats", "total_doubles", total_doubles)
	cfg.set_value("stats", "total_triples", total_triples)
	cfg.set_value("stats", "total_quads", total_quads)
	cfg.set_value("stats", "total_tspin_singles", total_tspin_singles)
	cfg.set_value("stats", "total_tspin_doubles", total_tspin_doubles)
	cfg.set_value("stats", "total_tspin_triples", total_tspin_triples)
	cfg.set_value("stats", "total_perfect_clears", total_perfect_clears)
	cfg.set_value("stats", "victories", victories)
	cfg.set_value("stats", "total_play_time", total_play_time)
	cfg.set_value("stats", "highest_combo_chain", highest_combo_chain)
	cfg.set_value("stats", "highest_b2b", highest_b2b)
	cfg.set_value("stats", "best_single_run_damage", best_single_run_damage)
	cfg.set_value("stats", "best_mastery", best_mastery)
	cfg.save(SAVE_PATH)

func record_victory(level: int) -> void:
	highest_beaten = max(highest_beaten, level)
	save_profile()

func accumulate_stats(run_stats) -> void:
	runs_completed += 1
	victories += 1
	total_damage += run_stats.total_damage
	total_quad_damage += run_stats.quad_damage
	total_tspin_damage += run_stats.tspin_damage
	total_singles += run_stats.singles
	total_doubles += run_stats.doubles
	total_triples += run_stats.triples
	total_quads += run_stats.quads
	total_tspin_singles += run_stats.tspin_singles
	total_tspin_doubles += run_stats.tspin_doubles
	total_tspin_triples += run_stats.tspin_triples
	total_perfect_clears += run_stats.perfect_clears
	total_play_time += run_stats.run_time
	highest_combo_chain = max(highest_combo_chain, run_stats.highest_combo_chain)
	highest_b2b = max(highest_b2b, run_stats.highest_b2b)
	best_single_run_damage = max(best_single_run_damage, run_stats.total_damage)
	for track in run_stats.mastery_levels:
		best_mastery[track] = max(best_mastery.get(track, 0), run_stats.mastery_levels[track])
	save_profile()
