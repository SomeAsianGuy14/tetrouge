class_name BossModifier
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

# Effect flags (applied to RoundConfig or handled by RunManager)
@export var disable_hold: bool = false
@export var hide_all_previews: bool = false
@export var time_limit_override: float = 0.0 # 0 = no override; 60 = The Blitz
@export var disable_b2b: bool = false
@export var board_width_override: int = 0    # 0 = standard; 8 = The Thin

# Piece generation
@export var random_pieces: bool = false

# Garbage behaviour
@export var garbage_individual_lines: bool = false
@export var reflect_ratio: float = 0.0  # 0 = no reflection; 0.5 = The Reflection

# Attack filter — which event types count toward quota (empty = all count)
@export var quota_whitelist: Array[String] = []  # empty = all; non-empty = only these

func apply_to_config(config: RoundConfig) -> void:
	if disable_hold:
		config.hold_disabled = true
	if hide_all_previews:
		config.preview_count = 0
	if time_limit_override > 0.0:
		config.time_limit = time_limit_override
	if disable_b2b:
		config.b2b_disabled = true
	if board_width_override > 0:
		config.board_width = board_width_override
	if random_pieces:
		config.random_pieces = true
	if garbage_individual_lines:
		config.garbage_individual_lines = true
	if reflect_ratio > 0.0:
		config.reflect_ratio = reflect_ratio

func attack_counts_toward_quota(event_type: String) -> bool:
	if quota_whitelist.is_empty():
		return true
	return event_type in quota_whitelist
