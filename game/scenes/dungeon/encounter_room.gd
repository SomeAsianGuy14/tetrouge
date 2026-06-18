class_name EncounterRoom
extends Control

signal encounter_completed

var _subtype: String = ""
var _run_manager = null  # RunManager ref (needed for Robbers fight)

func setup(subtype: String, run_manager) -> void:
	_subtype = subtype
	_run_manager = run_manager
	_build_panel()

func _build_panel() -> void:
	for child in get_children():
		child.queue_free()

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.1, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.set_anchor_and_offset(SIDE_LEFT,   0.0, 80.0)
	vbox.set_anchor_and_offset(SIDE_RIGHT,  1.0, -80.0)
	vbox.set_anchor_and_offset(SIDE_TOP,    0.0, 60.0)
	vbox.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -60.0)
	add_child(vbox)

	match _subtype:
		"wishing_well":   _build_wishing_well(vbox)
		"altar_technique":_build_altar_technique(vbox)
		"altar_keystone": _build_altar_keystone(vbox)
		"library":        _build_library(vbox)
		"robbers":        _build_robbers(vbox)
		"head_trauma":    _build_head_trauma(vbox)
		"pickpocket":     _build_pickpocket(vbox)
		"museum":         _build_museum(vbox)
		_:
			_build_unknown(vbox)

# ── Shared helpers ────────────────────────────────────────────────────────

func _header(vbox: VBoxContainer, title: String, flavor: String) -> void:
	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_lbl)

	if not flavor.is_empty():
		var flv := Label.new()
		flv.text = flavor
		flv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		flv.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		flv.modulate = Color(0.75, 0.75, 0.75)
		vbox.add_child(flv)

func _leave_button(vbox: VBoxContainer) -> Button:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	var btn := Button.new()
	btn.text = "Leave"
	vbox.add_child(btn)
	btn.connect("pressed", _on_leave)
	return btn

func _on_leave() -> void:
	emit_signal("encounter_completed")

# ── Wishing Well ──────────────────────────────────────────────────────────

func _build_wishing_well(vbox: VBoxContainer) -> void:
	_header(vbox,
		"The Wishing Well",
		"A coin glints at the bottom. Maybe one more will make a difference.")

	var result_label := Label.new()
	result_label.text = ""
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(result_label)

	var state := [0.01, 0]  # [probability, rewards_given]
	var throw_btn := Button.new()
	throw_btn.text = "Throw a coin (1)"
	vbox.add_child(throw_btn)

	throw_btn.connect("pressed", func() -> void:
		if not Economy.spend_coins(1):
			result_label.text = "Not enough coins!"
			return
		if RunState.seeded_randf() < state[0]:
			state[0] = 0.01
			var item_name := _wishing_well_award()
			if item_name.is_empty():
				result_label.text = "The well shimmers, but has nothing left to offer."
			else:
				state[1] += 1
				result_label.text = "The well shimmers! You receive: %s" % item_name
		else:
			state[0] = minf(state[0] + 0.01, 1.0)
			result_label.text = "Nothing happens."
		if state[1] >= 3:
			throw_btn.disabled = true
			throw_btn.text = "The well has run dry"
		else:
			throw_btn.text = "Throw another coin (1)"
	)

	_leave_button(vbox)

func _wishing_well_award() -> String:
	var categories: Array = []
	var tech_pool := ResourceRegistry.get_available_techniques().filter(
		func(t): return not RunState.has_technique(t.id))
	var tech_available := not tech_pool.is_empty() and RunState.techniques.size() < RunState.technique_capacity
	var cons_available := RunState.consumables.size() < RunState.consumable_capacity
	var ks_pool := ResourceRegistry.all_keystones.filter(
		func(k): return k.id not in RunState.used_keystone_ids)
	var ks_available := not ks_pool.is_empty()

	if cons_available:
		categories.append({"type": "consumable", "weight": 60})
	if tech_available:
		categories.append({"type": "technique", "weight": 30})
	if ks_available:
		categories.append({"type": "keystone", "weight": 10})

	if categories.is_empty():
		return ""

	var total_weight := 0
	for c in categories:
		total_weight += c.weight
	var roll := RunState.seeded_randf() * total_weight
	var cumulative := 0.0
	var chosen: String = categories[0].type
	for c in categories:
		cumulative += c.weight
		if roll < cumulative:
			chosen = c.type
			break

	match chosen:
		"consumable":
			var pool := ResourceRegistry.all_consumables.duplicate()
			RunState.seeded_shuffle(pool)
			if not pool.is_empty():
				var item: Consumable = pool[0]
				RunState.add_consumable(item)
				return "%s (Consumable)" % item.display_name
		"technique":
			RunState.seeded_shuffle(tech_pool)
			if not tech_pool.is_empty():
				var item: Technique = tech_pool[0]
				RunState.add_technique(item)
				return "%s (Technique)" % item.display_name
		"keystone":
			RunState.seeded_shuffle(ks_pool)
			if not ks_pool.is_empty():
				var item: Keystone = ks_pool[0]
				RunState.add_keystone(item)
				return "%s (Keystone)" % item.display_name
	return ""

