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

const SMALL_INTERVAL_MIN := 22.5
const SMALL_INTERVAL_MAX := 35.0
const SMALL_LINES_MIN := 1
const SMALL_LINES_MAX := 2
const BIG_INTERVAL_MIN := 17.5
const BIG_INTERVAL_MAX := 27.5
const BIG_LINES_MIN := 1
const BIG_LINES_MAX := 3
const ELITE_INTERVAL_MIN := 13.75
const ELITE_INTERVAL_MAX := 22.5
const ELITE_LINES_MIN := 2
const ELITE_LINES_MAX := 4
const BOSS_INTERVAL_MIN := 12.5
const BOSS_INTERVAL_MAX := 20.0
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
var surplus_attack: int = 0
var _garbage_packets: Array = []

var _attack_bar: Control = null

var _last_attack_was_quad: bool = false
var _t_spin_rotations: int = 0
var _pc_count_this_round: int = 0
var _last_cleared_rows: Array[int] = []

var _technique_round_state: TechniqueRoundState = null
var _held_this_piece: bool = false
var _used_soft_drop_this_piece: bool = false
var _hard_drop_used_this_piece: bool = false
var _rotations_this_piece: int = 0
var _locked_pivot_col: int = -1
var _piece_spawn_time: float = 0.0
var _burning_board_timer: float = 0.0
var _burning_board_active: bool = false
var _deferred_reflect_lines: int = 0
var _flash_step_arr_pending: bool = false
var _greedy_hands_active: bool = false

var _blessed_stone_spent: bool = false

var _run_stats: RunStats = null

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
	_run_stats = RunStats.new()
	var _asc := AscensionManager.get_modifiers(AscensionManager.current_level)
	RunState.consumable_capacity = maxi(0, RunState.consumable_capacity + _asc.get("consumable_capacity_delta", 0))
	RunState.technique_capacity = maxi(1, RunState.technique_capacity + _asc.get("technique_capacity_delta", 0))
	RunState.emit_signal("run_started")
	if _asc.get("skip_starter_keystone", false):
		start_round()
	else:
		_show_starter_keystone_selection()

func _show_starter_keystone_selection() -> void:
	hud.visible = false
	var scene: PackedScene = load(SCENE_KEYSTONE_SELECTION)
	var screen = scene.instantiate()
	screen.starter_only = true
	get_tree().root.add_child(screen)
	screen.connect("keystone_chosen", _on_starter_keystone_chosen)

func _on_starter_keystone_chosen(_keystone: Keystone) -> void:
	hud.visible = true
	start_round()

# ── Round start ───────────────────────────────────────────────────────────

func start_round() -> void:
	_round_ended = false
	_garbage_packets = []
	_deferred_reflect_lines = 0
	current_config = _build_round_config()
	hud.setup(current_config)
	quota_accumulated = 0.0
	surplus_attack = 0
	round_timer = current_config.time_limit
	_enemy_timer = 0.0
	_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)
	_last_attack_was_quad = false
	_t_spin_rotations = 0
	_pc_count_this_round = 0
	_last_cleared_rows = []
	_technique_round_state = TechniqueRoundState.new()
	_held_this_piece = false
	_used_soft_drop_this_piece = false
	_hard_drop_used_this_piece = false
	_rotations_this_piece = 0
	_piece_spawn_time = 0.0
	_burning_board_active = RunState.has_technique("burning_board")
	_burning_board_timer = 0.0
	_flash_step_arr_pending = false
	_greedy_hands_active = RunState.has_technique("greedy_hands")

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
	current_board.sdf_multiplier = Settings.load_sdf()
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
	current_board.connect("piece_locked", _on_piece_locked)

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
	_enemy_display.set_attack_bar_visible(current_config.reflect_ratio <= 0.0)
	hud.set_enemy_display(_enemy_display)
	hud.set_run_manager(self)

	var attack_bar_script := load("res://scenes/game/attack_bar.gd") as GDScript
	_attack_bar = attack_bar_script.new()
	board_container.add_child(_attack_bar)
	_attack_bar.position = Vector2(-20, 0)
	_attack_bar.flush_capacity = 8
	hud._refresh_backpack_slots()

