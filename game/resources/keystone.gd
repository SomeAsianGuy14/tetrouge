class_name Keystone
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var flavor_text: String = ""
@export var is_starter: bool = false
@export var category: String = ""
@export var requires_keystone_id: String = ""
@export var replaces_keystone_id: String = ""
@export var unlock_condition_id: String = ""

# ── Flat damage bonuses ───────────────────────────────────────────────────
@export var single_bonus: int = 0
@export var double_bonus: int = 0
@export var triple_bonus: int = 0
@export var quad_bonus: int = 0
@export var tspin_mini_bonus: int = 0
@export var tspin_single_bonus: int = 0
@export var tspin_double_bonus: int = 0
@export var tspin_triple_bonus: int = 0
@export var tspin_any_bonus: int = 0
@export var b2b_bonus: int = 0

# ── Per-technique bonuses ─────────────────────────────────────────────────
@export var per_technique_tspin_bonus: int = 0  # Enchant: +N per T-spin-relevant technique

# ── Multipliers (0.0 = inactive) ─────────────────────────────────────────
@export var quad_multiplier: float = 0.0
@export var tspin_double_multiplier: float = 0.0
@export var tspin_triple_multiplier: float = 0.0
@export var single_multiplier: float = 0.0
@export var combo_multiplier: float = 0.0
@export var combo_multiplier_threshold: int = 0
@export var pc_first_multiplier: float = 0.0
@export var pc_after_first_multiplier: float = 0.0
@export var consecutive_quad_multiplier: float = 0.0

# ── Suppression flags ─────────────────────────────────────────────────────
@export var suppress_spins: bool = false
@export var suppress_tspin_single: bool = false
@export var suppress_tspin_double: bool = false
@export var suppress_tspin_triple: bool = false
@export var suppress_non_singles: bool = false  # Holy Cheese: only singles deal damage

# ── Special mechanics ─────────────────────────────────────────────────────
@export var daze_stun_seconds: float = 0.0   # delay enemy timer on quad
@export var dizzy: bool = false              # >4 T-rotations adds +4 to next T-spin
@export var whirl: bool = false              # T-spins count as two combo steps
@export var safety_net: bool = false         # first B2B break per round absorbed
@export var final_blow: bool = false         # B2B break deals streak×2, disables B2B
@export var flexible_b2b: bool = false       # all spin clears maintain B2B

# ── Economy ───────────────────────────────────────────────────────────────
@export var end_round_coins: int = 0
@export var time_coins: bool = false

# ── Utility ───────────────────────────────────────────────────────────────
@export var hold_slots_bonus: int = 0
@export var preview_count_bonus: int = 0
@export var instant_arr: bool = false
@export var instant_soft_drop: bool = false
@export var risky_business: bool = false
@export var blessed_stone: bool = false
@export var per_attack_tag_bonus: int = 0
@export var reflect_on_flush: float = 0.0
@export var skip_line_clear_delay: bool = false
@export var attack_to_shield_pct: float = 0.0
@export var all_attack_multiplier: float = 0.0
@export var burning_board: bool = false
@export var burn_duration: float = 0.0
@export var master_of_none: bool = false
@export var master_of_one: bool = false

# ── New content keystones ───────────────────────────────────────────────────
@export var coins_per_10_held: int = 0
@export var shield_multiplier: float = 1.0
@export var shield_to_damage: bool = false
@export var enemy_interval_bonus: float = 0.0
@export var kill_coins: int = 0
@export var technique_trade: bool = false
@export var technique_capacity_bonus: int = 0
@export var ramping_rhythm: bool = false
@export var permanent_poison: bool = false
@export var permanent_burn: bool = false
@export var true_damage_on_start: int = 0

# ── Piece enhancements ──────────────────────────────────────────────────────
@export var piece_enhance_every_n: int = 0
@export var piece_enhance_type: String = ""
@export var start_shield: int = 0
@export var honed_bonus_per_cell: int = 0
@export var reinforced_bonus_per_cell: int = 0
@export var gilded_bonus_per_cell: int = 0
@export var amplified_bonus_per_cell: float = 0.0
@export var double_enhancement_benefits: bool = false

func apply_to_config(config: RoundConfig) -> void:
	if hold_slots_bonus > 0:
		config.hold_slots += hold_slots_bonus
	if preview_count_bonus > 0:
		config.preview_count += preview_count_bonus
	if instant_arr:
		config.instant_arr = true
	if instant_soft_drop:
		config.instant_soft_drop = true
	if safety_net:
		config.b2b_shield_count += 1
	if flexible_b2b:
		config.flexible_b2b = true
	if skip_line_clear_delay:
		config.line_clear_delay = 0.0
