class_name DungeonRoom
extends RefCounted

const TYPE_START := "start"
const TYPE_BOSS := "boss"
const TYPE_COMBAT_SMALL := "combat_small"
const TYPE_COMBAT_BIG := "combat_big"
const TYPE_COMBAT_ELITE := "combat_elite"
const TYPE_SHOP := "shop"
const TYPE_ENCOUNTER := "encounter"
const TYPE_COMBAT_ELITE_SPECIAL := "combat_elite_special"

const ENCOUNTER_SUBTYPES := [
	"wishing_well",
	"altar_technique",
	"altar_keystone",
	"library",
	"robbers",
	"head_trauma",
	"pickpocket",
	"treasure_chest",
	"tutor",
	"sleeping_beast",
	"laboratory",
	"demonic_deal",
	"mimic",
	"beggar",
	"map_room",
]

var room_type: String = ""
var encounter_subtype: String = ""  # only set when room_type == TYPE_ENCOUNTER
var tile_footprint: Array[Vector2i] = []
var visual_size: Vector2i = Vector2i(1, 1)
var cleared: bool = false
var revealed: bool = false
var adjacency: Array[int] = []  # indices into DungeonFloor.rooms

func get_combat_tier() -> String:
	match room_type:
		TYPE_COMBAT_SMALL:          return "Small"
		TYPE_COMBAT_BIG:            return "Big"
		TYPE_COMBAT_ELITE:          return "Elite"
		TYPE_COMBAT_ELITE_SPECIAL:  return "Elite"
		TYPE_BOSS:                  return "Boss"
	return ""

func is_combat() -> bool:
	return room_type in [TYPE_COMBAT_SMALL, TYPE_COMBAT_BIG, TYPE_COMBAT_ELITE, TYPE_COMBAT_ELITE_SPECIAL, TYPE_BOSS]