func _build_round_config() -> RoundConfig:
	var cfg := RoundConfig.new()
	cfg.rng = RunState.rng
	cfg.quota = RunState.calculate_quota(RunState.stage, RunState.round_index)
	var _asc_quota: float = AscensionManager.get_modifiers(AscensionManager.current_level).get("quota_mult", 1.0)
	if _asc_quota != 1.0:
		cfg.quota = ceili(cfg.quota * _asc_quota)

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
	var _asc := AscensionManager.get_modifiers(AscensionManager.current_level)
	var _interval_scalar := (1.0 / 1.25) if _asc.get("faster_attacks", false) else 1.0
	cfg.garbage_interval_min = _imin * _stage_scalar * _interval_scalar
	cfg.garbage_interval_max = _imax * _stage_scalar * _interval_scalar
	cfg.garbage_lines_min = _lmin + _lines_bonus + _asc.get("extra_lines", 0)
	cfg.garbage_lines_max = _lmax + _lines_bonus + _asc.get("extra_lines", 0)

	cfg.time_limit = RunState.calculate_time_limit(RunState.stage)

	if enemy.ability:
		cfg.boss_modifier = enemy.ability
		enemy.ability.apply_to_config(cfg)

	cfg.show_timer = RunState.has_keystone("golden_watch") or \
		(cfg.boss_modifier != null and cfg.boss_modifier.id == "the_blitz")

	# Glass Cannon: +2 incoming garbage lines per wave
	if RunState.has_technique("glass_cannon"):
		cfg.garbage_lines_min += 2
		cfg.garbage_lines_max += 2
	# Greedy Hands: enemy gains +1 attack per wave (reduce interval to simulate)
	if RunState.has_technique("greedy_hands"):
		cfg.garbage_lines_min += 1
		cfg.garbage_lines_max += 1

	return cfg

func _load_enemy_pool(tier: String) -> Array:
	var result := []
	for res in ResourceRegistry.all_enemies:
		if res.tier == tier:
			result.append(res)
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
	_tick_burning_board(delta)
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
		current_board.sdf_multiplier = Settings.load_sdf()
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

	if Input.is_action_pressed("soft_drop"):
		_used_soft_drop_this_piece = true
	current_board.input_soft_drop(Input.is_action_pressed("soft_drop"))

	if Input.is_action_just_pressed("hard_drop"):
		_hard_drop_used_this_piece = true
		current_board.input_hard_drop()
	if Input.is_action_just_pressed("rotate_cw"):
		current_board.input_rotate_cw()
	if Input.is_action_just_pressed("rotate_ccw"):
		current_board.input_rotate_ccw()
	if Input.is_action_just_pressed("rotate_180"):
		current_board.input_rotate_180()
	if Input.is_action_just_pressed("hold_piece"):
		_held_this_piece = true
		current_board.input_hold()

func _tick_timer(delta: float) -> void:
	round_timer -= delta
	if hud:
		hud.update_timer(round_timer)
	if round_timer <= 0.0:
		round_timer = 0.0
		if current_config and current_config.boss_modifier != null and current_config.boss_modifier.id == "the_blitz":
			_end_round(false)

func _tick_enemy_garbage(delta: float) -> void:
	if current_config == null or current_config.garbage_interval_max <= 0.0:
		return
	_enemy_timer += delta
	if _enemy_timer >= _next_garbage_interval:
		_enemy_timer = 0.0
		if current_config.reflect_ratio <= 0.0:
			var n := randi_range(current_config.garbage_lines_min, current_config.garbage_lines_max)
			n = maxi(0, n - current_config.garbage_flush_reduction)
			if n > 0:
				if current_config.garbage_individual_lines:
					for _i in range(n):
						var filth_col := randi() % current_config.board_width
						_garbage_packets.append({lines = 1, is_filth = true, col = filth_col})
				else:
					var packet_col := randi() % current_config.board_width
					_garbage_packets.append({lines = n, is_filth = false, col = packet_col})
			_notify_attack_bar()
			if _technique_round_state:
				_technique_round_state.after_receive_pending = true
		_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)
		if _enemy_display:
			_enemy_display.update_windup(0.0, _next_garbage_interval)

func _tick_burning_board(delta: float) -> void:
	if not _burning_board_active or current_board == null or not current_board.is_active:
		return
	_burning_board_timer += delta
	if _burning_board_timer >= 5.0:
		_burning_board_timer -= 5.0
		var col := randi() % current_config.board_width
		current_board.insert_garbage_rows(1, col)

