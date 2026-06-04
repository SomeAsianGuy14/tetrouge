class_name Voucher
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 12

# Effects applied immediately on purchase via RunState._apply_voucher_effects()
# interest_cap_up    → Economy.interest_cap = 8
# expanded_shop      → RunState.shop_technique_slots = 4
# consumable_expert  → RunState.consumable_capacity = 3
# bonus_round        → (speed bonus removed; currently no effect)
# sharp_eye          → RunState.sharp_eye_active = true
