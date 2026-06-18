class_name RunEndHelpers

# Tie-break priority: highest scoring type wins.
const CLEAR_PRIORITY: Array = [
	"perfect_clear", "quad",
	"tspin_triple", "tspin_double", "tspin_single", "tspin_mini",
	"triple", "double", "single",
]

const CLEAR_DISPLAY_NAMES: Dictionary = {
	"single":        "Single",
	"double":        "Double",
	"triple":        "Triple",
	"quad":          "Quad",
	"tspin_mini":    "T-Spin Mini",
	"tspin_single":  "T-Spin Single",
	"tspin_double":  "T-Spin Double",
	"tspin_triple":  "T-Spin Triple",
	"perfect_clear": "Perfect Clear",
}

static func format_time(seconds: float) -> String:
	var total_secs := int(seconds)
	var mins := total_secs / 60
	var secs := total_secs % 60
	return "%d:%02d" % [mins, secs]

static func most_common_clear(clear_counts: Dictionary) -> String:
	if clear_counts.is_empty():
		return "—"
	var best_key: String = ""
	var best_count: int = 0
	for key in CLEAR_PRIORITY:
		var count: int = clear_counts.get(key, 0)
		if count > best_count:
			best_count = count
			best_key = key
	if best_key == "":
		return "—"
	return CLEAR_DISPLAY_NAMES.get(best_key, best_key)

static func add_stat_row(parent: VBoxContainer, label_text: String, value_text: String, is_pb: bool = false) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.add_child(lbl)

	var val_text := value_text
	if is_pb:
		val_text += "  ★ PB"
	var val := Label.new()
	val.text = val_text
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if is_pb:
		val.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	row.add_child(val)

	parent.add_child(row)

static func add_section_header(parent: VBoxContainer, text: String) -> void:
	var sep := HSeparator.new()
	parent.add_child(sep)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	parent.add_child(lbl)

static func add_stats_section(parent: VBoxContainer, run_stats: RunStats, pbs: Dictionary) -> void:
	add_section_header(parent, "Stats")
	add_stat_row(parent, "Total Damage", str(run_stats.total_damage if run_stats else 0),
			pbs.has("total_damage"))
	add_stat_row(parent, "Best Combo",
			("%d-chain" % (run_stats.highest_combo_chain if run_stats else 0)) if (run_stats and run_stats.highest_combo_chain > 0) else "—",
			pbs.has("highest_combo_chain"))
	add_stat_row(parent, "Best B2B",
			str(run_stats.highest_b2b if run_stats else 0) if (run_stats and run_stats.highest_b2b > 0) else "—",
			pbs.has("highest_b2b"))
	add_stat_row(parent, "Quads", str(run_stats.quads if run_stats else 0))
	add_stat_row(parent, "T-Spins", str(run_stats.tspins if run_stats else 0))
	add_stat_row(parent, "Perfect Clears", str(run_stats.perfect_clears if run_stats else 0))
	add_stat_row(parent, "Run Time",
			format_time(run_stats.run_time if run_stats else 0.0))
	add_stat_row(parent, "Most Common Clear",
			most_common_clear(run_stats.clear_counts if run_stats else {}))

static func add_build_section(parent: VBoxContainer) -> void:
	var keystones: Array = RunState.keystones
	var techniques: Array = RunState.techniques
	if keystones.is_empty() and techniques.is_empty():
		return
	add_section_header(parent, "Build")
	if not keystones.is_empty():
		var names: Array = []
		for ks in keystones:
			names.append(ks.display_name)
		var lbl := Label.new()
		lbl.text = "Keystones: " + ", ".join(names)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		parent.add_child(lbl)
	if not techniques.is_empty():
		var names: Array = []
		for t in techniques:
			names.append(t.display_name)
		var lbl := Label.new()
		lbl.text = "Techniques: " + ", ".join(names)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		parent.add_child(lbl)