# ── Attack signal handler ─────────────────────────────────────────────────

func _on_piece_locked() -> void:
	_locked_pivot_col = current_board.current_pivot.x if current_board else -1
	if _technique_round_state:
		var rs := _technique_round_state
		rs.pieces_placed += 1
		if rs.pieces_placed % 10 == 0:
			rs.escalation_pending = true
		if rs.patience_cooldown_pieces > 0:
			rs.patience_cooldown_pieces -= 1
		# Constant Pressure: piece locked within 1 second of spawning
		var elapsed: float = Time.get_ticks_msec() / 1000.0 - _piece_spawn_time
		if elapsed <= 1.0:
			rs.constant_pressure_pending = true
		# Flow Step: 4 consecutive pieces without rotating
		if _rotations_this_piece == 0:
			rs.no_rotate_streak += 1
			if rs.no_rotate_streak >= 4:
				rs.flow_step_pending = true
		else:
			rs.no_rotate_streak = 0
		# Good Planning: 5 consecutive pieces without using hold
		if _held_this_piece:
			rs.good_planning_consecutive_no_hold = 0
			rs.good_planning_pending = false
		else:
			rs.good_planning_consecutive_no_hold += 1
			if rs.good_planning_consecutive_no_hold >= 5:
				rs.good_planning_pending = true

func _on_piece_rotated(piece_type: String) -> void:
	if piece_type == "T":
		_t_spin_rotations += 1
	else:
		_t_spin_rotations = 0
	_rotations_this_piece += 1

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
	var is_bonus_event: bool = event_type == "b2b" or event_type == "combo"
	var ctx := _build_attack_context(raw_attack, event_type)

	# Technique evaluation (only on primary clear events, not b2b/combo bonus events)
	var technique_atk: int = 0
	var technique_coins: int = 0
	if not is_bonus_event and _technique_round_state:
		var eval_result: Dictionary = TechniqueEvaluator.evaluate(
			RunState.techniques, ctx, _technique_round_state)
		technique_atk = eval_result.get("attack_delta", 0)
		technique_coins = eval_result.get("coins_delta", 0)
		Economy.add_coins(technique_coins)
		_handle_technique_flags(eval_result.get("flags", []))
		_update_round_state_after_eval(ctx, eval_result)

	var modified: int = raw_attack + technique_atk
	modified = _apply_keystone_suppressions(modified, event_type)
	modified = _apply_keystone_flat_bonuses(modified, event_type)
	modified = _apply_consumable_flat_bonuses(modified, event_type)
	modified = _apply_consumable_surge(modified, event_type)
	modified = _apply_keystone_multipliers(modified, event_type)

	# Apply boss modifier quota filter
	if not is_bonus_event and current_config.boss_modifier:
		if not current_config.boss_modifier.attack_counts_toward_quota(event_type):
			return

	if event_type != "b2b" and event_type != "combo":
		_last_attack_was_quad = (event_type == "quad")
	if event_type == "perfect_clear":
		_pc_count_this_round += 1

	if modified > 0:
		var tag_bonus := 0
		for ks in RunState.keystones:
			if ks.per_attack_tag_bonus > 0:
				tag_bonus += ks.per_attack_tag_bonus
		if tag_bonus > 0:
			var qualifying := 0
			for t in RunState.techniques:
				if t.tags.size() >= 2:
					qualifying += 1
			modified += tag_bonus * qualifying

	var to_quota: int = _drain_attack(modified)
	quota_accumulated += to_quota
	surplus_attack = maxi(0, int(quota_accumulated) - current_config.quota)
	if hud:
		hud.update_quota(quota_accumulated, current_config.quota)
	if _run_stats and to_quota > 0:
		_run_stats.total_damage += to_quota
		if event_type == "quad":
			_run_stats.quad_damage += to_quota
		elif event_type.begins_with("tspin"):
			_run_stats.tspin_damage += to_quota

	if current_config.reflect_ratio > 0.0 and to_quota > 0:
		var reflect_lines := floori(to_quota * current_config.reflect_ratio)
		if reflect_lines > 0:
			_deferred_reflect_lines += reflect_lines

	if quota_accumulated >= current_config.quota:
		_end_round(true)

