class_name RunManager
extends Node

const SCENE_TETRIS_BOARD := "res://scenes/tetris/tetris_board.tscn"
const SCENE_SHOP := "res://scenes/shop/shop.tscn"
const SCENE_KEYSTONE_SELECTION := "res://scenes/keystone_selection/keystone_selection.tscn"
const SCENE_ROUND_SUCCESS := "res://scenes/screens/round_success.tscn"
const SCENE_RUN_FAILURE := "res://scenes/screens/run_failure.tscn"
const SCENE_RUN_VICTORY := "res://scenes/screens/run_victory.tscn"
const SCENE_DEBUG_OVERLAY := "res://scenes/debug/debug_overlay.tscn"
const SCENE_HOLD_DISPLAY := "res://scenes/game/hold_display.tscn"
const SCENE_QUEUE_DISPLAY := "res://scenes/game/queue_display.tscn"
const SCENE_ENEMY_DISPLAY := "res://scenes/game/enemy_display.tscn"
const SCENE_PAUSE_MENU := "res://scenes/game/pause_menu.tscn"
const SCENE_MAIN_MENU := "res://scenes/main_menu/main_menu.tscn"
const BASE_PAYOUT := 4
const ROUND_TIERS := ["Small", "Big", "Elite", "Boss"]

const SMALL_INTERVAL_MIN := 18.0
const SMALL_INTERVAL_MAX := 28.0
const SMALL_LINES_MIN := 1
const SMALL_LINES_MAX := 2
const BIG_INTERVAL_MIN := 14.0
const BIG_INTERVAL_MAX := 22.0
const BIG_LINES_MIN := 1
const BIG_LINES_MAX := 3
const ELITE_INTERVAL_MIN := 11.0
const ELITE_INTERVAL_MAX := 18.0
const ELITE_LINES_MIN := 2
const ELITE_LINES_MAX := 4
const BOSS_INTERVAL_MIN := 10.0
const BOSS_INTERVAL_MAX := 16.0
const BOSS_LINES_MIN := 2
const BOSS_LINES_MAX := 4

@onready var board_container: Node2D = $BoardContainer
@onready var hud: Control = $HUD

var current_board: TetrisBoard = null
var current_config: RoundConfig = null

var _debug_overlay: DebugOverlay = null
var _hold_display: HoldDisplay = null
var _queue_display: QueueDisplay = null
var _enemy_display: Control = null

var round_timer: float = 0.0
var _enemy_timer: float = 0.0
var _next_garbage_interval: float = 0.0
var quota_accumulated: float = 0.0
var technique_income_this_round: int = 0
var surplus_attack: int = 0
var pending_garbage: int = 0

var _attack_bar: Control = null

var _last_attack_was_quad: bool = false
var _t_spin_rotations: int = 0
var _pc_count_this_round: int = 0
var _last_cleared_rows: Array[int] = []

var _paused: bool = false
var _pause_menu: Control = null
var _board_was_active: bool = false
var _active_overlay: Control = null
var _pending_keystone: bool = false
var _round_ended: bool = false

signal round_ended(success: bool)

# ── Run start ─────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("run_manager")
	_setup_debug_tools()

func _exit_tree() -> void:
	DevConsole.set_run_manager(null)

func _setup_debug_tools() -> void:
	var overlay_scene: PackedScene = load(SCENE_DEBUG_OVERLAY)
	_debug_overlay = overlay_scene.instantiate()
	add_child(_debug_overlay)

	DevConsole.set_run_manager(self)

func start_run() -> void:
	RunState.reset()
	Economy.reset()
	Economy.add_coins(RunState.STARTING_COINS)
	RunState.emit_signal("run_started")
	_show_starter_keystone_selection()

func _show_starter_keystone_selection() -> void:
	var scene: PackedScene = load(SCENE_KEYSTONE_SELECTION)
	var screen = scene.instantiate()
	screen.starter_only = true
	get_tree().root.add_child(screen)
	screen.connect("keystone_chosen", _on_starter_keystone_chosen)

func _on_starter_keystone_chosen(_keystone: Keystone) -> void:
	start_round()

# ── Round start ───────────────────────────────────────────────────────────

