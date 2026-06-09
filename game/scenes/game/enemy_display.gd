class_name EnemyDisplay
extends Control

signal death_animation_finished

var _enemy: Enemy = null
var _quota: int = 0

# ── Portrait nodes ─────────────────────────────────────────────────────────
var _portrait_anchor: Control = null
var _initial_label: Label = null
var _sprite_rect: TextureRect = null

# ── Info nodes ─────────────────────────────────────────────────────────────
var _round_label: Label = null
var _flavor_label: Label = null
var _modifier_label: Label = null

# ── Combat stat nodes ──────────────────────────────────────────────────────
var _hp_bar: ProgressBar = null
var _hp_label: Label = null
var _windup_container: Control = null
var _windup_bar: ProgressBar = null
var _windup_label: Label = null

# ── Animation state ────────────────────────────────────────────────────────
var _lunge_tween: Tween = null
var _pulse_tween: Tween = null
var _flash_tween: Tween = null
var _death_tween: Tween = null
var _death_shake_tween: Tween = null
var _pulse_active: bool = false
var _death_pending_success: bool = false
var _prev_accumulated: float = 0.0

func setup(enemy: Enemy, quota: int) -> void:
	_enemy = enemy
	_quota = quota
	_build_ui()

func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 24.0
	vbox.offset_top = 32.0
	vbox.offset_right = -24.0
	vbox.offset_bottom = -32.0
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# ── Name ──────────────────────────────────────────────────────────────
	var name_lbl := Label.new()
	name_lbl.text = _enemy.display_name if _enemy else ""
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.modulate = _enemy.color if _enemy else Color.WHITE
	vbox.add_child(name_lbl)

	# ── Portrait container (plain Control — children not layout-managed) ───
	# The VBox manages the container; the anchor Control inside can translate freely.
	var portrait_container := Control.new()
	portrait_container.custom_minimum_size = Vector2(0, 360)
	portrait_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(portrait_container)

	_portrait_anchor = Control.new()
	_portrait_anchor.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Pivot at centre so scale-pulse looks correct
	_portrait_anchor.pivot_offset = Vector2(180.0, 180.0)
	portrait_container.add_child(_portrait_anchor)

	# Initial-letter placeholder
	_initial_label = Label.new()
	_initial_label.text = _enemy.display_name[0] if _enemy and not _enemy.display_name.is_empty() else "?"
	_initial_label.add_theme_font_size_override("font_size", 180)
	_initial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_initial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_initial_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_initial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var init_color := _enemy.color if _enemy else Color.WHITE
	_initial_label.modulate = Color(init_color.r, init_color.g, init_color.b, 0.15)
	_portrait_anchor.add_child(_initial_label)

	# Sprite TextureRect
	_sprite_rect = TextureRect.new()
	_sprite_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sprite_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite_rect.texture = _enemy.sprite if _enemy else null
	_sprite_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_anchor.add_child(_sprite_rect)

	var has_sprite := _enemy != null and _enemy.sprite != null
	_sprite_rect.visible = has_sprite
	_initial_label.visible = not has_sprite

	# ── Info section ───────────────────────────────────────────────────────
	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 6)
	vbox.add_child(info_vbox)

	# Compact stage/round label (e.g. "2-3" or "2-BOSS")
	_round_label = Label.new()
	_round_label.text = format_round_label(RunState.stage, RunState.round_index)
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_round_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(_round_label)

	# Flavor text (italic-styled via colour, hidden if empty)
	_flavor_label = Label.new()
	_flavor_label.text = _enemy.flavor_text if _enemy else ""
	_flavor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_flavor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_flavor_label.add_theme_font_size_override("font_size", 12)
	_flavor_label.modulate = Color(0.75, 0.75, 0.75, 1.0)
	_flavor_label.visible = _enemy != null and not _enemy.flavor_text.is_empty()
	info_vbox.add_child(_flavor_label)

	# Boss modifier description (orange, hidden when no modifier)
	_modifier_label = Label.new()
	_modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modifier_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_modifier_label.add_theme_font_size_override("font_size", 12)
	_modifier_label.modulate = Color(1.0, 0.6, 0.2, 1.0)
	if _enemy != null and _enemy.ability != null:
		_modifier_label.text = _enemy.ability.description
		_modifier_label.visible = true
	else:
		_modifier_label.text = ""
		_modifier_label.visible = false
	info_vbox.add_child(_modifier_label)

	# HP bar
	var hp_container := Control.new()
	hp_container.custom_minimum_size = Vector2(0, 24)
	hp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_child(hp_container)

	_hp_bar = ProgressBar.new()
	_hp_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hp_bar.min_value = 0.0
	_hp_bar.max_value = _quota
	_hp_bar.value = _quota
	_hp_bar.show_percentage = false
	hp_container.add_child(_hp_bar)

	_hp_label = Label.new()
	_hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hp_label.text = "%d / %d" % [_quota, _quota]
	hp_container.add_child(_hp_label)

	# ATK windup bar
	_windup_container = Control.new()
	_windup_container.custom_minimum_size = Vector2(0, 24)
	_windup_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_child(_windup_container)

	_windup_bar = ProgressBar.new()
	_windup_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_windup_bar.min_value = 0.0
	_windup_bar.max_value = 1.0
	_windup_bar.value = 0.0
	_windup_bar.show_percentage = false
	_windup_container.add_child(_windup_bar)

	_windup_label = Label.new()
	_windup_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_windup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_windup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_windup_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_windup_label.text = "ATK: --s"
	_windup_container.add_child(_windup_label)

