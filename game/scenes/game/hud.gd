class_name HUD
extends Control

@onready var _top_bar: HBoxContainer = $TopBar
@onready var _info_panel: VBoxContainer = $InfoPanel
@onready var _persistent_root: Control = $PersistentLayer/PersistentRoot
@onready var _inventory_panel: VBoxContainer = $PersistentLayer/PersistentRoot/InventoryPanel
@onready var round_info_label: Label = $TopBar/RoundInfoLabel
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var round_label: Label = $TopBar/RoundLabel
@onready var modifier_label: Label = $TopBar/ModifierLabel
@onready var keystone_icons: HBoxContainer = $PersistentLayer/PersistentRoot/InventoryPanel/KeystoneIcons
@onready var technique_icons: HBoxContainer = $PersistentLayer/PersistentRoot/InventoryPanel/TechniqueIcons

@onready var timer_header_label: Label = $InfoPanel/TimerHeaderLabel
@onready var timer_big_label: Label = $InfoPanel/TimerBigLabel
@onready var round_big_label: Label = $InfoPanel/RoundBigLabel
@onready var b2b_label: Label = $InfoPanel/B2BLabel
@onready var combo_label: Label = $InfoPanel/ComboLabel

@onready var inventory_coin_label: Label = $PersistentLayer/PersistentRoot/InventoryPanel/InventoryCoinLabel
@onready var _mastery_panel: VBoxContainer = $PersistentLayer/PersistentRoot/MasteryPanel
@onready var _mastery_header: Button = $PersistentLayer/PersistentRoot/MasteryPanel/MasteryHeader
@onready var _mastery_tracks_container: VBoxContainer = $PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks
@onready var _mastery_track_labels: Array = [
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackSingle,
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackDouble,
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackTriple,
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackQuad,
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackTspinSingle,
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackTspinDouble,
	$PersistentLayer/PersistentRoot/MasteryPanel/MasteryTracks/TrackTspinTriple,
]
@onready var _backpack_slots: Array = [
	$PersistentLayer/PersistentRoot/InventoryPanel/BackpackContainer/BackpackSlot0,
	$PersistentLayer/PersistentRoot/InventoryPanel/BackpackContainer/BackpackSlot1,
	$PersistentLayer/PersistentRoot/InventoryPanel/BackpackContainer/BackpackSlot2,
]

var _run_manager = null  # set by RunManager after instantiation
var _technique_tweens: Dictionary = {}  # technique id → active pulse Tween

func set_run_manager(rm) -> void:
	_run_manager = rm

func _ready() -> void:
	Economy.connect("coins_changed", _on_coins_changed)
	_mastery_header.connect("pressed", _toggle_mastery_panel)
	for i in _backpack_slots.size():
		_backpack_slots[i].connect("pressed", _on_backpack_slot_pressed.bind(i))
	timer_label.visible = false
	timer_header_label.visible = false
	timer_big_label.visible = false

func setup(config: RoundConfig) -> void:
	var floor_text := "Floor %d" % RunState.floor
	round_info_label.text = floor_text
	round_label.text = floor_text
	round_big_label.text = floor_text

	var total_secs := int(config.time_limit)
	timer_big_label.text = "%d:%02d" % [total_secs / 60, total_secs % 60]
	timer_big_label.modulate = Color.WHITE
	timer_label.modulate = Color.WHITE
	timer_label.visible = config.show_timer
	timer_header_label.visible = config.show_timer
	timer_big_label.visible = config.show_timer

	if config.boss_modifier:
		modifier_label.text = config.boss_modifier.display_name
		modifier_label.tooltip_text = config.boss_modifier.description
		modifier_label.visible = true
	else:
		modifier_label.tooltip_text = ""
		modifier_label.visible = false

	coin_label.text = "Coins: %d" % Economy.coins
	inventory_coin_label.text = "Coins: %d" % Economy.coins
	_refresh_keystone_icons()
	_refresh_technique_icons()
	_refresh_backpack_slots()
	_refresh_mastery_panel()
	update_b2b_combo(false, 0, -1)

func update_b2b_combo(is_b2b: bool, b2b_count: int, combo: int) -> void:
	b2b_label.visible = is_b2b
	if is_b2b:
		b2b_label.text = "B2B x%d" % b2b_count
	combo_label.visible = combo >= 0
	if combo >= 0:
		combo_label.text = "Combo x%d" % (combo + 1)

func update_timer(time_remaining: float) -> void:
	if not timer_label.visible:
		return
	var secs := maxf(0.0, time_remaining)
	var formatted := "%d:%02d" % [int(secs) / 60, int(secs) % 60]
	timer_label.text = formatted
	timer_big_label.text = formatted
	var color := Color.RED if secs <= 10.0 else Color.WHITE
	timer_label.modulate = color
	timer_big_label.modulate = color