func start_round() -> void:
	_round_ended = false
	pending_garbage = 0
	current_config = _build_round_config()
	hud.setup(current_config)
	quota_accumulated = 0.0
	technique_income_this_round = 0
	surplus_attack = 0
	round_timer = current_config.time_limit
	_enemy_timer = 0.0
	_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)
	_last_attack_was_quad = false
	_t_spin_rotations = 0
	_pc_count_this_round = 0
	_last_cleared_rows = []

	if current_board:
		current_board.queue_free()
	if _hold_display:
		_hold_display.queue_free()
	if _queue_display:
		_queue_display.queue_free()
	if _enemy_display:
		_enemy_display.queue_free()
		_enemy_display = null
	if _attack_bar:
		_attack_bar.queue_free()
		_attack_bar = null

	var board_scene: PackedScene = load(SCENE_TETRIS_BOARD)
	current_board = board_scene.instantiate()
	board_container.add_child(current_board)
	current_board.das_delay = Settings.load_das()
	current_board.arr_rate = Settings.load_arr()
	# Apply Persistence technique: doubles don't break B2B
	if RunState.has_technique("persistence"):
		current_config.b2b_persists_on_doubles = true
	current_board.setup(current_config)
	current_board.connect("attack_generated", _on_attack_generated)
	current_board.connect("game_over", _on_game_over)
	current_board.connect("board_updated", _on_board_updated)
	current_board.connect("lock_processed", _on_lock_processed)
	current_board.connect("piece_rotated", _on_piece_rotated)
	current_board.connect("rows_cleared", _on_rows_cleared)
	current_board.connect("b2b_broken", _on_b2b_broken)

	if _debug_overlay:
		_debug_overlay.set_board(current_board)
		_debug_overlay.run_manager = self

	var hold_scene: PackedScene = load(SCENE_HOLD_DISPLAY)
	_hold_display = hold_scene.instantiate()
	board_container.add_child(_hold_display)
	_hold_display.position = Vector2(-(4 * 24 + 16 + 8 + 20), 0)
	_hold_display.setup(current_board)

	var queue_scene: PackedScene = load(SCENE_QUEUE_DISPLAY)
	_queue_display = queue_scene.instantiate()
	board_container.add_child(_queue_display)
	_queue_display.position = Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16, 0)
	_queue_display.setup(current_board)

	var enemy_scene: PackedScene = load(SCENE_ENEMY_DISPLAY)
	_enemy_display = enemy_scene.instantiate()
	board_container.add_child(_enemy_display)
	_enemy_display.position = Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16 + 112 + 48, 0)
	_enemy_display.setup(current_config.enemy, current_config.quota)
	hud.set_enemy_display(_enemy_display)

	var attack_bar_script := load("res://scenes/game/attack_bar.gd") as GDScript
	_attack_bar = attack_bar_script.new()
	board_container.add_child(_attack_bar)
	_attack_bar.position = Vector2(-20, 0)

func _build_round_config() -> RoundConfig:
	var cfg := RoundConfig.new()
	cfg.rng = RunState.rng
	cfg.quota = RunState.calculate_quota(RunState.stage, RunState.round_index)

	for keystone in RunState.keystones:
		keystone.apply_to_config(cfg)

	var enemy := _draw_enemy()
	cfg.enemy = enemy
	var _stage_scalar := maxf(0.5, 1.0 - (RunState.stage - 1) * 0.1)
	var _lines_bonus := (RunState.stage - 1) / 2
	var _imin: float; var _imax: float; var _lmin: int; var _lmax: int
	match enemy.tier:
		"Small":
			_imin = SMALL_INTERVAL_MIN; _imax = SMALL_INTERVAL_MAX
			_lmin = SMALL_LINES_MIN;    _lmax = SMALL_LINES_MAX
		"Big":
			_imin = BIG_INTERVAL_MIN;   _imax = BIG_INTERVAL_MAX
			_lmin = BIG_LINES_MIN;      _lmax = BIG_LINES_MAX
		"Elite":
			_imin = ELITE_INTERVAL_MIN; _imax = ELITE_INTERVAL_MAX
			_lmin = ELITE_LINES_MIN;    _lmax = ELITE_LINES_MAX
		_:
			_imin = BOSS_INTERVAL_MIN;  _imax = BOSS_INTERVAL_MAX
			_lmin = BOSS_LINES_MIN;     _lmax = BOSS_LINES_MAX
	cfg.garbage_interval_min = _imin * _stage_scalar
	cfg.garbage_interval_max = _imax * _stage_scalar
	cfg.garbage_lines_min = _lmin + _lines_bonus
	cfg.garbage_lines_max = _lmax + _lines_bonus

	if enemy.ability:
		cfg.boss_modifier = enemy.ability
		enemy.ability.apply_to_config(cfg)

	cfg.time_limit = RunState.calculate_time_limit(RunState.stage, cfg.boss_modifier.id if cfg.boss_modifier else "")
	return cfg

