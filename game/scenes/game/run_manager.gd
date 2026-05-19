class_name RunManager
extends Node

const SCENE_TETRIS_BOARD := "res://scenes/tetris/tetris_board.tscn"
const SCENE_SHOP := "res://scenes/shop/shop.tscn"
const SCENE_KEYSTONE_SELECTION := "res://scenes/keystone_selection/keystone_selection.tscn"
const SCENE_ROUND_SUCCESS := "res://scenes/screens/round_success.tscn"
const SCENE_RUN_FAILURE := "res://scenes/screens/run_failure.tscn"
const SCENE_RUN_VICTORY := "res://scenes/screens/run_victory.tscn"
const SCENE_DEBUG_OVERLAY := "res://scenes/debug/debug_overlay.tscn"
const SCENE_DEV_CONSOLE := "res://scenes/debug/dev_console.tscn"
const SCENE_HOLD_DISPLAY := "res://scenes/game/hold_display.tscn"
const SCENE_QUEUE_DISPLAY := "res://scenes/game/queue_display.tscn"
const BASE_PAYOUT := 4

@onready var board_container: Node2D = $BoardContainer
@onready var hud: Control = $HUD

var current_board: TetrisBoard = null
var current_config: RoundConfig = null

var _debug_overlay: DebugOverlay = null
var _dev_console: DevConsole = null
var _hold_display: HoldDisplay = null
var _queue_display: QueueDisplay = null

var round_timer: float = 0.0
var quota_accumulated: float = 0.0
var technique_income_this_round: int = 0
var surplus_attack: int = 0

var tide_timer: float = 0.0
var second_wind_triggered: bool = false

signal round_ended(success: bool)

# ── Run start ─────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("run_manager")
	_setup_debug_tools()

func _setup_debug_tools() -> void:
	var overlay_scene: PackedScene = load(SCENE_DEBUG_OVERLAY)
	_debug_overlay = overlay_scene.instantiate()
	add_child(_debug_overlay)

	var console_scene: PackedScene = load(SCENE_DEV_CONSOLE)
	_dev_console = console_scene.instantiate()
	_dev_console.set_run_manager(self)
	add_child(_dev_console)

func start_run() -> void:
	RunState.reset()
	Economy.reset()
	Economy.add_coins(RunState.STARTING_COINS)
	_assign_starting_keystone()
	RunState.emit_signal("run_started")
	start_round()

func _assign_starting_keystone() -> void:
	var pool := _load_starter_keystone_pool()
	if pool.is_empty():
		return
	pool.shuffle()
	RunState.add_keystone(pool[0])

func _load_starter_keystone_pool() -> Array:
	var dir := DirAccess.open("res://resources/data/keystones/")
	var starters := []
	if dir:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".tres"):
				var res: Keystone = load("res://resources/data/keystones/" + f)
				if res and res.is_starter:
					starters.append(res)
			f = dir.get_next()
	return starters

# ── Round start ───────────────────────────────────────────────────────────

func start_round() -> void:
	current_config = _build_round_config()
	quota_accumulated = 0.0
	technique_income_this_round = 0
	surplus_attack = 0
	round_timer = current_config.time_limit
	tide_timer = 0.0
	second_wind_triggered = RunState.second_wind_used_this_round

	if current_board:
		current_board.queue_free()
	if _hold_display:
		_hold_display.queue_free()
	if _queue_display:
		_queue_display.queue_free()

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

	if _debug_overlay:
		_debug_overlay.set_board(current_board)
		_debug_overlay.run_manager = self

	var hold_scene: PackedScene = load(SCENE_HOLD_DISPLAY)
	_hold_display = hold_scene.instantiate()
	board_container.add_child(_hold_display)
	_hold_display.position = Vector2(-(4 * 24 + 16 + 8), 0)
	_hold_display.setup(current_board)

	var queue_scene: PackedScene = load(SCENE_QUEUE_DISPLAY)
	_queue_display = queue_scene.instantiate()
	board_container.add_child(_queue_display)
	_queue_display.position = Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16, 0)
	_queue_display.setup(current_board)

func _build_round_config() -> RoundConfig:
	var cfg := RoundConfig.new()
	cfg.quota = RunState.calculate_quota(RunState.ante, RunState.round_index)

	# Apply keystones
	for keystone in RunState.keystones:
		keystone.apply_to_config(cfg)

	# Apply boss modifier (boss round only)
	if RunState.is_boss_round():
		var modifier := _select_boss_modifier()
		if modifier:
			cfg.boss_modifier = modifier
			modifier.apply_to_config(cfg)

	cfg.time_limit = RunState.calculate_time_limit(RunState.ante, cfg.boss_modifier.id if cfg.boss_modifier else "")
	return cfg