func _on_coins_changed(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount
	inventory_coin_label.text = "Coins: %d" % amount

func _refresh_keystone_icons() -> void:
	for child in keystone_icons.get_children():
		child.queue_free()
	for keystone in RunState.keystones:
		var lbl := Label.new()
		lbl.text = keystone.display_name[0]
		lbl.tooltip_text = keystone.display_name + "\n" + keystone.description
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.set_meta("id", keystone.id)
		keystone_icons.add_child(lbl)

func _refresh_technique_icons() -> void:
	_technique_tweens.clear()
	for child in technique_icons.get_children():
		child.queue_free()
	for technique in RunState.techniques:
		var lbl := Label.new()
		lbl.text = technique.display_name[0]
		lbl.tooltip_text = "%s\n%s" % [technique.display_name, technique.description]
		lbl.modulate = Technique.RARITY_COLOR.get(technique.rarity, Color.WHITE)
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.set_meta("id", technique.id)
		technique_icons.add_child(lbl)

# ── Visibility management ────────────────────────────────────────────────

func hide_combat_elements() -> void:
	_top_bar.visible = false
	_info_panel.visible = false
	for btn in _backpack_slots:
		btn.disabled = true

func show_combat_elements() -> void:
	_top_bar.visible = true
	_info_panel.visible = true

func hide_inventory() -> void:
	_persistent_root.visible = false

func show_inventory() -> void:
	_persistent_root.visible = true

func refresh_inventory() -> void:
	_refresh_keystone_icons()
	_refresh_technique_icons()
	_refresh_backpack_slots()
	_refresh_mastery_panel()
	inventory_coin_label.text = "Coins: %d" % Economy.coins

# ── Mastery panel ────────────────────────────────────────────────────────

const _MASTERY_DISPLAY_NAMES := {
	"single": "Singles", "double": "Doubles", "triple": "Triples", "quad": "Quads",
	"tspin_single": "T-Singles", "tspin_double": "T-Doubles", "tspin_triple": "T-Triples",
}

const _MASTERY_COLLAPSED_TOP := -260.0
const _MASTERY_EXPANDED_TOP := -400.0

func _toggle_mastery_panel() -> void:
	_mastery_tracks_container.visible = not _mastery_tracks_container.visible
	_mastery_header.text = "▼ Mastery" if _mastery_tracks_container.visible else "▶ Mastery"
	_mastery_panel.offset_top = _MASTERY_EXPANDED_TOP if _mastery_tracks_container.visible else _MASTERY_COLLAPSED_TOP

func _refresh_mastery_panel() -> void:
	for i in RunState.MASTERY_TRACKS.size():
		var track: String = RunState.MASTERY_TRACKS[i]
		var data: Dictionary = RunState.mastery.get(track, {"xp": 0, "level": 0})
		var display_name: String = _MASTERY_DISPLAY_NAMES.get(track, track)
		var threshold: int = RunState.get_mastery_threshold(track)
		_mastery_track_labels[i].text = "%s  Lv %d (%d/%d)" % [display_name, data.level, data.xp, threshold]

# ── Animation helpers ─────────────────────────────────────────────────────

func pop_icon(id: String) -> void:
	for container in [technique_icons, keystone_icons]:
		for child in container.get_children():
			if child.has_meta("id") and child.get_meta("id") == id:
				var tw := create_tween()
				tw.tween_property(child, "scale", Vector2(1.35, 1.35), 0.08)
				tw.tween_property(child, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK)
				return

func update_technique_states(states: Dictionary) -> void:
	for child in technique_icons.get_children():
		if not child.has_meta("id"):
			continue
		var id: String = child.get_meta("id")
		var pending: bool = states.get(id, false)
		if pending:
			if not _technique_tweens.has(id) or not is_instance_valid(_technique_tweens[id]):
				var tw := create_tween().set_loops()
				tw.tween_property(child, "modulate", Color(1.0, 1.0, 0.35, 1.0), 0.4)
				tw.tween_property(child, "modulate", Color.WHITE, 0.4)
				_technique_tweens[id] = tw
		else:
			if _technique_tweens.has(id) and is_instance_valid(_technique_tweens[id]):
				_technique_tweens[id].kill()
				_technique_tweens.erase(id)
			child.modulate = Color.WHITE

func flash_keystone(keystone_id: String) -> void:
	for child in keystone_icons.get_children():
		if child.has_meta("id") and child.get_meta("id") == keystone_id:
			var tw := create_tween()
			tw.tween_property(child, "modulate", Color(0.5, 0.8, 1.0), 0.08)
			tw.tween_property(child, "modulate", Color.WHITE, 0.15)
			return

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
	_backpack_slots[index].release_focus()