func _load_enemy_pool(tier: String) -> Array:
	var dir := DirAccess.open("res://resources/data/enemies/")
	var result := []
	if dir:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".tres"):
				var res := load("res://resources/data/enemies/" + f)
				if res != null and res.tier == tier:
					result.append(res)
			f = dir.get_next()
	return result

func _draw_enemy() -> Enemy:
	var tier: String = ROUND_TIERS[RunState.round_index]
	var pool := _load_enemy_pool(tier)
	var available: Array
	if tier == "Boss":
		available = pool.filter(func(e): return e.id not in RunState.used_boss_enemy_ids)
		if available.is_empty():
			available = pool
	else:
		available = pool
	RunState.seeded_shuffle(available)
	var chosen: Enemy = available[0]
	if tier == "Boss":
		RunState.used_boss_enemy_ids.append(chosen.id)
	return chosen

# ── Per-frame update ──────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if _pause_menu == null:
			_open_pause()
		else:
			_close_pause()
		return

	if _paused or current_board == null or not current_board.is_active:
		return

	current_board.tick(delta)
	_handle_input()
	_tick_timer(delta)
	_tick_enemy_garbage(delta)
	if _enemy_display and current_config:
		_enemy_display.update_windup(_enemy_timer, _next_garbage_interval)

# ── Pause ─────────────────────────────────────────────────────────────────

func _open_pause() -> void:
	_paused = true
	_board_was_active = current_board != null and current_board.is_active
	if _board_was_active:
		current_board.is_active = false
		current_board.input_move_released()
	var scene: PackedScene = load(SCENE_PAUSE_MENU)
	_pause_menu = scene.instantiate()
	add_child(_pause_menu)
	_pause_menu.connect("resume_requested", _close_pause)
	_pause_menu.connect("quit_requested", _quit_to_menu)

func _close_pause() -> void:
	_paused = false
	if _board_was_active and current_board != null:
		current_board.das_delay = Settings.load_das()
		current_board.arr_rate = Settings.load_arr()
		current_board.is_active = true
	_board_was_active = false
	if _pause_menu:
		_pause_menu.queue_free()
		_pause_menu = null

func _quit_to_menu() -> void:
	RunState.reset()
	Economy.reset()
	var scene: PackedScene = load(SCENE_MAIN_MENU)
	get_tree().root.add_child(scene.instantiate())
	queue_free()

func _handle_input() -> void:
	if Input.is_action_just_pressed("move_left"):
		current_board.input_move_left_pressed()
	elif Input.is_action_just_released("move_left"):
		if not Input.is_action_pressed("move_right"):
			current_board.input_move_released()

	if Input.is_action_just_pressed("move_right"):
		current_board.input_move_right_pressed()
	elif Input.is_action_just_released("move_right"):
		if not Input.is_action_pressed("move_left"):
			current_board.input_move_released()

	current_board.input_soft_drop(Input.is_action_pressed("soft_drop"))

	if Input.is_action_just_pressed("hard_drop"):
		current_board.input_hard_drop()
	if Input.is_action_just_pressed("rotate_cw"):
		current_board.input_rotate_cw()
	if Input.is_action_just_pressed("rotate_ccw"):
		current_board.input_rotate_ccw()
	if Input.is_action_just_pressed("rotate_180"):
		current_board.input_rotate_180()
	if Input.is_action_just_pressed("hold_piece"):
		current_board.input_hold()

func _tick_timer(delta: float) -> void:
	round_timer -= delta
	hud.update_timer(round_timer)
	if round_timer <= 0.0:
		_end_round(false)

func _tick_enemy_garbage(delta: float) -> void:
	if current_config == null or current_config.garbage_interval_max <= 0.0:
		return
	_enemy_timer += delta
	if _enemy_timer >= _next_garbage_interval:
		_enemy_timer = 0.0
		pending_garbage += randi_range(current_config.garbage_lines_min, current_config.garbage_lines_max)
		_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)
		_notify_attack_bar()
		if _enemy_display:
			_enemy_display.update_windup(0.0, _next_garbage_interval)