func _build_attack_context(raw_attack: int, event_type: String) -> AttackContext:
	var ctx := AttackContext.new()
	ctx.garbage_sent = raw_attack
	ctx.b2b = current_board.is_b2b if current_board else false
	ctx.combo = current_board.combo if current_board else -1
	ctx.board_height = current_board.summit_height if current_board else 0
	ctx.held_this_piece = _held_this_piece
	ctx.used_soft_drop = _used_soft_drop_this_piece
	ctx.rotations_this_placement = _rotations_this_piece
	ctx.locked_col = _locked_pivot_col
	ctx.piece_placement_count = _technique_round_state.pieces_placed if _technique_round_state else 0
	ctx.enemy_hp_pct = maxf(0.0, 1.0 - quota_accumulated / maxf(1.0, float(current_config.quota))) if current_config else 1.0
	match event_type:
		"single":          ctx.lines_cleared = 1
		"double":          ctx.lines_cleared = 2
		"triple":          ctx.lines_cleared = 3
		"quad":            ctx.lines_cleared = 4
		"tspin_mini":      ctx.lines_cleared = 1; ctx.tspin = "mini"
		"tspin_single":    ctx.lines_cleared = 1; ctx.tspin = "single"
		"tspin_double":    ctx.lines_cleared = 2; ctx.tspin = "double"
		"tspin_triple":    ctx.lines_cleared = 3; ctx.tspin = "triple"
		"perfect_clear":   ctx.lines_cleared = 4; ctx.perfect_clear = true
	return ctx

func _handle_technique_flags(flags: Array) -> void:
	for flag: String in flags:
		match flag:
			"flash_step_arr":
				_flash_step_arr_pending = true
			"burning_board":
				_burning_board_active = true
			"glass_cannon":
				pass  # +2 incoming handled in _build_round_config via technique check
			"greedy_hands":
				_greedy_hands_active = true

func _update_round_state_after_eval(ctx: AttackContext, _eval: Dictionary) -> void:
	if _technique_round_state == null:
		return
	var rs := _technique_round_state
	if ctx.lines_cleared > 0:
		rs.clears_this_round += 1
		rs.attack_events_this_round += 1
		rs.total_garbage_sent += ctx.garbage_sent

		# Apply Whirl keystone: T-spins count as 2 combo steps
		if ctx.tspin != "" and RunState.has_keystone("whirl") and current_board:
			current_board.combo += 1  # already incremented once in board; add 1 more

		if ctx.tspin != "":
			rs.tspin_count += 1
		if ctx.b2b:
			rs.b2b_count += 1
		if ctx.perfect_clear:
			rs.perfect_clear_count += 1
		if ctx.lines_cleared == 4:
			rs.tetris_count += 1
			rs.tetris_echo_pending = true
			rs.last_clear_was_tetris = true
		else:
			rs.last_clear_was_tetris = false
			rs.tetris_echo_pending = false

		# Consume one-shot pending flags
		if rs.opening_blow_used == false:
			rs.opening_blow_used = true
		if rs.follow_up_pending:
			rs.follow_up_pending = false
		else:
			rs.follow_up_pending = true  # arm for next clear
		if rs.tetris_echo_pending and ctx.lines_cleared != 4:
			rs.tetris_echo_pending = false
		if rs.escalation_pending:
			rs.escalation_pending = false
		if rs.after_receive_pending:
			rs.after_receive_pending = false
		if rs.patience_pending:
			rs.patience_pending = false
			rs.patience_cooldown_pieces = 5
		if rs.constant_pressure_pending:
			rs.constant_pressure_pending = false
		if rs.flow_step_pending:
			rs.flow_step_pending = false
		if rs.good_planning_pending:
			rs.good_planning_pending = false

		# Flash Step: restore ARR after the piece that triggered it locks
		if _flash_step_arr_pending and current_board:
			current_board.arr_rate = 0.0
			_flash_step_arr_pending = false

		# Combo payout: mark used; coins already credited via TechniqueEvaluator
		if ctx.combo >= 4 and not rs.combo_payout_used:
			rs.combo_payout_used = true

		# Patience cooldown
		if _held_this_piece and rs.patience_cooldown_pieces == 0:
			rs.patience_pending = true

	# Reset per-piece flags
	_held_this_piece = false
	_used_soft_drop_this_piece = false
	_rotations_this_piece = 0

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
			"quad":
				bonus += ks.quad_bonus
				if ks.per_technique_quad_bonus > 0:
					for t in RunState.techniques:
						if "quad" in t.tags or "general" in t.tags:
							bonus += ks.per_technique_quad_bonus
			"tspin_mini":
				bonus += ks.tspin_mini_bonus + ks.tspin_any_bonus
			"tspin_single":
				bonus += ks.tspin_single_bonus + ks.tspin_any_bonus
				if ks.per_technique_tspin_bonus > 0:
					for t in RunState.techniques:
						if "tspin" in t.tags:
							bonus += ks.per_technique_tspin_bonus
			"tspin_double":
				bonus += ks.tspin_double_bonus + ks.tspin_any_bonus
				if ks.per_technique_tspin_bonus > 0:
					for t in RunState.techniques:
						if "tspin" in t.tags:
							bonus += ks.per_technique_tspin_bonus
			"tspin_triple":
				bonus += ks.tspin_triple_bonus + ks.tspin_any_bonus
				if ks.per_technique_tspin_bonus > 0:
					for t in RunState.techniques:
						if "tspin" in t.tags:
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
			"quad":
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


