class_name HUD
extends Control

@onready var round_info_label: Label = $TopBar/RoundInfoLabel
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var round_label: Label = $TopBar/RoundLabel
@onready var modifier_label: Label = $TopBar/ModifierLabel
@onready var keystone_icons: HBoxContainer = $InventoryPanel/KeystoneIcons
@onready var technique_icons: HBoxContainer = $InventoryPanel/TechniqueIcons

@onready var timer_big_label: Label = $InfoPanel/TimerBigLabel
@onready var round_big_label: Label = $InfoPanel/RoundBigLabel
@onready var modifier_big_label: Label = $ModifierBigLabel
@onready var b2b_label: Label = $InfoPanel/B2BLabel
@onready var combo_label: Label = $InfoPanel/ComboLabel

@onready var _backpack_slots: Array = [
	$InventoryPanel/BackpackContainer/BackpackSlot0,
	$InventoryPanel/BackpackContainer/BackpackSlot1,
	$InventoryPanel/BackpackContainer/BackpackSlot2,
]

var _enemy_display: Control = null
var _run_manager = null  # set by RunManager after instantiation

func set_enemy_display(display: Control) -> void:
	_enemy_display = display

func set_run_manager(rm) -> void:
	_run_manager = rm

func _ready() -> void:
	Economy.connect("coins_changed", _on_coins_changed)
	for i in _backpack_slots.size():
		_backpack_slots[i].connect("pressed", _on_backpack_slot_pressed.bind(i))

func setup(config: RoundConfig) -> void:
	var round_text := "Stage %d — %s" % [RunState.stage, RunState.get_round_name()]
	round_info_label.text = RunState.get_round_name()
	round_label.text = round_text
	round_big_label.text = round_text

	var total_secs := int(config.time_limit)
	timer_big_label.text = "%d:%02d" % [total_secs / 60, total_secs % 60]
	timer_big_label.modulate = Color.WHITE
	timer_label.modulate = Color.WHITE

	if config.boss_modifier:
		modifier_label.text = config.boss_modifier.display_name
		modifier_label.tooltip_text = config.boss_modifier.description
		modifier_label.visible = true
		modifier_big_label.text = config.boss_modifier.display_name + "\n" + config.boss_modifier.description
		modifier_big_label.visible = true
	else:
		modifier_label.tooltip_text = ""
		modifier_label.visible = false
		modifier_big_label.visible = false

	coin_label.text = "Coins: %d" % Economy.coins
	_refresh_keystone_icons()
	_refresh_technique_icons()
	_refresh_backpack_slots()
	update_b2b_combo(false, 0, -1)

func update_b2b_combo(is_b2b: bool, b2b_count: int, combo: int) -> void:
	b2b_label.visible = is_b2b
	if is_b2b:
		b2b_label.text = "B2B x%d" % b2b_count
	combo_label.visible = combo >= 0
	if combo >= 0:
		combo_label.text = "Combo x%d" % (combo + 1)

func update_quota(accumulated: float, _quota: int) -> void:
	if _enemy_display:
		_enemy_display.update_hp(accumulated)

func update_timer(time_remaining: float) -> void:
	var secs := maxf(0.0, time_remaining)
	var formatted := "%d:%02d" % [int(secs) / 60, int(secs) % 60]
	timer_label.text = formatted
	timer_big_label.text = formatted
	var color := Color.RED if secs <= 10.0 else Color.WHITE
	timer_label.modulate = color
	timer_big_label.modulate = color

func _on_coins_changed(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _refresh_keystone_icons() -> void:
	for child in keystone_icons.get_children():
		child.queue_free()
	for keystone in RunState.keystones:
		var lbl := Label.new()
		lbl.text = keystone.display_name[0]
		lbl.tooltip_text = keystone.display_name + "\n" + keystone.description
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		keystone_icons.add_child(lbl)

func _refresh_technique_icons() -> void:
	for child in technique_icons.get_children():
		child.queue_free()
	for technique in RunState.techniques:
		var lbl := Label.new()
		lbl.text = technique.display_name[0]
		lbl.tooltip_text = "%s\n%s" % [technique.display_name, technique.description]
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		technique_icons.add_child(lbl)

func _refresh_backpack_slots() -> void:
	for i in _backpack_slots.size():
		var btn: Button = _backpack_slots[i]
		if i < RunState.consumables.size():
			var item: Consumable = RunState.consumables[i]
			btn.text = item.display_name
			btn.tooltip_text = item.description
			btn.disabled = false
		else:
			btn.text = "—"
			btn.tooltip_text = ""
			btn.disabled = true

func _on_backpack_slot_pressed(index: int) -> void:
	if _run_manager == null or index >= RunState.consumables.size():
		return
	_run_manager.apply_consumable(RunState.consumables[index])
	_refresh_backpack_slots()