# ── Attack signal handler ─────────────────────────────────────────────────

func _on_piece_rotated(piece_type: String) -> void:
	if piece_type == "T":
		_t_spin_rotations += 1
	else:
		_t_spin_rotations = 0

func _on_rows_cleared(row_indices: Array[int]) -> void:
	_last_cleared_rows = row_indices

func _on_b2b_broken(streak: int) -> void:
	for ks in RunState.keystones:
		if ks.final_blow:
			quota_accumulated += streak * 2
			if current_config:
				current_config.b2b_disabled = true
			break

func _on_attack_generated(raw_attack: int, event_type: String) -> void:
	var modified := _apply_techniques(raw_attack, event_type)
	_accumulate_technique_income(event_type, modified)
	modified = _apply_keystone_suppressions(modified, event_type)
	modified = _apply_keystone_flat_bonuses(modified, event_type)
	modified = _apply_keystone_multipliers(modified, event_type)

	# Apply boss modifier quota filter; bonus events always count if their parent clear qualified
	var is_bonus_event := event_type == "b2b" or event_type == "combo"
	if not is_bonus_event and current_config.boss_modifier:
		if not current_config.boss_modifier.attack_counts_toward_quota(event_type):
			return

	# Update per-round trackers (skip bonus events so they don't reset the quad streak)
	if event_type != "b2b" and event_type != "combo":
		_last_attack_was_quad = (event_type == "tetris")
	if event_type == "perfect_clear":
		_pc_count_this_round += 1

	var to_quota := _drain_attack(modified)
	quota_accumulated += to_quota
	surplus_attack = maxi(0, int(quota_accumulated) - current_config.quota)
	if hud:
		hud.update_quota(quota_accumulated, current_config.quota)

	if quota_accumulated >= current_config.quota:
		_end_round(true)

# ── Keystone attack modifiers ─────────────────────────────────────────────

func _apply_keystone_suppressions(attack: int, event_type: String) -> int:
	for ks in RunState.keystones:
		if ks.suppress_spins and event_type in ["tspin_mini", "tspin_single", "tspin_double", "tspin_triple", "tspin_any"]:
			return 0
		if ks.suppress_tspin_single and event_type == "tspin_single":
			return 0
		if ks.suppress_tspin_double and event_type == "tspin_double":
			return 0
		if ks.suppress_tspin_triple and event_type == "tspin_triple":
			return 0
		if ks.suppress_non_singles and event_type != "single":
			return 0
	return attack

func _apply_keystone_flat_bonuses(attack: int, event_type: String) -> int:
	if attack == 0:
		return 0
	var bonus := 0
	for ks in RunState.keystones:
		match event_type:
			"single":
				bonus += ks.single_bonus
			"double":
				bonus += ks.double_bonus
			"triple":
				bonus += ks.triple_bonus
			"tetris":
				bonus += ks.quad_bonus
				if ks.per_technique_quad_bonus > 0:
					for t in RunState.techniques:
						if t.flat_bonus_by_event.get("tetris", 0) > 0 or t.flat_bonus_by_event.get("any_clear", 0) > 0:
							bonus += ks.per_technique_quad_bonus
			"tspin_mini":
				bonus += ks.tspin_mini_bonus + ks.tspin_any_bonus
			"tspin_single":
				bonus += ks.tspin_single_bonus + ks.tspin_any_bonus
				if ks.per_technique_tspin_bonus > 0:
					for t in RunState.techniques:
						if t.flat_bonus_by_event.get("tspin_single", 0) > 0 or t.flat_bonus_by_event.get("tspin_any", 0) > 0 or t.flat_bonus_by_event.get("any_clear", 0) > 0:
							bonus += ks.per_technique_tspin_bonus
			"tspin_double":
				bonus += ks.tspin_double_bonus + ks.tspin_any_bonus
				if ks.per_technique_tspin_bonus > 0:
					for t in RunState.techniques:
						if t.flat_bonus_by_event.get("tspin_double", 0) > 0 or t.flat_bonus_by_event.get("tspin_any", 0) > 0 or t.flat_bonus_by_event.get("any_clear", 0) > 0:
							bonus += ks.per_technique_tspin_bonus
			"tspin_triple":
				bonus += ks.tspin_triple_bonus + ks.tspin_any_bonus
				if ks.per_technique_tspin_bonus > 0:
					for t in RunState.techniques:
						if t.flat_bonus_by_event.get("tspin_triple", 0) > 0 or t.flat_bonus_by_event.get("tspin_any", 0) > 0 or t.flat_bonus_by_event.get("any_clear", 0) > 0:
							bonus += ks.per_technique_tspin_bonus
			"b2b":
				bonus += ks.b2b_bonus
		# Dizzy: >4 T rotations adds +4 to the next T-spin
		if ks.dizzy and "tspin" in event_type and event_type != "tspin_mini" and _t_spin_rotations > 4:
			bonus += 4
	return attack + bonus