# ── Public API ─────────────────────────────────────────────────────────────

func set_attack_bar_visible(vis: bool) -> void:
	if _windup_container:
		_windup_container.visible = vis

func update_hp(accumulated: float) -> void:
	if _hp_bar == null:
		return
	var delta := accumulated - _prev_accumulated
	_prev_accumulated = accumulated
	var remaining: int = max(0, _quota - int(accumulated))
	_hp_bar.value = remaining
	_hp_label.text = "%d / %d" % [remaining, _quota]
	if delta > 0.0:
		_trigger_damage_flash()
		_spawn_damage_number(int(delta))

func update_windup(timer: float, interval: float) -> void:
	if _windup_bar == null:
		return
	var ratio := timer / interval if interval > 0.0 else 0.0
	_windup_bar.value = ratio
	_windup_label.text = "ATK: %ds" % max(0, int(interval - timer))
	if ratio >= 0.8:
		_start_pulse()
	else:
		_stop_pulse()

# ── Death animation ────────────────────────────────────────────────────────

func play_death_animation() -> void:
	_stop_pulse()
	if _lunge_tween and _lunge_tween.is_valid():
		_lunge_tween.kill()
		_lunge_tween = null
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
		_flash_tween = null
	_death_pending_success = true
	var is_boss := _enemy != null and _enemy.ability != null
	if is_boss:
		_play_boss_death()
	else:
		_play_regular_death()

func _play_regular_death() -> void:
	_death_tween = create_tween()
	_death_tween.tween_property(_portrait_anchor, "modulate", Color.WHITE, 0.10)
	_death_tween.tween_property(_portrait_anchor, "modulate:a", 0.0, 0.50).set_ease(Tween.EASE_IN)
	_death_tween.parallel().tween_property(_portrait_anchor, "scale", Vector2(1.1, 1.1), 0.50).set_ease(Tween.EASE_OUT)
	_death_tween.finished.connect(_on_death_tween_finished)

