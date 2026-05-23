class_name EnemyDisplay
extends Control

var _enemy: Enemy = null
var _quota: int = 0

var _portrait: Panel = null
var _sprite_rect: TextureRect = null
var _name_label: Label = null
var _hp_bar: ProgressBar = null
var _hp_label: Label = null
var _windup_bar: ProgressBar = null
var _windup_label: Label = null

func setup(enemy: Enemy, quota: int) -> void:
	_enemy = enemy
	_quota = quota
	_build_ui()

func _build_ui() -> void:
	custom_minimum_size = Vector2(140, 0)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	_portrait = Panel.new()
	_portrait.custom_minimum_size = Vector2(140, 140)
	var style := StyleBoxFlat.new()
	style.bg_color = _enemy.color if _enemy else Color.GRAY
	_portrait.add_theme_stylebox_override("panel", style)
	vbox.add_child(_portrait)

	_sprite_rect = TextureRect.new()
	_sprite_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sprite_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite_rect.texture = _enemy.sprite if _enemy else null
	_sprite_rect.visible = _enemy != null and _enemy.sprite != null
	_portrait.add_child(_sprite_rect)

	_name_label = Label.new()
	_name_label.text = _enemy.display_name if _enemy else ""
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_name_label)

	var hp_container := Control.new()
	hp_container.custom_minimum_size = Vector2(0, 24)
	hp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(hp_container)

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

	var windup_container := Control.new()
	windup_container.custom_minimum_size = Vector2(0, 24)
	windup_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(windup_container)

	_windup_bar = ProgressBar.new()
	_windup_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_windup_bar.min_value = 0.0
	_windup_bar.max_value = 1.0
	_windup_bar.value = 0.0
	_windup_bar.show_percentage = false
	windup_container.add_child(_windup_bar)

	_windup_label = Label.new()
	_windup_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_windup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_windup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_windup_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_windup_label.text = "⚡ --s"
	windup_container.add_child(_windup_label)

func update_hp(accumulated: float) -> void:
	if _hp_bar == null:
		return
	var remaining: int = max(0, _quota - int(accumulated))
	_hp_bar.value = remaining
	_hp_label.text = "%d / %d" % [remaining, _quota]

func update_windup(timer: float, interval: float) -> void:
	if _windup_bar == null:
		return
	_windup_bar.value = timer / interval if interval > 0.0 else 0.0
	_windup_label.text = "⚡ %ds" % max(0, int(interval - timer))
