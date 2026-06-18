class_name StatsScreen
extends Control

@onready var career_section: VBoxContainer = $Panel/VBox/CareerSection
@onready var pb_section: VBoxContainer = $Panel/VBox/PBSection
@onready var lifetime_section: VBoxContainer = $Panel/VBox/LifetimeSection
@onready var close_button: Button = $Panel/VBox/CloseButton

func _ready() -> void:
	_populate()
	close_button.connect("pressed", queue_free)

func _populate() -> void:
	_add_section_label(career_section, "Career")
	_add_row(career_section, "Runs Played", str(ProfileSave.runs_completed))
	_add_row(career_section, "Victories", str(ProfileSave.victories))
	var ascension_text: String
	if ProfileSave.highest_beaten < 0:
		ascension_text = "—"
	else:
		ascension_text = "A%d" % ProfileSave.highest_beaten
	_add_row(career_section, "Best Ascension", ascension_text)

	_add_section_label(pb_section, "Personal Bests")
	_add_row(pb_section, "Best Damage (1 run)", str(ProfileSave.best_single_run_damage))
	_add_row(pb_section, "Longest Combo",
			"%d-chain" % ProfileSave.highest_combo_chain if ProfileSave.highest_combo_chain > 0 else "—")
	_add_row(pb_section, "Longest B2B",
			str(ProfileSave.highest_b2b) if ProfileSave.highest_b2b > 0 else "—")

	_add_section_label(lifetime_section, "Lifetime Totals")
	_add_row(lifetime_section, "Total Damage", str(ProfileSave.total_damage))
	_add_row(lifetime_section, "Total Quads", str(ProfileSave.total_quads))
	_add_row(lifetime_section, "Total T-Spins", str(ProfileSave.total_tspins))
	_add_row(lifetime_section, "Total Play Time", _format_lifetime_time(ProfileSave.total_play_time))

func _add_section_label(parent: VBoxContainer, text: String) -> void:
	var sep := HSeparator.new()
	parent.add_child(sep)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	parent.add_child(lbl)

func _add_row(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var lbl := Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var val := Label.new()
	val.text = value_text
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	parent.add_child(row)

func _format_lifetime_time(seconds: float) -> String:
	var total_secs := int(seconds)
	var hours := total_secs / 3600
	var mins := (total_secs % 3600) / 60
	var secs := total_secs % 60
	return "%d:%02d:%02d" % [hours, mins, secs]
