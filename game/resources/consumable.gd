class_name Consumable
extends Resource

enum UseTiming { ROUND_START, DURING_ROUND, ANYTIME }

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 4
@export var use_timing: UseTiming = UseTiming.ROUND_START

# Time effect (Time Shard only — applied mid-round)
@export var adds_time: float = 0.0

# Attack surge (first N clears deal double attack — applied via RoundConfig)
@export var attack_surge_clears: int = 0

# Piece enhancement grant (next N spawned pieces carry enhance_type)
@export var enhance_type: String = ""
@export var enhance_pieces: int = 0

# Flat attack bonus fields (applied to RoundConfig at round start)
@export var bonus_all_clears: int = 0
@export var bonus_quad: int = 0
@export var bonus_tspin: int = 0
@export var bonus_b2b: int = 0
@export var bonus_combo: int = 0
@export var bonus_pc: int = 0

func apply_to_config(cfg: RoundConfig) -> void:
	if bonus_all_clears > 0:
		cfg.consumable_all_bonus += bonus_all_clears
	if bonus_quad > 0:
		cfg.consumable_quad_bonus += bonus_quad
	if bonus_tspin > 0:
		cfg.consumable_tspin_bonus += bonus_tspin
	if bonus_b2b > 0:
		cfg.consumable_b2b_bonus += bonus_b2b
	if bonus_combo > 0:
		cfg.consumable_combo_bonus += bonus_combo
	if bonus_pc > 0:
		cfg.consumable_pc_bonus += bonus_pc
	if attack_surge_clears > 0:
		cfg.consumable_surge_clears_remaining += attack_surge_clears
