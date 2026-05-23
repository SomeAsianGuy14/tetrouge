class_name BossModifier
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

# Effect flags (applied to RoundConfig or handled by RunManager)
@export var disable_hold: bool = false
@export var preview_override: int = 0        # 0 = no override; 1 = The Blinder
@export var time_limit_override: float = 0.0 # 0 = no override; 45 = The Enforcer
@export var disable_b2b: bool = false
@export var board_width_override: int = 0    # 0 = standard; 8 = The Narrow

# Attack filter — which event types count toward quota (empty = all count)
# The Purge: only triple/tetris/tspin; The Surgeon: only tspin
@export var quota_whitelist: Array[String] = []  # empty = all; non-empty = only these

func apply_to_config(config: RoundConfig) -> void:
	if disable_hold:
		config.hold_disabled = true
	if preview_override > 0:
		config.preview_count = preview_override
	if time_limit_override > 0.0:
		config.time_limit = time_limit_override
	if disable_b2b:
		config.b2b_disabled = true
	if board_width_override > 0:
		config.board_width = board_width_override

func attack_counts_toward_quota(event_type: String) -> bool:
	if quota_whitelist.is_empty():
		return true
	return event_type in quota_whitelist