func _select_boss_modifier() -> BossModifier:
	var all_modifiers := _load_all_boss_modifiers()
	var available := all_modifiers.filter(func(m): return m.id not in RunState.used_boss_modifiers)
	if available.is_empty():
		available = all_modifiers
	available.shuffle()
	var chosen: BossModifier = available[0]
	RunState.used_boss_modifiers.append(chosen.id)
	return chosen

func _load_all_boss_modifiers() -> Array:
	var dir := DirAccess.open("res://resources/data/boss_modifiers/")
	var result := []
	if dir:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".tres"):
				result.append(load("res://resources/data/boss_modifiers/" + f))
			f = dir.get_next()
	return result

# ── Per-frame update ──────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if current_board == null or not current_board.is_active:
		return

	current_board.tick(delta)
	_handle_input()
	_tick_timer(delta)
	_tick_tide(delta)
	_check_second_wind()

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

func _tick_tide(delta: float) -> void:
	if current_config.boss_modifier == null:
		return
	if current_config.boss_modifier.garbage_interval <= 0.0:
		return
	tide_timer += delta
	if tide_timer >= current_config.boss_modifier.garbage_interval:
		tide_timer = 0.0
		current_board.insert_garbage_row()

func _check_second_wind() -> void:
	if second_wind_triggered:
		return
	if not RunState.has_keystone("second_wind"):
		return
	if round_timer <= 10.0 and quota_accumulated < current_config.quota:
		second_wind_triggered = true
		RunState.second_wind_used_this_round = true
		round_timer += 5.0

# ── Attack signal handler ─────────────────────────────────────────────────

func _on_attack_generated(raw_attack: int, event_type: String) -> void:
	var modified := _apply_techniques(raw_attack, event_type)
	_accumulate_technique_income(event_type, modified)

	# Apply boss modifier quota filter
	if current_config.boss_modifier:
		if not current_config.boss_modifier.attack_counts_toward_quota(event_type):
			return

	quota_accumulated += modified
	surplus_attack = maxi(0, int(quota_accumulated) - current_config.quota)
	hud.update_quota(quota_accumulated, current_config.quota)

	if quota_accumulated >= current_config.quota:
		_end_round(true)

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

# ── Round end ─────────────────────────────────────────────────────────────

func _on_game_over() -> void:
	_end_round(false)

func _end_round(success: bool) -> void:
	if current_board:
		current_board.is_active = false
	if not success:
		_show_failure()
		return

	var speed_bonus := Economy.calculate_speed_bonus(round_timer, current_config.time_limit)
	var surplus_income := _calculate_surplus_income()
	Economy.pay_round(BASE_PAYOUT, speed_bonus, technique_income_this_round + surplus_income)

	var was_boss := RunState.is_boss_round()
	RunState.advance_round()

	if RunState.is_run_complete():
		_show_victory()
		return

	if was_boss:
		_show_keystone_selection()
	else:
		_show_round_success(speed_bonus, surplus_income)

func _calculate_surplus_income() -> int:
	var income := 0
	for technique in RunState.techniques:
		if technique.coins_per_attack_above_quota > 0:
			income += surplus_attack / technique.surplus_divisor
	return income

func _on_board_updated() -> void:
	if current_board:
		current_board.queue_redraw()

# ── Scene transitions ─────────────────────────────────────────────────────

func _show_round_success(speed_bonus: int, surplus_income: int) -> void:
	var scene: PackedScene = load(SCENE_ROUND_SUCCESS)
	var screen = scene.instantiate()
	add_child(screen)
	screen.connect("proceed", _on_success_proceed)
	screen.setup(BASE_PAYOUT, speed_bonus, technique_income_this_round + surplus_income)

func _on_success_proceed() -> void:
	_show_shop()

func _show_shop() -> void:
	var scene: PackedScene = load(SCENE_SHOP)
	var shop = scene.instantiate()
	add_child(shop)
	shop.connect("shop_closed", _on_shop_closed)

func _on_shop_closed() -> void:
	start_round()

func _show_keystone_selection() -> void:
	var scene: PackedScene = load(SCENE_KEYSTONE_SELECTION)
	var screen = scene.instantiate()
	add_child(screen)
	screen.connect("keystone_chosen", _on_keystone_chosen)

func _on_keystone_chosen(_keystone: Keystone) -> void:
	_show_round_success_after_boss()

func _show_round_success_after_boss() -> void:
	var scene: PackedScene = load(SCENE_ROUND_SUCCESS)
	var screen = scene.instantiate()
	add_child(screen)
	screen.connect("proceed", _on_success_proceed)
	screen.setup(BASE_PAYOUT, Economy.calculate_speed_bonus(round_timer, current_config.time_limit), technique_income_this_round)

func _show_failure() -> void:
	var scene: PackedScene = load(SCENE_RUN_FAILURE)
	var screen = scene.instantiate()
	add_child(screen)
	screen.setup(RunState.ante, RunState.round_index)

func _show_victory() -> void:
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
