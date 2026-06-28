class_name CompendiumScreen
extends Control

var _content_vbox: VBoxContainer
var _counter_label: Label
var _tab_buttons: Array[Button] = []
var _scroll: ScrollContainer
var _current_tab: String = "keystones"

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	var screen_w := int(ProjectSettings.get_setting("display/window/size/viewport_width", 1600))
	var col_width := 500
	var side := int((screen_w - col_width) / 2.0)
	margin.add_theme_constant_override("margin_left", side)
	margin.add_theme_constant_override("margin_right", side)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("separation", 12)
	margin.add_child(outer)

	var title := Label.new()
	title.text = "Compendium"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	outer.add_child(title)

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	outer.add_child(tab_row)

	for tab_name in ["Keystones", "Techniques", "Consumables", "Enemies", "Bosses"]:
		var btn := Button.new()
		btn.text = tab_name
		btn.connect("pressed", _on_tab_pressed.bind(tab_name.to_lower()))
		tab_row.add_child(btn)
		_tab_buttons.append(btn)

	_counter_label = Label.new()
	_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counter_label.modulate = Color(0.6, 0.6, 0.6)
	outer.add_child(_counter_label)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_scroll.custom_minimum_size = Vector2(0, 500)
	outer.add_child(_scroll)

	_content_vbox = VBoxContainer.new()
	_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.add_theme_constant_override("separation", 6)
	_scroll.add_child(_content_vbox)

	var close_btn := Button.new()
	close_btn.text = "Back"
	close_btn.connect("pressed", _on_back)
	outer.add_child(close_btn)

	_on_tab_pressed("keystones")

func _on_back() -> void:
	var menu_scene: PackedScene = load("res://scenes/main_menu/main_menu.tscn")
	get_tree().root.add_child(menu_scene.instantiate())
	queue_free()

func _on_tab_pressed(tab: String) -> void:
	_current_tab = tab
	for child in _content_vbox.get_children():
		_content_vbox.remove_child(child)
		child.free()

	match tab:
		"keystones":    _build_keystones_tab()
		"techniques":   _build_techniques_tab()
		"consumables":  _build_consumables_tab()
		"enemies":      _build_enemies_tab()
		"bosses":       _build_bosses_tab()

func _build_keystones_tab() -> void:
	var all := ResourceRegistry.all_keystones
	var discovered := ProfileSave.discovered_keystones
	var items := _sort_discovered_first(all, discovered)
	_counter_label.text = "%d / %d discovered" % [_count_discovered(all, discovered), all.size()]
	for item in items:
		if item.id in discovered:
			_add_discovered_row(item.display_name, item.description, Color.WHITE, item.category)
		else:
			_add_undiscovered_row(item)

func _build_techniques_tab() -> void:
	var all := ResourceRegistry.all_techniques
	var discovered := ProfileSave.discovered_techniques
	var items := _sort_discovered_first(all, discovered)
	_counter_label.text = "%d / %d discovered" % [_count_discovered(all, discovered), all.size()]
	for item in items:
		if item.id in discovered:
			var color: Color = Technique.RARITY_COLOR.get(item.rarity, Color.WHITE)
			_add_discovered_row(item.display_name, item.description, color)
		else:
			_add_undiscovered_row(item)

func _build_consumables_tab() -> void:
	var all := ResourceRegistry.all_consumables
	var discovered := ProfileSave.discovered_consumables
	var items := _sort_discovered_first(all, discovered)
	_counter_label.text = "%d / %d discovered" % [_count_discovered(all, discovered), all.size()]
	for item in items:
		if item.id in discovered:
			_add_discovered_row(item.display_name, item.description, Color.WHITE)
		else:
			_add_undiscovered_row(item)

