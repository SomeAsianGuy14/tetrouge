class_name Shop
extends Control

signal shop_closed

@onready var technique_slots: HBoxContainer = $Panel/VBox/TechniqueSlots
@onready var consumable_slot: Control = $Panel/VBox/BottomRow/ConsumableSlot
@onready var consumable_slot_2: Control = $Panel/VBox/BottomRow/ConsumableSlot2
@onready var voucher_slot: Control = $Panel/VBox/BottomRow/VoucherSlot
@onready var coin_label: Label = $Panel/VBox/Header/CoinLabel
@onready var interest_label: Label = $Panel/VBox/Header/InterestLabel
@onready var exit_button: Button = $Panel/VBox/Footer/ExitButton
@onready var keystone_icons: HBoxContainer = $Panel/VBox/CollectionPanel/KeystonesRow/KeystoneIcons
@onready var technique_icons: HBoxContainer = $Panel/VBox/CollectionPanel/TechniquesRow/TechniqueIcons
@onready var _collection_slots: Array = [
	$Panel/VBox/CollectionPanel/BackpackRow/CollectionSlot0,
	$Panel/VBox/CollectionPanel/BackpackRow/CollectionSlot1,
	$Panel/VBox/CollectionPanel/BackpackRow/CollectionSlot2,
]

var _all_techniques: Array = []
var _all_consumables: Array = []
var _all_vouchers: Array = []
var _buy_buttons: Dictionary = {}  # slot node → buy Button (or null if owned)

func _ready() -> void:
	Economy.connect("coins_changed", _update_coin_display)
	exit_button.connect("pressed", _on_exit_pressed)
	for i in _collection_slots.size():
		_collection_slots[i].connect("pressed", _on_sell_consumable.bind(i))
	var interest := Economy.apply_interest()
	interest_label.text = "+%d interest" % interest if interest > 0 else ""
	_load_item_pools()
	_populate_shop()
	_update_coin_display(Economy.coins)
	_build_collection()

func _load_item_pools() -> void:
	_all_techniques = _load_from_dir("res://resources/data/techniques/", "Technique")
	_all_consumables = _load_from_dir("res://resources/data/consumables/", "Consumable")
	_all_vouchers = _load_from_dir("res://resources/data/vouchers/", "Voucher")

func _load_from_dir(path: String, _type: String) -> Array:
	var result := []
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".tres"):
				var res := load(path + f)
				if res != null:
					result.append(res)
				else:
					push_warning("Shop: failed to load resource: " + path + f)
			f = dir.get_next()
	return result

func _populate_shop() -> void:
	_populate_technique_slots()
	var first_consumable := _pick_one(_all_consumables, [])
	var first_id: String = first_consumable.id if first_consumable else ""
	_populate_slot(consumable_slot, first_consumable)
	_populate_slot(consumable_slot_2, _pick_one(_all_consumables, [first_id]))
	_populate_voucher_slot()

func _populate_technique_slots() -> void:
	var available := _all_techniques.filter(func(t): return not RunState.has_technique(t.id))
	RunState.seeded_shuffle(available)
	var count := RunState.shop_technique_slots
	for i in range(technique_slots.get_child_count()):
		technique_slots.get_child(i).visible = i < count
	for i in range(count):
		var slot: Control = technique_slots.get_child(i) as Control if i < technique_slots.get_child_count() else _create_slot()
		var item: Resource = available[i] as Resource if i < available.size() else null
		_populate_slot(slot, item)

func _populate_voucher_slot() -> void:
	var stage_chance := RunState.stage * 0.15  # 15% per stage
	if RunState.seeded_randf() > stage_chance:
		_populate_slot(voucher_slot, null)
		return
	var available := _all_vouchers.filter(func(v): return not RunState.has_voucher(v.id))
	RunState.seeded_shuffle(available)
	_populate_slot(voucher_slot, available[0] if not available.is_empty() else null)

func _pick_one(pool: Array, exclude_ids: Array) -> Resource:
	var available := pool.filter(func(x): return x.id not in exclude_ids)
	if available.is_empty():
		return null
	RunState.seeded_shuffle(available)
	return available[0]

func _create_slot() -> Control:
	var slot := PanelContainer.new()
	technique_slots.add_child(slot)
	return slot

func _populate_slot(slot: Control, item: Resource) -> void:
	_build_item_card(slot, item)