# ── Attack buffer helpers ─────────────────────────────────────────────────

func _drain_attack(modified: int) -> int:
	var remaining := modified
	var i := 0
	while remaining > 0 and i < _garbage_packets.size():
		var packet = _garbage_packets[i]
		if packet.get("is_reflected", false):
			i += 1
			continue
		var drain := mini(remaining, packet.lines)
		packet.lines -= drain
		remaining -= drain
		if packet.lines == 0:
			_garbage_packets.remove_at(i)
		else:
			i += 1
	_notify_attack_bar()
	return remaining

func _flush_pending_garbage() -> void:
	if current_board == null:
		return
	if _garbage_packets.is_empty() and _deferred_reflect_lines == 0:
		return
	var remaining := 8
	var reflect_ratio := 0.0
	for ks in RunState.keystones:
		if ks.reflect_on_flush > 0.0:
			reflect_ratio = maxf(reflect_ratio, ks.reflect_on_flush)
	while remaining > 0 and not _garbage_packets.is_empty():
		var packet = _garbage_packets[0]
		var to_flush := mini(remaining, packet.lines)
		if packet.is_filth:
			for _i in range(to_flush):
				var col: int = packet.get("col", randi() % current_config.board_width)
				current_board.insert_garbage_rows(1, col)
		else:
			var col: int = packet.get("col", randi() % current_config.board_width)
			current_board.insert_garbage_rows(to_flush, col)
		if reflect_ratio > 0.0:
			var reflected := floori(to_flush * reflect_ratio)
			if reflected > 0:
				quota_accumulated += reflected
				if hud:
					hud.update_quota(quota_accumulated, current_config.quota)
				if quota_accumulated >= current_config.quota:
					_notify_attack_bar()
					_end_round(true)
					return
		packet.lines -= to_flush
		remaining -= to_flush
		if packet.lines == 0:
			_garbage_packets.remove_at(0)
	if _deferred_reflect_lines > 0:
		var reflect_col := randi() % (current_config.board_width if current_config else 10)
		_garbage_packets.append({lines = _deferred_reflect_lines, is_filth = false, is_reflected = true, col = reflect_col})
		_deferred_reflect_lines = 0
	_notify_attack_bar()

func _notify_attack_bar() -> void:
	if _attack_bar:
		_attack_bar.update_packets(_garbage_packets)

# ── Round end ─────────────────────────────────────────────────────────────

func _on_game_over() -> void:
	if _try_blessed_stone():
		return
	_end_round(false)

func _try_blessed_stone() -> bool:
	if _blessed_stone_spent:
		return false
	for ks in RunState.keystones:
		if ks.blessed_stone:
			_blessed_stone_spent = true
			round_timer = 120.0
			if current_board:
				current_board.clear_board()
				current_board.is_active = true
			return true
	return false

