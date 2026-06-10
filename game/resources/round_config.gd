class_name RoundConfig
extends Resource

@export var quota: int = 20
@export var time_limit: float = 60.0
@export var show_timer: bool = false
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

# ── Keystone-driven extensions ─────────────────────────────────────────────
@export var b2b_shield_count: int = 0
@export var flexible_b2b: bool = false
@export var instant_arr: bool = false
@export var instant_soft_drop: bool = false
@export var garbage_flush_reduction: int = 0
@export var line_clear_delay: float = 0.5

# Boss modifier: piece generation and garbage behaviour
var random_pieces: bool = false
var garbage_individual_lines: bool = false
var reflect_ratio: float = 0.0

var rng: RandomNumberGenerator = null
var enemy: Enemy = null
var garbage_interval_min: float = 0.0
var garbage_interval_max: float = 0.0
var garbage_lines_min: int = 1
var garbage_lines_max: int = 1

# ── Consumable-driven bonuses (applied via Consumable.apply_to_config) ──────
var consumable_all_bonus: int = 0
var consumable_quad_bonus: int = 0
var consumable_tspin_bonus: int = 0
var consumable_b2b_bonus: int = 0
var consumable_combo_bonus: int = 0
var consumable_pc_bonus: int = 0
var consumable_surge_clears_remaining: int = 0