func _build_item_card(slot: Control, item: Resource) -> void:
	for child in slot.get_children():
		child.free()

	if item == null:
		var empty := Label.new()
		empty.text = "— Empty —"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(empty)
		_buy_buttons[slot] = null
		slot.modulate = Color.WHITE
		return

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	slot.add_child(vbox)

	var name_label := Label.new()
	name_label.text = item.display_name
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = item.description
	desc_label.autowrap_mode = 3  # TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)

	var cost_label := Label.new()
	cost_label.text = "%d coins" % item.cost
	vbox.add_child(cost_label)

	var owned := item is Technique and RunState.has_technique(item.id)
	if owned:
		var owned_label := Label.new()
		owned_label.text = "OWNED"
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(owned_label)
		_buy_buttons[slot] = null
		slot.modulate = Color.WHITE
	else:
		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.set_meta("cost", item.cost)
		buy_btn.disabled = not Economy.can_afford(item.cost)
		buy_btn.connect("pressed", _on_purchase.bind(item, slot))
		vbox.add_child(buy_btn)
		_buy_buttons[slot] = buy_btn
		slot.modulate = Color.WHITE if Economy.can_afford(item.cost) else Color(0.55, 0.55, 0.55)

func _on_purchase(item: Resource, slot: Control) -> void:
	if not Economy.spend_coins(item.cost):
		return
	if item is Technique:
		RunState.add_technique(item)
		_build_technique_icons()
	elif item is Consumable:
		if not RunState.add_consumable(item):
			Economy.add_coins(item.cost)  # refund if full
			return
		_refresh_collection_backpack()
	elif item is Voucher:
		RunState.add_voucher(item)
	_mark_slot_purchased(slot, item)
	_refresh_button_states()

func _mark_slot_purchased(slot: Control, _item: Resource) -> void:
	var btn = _buy_buttons.get(slot)
	if btn != null:
		btn.queue_free()
	_buy_buttons.erase(slot)
	var vbox := slot.get_child(0) as VBoxContainer
	if vbox:
		var lbl := Label.new()
		lbl.text = "PURCHASED"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl)

func _sell_price(item) -> int:
	return int(item.cost * 0.6)

func _build_collection() -> void:
	_build_keystone_icons()
	_build_technique_icons()
	_refresh_collection_backpack()

func _build_keystone_icons() -> void:
	for child in keystone_icons.get_children():
		child.queue_free()
	for keystone in RunState.keystones:
		var lbl := Label.new()
		lbl.text = keystone.display_name[0]
		lbl.tooltip_text = keystone.display_name + "\n" + keystone.description
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		keystone_icons.add_child(lbl)

func _build_technique_icons() -> void:
	for child in technique_icons.get_children():
		child.queue_free()
	for technique in RunState.techniques:
		var btn := Button.new()
		btn.text = technique.display_name[0] + " • " + str(_sell_price(technique)) + "¢"
		btn.tooltip_text = technique.display_name + "\n" + technique.description
		btn.connect("pressed", _on_sell_technique.bind(technique))
		technique_icons.add_child(btn)

func _refresh_collection_backpack() -> void:
	for i in _collection_slots.size():
		var btn: Button = _collection_slots[i]
		if i < RunState.consumables.size():
			var item: Consumable = RunState.consumables[i]
			btn.text = item.display_name + "\nSell • " + str(_sell_price(item)) + "¢"
			btn.disabled = false
		else:
			btn.text = "—"
			btn.disabled = true

func _on_sell_technique(technique) -> void:
	Economy.add_coins(_sell_price(technique))
	RunState.remove_technique(technique)
	_build_technique_icons()

func _on_sell_consumable(index: int) -> void:
	if index >= RunState.consumables.size():
		return
	Economy.add_coins(_sell_price(RunState.consumables[index]))
	RunState.remove_consumable(RunState.consumables[index])
	_refresh_collection_backpack()

func _refresh_button_states() -> void:
	for slot in _buy_buttons:
		var btn = _buy_buttons[slot]
		if btn == null:
			continue
		var can_afford := Economy.can_afford(int(btn.get_meta("cost")))
		btn.disabled = not can_afford
		slot.modulate = Color.WHITE if can_afford else Color(0.55, 0.55, 0.55)

func _update_coin_display(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _on_exit_pressed() -> void:
	queue_free()
	emit_signal("shop_closed")
