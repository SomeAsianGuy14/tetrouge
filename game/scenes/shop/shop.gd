class_name Shop
extends Control

signal shop_closed

@onready var technique_slots: HBoxContainer = $Panel/VBox/TechniqueSlots
@onready var consumable_slot: Control = $Panel/VBox/BottomRow/ConsumableSlot
@onready var consumable_slot_2: Control = $Panel/VBox/BottomRow/ConsumableSlot2
@onready var consumable_slot_3: Control = $Panel/VBox/BottomRow/ConsumableSlot3
@onready var coin_label: Label = $Panel/VBox/Header/CoinLabel
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
var _buy_buttons: Dictionary = {}  # slot node → buy Button (or null if owned)
var _technique_slot_nodes: Array = []  # tracks which slots show techniques
var _slot_item_map: Dictionary = {}  # slot node → resource item

func _ready() -> void:
	Economy.connect("coins_changed", _update_coin_display)
	exit_button.connect("pressed", _on_exit_pressed)
	for i in _collection_slots.size():
		_collection_slots[i].connect("pressed", _on_sell_consumable.bind(i))
	_load_item_pools()
	_populate_shop()
	_update_coin_display(Economy.coins)
	_build_collection()

func _is_at_technique_capacity() -> bool:
	return RunState.techniques.size() >= RunState.technique_capacity


func _load_item_pools() -> void:
	_all_techniques = ResourceRegistry.get_available_techniques()
	_all_consumables = ResourceRegistry.all_consumables.duplicate()

func _populate_shop() -> void:
	_populate_technique_slots()
	var exclude_ids: Array = []
	var c1 := _pick_one(_all_consumables, exclude_ids)
	if c1: exclude_ids.append(c1.id)
	_populate_slot(consumable_slot, c1)
	var c2 := _pick_one(_all_consumables, exclude_ids)
	if c2: exclude_ids.append(c2.id)
	_populate_slot(consumable_slot_2, c2)
	_populate_slot(consumable_slot_3, _pick_one(_all_consumables, exclude_ids))
	
func _populate_technique_slots() -> void:
	_technique_slot_nodes.clear()
	var available := _all_techniques.filter(func(t): return not RunState.has_technique(t.id))
	var drawn := ResourceRegistry.weighted_technique_draw_n(available, RunState.shop_technique_slots, RunState.rng)
	var count := RunState.shop_technique_slots
	for i in range(technique_slots.get_child_count()):
		technique_slots.get_child(i).visible = i < count
	for i in range(count):
		var slot: Control = technique_slots.get_child(i) as Control if i < technique_slots.get_child_count() else _create_slot()
		var item: Technique = drawn[i] as Technique if i < drawn.size() else null
		_populate_slot(slot, item)
		if item != null:
			_technique_slot_nodes.append(slot)
	
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
	_slot_item_map[slot] = item
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
	if item is Technique:
		name_label.modulate = Technique.RARITY_COLOR.get(item.rarity, Color.WHITE)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = item.description
	desc_label.autowrap_mode = 3  # TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)

	var display_cost: int = _effective_cost(item)
	if item is Technique:
		display_cost += RunState.rng.randi_range(-4, 4)
		display_cost = maxi(1, display_cost)
	var cost_label := Label.new()
	cost_label.text = "%d coins" % display_cost
	vbox.add_child(cost_label)

	var owned := item is Technique and RunState.has_technique(item.id)
	var at_cap := item is Technique and _is_at_technique_capacity() and not owned
	if owned:
		var owned_label := Label.new()
		owned_label.text = "OWNED"
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(owned_label)
		_buy_buttons[slot] = null
		slot.modulate = Color.WHITE
	elif at_cap:
		var cap_label := Label.new()
		cap_label.text = "FULL"
		cap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap_label.modulate = Color(1.0, 0.6, 0.2)
		vbox.add_child(cap_label)
		_buy_buttons[slot] = null
		slot.modulate = Color(0.55, 0.55, 0.55)
	else:
		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.set_meta("cost", display_cost)
		buy_btn.set_meta("is_technique", item is Technique)
		buy_btn.disabled = not Economy.can_afford(display_cost)
		buy_btn.connect("pressed", _on_purchase_at_cost.bind(item, slot, display_cost))
		vbox.add_child(buy_btn)
		_buy_buttons[slot] = buy_btn
		slot.modulate = Color.WHITE if Economy.can_afford(display_cost) else Color(0.55, 0.55, 0.55)

func _on_purchase_at_cost(item: Resource, slot: Control, purchase_cost: int) -> void:
	if not Economy.spend_coins(purchase_cost):
		return
	if item is Technique:
		RunState.add_technique(item)
		_build_technique_icons()
	elif item is Consumable:
		if not RunState.add_consumable(item):
			Economy.add_coins(purchase_cost)
			return
		_refresh_collection_backpack()
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
	var ratio := 0.8 if RunState.has_technique("smooth_haggling") else 0.6
	return int(item.cost * ratio)

func _effective_cost(item: Resource) -> int:
	if not (item is Technique):
		return item.cost
	var cost: int = item.cost
	if RunState.has_technique("coupon"):
		cost = int(cost * 0.9)
	if RunState.has_technique("specialist_discount"):
		for ks in RunState.keystones:
			if ks.category != "" and ks.category in item.tags:
				cost = int(cost * 0.75)
				break
	return maxi(1, cost)

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
	for i in RunState.technique_capacity:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(80, 32)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_font_size_override("font_size", 11)
		if i < RunState.techniques.size():
			var technique: Technique = RunState.techniques[i]
			btn.text = technique.display_name + "\nSell - " + str(_sell_price(technique)) + "c"
			btn.tooltip_text = technique.display_name + "\n" + technique.description
			btn.modulate = Technique.RARITY_COLOR.get(technique.rarity, Color.WHITE)
			btn.disabled = false
			btn.connect("pressed", _on_sell_technique.bind(technique))
		else:
			btn.text = "—"
			btn.disabled = true
		technique_icons.add_child(btn)

func _refresh_collection_backpack() -> void:
	for i in _collection_slots.size():
		var btn: Button = _collection_slots[i]
		if i < RunState.consumables.size():
			var item: Consumable = RunState.consumables[i]
			btn.text = item.display_name + "\nSell - " + str(_sell_price(item)) + "c"
			btn.disabled = false
		else:
			btn.text = "—"
			btn.disabled = true

func _on_sell_technique(technique) -> void:
	Economy.add_coins(_sell_price(technique))
	RunState.remove_technique(technique)
	_build_technique_icons()
	for slot in _technique_slot_nodes:
		_build_item_card(slot, _slot_item_map.get(slot))
	_refresh_button_states()

func _on_sell_consumable(index: int) -> void:
	if index >= RunState.consumables.size():
		return
	Economy.add_coins(_sell_price(RunState.consumables[index]))
	RunState.remove_consumable(RunState.consumables[index])
	_refresh_collection_backpack()

func _refresh_button_states() -> void:
	var at_cap := _is_at_technique_capacity()
	for slot in _buy_buttons:
		var btn = _buy_buttons[slot]
		if btn == null:
			continue
		var is_technique_btn: bool = btn.has_meta("is_technique") and btn.get_meta("is_technique")
		var can_afford := Economy.can_afford(int(btn.get_meta("cost")))
		var blocked := is_technique_btn and at_cap
		btn.disabled = not can_afford or blocked
		slot.modulate = Color.WHITE if (can_afford and not blocked) else Color(0.55, 0.55, 0.55)
	
func _update_coin_display(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _on_exit_pressed() -> void:
	queue_free()
	emit_signal("shop_closed")
