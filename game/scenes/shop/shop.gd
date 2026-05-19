class_name Shop
extends Control

signal shop_closed

@onready var technique_slots: HBoxContainer = $Panel/VBox/TechniqueSlots
@onready var consumable_slot: Control = $Panel/VBox/BottomRow/ConsumableSlot
@onready var voucher_slot: Control = $Panel/VBox/BottomRow/VoucherSlot
@onready var coin_label: Label = $Panel/VBox/Header/CoinLabel
@onready var interest_label: Label = $Panel/VBox/Header/InterestLabel
@onready var exit_button: Button = $Panel/VBox/Footer/ExitButton

var _all_techniques: Array = []
var _all_consumables: Array = []
var _all_vouchers: Array = []

func _ready() -> void:
	Economy.connect("coins_changed", _update_coin_display)
	exit_button.connect("pressed", _on_exit_pressed)
	var interest := Economy.apply_interest()
	interest_label.text = "+%d interest" % interest if interest > 0 else ""
	_load_item_pools()
	_populate_shop()
	_update_coin_display(Economy.coins)

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
	_populate_slot(consumable_slot, _pick_one(_all_consumables, []))
	_populate_voucher_slot()

func _populate_technique_slots() -> void:
	var available := _all_techniques.filter(func(t): return not RunState.has_technique(t.id))
	available.shuffle()
	var count := RunState.shop_technique_slots
	for i in range(technique_slots.get_child_count()):
		technique_slots.get_child(i).visible = i < count
	for i in range(count):
		var slot: Control = technique_slots.get_child(i) as Control if i < technique_slots.get_child_count() else _create_slot()
		var item: Resource = available[i] as Resource if i < available.size() else null
		_populate_slot(slot, item)

func _populate_voucher_slot() -> void:
	var stage_chance := RunState.stage * 0.15  # 15% per stage
	if randf() > stage_chance:
		_populate_slot(voucher_slot, null)
		return
	var available := _all_vouchers.filter(func(v): return not RunState.has_voucher(v.id))
	available.shuffle()
	_populate_slot(voucher_slot, available[0] if not available.is_empty() else null)

func _pick_one(pool: Array, exclude_ids: Array) -> Resource:
	var available := pool.filter(func(x): return x.id not in exclude_ids)
	if available.is_empty():
		return null
	available.shuffle()
	return available[0]

func _create_slot() -> Control:
	var slot := PanelContainer.new()
	technique_slots.add_child(slot)
	return slot

func _populate_slot(slot: Control, item: Resource) -> void:
	for child in slot.get_children():
		child.queue_free()
	if item == null:
		var empty := Label.new()
		empty.text = "— Empty —"
		slot.add_child(empty)
		return
	var btn := Button.new()
	var owned := item is Technique and RunState.has_technique(item.id)
	btn.text = "%s\n%s\n%d coins%s" % [item.display_name, item.description, item.cost, " [OWNED]" if owned else ""]
	btn.disabled = owned or not Economy.can_afford(item.cost)
	btn.connect("pressed", _on_purchase.bind(item, slot))
	slot.add_child(btn)

func _on_purchase(item: Resource, slot: Control) -> void:
	if not Economy.spend_coins(item.cost):
		return
	if item is Technique:
		RunState.add_technique(item)
	elif item is Consumable:
		if not RunState.add_consumable(item):
			Economy.add_coins(item.cost)  # refund if full
			return
	elif item is Voucher:
		RunState.add_voucher(item)
	_populate_slot(slot, null)
	_refresh_button_states()

func _refresh_button_states() -> void:
	for slot in technique_slots.get_children():
		for btn in slot.get_children():
			if btn is Button:
				btn.disabled = not Economy.can_afford(0) or btn.text.contains("[OWNED]")

func _update_coin_display(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _on_exit_pressed() -> void:
	queue_free()
	emit_signal("shop_closed")
