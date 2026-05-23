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
const SCENE_ENEMY_DISPLAY := "res://scenes/game/enemy_display.tscn"
const SCENE_PAUSE_MENU := "res://scenes/game/pause_menu.tscn"
const SCENE_MAIN_MENU := "res://scenes/main_menu/main_menu.tscn"
const BASE_PAYOUT := 4
const ROUND_TIERS := ["Small", "Big", "Elite", "Boss"]

@onready var board_container: Node2D = $BoardContainer
@onready var hud: Control = $HUD

var current_board: TetrisBoard = null
var current_config: RoundConfig = null

var _debug_overlay: DebugOverlay = null
var _dev_console: DevConsole = null
var _hold_display: HoldDisplay = null
var _queue_display: QueueDisplay = null
var _enemy_display: Control = null

var round_timer: float = 0.0
var _enemy_timer: float = 0.0
var quota_accumulated: float = 0.0
var technique_income_this_round: int = 0
var surplus_attack: int = 0

var second_wind_triggered: bool = false

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
	RunState.emit_signal("run_started")
	start_round()

# ── Round start ───────────────────────────────────────────────────────────

func start_round() -> void:
	_round_ended = false
	current_config = _build_round_config()
	hud.setup(current_config)
	quota_accumulated = 0.0
	technique_income_this_round = 0
	surplus_attack = 0
	round_timer = current_config.time_limit
	_enemy_timer = 0.0
	second_wind_triggered = RunState.second_wind_used_this_round

	if current_board:
		current_board.queue_free()
	if _hold_display:
		_hold_display.queue_free()
	if _queue_display:
		_queue_display.queue_free()
	if _enemy_display:
		_enemy_display.queue_free()
		_enemy_display = null

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

	var enemy_scene: PackedScene = load(SCENE_ENEMY_DISPLAY)
	_enemy_display = enemy_scene.instantiate()
	board_container.add_child(_enemy_display)
	_enemy_display.position = Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16 + 112 + 48, 0)
	_enemy_display.setup(current_config.enemy, current_config.quota)
	hud.set_enemy_display(_enemy_display)

func _build_round_config() -> RoundConfig:
	var cfg := RoundConfig.new()
	cfg.rng = RunState.rng
	cfg.quota = RunState.calculate_quota(RunState.stage, RunState.round_index)

	for keystone in RunState.keystones:
		keystone.apply_to_config(cfg)

	var enemy := _draw_enemy()
	cfg.enemy = enemy
	cfg.effective_garbage_interval = enemy.garbage_interval * max(0.5, 1.0 - (RunState.stage - 1) * 0.1)

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
	_check_second_wind()
	if _enemy_display and current_config:
		_enemy_display.update_windup(_enemy_timer, current_config.effective_garbage_interval)

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
	if current_config == null or current_config.effective_garbage_interval <= 0.0:
		return
	_enemy_timer += delta
	if _enemy_timer >= current_config.effective_garbage_interval:
		_enemy_timer = 0.0
		current_board.insert_garbage_row()
		if _enemy_display:
			_enemy_display.update_windup(0.0, current_config.effective_garbage_interval)

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

	# Apply boss modifier quota filter; bonus events always count if their parent clear qualified
	var is_bonus_event := event_type == "b2b" or event_type == "combo"
	if not is_bonus_event and current_config.boss_modifier:
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
	if _round_ended:
		return
	_round_ended = true
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

	_pending_keystone = was_boss
	_show_round_success(speed_bonus, surplus_income)

func _calculate_surplus_income() -> int:
	var income := 0
	for technique in RunState.techniques:
		if technique.coins_per_attack_above_quota > 0:
			income += surplus_attack / technique.surplus_divisor
	return income

func _on_lock_processed() -> void:
	hud.update_b2b_combo(current_board.is_b2b, current_board.b2b_count, current_board.combo)

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