# ── Altar (Technique) ─────────────────────────────────────────────────────

func _build_altar_technique(vbox: VBoxContainer) -> void:
	_header(vbox,
		"The Altar",
		"Ancient runes shift. Sacrifice a technique to receive another.")

	if RunState.techniques.is_empty():
		var no_tech := Label.new()
		no_tech.text = "You have no techniques to sacrifice."
		no_tech.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(no_tech)
		_leave_button(vbox)
		return

	var selection_label := Label.new()
	selection_label.text = "Choose a technique to sacrifice:"
	vbox.add_child(selection_label)

	var result_label := Label.new()
	result_label.text = ""
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(result_label)

	var btn_container := VBoxContainer.new()
	vbox.add_child(btn_container)

	for technique in RunState.techniques.duplicate():
		var t: Technique = technique
		var btn := Button.new()
		btn.text = "%s\n%s" % [t.display_name, t.description]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn_container.add_child(btn)
		btn.connect("pressed", func() -> void:
			RunState.remove_technique(t)
			var pool := ResourceRegistry.get_available_techniques().filter(
				func(x): return not RunState.has_technique(x.id))
			RunState.seeded_shuffle(pool)
			if not pool.is_empty():
				var granted: Technique = pool[0]
				RunState.add_technique(granted)
				result_label.text = "You received: %s" % granted.display_name
			else:
				result_label.text = "The altar shudders — nothing more to give."
			for child in btn_container.get_children():
				child.queue_free()
		)

	_leave_button(vbox)

# ── Altar (Keystone) ──────────────────────────────────────────────────────

func _build_altar_keystone(vbox: VBoxContainer) -> void:
	_header(vbox,
		"The Altar",
		"Power emanates from the stone. Sacrifice a keystone to receive another.")

	if RunState.keystones.is_empty():
		var no_ks := Label.new()
		no_ks.text = "You have no keystones to sacrifice."
		no_ks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(no_ks)
		_leave_button(vbox)
		return

	var selection_label := Label.new()
	selection_label.text = "Choose a keystone to sacrifice:"
	vbox.add_child(selection_label)

	var result_label := Label.new()
	result_label.text = ""
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(result_label)

	var btn_container := VBoxContainer.new()
	vbox.add_child(btn_container)

	for keystone in RunState.keystones.duplicate():
		var ks: Keystone = keystone
		var btn := Button.new()
		btn.text = "%s\n%s" % [ks.display_name, ks.description]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn_container.add_child(btn)
		btn.connect("pressed", func() -> void:
			RunState.keystones.erase(ks)
			var pool := ResourceRegistry.all_keystones.filter(
				func(x): return x.id not in RunState.used_keystone_ids)
			RunState.seeded_shuffle(pool)
			if not pool.is_empty():
				var granted: Keystone = pool[0]
				RunState.add_keystone(granted)
				result_label.text = "You received: %s" % granted.display_name
			else:
				result_label.text = "The altar offers nothing more."
			for child in btn_container.get_children():
				child.queue_free()
		)

	_leave_button(vbox)

# ── Library ───────────────────────────────────────────────────────────────