func _apply_keystone_multipliers(attack: int, event_type: String) -> int:
	if attack == 0:
		return 0
	var mult := 1.0
	for ks in RunState.keystones:
		match event_type:
			"single":
				if ks.single_multiplier > 0.0:
					mult *= ks.single_multiplier
			"tetris":
				if ks.quad_multiplier > 0.0:
					mult *= ks.quad_multiplier
				if ks.consecutive_quad_multiplier > 0.0 and _last_attack_was_quad:
					mult *= ks.consecutive_quad_multiplier
				if ks.daze_stun_seconds > 0.0:
					_enemy_timer = maxf(0.0, _enemy_timer - ks.daze_stun_seconds)
			"tspin_double":
				if ks.tspin_double_multiplier > 0.0:
					mult *= ks.tspin_double_multiplier
			"tspin_triple":
				if ks.tspin_triple_multiplier > 0.0:
					mult *= ks.tspin_triple_multiplier
			"combo":
				if ks.combo_multiplier > 0.0 and current_board and current_board.combo > ks.combo_multiplier_threshold:
					mult *= ks.combo_multiplier
			"perfect_clear":
				if ks.pc_first_multiplier > 0.0 and _pc_count_this_round == 0:
					mult *= ks.pc_first_multiplier
				elif ks.pc_after_first_multiplier > 0.0 and _pc_count_this_round > 0:
					mult *= ks.pc_after_first_multiplier
		# Risky Business: any cleared row in top 5 visible rows doubles damage
		if ks.risky_business and event_type not in ["b2b", "combo"]:
			for row_idx in _last_cleared_rows:
				if row_idx >= TetrisBoard.HIDDEN_ROWS and row_idx < TetrisBoard.HIDDEN_ROWS + 5:
					mult *= 2.0
					break
	return int(float(attack) * mult)

func _apply_techniques(raw_attack: int, event_type: String) -> int:
	var result := raw_attack
	for technique in RunState.techniques:
		result += technique.get_flat_bonus(event_type)
		if technique.b2b_bonus_override > 0 and event_type == Technique.EVENT_B2B:
			result += technique.b2b_bonus_override - 1  # already have base +1
		if technique.combo_bonus_per_step > 0 and event_type == Technique.EVENT_COMBO:
			result += technique.combo_bonus_per_step
		if technique.avalanche_threshold > 0 and current_board.combo >= technique.avalanche_threshold:
			result *= 2
		if technique.perfect_clear_bonus > 0 and event_type == Technique.EVENT_PERFECT_CLEAR:
			result += technique.perfect_clear_bonus
	return maxi(0, result)

func _accumulate_technique_income(event_type: String, _modified_attack: int) -> void:
	for technique in RunState.techniques:
		if technique.coins_per_tspin > 0 and "tspin" in event_type:
			technique_income_this_round += technique.coins_per_tspin
		if technique.coins_per_b2b > 0 and event_type == Technique.EVENT_B2B:
			technique_income_this_round += technique.coins_per_b2b

# ── Attack buffer helpers ─────────────────────────────────────────────────

func _drain_attack(modified: int) -> int:
	var drain := mini(modified, pending_garbage)
	pending_garbage -= drain
	_notify_attack_bar()
	return modified - drain

func _flush_pending_garbage() -> int:
	var reduction := current_config.garbage_flush_reduction if current_config else 0
	var flush := maxi(0, mini(pending_garbage, 8) - reduction)
	pending_garbage -= flush
	return flush

func _notify_attack_bar() -> void:
	if _attack_bar:
		_attack_bar.update_pending(pending_garbage)

# ── Round end ─────────────────────────────────────────────────────────────

func _on_game_over() -> void:
	_end_round(false)