func _end_round(success: bool) -> void:
	if _round_ended:
		return
	_round_ended = true
	_garbage_packets = []
	_notify_attack_bar()
	if current_board:
		current_board.is_active = false
	if not success:
		_show_failure()
		return

	var surplus_income := _calculate_surplus_income()
	_apply_keystone_economy()
	Economy.add_coins(surplus_income)
	Economy.pay_round(BASE_PAYOUT)

	var was_boss := RunState.is_boss_round()
	RunState.advance_round()

	if RunState.is_run_complete():
		_show_victory()
		return

	_pending_keystone = was_boss
	_show_round_success()

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
		if technique.effect_type == "economy" and technique.params.get("trigger", "") == "surplus":
			var divisor: int = technique.params.get("divisor", 3)
			income += surplus_attack / divisor
	# Greedy Hands: +2 coins per round
	if _greedy_hands_active:
		income += 2
	# Bounty List: +10 coins on boss kill
	if RunState.is_boss_round() and RunState.has_technique("bounty_list"):
		income += 10
	return income

func _on_lock_processed() -> void:
	_t_spin_rotations = 0
	_rotations_this_piece = 0
	var _did_clear := not _last_cleared_rows.is_empty()
	_last_cleared_rows = []
	_piece_spawn_time = Time.get_ticks_msec() / 1000.0
	# Switch-Up: arm for next piece based on whether THIS piece was hard-dropped
	if _technique_round_state:
		_technique_round_state.switch_up_armed = _hard_drop_used_this_piece
	_hard_drop_used_this_piece = false
	# Restore ARR after flash_step piece (the next piece after the 2+ clear is now locking)
	if _flash_step_arr_pending and current_board:
		current_board.arr_rate = Settings.load_arr()
		_flash_step_arr_pending = false
	if hud and current_board:
		hud.update_b2b_combo(current_board.is_b2b, current_board.b2b_count, current_board.combo)
	if _run_stats and current_board:
		_run_stats.highest_combo_chain = max(_run_stats.highest_combo_chain, current_board.combo)
		_run_stats.highest_b2b = max(_run_stats.highest_b2b, current_board.b2b_count)
	if not _did_clear:
		_flush_pending_garbage()

func _on_board_updated() -> void:
	if current_board:
		current_board.queue_redraw()

# ── Scene transitions ─────────────────────────────────────────────────────

func _show_round_success() -> void:
	var scene: PackedScene = load(SCENE_ROUND_SUCCESS)
	var screen = scene.instantiate()
	_active_overlay = screen
	add_child(screen)
	screen.connect("proceed", _on_success_proceed)
	screen.setup(BASE_PAYOUT)

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
	if _run_stats:
		_run_stats.total_damage = int(quota_accumulated)
	var beaten_level := AscensionManager.current_level
	ProfileSave.record_victory(beaten_level)
	if _run_stats:
		ProfileSave.accumulate_stats(_run_stats)
		UnlockChecker.check_all(_run_stats, ProfileSave)
	var scene: PackedScene = load(SCENE_RUN_VICTORY)
	var screen = scene.instantiate()
	add_child(screen)
	screen.setup(Economy.coins, beaten_level)

# ── Consumable integration ────────────────────────────────────────────────

func apply_consumable(consumable: Consumable) -> void:
	if consumable.adds_time > 0.0:
		round_timer = minf(round_timer + consumable.adds_time, current_config.time_limit + consumable.adds_time)
	else:
		consumable.apply_to_config(current_config)
	RunState.remove_consumable(consumable)
	if hud:
		hud._refresh_backpack_slots()

func _apply_consumable_flat_bonuses(attack: int, event_type: String) -> int:
	if attack == 0:
		return 0
	var bonus := current_config.consumable_all_bonus
	match event_type:
		"quad":
			bonus += current_config.consumable_quad_bonus
		"tspin_mini", "tspin_single", "tspin_double", "tspin_triple":
			bonus += current_config.consumable_tspin_bonus
		"b2b":
			bonus += current_config.consumable_b2b_bonus
		"combo":
			bonus += current_config.consumable_combo_bonus
		"perfect_clear":
			bonus += current_config.consumable_pc_bonus
	return attack + bonus

func _apply_consumable_surge(attack: int, event_type: String) -> int:
	if current_config.consumable_surge_clears_remaining <= 0:
		return attack
	if event_type == "b2b" or event_type == "combo":
		return attack * 2
	current_config.consumable_surge_clears_remaining -= 1
	return attack * 2
