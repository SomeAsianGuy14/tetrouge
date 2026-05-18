class_name Keystone
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var is_starter: bool = false

# Effect parameters applied to RoundConfig at round start
@export var preview_count_override: int = 0     # 0 = no override
@export var hold_slots_override: int = 0        # 0 = no override
@export var lock_delay_ms_override: float = 0.0 # 0 = no override
@export var lock_max_resets_override: int = 0   # 0 = no override
@export var disable_hold_lockout: bool = false
@export var bag_reset_interval_override: int = 0 # 0 = no override
@export var deep_sight: bool = false
@export var second_wind: bool = false           # handled by RunManager

func apply_to_config(config: RoundConfig) -> void:
	if preview_count_override > 0:
		config.preview_count = preview_count_override
	if hold_slots_override > 0:
		config.hold_slots = hold_slots_override
	if lock_delay_ms_override > 0.0:
		config.lock_delay_ms = lock_delay_ms_override
	if lock_max_resets_override > 0:
		config.lock_max_resets = lock_max_resets_override
	if disable_hold_lockout:
		config.hold_lockout_enabled = false
	if bag_reset_interval_override > 0:
		config.bag_reset_interval = bag_reset_interval_override
	if deep_sight:
		config.deep_sight_enabled = true