func _build_library(vbox: VBoxContainer) -> void:
	_header(vbox,
		"The Library",
		"Dusty tomes line the shelves. One technique catches your eye — free of charge.")

	var pool := ResourceRegistry.get_available_techniques()
	RunState.seeded_shuffle(pool)
	var candidates := pool.slice(0, mini(10, pool.size()))

	if candidates.is_empty():
		var no_tech := Label.new()
		no_tech.text = "The library has nothing you don't already know."
		no_tech.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(no_tech)
		_leave_button(vbox)
		return

	var select_label := Label.new()
	select_label.text = "Choose a technique to learn for free:"
	vbox.add_child(select_label)

	var btn_list := VBoxContainer.new()
	btn_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(btn_list)

	for tech in candidates:
		var t: Technique = tech
		var btn := Button.new()
		btn.text = "%s — %s" % [t.display_name, t.description]
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn_list.add_child(btn)
		btn.connect("pressed", func() -> void:
			if RunState.techniques.size() < RunState.technique_capacity:
				RunState.add_technique(t)
			for child in btn_list.get_children():
				child.disabled = true
			emit_signal("encounter_completed")
		)

	_leave_button(vbox)

# ── Robbers ───────────────────────────────────────────────────────────────

func _build_robbers(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Robbers!",
		"Three masked figures block the path. \"Your coins or your life!\"\nYou have %d coins." % Economy.coins)

	var btn_surrender := Button.new()
	btn_surrender.text = "Surrender your gold (%d coins)" % Economy.coins
	vbox.add_child(btn_surrender)
	btn_surrender.connect("pressed", func() -> void:
		Economy.coins = 0
		Economy.emit_signal("coins_changed", 0)
		emit_signal("encounter_completed")
	)

	var btn_fight := Button.new()
	btn_fight.text = "Fight! (Elite encounter)"
	vbox.add_child(btn_fight)
	btn_fight.connect("pressed", func() -> void:
		if _run_manager:
			_run_manager.start_robbers_combat()
	)

# ── Unfortunate Head Trauma ───────────────────────────────────────────────

func _build_head_trauma(vbox: VBoxContainer) -> void:
	_header(vbox, "Unfortunate Head Trauma", "")

	var removed_name := ""
	if not RunState.techniques.is_empty():
		RunState.seeded_shuffle(RunState.techniques)
		var removed: Technique = RunState.techniques[0]
		removed_name = removed.display_name
		RunState.remove_technique(removed)

	var msg_label := Label.new()
	if removed_name.is_empty():
		msg_label.text = "You seem to have forgotten something, but you don't think it was that important."
	else:
		msg_label.text = "You seem to have forgotten %s." % removed_name
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(msg_label)

	_leave_button(vbox)

# ── Pickpocket ────────────────────────────────────────────────────────────

func _build_pickpocket(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Pickpocket",
		"You feel a hand in your pocket — gone before you can react.")

	var loss := int(floorf(Economy.coins * 0.5))
	if loss > 0:
		Economy.coins -= loss
		Economy.emit_signal("coins_changed", Economy.coins)

	var msg_label := Label.new()
	if loss > 0:
		msg_label.text = "You lost %d coins." % loss
	else:
		msg_label.text = "Your pockets were already empty."
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(msg_label)

	_leave_button(vbox)

# ── Museum ────────────────────────────────────────────────────────────────

func _build_museum(vbox: VBoxContainer) -> void:
	_header(vbox,
		"The Museum",
		"A rare exhibit. The docent gestures toward a pedestal.")

	var pool := ResourceRegistry.all_keystones.filter(
		func(x): return x.id not in RunState.used_keystone_ids)
	RunState.seeded_shuffle(pool)

	if pool.is_empty():
		var no_ks := Label.new()
		no_ks.text = "The pedestals are all empty."
		no_ks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(no_ks)
		_leave_button(vbox)
		return

	var exhibit: Keystone = pool[0]

	var name_label := Label.new()
	name_label.text = exhibit.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = exhibit.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	var take_btn := Button.new()
	take_btn.text = "Take it (free)"
	vbox.add_child(take_btn)
	take_btn.connect("pressed", func() -> void:
		RunState.add_keystone(exhibit)
		take_btn.disabled = true
		emit_signal("encounter_completed")
	)

	_leave_button(vbox)

# ── Unknown fallback ──────────────────────────────────────────────────────

func _build_unknown(vbox: VBoxContainer) -> void:
	_header(vbox, "Mysterious Chamber", "Nothing happens here.")
	_leave_button(vbox)
