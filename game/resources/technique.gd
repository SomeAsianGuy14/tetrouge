class_name Technique
extends Resource

# Attack event types that techniques can target
const EVENT_TSPIN_SINGLE := "tspin_single"
const EVENT_TSPIN_DOUBLE := "tspin_double"
const EVENT_TSPIN_TRIPLE := "tspin_triple"
const EVENT_TSPIN_ANY := "tspin_any"
const EVENT_TETRIS := "tetris"
const EVENT_TRIPLE := "triple"
const EVENT_B2B := "b2b"
const EVENT_COMBO := "combo"
const EVENT_PERFECT_CLEAR := "perfect_clear"
const EVENT_ANY_CLEAR := "any_clear"

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 5

# Modifiers applied per attack event
@export var flat_bonus_by_event: Dictionary = {}   # event_type -> int bonus
@export var combo_bonus_per_step: int = 0
@export var b2b_bonus_override: int = 0            # 0 = don't override
@export var b2b_persists_on_doubles: bool = false
@export var avalanche_threshold: int = 0           # combo step above which double; 0 = off
@export var perfect_clear_bonus: int = 0

# Economy stream bonuses (coins per event, credited after round)
@export var coins_per_tspin: int = 0
@export var coins_per_b2b: int = 0
@export var coins_per_attack_above_quota: int = 0   # tracked at round end
@export var surplus_divisor: int = 3               # for Surplus: 1 coin per N surplus

func get_flat_bonus(event_type: String) -> int:
	return flat_bonus_by_event.get(event_type, 0)