func _play_boss_death() -> void:
	_death_tween = create_tween()
	_death_tween.tween_property(_portrait_anchor, "modulate", Color.WHITE, 0.10)
	_death_tween.tween_property(_portrait_anchor, "modulate:a", 0.0, 0.80).set_ease(Tween.EASE_IN)
	_death_tween.parallel().tween_property(_portrait_anchor, "scale", Vector2(1.18, 1.18), 0.80).set_ease(Tween.EASE_OUT)
	_death_tween.finished.connect(_on_death_tween_finished)
	_death_shake_tween = create_tween()
	_death_shake_tween.tween_property(_portrait_anchor, "position:x", 8.0, 0.07)
	_death_shake_tween.tween_property(_portrait_anchor, "position:x", -8.0, 0.07)
	_death_shake_tween.tween_property(_portrait_anchor, "position:x", 4.0, 0.07)
	_death_shake_tween.tween_property(_portrait_anchor, "position:x", -4.0, 0.07)
	_death_shake_tween.tween_property(_portrait_anchor, "position:x", 0.0, 0.07)

func _on_death_tween_finished() -> void:
	_death_pending_success = false
	death_animation_finished.emit()

# ── Pause hook ────────────────────────────────────────────────────────────

func stop_animations() -> void:
	_stop_pulse()
	if _lunge_tween and _lunge_tween.is_valid():
		_lunge_tween.kill()
		_lunge_tween = null
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
		_flash_tween = null
	if _death_tween and _death_tween.is_valid():
		_death_tween.kill()
		_death_tween = null
	if _death_shake_tween and _death_shake_tween.is_valid():
		_death_shake_tween.kill()
		_death_shake_tween = null
	if _portrait_anchor:
		_portrait_anchor.position.x = 0.0
		if not _death_pending_success:
			_portrait_anchor.modulate = Color.WHITE
	if _death_pending_success:
		_death_pending_success = false
		death_animation_finished.emit()

# ── Lunge animation ────────────────────────────────────────────────────────

func on_attack_fired() -> void:
	_stop_pulse()
	if _lunge_tween and _lunge_tween.is_valid():
		_lunge_tween.kill()
	if _portrait_anchor:
		_portrait_anchor.scale = Vector2.ONE
	_lunge_tween = create_tween()
	_lunge_tween.tween_property(_portrait_anchor, "position:x", -90.0, 0.09)
	_lunge_tween.tween_interval(0.1)
	_lunge_tween.tween_property(_portrait_anchor, "position:x", 0.0, 0.45).set_ease(Tween.EASE_OUT)

# ── Anticipation pulse ─────────────────────────────────────────────────────

func _start_pulse() -> void:
	if _pulse_active:
		return
	_pulse_active = true
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_portrait_anchor, "scale", Vector2(1.04, 1.04), 0.25).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(_portrait_anchor, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_IN_OUT)

func _stop_pulse() -> void:
	if not _pulse_active:
		return
	_pulse_active = false
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
		_pulse_tween = null
	if _portrait_anchor:
		_portrait_anchor.scale = Vector2.ONE

# ── Damage flash ───────────────────────────────────────────────────────────

func _trigger_damage_flash() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(_portrait_anchor, "modulate", Color.RED, 0.08)
	_flash_tween.tween_property(_portrait_anchor, "modulate", Color.WHITE, 0.2)

# ── Floating damage number ─────────────────────────────────────────────────

func _spawn_damage_number(amount: int) -> void:
	if _portrait_anchor == null or not is_inside_tree():
		return
	var lbl := Label.new()
	lbl.text = str(amount)
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.modulate = Color.WHITE
	# Position at centre of portrait area in EnemyDisplay local space
	var anchor_global_rect := _portrait_anchor.get_global_rect()
	var spawn := Vector2(
		anchor_global_rect.get_center().x - global_position.x - 15.0,
		anchor_global_rect.position.y - global_position.y + anchor_global_rect.size.y * 0.3
	)
	lbl.position = spawn
	add_child(lbl)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "position:y", spawn.y - 50.0, 0.9)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.9)
	tween.finished.connect(lbl.queue_free)

# ── Helpers ────────────────────────────────────────────────────────────────

static func format_round_label(stage: int, round_index: int) -> String:
	if round_index == 3:
		return "%d-BOSS" % stage
	return "%d-%d" % [stage, round_index + 1]
