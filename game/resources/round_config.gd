class_name RoundConfig
extends Resource

@export var quota: int = 20
@export var time_limit: float = 60.0
@export var boss_modifier: BossModifier = null

# Keystone-driven parameters (set by RunManager from active keystones)
@export var preview_count: int = 5
@export var hold_slots: int = 1
@export var lock_delay_ms: float = 500.0
@export var lock_max_resets: int = 15
@export var hold_lockout_enabled: bool = true
@export var bag_reset_interval: int = 7  # 7 = standard bag; 5 = Bag Shift keystone
@export var deep_sight_enabled: bool = false
@export var b2b_disabled: bool = false
@export var b2b_persists_on_doubles: bool = false
@export var hold_disabled: bool = false
@export var board_width: int = 10
@export var blinder_preview: int = 5  # overridden by The Blinder boss modifier

var rng: RandomNumberGenerator = null
var enemy: Enemy = null
var effective_garbage_interval: float = 0.0
