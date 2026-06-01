extends Node

var current_level: int = 0

# Each entry in LEVEL_MODIFIERS is the CUMULATIVE modifier set for that level.
# Level 0 = base game (no modifiers). Each level adds one new key on top.
const LEVEL_MODIFIERS: Array = [
	{},  # 0: base game
	{"faster_attacks": true},  # 1: restore pre-rebalance interval speeds
	{"faster_attacks": true, "extra_lines": 1},  # 2: +1 garbage line per wave
	{"faster_attacks": true, "extra_lines": 1, "consumable_capacity_delta": -1},  # 3: backpack -1
	{"faster_attacks": true, "extra_lines": 1, "consumable_capacity_delta": -1, "quota_mult": 1.2},  # 4: HP +20%
	{"faster_attacks": true, "extra_lines": 1, "consumable_capacity_delta": -1, "quota_mult": 1.2, "skip_starter_keystone": true},  # 5: no starter keystone
	{"faster_attacks": true, "extra_lines": 1, "consumable_capacity_delta": -1, "quota_mult": 1.2, "skip_starter_keystone": true, "technique_capacity_delta": -1},  # 6: technique capacity -1
]

func get_modifiers(level: int) -> Dictionary:
	var clamped := clampi(level, 0, LEVEL_MODIFIERS.size() - 1)
	return LEVEL_MODIFIERS[clamped]