func _build_enemies_tab() -> void:
	var all: Array = []
	for e in ResourceRegistry.all_enemies:
		if e.tier not in ["Boss", "FinalBoss"]:
			all.append(e)
	var discovered := ProfileSave.discovered_enemies
	var items := _sort_discovered_first(all, discovered)
	_counter_label.text = "%d / %d discovered" % [_count_discovered(all, discovered), all.size()]
	for item in items:
		if item.id in discovered:
			_add_discovered_row(item.display_name, item.flavor_text if item.flavor_text else "", item.color)
		else:
			_add_undiscovered_row(item)

func _build_bosses_tab() -> void:
	var all: Array = []
	for e in ResourceRegistry.all_enemies:
		if e.tier in ["Boss", "FinalBoss"]:
			all.append(e)
	var discovered := ProfileSave.discovered_bosses
	var items := _sort_discovered_first(all, discovered)
	_counter_label.text = "%d / %d discovered" % [_count_discovered(all, discovered), all.size()]
	for item in items:
		if item.id in discovered:
			var desc: String = item.ability.description if item.ability else ""
			_add_discovered_row(item.display_name, desc, item.color)
		else:
			_add_undiscovered_row(item)

func _add_discovered_row(title_text: String, subtitle: String, color: Color, extra: String = "") -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var name_lbl := Label.new()
	name_lbl.text = title_text
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.modulate = color
	row.add_child(name_lbl)

	if not subtitle.is_empty():
		var desc_lbl := Label.new()
		desc_lbl.text = subtitle
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.modulate = Color(0.75, 0.75, 0.75)
		row.add_child(desc_lbl)

	if not extra.is_empty():
		var extra_lbl := Label.new()
		extra_lbl.text = extra
		extra_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		extra_lbl.modulate = Color(0.5, 0.5, 0.5)
		extra_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(extra_lbl)

	var sep := HSeparator.new()
	row.add_child(sep)
	_content_vbox.add_child(row)

func _add_undiscovered_row(item: Resource) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var name_lbl := Label.new()
	name_lbl.text = "???"
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.modulate = Color(0.4, 0.4, 0.4)
	row.add_child(name_lbl)

	var cond_id: String = item.get("unlock_condition_id") if item.get("unlock_condition_id") else ""
	if cond_id != "":
		var progress_text := _get_unlock_progress(cond_id)
		if not progress_text.is_empty():
			var prog_lbl := Label.new()
			prog_lbl.text = progress_text
			prog_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			prog_lbl.modulate = Color(0.5, 0.5, 0.5)
			prog_lbl.add_theme_font_size_override("font_size", 12)
			row.add_child(prog_lbl)

	var sep := HSeparator.new()
	row.add_child(sep)
	_content_vbox.add_child(row)

func _get_unlock_progress(condition_id: String) -> String:
	for condition in UnlockChecker.CONDITIONS:
		if condition.target_id == condition_id:
			match condition.condition_type:
				"cumulative_stat":
					var stat: String = condition.params.get("stat", "")
					var threshold: int = condition.params.get("threshold", 0)
					var current: int = 0
					match stat:
						"runs_completed": current = ProfileSave.runs_completed
						"total_damage": current = ProfileSave.total_damage
						"highest_combo_chain": current = ProfileSave.highest_combo_chain
						"highest_b2b": current = ProfileSave.highest_b2b
					return "%d / %d" % [mini(current, threshold), threshold]
				"run_condition":
					var cond: String = condition.params.get("cond", "")
					if cond == "beat_ascension":
						var level: int = condition.params.get("level", 0)
						return "Beat Ascension %d" % level
	return ""

func _sort_discovered_first(items: Array, discovered: Array) -> Array:
	var found: Array = []
	var unknown: Array = []
	for item in items:
		if item.id in discovered:
			found.append(item)
		else:
			unknown.append(item)
	found.sort_custom(func(a, b): return a.display_name < b.display_name)
	return found + unknown

func _count_discovered(items: Array, discovered: Array) -> int:
	var count := 0
	for item in items:
		if item.id in discovered:
			count += 1
	return count
