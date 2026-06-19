class_name Technique
extends Resource

const RARITY_BASE_COST := {"common": 40, "rare": 52, "epic": 64}
const RARITY_COLOR := {"common": Color(1, 1, 1), "rare": Color(0.3, 0.5, 1.0), "epic": Color(0.7, 0.3, 1.0)}
const RARITY_WEIGHT := {"common": 5, "rare": 3, "epic": 1}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var flavor_text: String = ""
@export var unlock_condition_id: String = ""
@export var rarity: String = "common"
@export var cost: int = 40
@export var tags: Array = []          # Array of tag strings
@export var effect_type: String = ""
@export var params: Dictionary = {}

func get_base_cost() -> int:
	return RARITY_BASE_COST.get(rarity, 40)
