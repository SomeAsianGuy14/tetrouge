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
	vbox.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -220.0)
	add_child(vbox)

	match _subtype:
		"wishing_well":    _build_wishing_well(vbox)
		"altar_technique": _build_altar_technique(vbox)
		"altar_keystone":  _build_altar_keystone(vbox)
		"library":         _build_library(vbox)
		"robbers":         _build_robbers(vbox)
		"head_trauma":     _build_head_trauma(vbox)
		"pickpocket":      _build_pickpocket(vbox)
		"treasure_chest":  _build_treasure_chest(vbox)
		"tutor":           _build_tutor(vbox)
		"sleeping_beast":  _build_sleeping_beast(vbox)
		"laboratory":      _build_laboratory(vbox)
		"demonic_deal":    _build_demonic_deal(vbox)
		"mimic":           _build_mimic(vbox)
		"beggar":          _build_beggar(vbox)
		"map_room":        _build_map_room(vbox)
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

func _refresh_hud() -> void:
	if _run_manager and _run_manager.hud:
		_run_manager.hud.refresh_inventory()

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
				_refresh_hud()
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
			var item: Technique = ResourceRegistry.weighted_technique_draw(tech_pool, RunState.rng)
			if item != null:
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
			_refresh_hud()
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
			_refresh_hud()
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
	var candidates := ResourceRegistry.weighted_technique_draw_n(pool, 10, RunState.rng)

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
		btn.modulate = Technique.RARITY_COLOR.get(t.rarity, Color.WHITE)
		btn_list.add_child(btn)
		btn.connect("pressed", func() -> void:
			if RunState.techniques.size() < RunState.technique_capacity:
				RunState.add_technique(t)
				_refresh_hud()
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
	_header(vbox, "Unfortunate Head Trauma", "A loose rock tumbles from the ceiling!")

	var has_speed := false
	for t in RunState.techniques:
		if "speed" in t.tags:
			has_speed = true
			break
	if not has_speed:
		for ks in RunState.keystones:
			if ks.instant_arr or ks.instant_soft_drop:
				has_speed = true
				break

	var msg_label := Label.new()
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if has_speed:
		msg_label.text = "You dodge the falling rock!"
	else:
		var removed_name := ""
		if not RunState.techniques.is_empty():
			RunState.seeded_shuffle(RunState.techniques)
			var removed: Technique = RunState.techniques[0]
			removed_name = removed.display_name
			RunState.remove_technique(removed)
			_refresh_hud()
		if removed_name.is_empty():
			msg_label.text = "You seem to have forgotten something, but you don't think it was that important."
		else:
			msg_label.text = "You seem to have forgotten %s." % removed_name

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
		RunState.pickpocket_stolen_gold = loss
		if RunState.current_floor_data:
			for i in range(RunState.current_floor_data.rooms.size()):
				var room: DungeonRoom = RunState.current_floor_data.rooms[i]
				if room.is_combat() and not room.cleared and room.room_type != DungeonRoom.TYPE_BOSS:
					RunState.pickpocket_revenge_room_idx = i
					break

	var msg_label := Label.new()
	if loss > 0:
		msg_label.text = "You lost %d coins." % loss
	else:
		msg_label.text = "Your pockets were already empty."
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(msg_label)

	_leave_button(vbox)

# ── Treasure Chest ───────────────────────────────────────────────────────

func _build_treasure_chest(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Treasure Chest",
		"A gleaming chest sits in the center of the room...")

	var pool := ResourceRegistry.all_keystones.filter(
		func(x): return x.id not in RunState.used_keystone_ids)
	RunState.seeded_shuffle(pool)
	var exhibit: Keystone = pool[0] if not pool.is_empty() else null

	var result_label := Label.new()
	result_label.text = ""
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(result_label)

	var claim_btn := Button.new()
	claim_btn.text = "Claim"
	vbox.add_child(claim_btn)
	claim_btn.connect("pressed", func() -> void:
		if exhibit != null:
			RunState.add_keystone(exhibit)
			result_label.text = "You found %s!" % exhibit.display_name
		else:
			result_label.text = "The chest is empty."
		claim_btn.disabled = true
		_refresh_hud()
		emit_signal("encounter_completed")
	)

	_leave_button(vbox)

# ── Tutor ─────────────────────────────────────────────────────────────────

func _build_tutor(vbox: VBoxContainer) -> void:
	_header(vbox,
		"The Tutor",
		"A wise figure offers to share their knowledge...")

	var tracks := RunState.MASTERY_TRACKS.duplicate()
	RunState.seeded_shuffle(tracks)
	var chosen_track: String = tracks[0]

	var accept_btn := Button.new()
	accept_btn.text = "Accept"
	vbox.add_child(accept_btn)

	var result_label := Label.new()
	result_label.text = ""
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(result_label)

	accept_btn.connect("pressed", func() -> void:
		RunState.mastery[chosen_track].level += 2
		var display := {"single": "Singles", "double": "Doubles", "triple": "Triples",
			"quad": "Quads", "tspin_single": "T-Spin Singles",
			"tspin_double": "T-Spin Doubles", "tspin_triple": "T-Spin Triples"}
		result_label.text = "%s mastery increased by 2!" % display.get(chosen_track, chosen_track)
		accept_btn.disabled = true
		_refresh_hud()
		emit_signal("encounter_completed")
	)

	_leave_button(vbox)

# ── Sleeping Beast ───────────────────────────────────────────────────────

func _build_sleeping_beast(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Sleeping Beast",
		"A powerful creature slumbers nearby. You see the glint of treasure poking out behind them. Disturb it?")

	var btn_fight := Button.new()
	btn_fight.text = "Disturb"
	vbox.add_child(btn_fight)
	btn_fight.connect("pressed", func() -> void:
		if _run_manager:
			_run_manager.start_robbers_combat()
	)

	_leave_button(vbox)

# ── Laboratory ───────────────────────────────────────────────────────────

func _build_laboratory(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Laboratory",
		"Vials of strange substances line the shelves...")

	var pool := ResourceRegistry.all_consumables.duplicate()
	RunState.seeded_shuffle(pool)
	var offered := pool.slice(0, mini(3, pool.size()))

	for consumable in offered:
		var btn := Button.new()
		btn.text = consumable.display_name
		btn.disabled = RunState.consumables.size() >= RunState.consumable_capacity
		vbox.add_child(btn)
		btn.connect("pressed", func() -> void:
			if RunState.add_consumable(consumable):
				btn.disabled = true
				btn.text = consumable.display_name + " (taken)"
				_refresh_hud()
		)

	_leave_button(vbox)

# ── Demonic Deal ─────────────────────────────────────────────────────────

func _build_demonic_deal(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Demonic Deal",
		"A dark presence offers a bargain...")

	var display_names := {"single": "Singles", "double": "Doubles", "triple": "Triples",
		"quad": "Quads", "tspin_single": "T-Spin Singles",
		"tspin_double": "T-Spin Doubles", "tspin_triple": "T-Spin Triples"}

	var eligible: Array = []
	for track in RunState.MASTERY_TRACKS:
		if RunState.mastery.get(track, {}).get("level", 0) >= 3:
			eligible.append(track)

	if eligible.is_empty():
		var msg := Label.new()
		msg.text = "The presence stares at you, then turns away. You have nothing it wants."
		msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(msg)
		_leave_button(vbox)
		return

	for track in eligible:
		var btn := Button.new()
		btn.text = "Offer %s mastery" % display_names.get(track, track)
		vbox.add_child(btn)
		btn.connect("pressed", func() -> void:
			RunState.mastery[track].level -= 3
			Economy.add_coins(150)
			btn.disabled = true
			btn.text = "Accepted"
			_refresh_hud()
			emit_signal("encounter_completed")
		)

	_leave_button(vbox)

# ── Mimic ─────────────────────────────────────────────────────────────────

func _build_mimic(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Treasure Chest",
		"A gleaming chest sits in the center of the room...")

	var claim_btn := Button.new()
	claim_btn.text = "Claim"
	vbox.add_child(claim_btn)
	claim_btn.connect("pressed", func() -> void:
		if _run_manager:
			_run_manager.start_mimic_combat()
	)

	_leave_button(vbox)

# ── Beggar ────────────────────────────────────────────────────────────────

func _build_beggar(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Beggar",
		"A ragged figure holds out their hand...")

	var btn := Button.new()
	btn.text = "Offer gold"
	btn.disabled = Economy.coins < 50
	vbox.add_child(btn)

	var result_label := Label.new()
	result_label.text = ""
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(result_label)

	btn.connect("pressed", func() -> void:
		Economy.coins -= 50
		Economy.emit_signal("coins_changed", Economy.coins)
		var pool := ResourceRegistry.all_techniques.filter(
			func(t): return t.rarity in ["common", "rare"])
		RunState.seeded_shuffle(pool)
		if not pool.is_empty() and RunState.techniques.size() < RunState.technique_capacity:
			var tech: Technique = pool[0]
			RunState.add_technique(tech)
			result_label.text = "You received %s!" % tech.display_name
		else:
			result_label.text = "The beggar nods gratefully but has nothing to offer in return."
		btn.disabled = true
		_refresh_hud()
		emit_signal("encounter_completed")
	)

	_leave_button(vbox)

# ── Map Room ──────────────────────────────────────────────────────────────

func _build_map_room(vbox: VBoxContainer) -> void:
	_header(vbox,
		"Map Room",
		"An old cartographer's desk, covered in dusty maps...")

	var btn := Button.new()
	btn.text = "Examine"
	vbox.add_child(btn)
	btn.connect("pressed", func() -> void:
		if RunState.current_floor_data:
			for room in RunState.current_floor_data.rooms:
				room.revealed = true
		btn.disabled = true
		btn.text = "Examined"
		emit_signal("encounter_completed")
	)

	_leave_button(vbox)

# ── Unknown fallback ──────────────────────────────────────────────────────

func _build_unknown(vbox: VBoxContainer) -> void:
	_header(vbox, "Mysterious Chamber", "Nothing happens here.")
	_leave_button(vbox)