func _end_round(success: bool) -> void:
	if _round_ended:
		return
	_round_ended = true
	pending_garbage = 0
	_notify_attack_bar()
	if current_board:
		current_board.is_active = false
	if not success:
		_show_failure()
		return

	var speed_bonus := Economy.calculate_speed_bonus(round_timer, current_config.time_limit)
	var surplus_income := _calculate_surplus_income()
	_apply_keystone_economy()
	Economy.pay_round(BASE_PAYOUT, speed_bonus, technique_income_this_round + surplus_income)

	var was_boss := RunState.is_boss_round()
	RunState.advance_round()

	if RunState.is_run_complete():
		_show_victory()
		return

	_pending_keystone = was_boss
	_show_round_success(speed_bonus, surplus_income)

func _apply_keystone_economy() -> void:
	for ks in RunState.keystones:
		if ks.end_round_coins > 0:
			Economy.coins += ks.end_round_coins
		if ks.overkill_coins:
			Economy.coins += surplus_attack
		if ks.time_coins:
			Economy.coins += int(round_timer / 5.0)

func _calculate_surplus_income() -> int:
	var income := 0
	for technique in RunState.techniques:
		if technique.coins_per_attack_above_quota > 0:
			income += surplus_attack / technique.surplus_divisor
	return income

func _on_lock_processed() -> void:
	_t_spin_rotations = 0
	_last_cleared_rows = []
	if hud and current_board:
		hud.update_b2b_combo(current_board.is_b2b, current_board.b2b_count, current_board.combo)
	var flush := _flush_pending_garbage()
	if flush > 0 and current_board:
		var col := randi() % current_config.board_width
		current_board.insert_garbage_rows(flush, col)
		_notify_attack_bar()

func _on_board_updated() -> void:
	if current_board:
		current_board.queue_redraw()

# ── Scene transitions ─────────────────────────────────────────────────────

func _show_round_success(speed_bonus: int, surplus_income: int) -> void:
	var scene: PackedScene = load(SCENE_ROUND_SUCCESS)
	var screen = scene.instantiate()
	_active_overlay = screen
	add_child(screen)
	screen.connect("proceed", _on_success_proceed)
	screen.setup(BASE_PAYOUT, speed_bonus, technique_income_this_round + surplus_income)

func _on_success_proceed() -> void:
	if _pending_keystone:
		_pending_keystone = false
		_show_keystone_selection()
	else:
		_show_shop()

func _show_shop() -> void:
	for child in get_children():
		if child is CanvasItem:
			child.visible = false
	var scene: PackedScene = load(SCENE_SHOP)
	var shop = scene.instantiate()
	add_child(shop)
	shop.connect("shop_closed", _on_shop_closed)

func _on_shop_closed() -> void:
	board_container.visible = true
	hud.visible = true
	RunSave.save()
	start_round()

func _show_keystone_selection() -> void:
	var scene: PackedScene = load(SCENE_KEYSTONE_SELECTION)
	var screen = scene.instantiate()
	get_tree().root.add_child(screen)
	screen.connect("keystone_chosen", _on_keystone_chosen)

func _on_keystone_chosen(_keystone: Keystone) -> void:
	_show_shop()

func _show_failure() -> void:
	RunSave.delete()
	var scene: PackedScene = load(SCENE_RUN_FAILURE)
	var screen = scene.instantiate()
	add_child(screen)
	screen.setup(RunState.stage, RunState.round_index)

func _show_victory() -> void:
	RunSave.delete()
	var scene: PackedScene = load(SCENE_RUN_VICTORY)
	var screen = scene.instantiate()
	add_child(screen)
	screen.setup(Economy.coins)

# ── Consumable integration ────────────────────────────────────────────────

func apply_consumable(consumable: Consumable) -> void:
	if consumable.clears_board and current_board:
		current_board.apply_clean_slate()
	if consumable.guarantees_next_t and current_board:
		current_board.next_piece_forced_t = true
	if consumable.adds_time > 0.0:
		round_timer = minf(round_timer + consumable.adds_time, current_config.time_limit + consumable.adds_time)
	if consumable.adds_coins > 0:
		Economy.add_coins(consumable.adds_coins)
	if consumable.attack_surge_clears > 0 and current_board:
		current_board.activate_attack_surge(consumable.attack_surge_clears)
	RunState.remove_consumable(consumable)
