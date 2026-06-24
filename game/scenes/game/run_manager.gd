class_name RunManager
extends Node

const SCENE_TETRIS_BOARD       := "res://scenes/tetris/tetris_board.tscn"
const SCENE_SHOP               := "res://scenes/shop/shop.tscn"
const SCENE_KEYSTONE_SELECTION := "res://scenes/keystone_selection/keystone_selection.tscn"
const SCENE_ROUND_SUCCESS      := "res://scenes/screens/round_success.tscn"
const SCENE_RUN_FAILURE        := "res://scenes/screens/run_failure.tscn"
const SCENE_RUN_VICTORY        := "res://scenes/screens/run_victory.tscn"
const SCENE_DEBUG_OVERLAY      := "res://scenes/debug/debug_overlay.tscn"
const SCENE_HOLD_DISPLAY       := "res://scenes/game/hold_display.tscn"
const SCENE_QUEUE_DISPLAY      := "res://scenes/game/queue_display.tscn"
const SCENE_ENEMY_DISPLAY      := "res://scenes/game/enemy_display.tscn"
const SCENE_PAUSE_MENU         := "res://scenes/game/pause_menu.tscn"
const SCENE_MAIN_MENU          := "res://scenes/main_menu/main_menu.tscn"
const SCENE_DUNGEON_MAP        := "res://scenes/dungeon/dungeon_map.tscn"
const SCENE_ENCOUNTER_ROOM     := "res://scenes/dungeon/encounter_room.tscn"

const BASE_PAYOUT := 15
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

const CLEAR_TYPE_DISPLAY: Dictionary = {
	"single":        ["Single",        Color.WHITE],
	"double":        ["Double",        Color.WHITE],
	"triple":        ["Triple",        Color.WHITE],
	"quad":          ["Quad",          Color(0.3, 0.9, 1.0)],
	"tspin_mini":    ["T-Spin Mini",   Color(0.7, 0.4, 1.0)],
	"tspin_single":  ["T-Spin Single", Color(0.7, 0.4, 1.0)],
	"tspin_double":  ["T-Spin Double", Color(0.7, 0.4, 1.0)],
	"tspin_triple":  ["T-Spin Triple", Color(0.7, 0.4, 1.0)],
	"perfect_clear": ["Perfect Clear", Color(1.0, 0.85, 0.1)],
}

@onready var board_container: Node2D = $BoardContainer
@onready var hud: Control = $HUD

var current_board: TetrisBoard = null
var current_config: RoundConfig = null
var _flow: RunFlow = null

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
var _shield_bar: Control = null

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
var _flash_step_arr_active: bool = false
var _greedy_hands_active: bool = false

var _blessed_stone_spent: bool = false

var _enhancement_grant: Dictionary = {}
var _enhancement_cadence: Dictionary = {}
var _enhancement_grant_queue: Array = []
var _garbage_shield: int = 0
var _pending_enh_counts: Dictionary = {}

var _round_technique_coins: int = 0
var _round_enhancement_coins: int = 0
var _round_income_breakdown: Dictionary = {}

var _popup_schedule: Array = []
var _popup_elapsed: float = 0.0
var _technique_pre_evaluated: bool = false
var _pre_evaluated_technique_atk: int = 0
var _clear_popup_shown_this_piece: bool = false
var _active_clear_popup_label: Label = null
var _active_clear_popup_tween: Tween = null

var _run_stats: RunStats = null

var _paused: bool = false
var _pause_menu: Control = null
var _board_was_active: bool = false
var _active_overlay: Control = null
var _round_ended: bool = false
var _pending_round_end: Callable

signal round_ended(success: bool)

# ── Run start ─────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("run_manager")
	_flow = RunFlow.new()
	_flow.combat_entered.connect(_on_flow_combat_entered)
	_flow.shop_entered.connect(_on_flow_shop_entered)
	_flow.encounter_entered.connect(_on_flow_encounter_entered)
	_flow.dungeon_map_requested.connect(_on_flow_dungeon_map_requested)
	_flow.round_success_requested.connect(_on_flow_round_success_requested)
	_flow.keystone_selection_requested.connect(_on_flow_keystone_selection_requested)
	_flow.victory_requested.connect(_on_flow_victory_requested)
	_flow.failure_requested.connect(_on_flow_failure_requested)
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
	DamageLog.start_run(RunState.run_seed, AscensionManager.current_level)
	DamageLog.log_build()
	RunState.emit_signal("run_started")
	if _asc.get("skip_starter_keystone", false):
		_show_dungeon_map()
	else:
		_show_starter_keystone_selection()

func _show_starter_keystone_selection() -> void:
	hud.visible = false
	hud.hide_inventory()
	var scene: PackedScene = load(SCENE_KEYSTONE_SELECTION)
	var screen = scene.instantiate()
	get_tree().root.add_child(screen)
	screen.setup(true)
	screen.connect("keystone_chosen", _on_starter_keystone_chosen)

func _on_starter_keystone_chosen(_keystone: Keystone) -> void:
	hud.visible = true
	hud.show_inventory()
	_show_dungeon_map()

func continue_run() -> void:
	_run_stats = RunStats.new()
	DamageLog.start_run(RunState.run_seed, AscensionManager.current_level)
	DamageLog.log_build()
	_show_dungeon_map()

# ── Dungeon map ────────────────────────────────────────────────────────────

func _show_dungeon_map() -> void:
	_hide_board_ui()
	var scene: PackedScene = load(SCENE_DUNGEON_MAP)
	var map = scene.instantiate()
	_active_overlay = map
	add_child(map)
	map.setup(RunState.current_floor_data)
	map.connect("room_selected", _on_room_selected)

func _on_room_selected(room: DungeonRoom) -> void:
	if _active_overlay:
		_active_overlay.queue_free()
		_active_overlay = null
	enter_room(room)

func enter_room(room: DungeonRoom) -> void:
	_flow.enter_room(room)

func _hide_board_ui() -> void:
	board_container.visible = false
	hud.hide_combat_elements()
	hud.refresh_inventory()
	if _enemy_display:
		_enemy_display.queue_free()
		_enemy_display = null
	if _attack_bar:
		_attack_bar.queue_free()
		_attack_bar = null
	if _shield_bar:
		_shield_bar.queue_free()
		_shield_bar = null

func _show_board_ui() -> void:
	board_container.visible = true
	hud.show_combat_elements()

# ── Combat room ────────────────────────────────────────────────────────────

func _start_combat_room(room: DungeonRoom) -> void:
	_show_board_ui()
	start_round(room)

func start_round(room: DungeonRoom) -> void:
	_round_ended = false
	_garbage_packets = []
	_deferred_reflect_lines = 0
	current_config = _build_round_config(room)
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
	_burning_board_active = false
	for ks in RunState.keystones:
		if ks.burning_board:
			_burning_board_active = true
			break
	_burning_board_timer = 0.0
	_flash_step_arr_pending = false
	_flash_step_arr_active = false
	_greedy_hands_active = RunState.has_technique("greedy_hands")
	_round_technique_coins = 0
	_round_enhancement_coins = 0
	_reset_enhancement_round_state()

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
	if _shield_bar:
		_shield_bar.queue_free()
		_shield_bar = null

	var board_scene: PackedScene = load(SCENE_TETRIS_BOARD)
	current_board = board_scene.instantiate()
	board_container.add_child(current_board)
	current_board.das_delay = Settings.load_das()
	current_board.arr_rate = Settings.load_arr()
	current_board.sdf_multiplier = Settings.load_sdf()
	if RunState.has_technique("persistence"):
		current_config.b2b_persists_on_doubles = true
	current_board.setup(current_config)
	current_board.connect("attack_generated", _on_attack_generated)
	current_board.connect("game_over", _on_game_over)
	current_board.connect("board_updated", _on_board_updated)
	current_board.connect("lock_processed", _on_lock_processed)
	current_board.connect("piece_rotated", _on_piece_rotated)
	current_board.connect("rows_cleared", _on_rows_cleared)
	current_board.connect("lines_cleared", _on_lines_cleared)
	current_board.connect("b2b_broken", _on_b2b_broken)
	current_board.connect("piece_locked", _on_piece_locked)
	current_board.connect("line_clear_delay_started", _on_line_clear_delay_started)
	current_board.connect("piece_spawned", _on_piece_spawned)

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
	_queue_display.position = Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 16 + ShieldBar.BAR_WIDTH + 8, 0)
	_queue_display.setup(current_board, self)

	var enemy_scene: PackedScene = load(SCENE_ENEMY_DISPLAY)
	_enemy_display = enemy_scene.instantiate()
	add_child(_enemy_display)
	_enemy_display.set_anchor_and_offset(SIDE_LEFT,   0.0, 900.0)
	_enemy_display.set_anchor_and_offset(SIDE_TOP,    0.0,   0.0)
	_enemy_display.set_anchor_and_offset(SIDE_RIGHT,  1.0,   0.0)
	_enemy_display.set_anchor_and_offset(SIDE_BOTTOM, 1.0,   0.0)
	_enemy_display.setup(current_config.enemy, current_config.quota)
	_enemy_display.set_attack_bar_visible(current_config.reflect_ratio <= 0.0)
	hud.set_run_manager(self)

	var attack_bar_script := load("res://scenes/game/attack_bar.gd") as GDScript
	_attack_bar = attack_bar_script.new()
	board_container.add_child(_attack_bar)
	_attack_bar.position = Vector2(-20, 0)
	_attack_bar.flush_capacity = 8

	var shield_bar_script := load("res://scenes/game/shield_bar.gd") as GDScript
	_shield_bar = shield_bar_script.new()
	board_container.add_child(_shield_bar)
	_shield_bar.position = Vector2(TetrisBoard.COLS * TetrisBoard.CELL_SIZE + 4, 0)
	_shield_bar.update_charges(_garbage_shield)

	hud._refresh_backpack_slots()

func _build_round_config(room: DungeonRoom) -> RoundConfig:
	var cfg := RoundConfig.new()
	cfg.rng = RunState.rng
	var tier := room.get_combat_tier()
	var base_quota := RunState.calculate_quota(RunState.floor, tier)
	var _asc_quota: float = AscensionManager.get_modifiers(AscensionManager.current_level).get("quota_mult", 1.0)
	if _asc_quota != 1.0:
		base_quota = ceili(base_quota * _asc_quota)

	cfg.quota = ceili(base_quota * (1.0 + RunState.combat_rooms_cleared_this_floor * 0.08))

	for keystone in RunState.keystones:
		keystone.apply_to_config(cfg)

	var enemy := _draw_enemy(tier)
	cfg.enemy = enemy
	var _stage_scalar := maxf(0.5, 1.0 - (RunState.floor - 1) * 0.1)
	var _lines_bonus := (RunState.floor - 1) / 2
	var _imin: float; var _imax: float; var _lmin: int; var _lmax: int
	match tier:
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

	cfg.time_limit = RunState.calculate_time_limit(RunState.floor)

	if enemy.ability:
		cfg.boss_modifier = enemy.ability
		enemy.ability.apply_to_config(cfg)

	cfg.show_timer = RunState.has_keystone("golden_watch") or \
		(cfg.boss_modifier != null and cfg.boss_modifier.id == "the_blitz")

	if RunState.has_technique("glass_cannon"):
		cfg.garbage_lines_min += 2
		cfg.garbage_lines_max += 2
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

func _draw_enemy(tier: String) -> Enemy:
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

# ── Shop room ──────────────────────────────────────────────────────────────

func _open_shop_room(room: DungeonRoom) -> void:
	_hide_board_ui()
	hud.hide_inventory()
	var scene: PackedScene = load(SCENE_SHOP)
	var shop = scene.instantiate()
	_active_overlay = shop
	add_child(shop)
	shop.connect("shop_closed", _on_shop_room_closed.bind(room))

func _on_shop_room_closed(room: DungeonRoom) -> void:
	if _active_overlay:
		_active_overlay = null
	hud.show_inventory()
	hud.refresh_inventory()
	_flow.resolve_shop(room)

# ── Encounter room ─────────────────────────────────────────────────────────

func _start_encounter_room(room: DungeonRoom) -> void:
	_hide_board_ui()
	var scene: PackedScene = load(SCENE_ENCOUNTER_ROOM)
	var encounter = scene.instantiate()
	_active_overlay = encounter
	add_child(encounter)
	encounter.setup(room.encounter_subtype, self)
	encounter.connect("encounter_completed", _on_encounter_completed.bind(room))

func _on_encounter_completed(room: DungeonRoom) -> void:
	if _active_overlay:
		_active_overlay.queue_free()
		_active_overlay = null
	_flow.resolve_encounter(room)

# ── RunFlow signal handlers ───────────────────────────────────────────────

func _on_flow_combat_entered(room: DungeonRoom) -> void:
	_start_combat_room(room)

func _on_flow_shop_entered(room: DungeonRoom) -> void:
	_open_shop_room(room)

func _on_flow_encounter_entered(room: DungeonRoom) -> void:
	_start_encounter_room(room)

func _on_flow_dungeon_map_requested() -> void:
	RunSave.save()
	_show_dungeon_map()

func _on_flow_round_success_requested(is_boss: bool) -> void:
	if is_boss:
		_pending_round_end = _show_round_success_then_boss_cleared
	else:
		_pending_round_end = _show_round_success_then_map
	if _enemy_display:
		_enemy_display.death_animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)
		_enemy_display.play_death_animation()
	else:
		_on_death_animation_finished()

func _on_flow_keystone_selection_requested() -> void:
	_show_keystone_selection_then_map()

func _on_flow_victory_requested() -> void:
	_show_victory()

func _on_flow_failure_requested() -> void:
	_show_failure()

# Special case: Robbers "fight" choice triggers an Elite combat
func start_robbers_combat() -> void:
	if _active_overlay:
		_active_overlay.queue_free()
		_active_overlay = null
	var synthetic_room: DungeonRoom = _flow.begin_robbers_combat()
	_show_board_ui()
	start_round(synthetic_room)

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
	_drain_popup_schedule(delta)
	if _enemy_display and current_config:
		_enemy_display.update_windup(_enemy_timer, _next_garbage_interval)

# ── Pause ─────────────────────────────────────────────────────────────────

func _open_pause() -> void:
	_paused = true
	if _enemy_display:
		_enemy_display.stop_animations()
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
		if not (_has_instant_arr() or _flash_step_arr_active):
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
			if n > 0 and _garbage_shield > 0:
				var absorbed := mini(n, _garbage_shield)
				_garbage_shield -= absorbed
				n -= absorbed
				if _shield_bar:
					_shield_bar.update_charges(_garbage_shield)
			if n > 0:
				if current_config.garbage_individual_lines:
					for _i in range(n):
						var filth_col := randi() % current_config.board_width
						_garbage_packets.append({lines = 1, is_filth = true, col = filth_col})
				else:
					var packet_col := randi() % current_config.board_width
					_garbage_packets.append({lines = n, is_filth = false, col = packet_col})
				if _enemy_display:
					_enemy_display.on_attack_fired()
			_notify_attack_bar()
			if _technique_round_state:
				_technique_round_state.after_receive_pending = true
		_next_garbage_interval = randf_range(current_config.garbage_interval_min, current_config.garbage_interval_max)
		if _enemy_display:
			_enemy_display.update_windup(0.0, _next_garbage_interval)

func _build_technique_states() -> Dictionary:
	var states := {}
	if _technique_round_state == null:
		return states
	var rs := _technique_round_state
	for t in RunState.techniques:
		var pending := false
		match t.effect_type:
			"escalation":        pending = rs.escalation_pending
			"follow_up":         pending = rs.follow_up_pending
			"patience":          pending = rs.patience_pending
			"constant_pressure": pending = rs.constant_pressure_pending
			"flow_step":         pending = rs.flow_step_pending
			"good_planning":     pending = rs.good_planning_pending
		states[t.id] = pending
	return states

func _drain_popup_schedule(delta: float) -> void:
	if _popup_schedule.is_empty():
		return
	_popup_elapsed += delta
	var i := 0
	while i < _popup_schedule.size():
		var entry = _popup_schedule[i]
		if _popup_elapsed >= entry.time:
			_spawn_event_popup(entry, entry.index, entry.total)
			_popup_schedule.remove_at(i)
		else:
			i += 1

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
	if _technique_round_state == null:
		return
	var rs := _technique_round_state
	rs.pieces_placed += 1
	if rs.pieces_placed % 10 == 0:
		rs.escalation_pending = true
	if rs.patience_cooldown_pieces > 0:
		rs.patience_cooldown_pieces -= 1
	if _held_this_piece and rs.patience_cooldown_pieces == 0:
		rs.patience_pending = true
	var elapsed: float = Time.get_ticks_msec() / 1000.0 - _piece_spawn_time
	if elapsed <= 1.0:
		rs.constant_pressure_pending = true
	if _rotations_this_piece == 0:
		rs.no_rotate_streak += 1
		if rs.no_rotate_streak >= 4:
			rs.flow_step_pending = true
	else:
		rs.no_rotate_streak = 0
	if _held_this_piece:
		rs.good_planning_consecutive_no_hold = 0
		rs.good_planning_pending = false
	else:
		rs.good_planning_consecutive_no_hold += 1
		if rs.good_planning_consecutive_no_hold >= 5:
			rs.good_planning_pending = true
	if not rs.last_stand_triggered and current_board:
		var height: int = current_board.summit_height
		for t in RunState.techniques:
			if t.effect_type == "height_shield":
				var threshold: float = t.params.get("threshold_pct", 0.8)
				if height >= 20 * threshold:
					_garbage_shield += t.params.get("shield", 10)
					rs.last_stand_triggered = true
					if _shield_bar:
						_shield_bar.update_charges(_garbage_shield)
					break

func _reset_enhancement_round_state() -> void:
	_enhancement_grant = {}
	_enhancement_cadence = {}
	_enhancement_grant_queue = []
	for t in RunState.techniques:
		if t.effect_type == "piece_enhancer":
			_enhancement_cadence[t.id] = 0
	for ks in RunState.keystones:
		if ks.piece_enhance_every_n > 0:
			_enhancement_cadence[ks.id] = 0
	_garbage_shield = 0
	for ks in RunState.keystones:
		_garbage_shield += ks.start_shield
	_pending_enh_counts = {}

func _on_piece_spawned(_piece_type: String) -> void:
	var assigned := _advance_enhancement_state(_enhancement_grant, _enhancement_cadence, RunState.techniques, RunState.keystones, _enhancement_grant_queue)
	if current_board:
		current_board.current_enhancement = assigned

static func _advance_enhancement_state(grant: Dictionary, cadence: Dictionary, techniques: Array, keystones: Array, grant_queue: Array) -> String:
	var assigned := ""
	if grant.get("remaining", 0) <= 0 and grant_queue.size() > 0:
		var next_grant: Dictionary = grant_queue.pop_front()
		grant["type"] = next_grant.get("type", "")
		grant["remaining"] = next_grant.get("remaining", 0)
	if grant.get("remaining", 0) > 0:
		assigned = grant.get("type", "")
		grant["remaining"] -= 1
		if grant["remaining"] <= 0:
			grant.clear()
	for t in techniques:
		if t.effect_type != "piece_enhancer":
			continue
		var every_n: int = t.params.get("every_n", 0)
		if every_n <= 0:
			continue
		cadence[t.id] = cadence.get(t.id, 0) + 1
		if cadence[t.id] >= every_n:
			cadence[t.id] = 0
			if assigned == "":
				assigned = t.params.get("enhancement", "")
			else:
				var overflow_type: String = PieceEnhancements.resolve_type(t.params.get("enhancement", ""))
				if overflow_type != "":
					grant_queue.append({"type": overflow_type, "remaining": 1})
	for ks in keystones:
		if ks.piece_enhance_every_n <= 0:
			continue
		cadence[ks.id] = cadence.get(ks.id, 0) + 1
		if cadence[ks.id] >= ks.piece_enhance_every_n:
			cadence[ks.id] = 0
			if assigned == "":
				assigned = ks.piece_enhance_type
			else:
				var overflow_type: String = PieceEnhancements.resolve_type(ks.piece_enhance_type)
				if overflow_type != "":
					grant_queue.append({"type": overflow_type, "remaining": 1})
	return PieceEnhancements.resolve_type(assigned)

func preview_enhancements(count: int) -> Array[String]:
	var grant: Dictionary = _enhancement_grant.duplicate()
	var cadence: Dictionary = _enhancement_cadence.duplicate()
	var grant_queue: Array = _enhancement_grant_queue.duplicate(true)
	var result: Array[String] = []
	for _i in count:
		result.append(_advance_enhancement_state(grant, cadence, RunState.techniques, RunState.keystones, grant_queue))
	return result

func _queue_enhancement_grant(enh_type: String, pieces: int) -> void:
	if _enhancement_grant.is_empty():
		_enhancement_grant = {"type": enh_type, "remaining": pieces}
	elif _enhancement_grant.get("type", "") == enh_type:
		_enhancement_grant["remaining"] = _enhancement_grant.get("remaining", 0) + pieces
	else:
		_enhancement_grant_queue.append({"type": enh_type, "remaining": pieces})

func _effective_enhancement_params() -> Dictionary:
	var honed_per_cell: int = PieceEnhancements.HONED_ATTACK_PER_CELL
	var reinforced_per_cell: int = PieceEnhancements.REINFORCED_SHIELD_PER_CELL
	var gilded_per_cell: int = PieceEnhancements.GILDED_COINS_PER_CELL
	var amplified_per_cell: float = PieceEnhancements.AMPLIFIED_PER_CELL
	for ks in RunState.keystones:
		honed_per_cell += ks.honed_bonus_per_cell
		reinforced_per_cell += ks.reinforced_bonus_per_cell
		gilded_per_cell += ks.gilded_bonus_per_cell
		amplified_per_cell += ks.amplified_bonus_per_cell
	return {
		"honed": honed_per_cell,
		"reinforced": reinforced_per_cell,
		"gilded": gilded_per_cell,
		"amplified": amplified_per_cell,
	}

func _effective_enhancement_counts(counts: Dictionary) -> Dictionary:
	for ks in RunState.keystones:
		if ks.double_enhancement_benefits:
			return PieceEnhancements.double_counts(counts)
	return counts

func _apply_enhancement_clear_benefits(counts: Dictionary) -> Array:
	var events: Array = []
	var effective: Dictionary = _effective_enhancement_counts(counts)
	var params: Dictionary = _effective_enhancement_params()

	var gilded := PieceEnhancements.gilded_coins(effective, params["gilded"])
	if gilded > 0:
		Economy.add_coins(gilded)
		_round_enhancement_coins += gilded
		events.append({"name": "Gilded", "id": "gilded", "bonus": gilded, "color": PieceEnhancements.GILDED_COLOR})

	var shield := PieceEnhancements.shield_charges(effective, params["reinforced"])
	if shield > 0:
		_garbage_shield += shield
		if _shield_bar:
			_shield_bar.update_charges(_garbage_shield)
		events.append({"name": "Reinforced", "id": "reinforced", "bonus": shield, "color": PieceEnhancements.REINFORCED_FILL_COLOR})

	var honed := PieceEnhancements.honed_bonus(effective, params["honed"])
	if honed > 0:
		events.append({"name": "Honed", "id": "honed", "bonus": honed, "color": PieceEnhancements.HONED_COLOR})

	var amplified_cells: int = effective.get(PieceEnhancements.AMPLIFIED, 0)
	if amplified_cells > 0:
		events.append({"name": "Amplified", "id": "amplified", "bonus": amplified_cells, "color": PieceEnhancements.AMPLIFIED_TRIANGLE_COLOR})

	return events

func _on_line_clear_delay_started(clear_type: String) -> void:
	_spawn_clear_type_popup(clear_type)
	_clear_popup_shown_this_piece = true

	_pending_enh_counts = current_board.pending_enhancement_counts if current_board else {}
	var enh_events := _apply_enhancement_clear_benefits(_pending_enh_counts)

	if _technique_round_state == null:
		if enh_events.size() > 0:
			_schedule_popups(enh_events, current_config.line_clear_delay if current_config else 0.0)
		return
	_technique_pre_evaluated = false
	var raw: int = TetrisBoard.BASE_ATTACK.get(clear_type, 0)
	var ctx := _build_attack_context(raw, clear_type)
	var eval_result: Dictionary = TechniqueEvaluator.evaluate(
		RunState.techniques, ctx, _technique_round_state)
	_pre_evaluated_technique_atk = eval_result.get("attack_delta", 0)
	var coins_delta: int = eval_result.get("coins_delta", 0)
	Economy.add_coins(coins_delta)
	_round_technique_coins += coins_delta
	_handle_technique_flags(eval_result.get("flags", []))
	_update_round_state_after_eval(ctx, eval_result)
	var technique_events: Array = eval_result.get("events", [])
	var pre_total := raw + _pre_evaluated_technique_atk
	var ks_events := _collect_keystone_events(pre_total, clear_type)
	_fire_keystone_visuals(ks_events)

	var all_events := technique_events + ks_events + enh_events
	if all_events.size() > 0:
		_schedule_popups(all_events, current_config.line_clear_delay if current_config else 0.0)
	_technique_pre_evaluated = true

func _on_piece_rotated(piece_type: String) -> void:
	if piece_type == "T":
		_t_spin_rotations += 1
	else:
		_t_spin_rotations = 0
	_rotations_this_piece += 1

func _on_rows_cleared(row_indices: Array[int]) -> void:
	_last_cleared_rows = row_indices

func _on_lines_cleared(_count: int, clear_type: String) -> void:
	if _clear_popup_shown_this_piece:
		_clear_popup_shown_this_piece = false
		return
	_spawn_clear_type_popup(clear_type)

func _has_instant_arr() -> bool:
	return current_config != null and current_config.instant_arr

func _on_b2b_broken(streak: int) -> void:
	for ks in RunState.keystones:
		if ks.final_blow:
			quota_accumulated += streak * 2
			if current_config:
				current_config.b2b_disabled = true
				surplus_attack = maxi(0, int(quota_accumulated) - current_config.quota)
			if _run_stats:
				_run_stats.total_damage += streak * 2
			if _enemy_display:
				_enemy_display.update_hp(quota_accumulated)
			if current_config and quota_accumulated >= current_config.quota:
				_end_round(true)
			break

func _on_attack_generated(raw_attack: int, event_type: String) -> void:
	var is_bonus_event: bool = event_type == "b2b" or event_type == "combo"
	var ctx := _build_attack_context(raw_attack, event_type)

	var technique_atk: int = 0
	var technique_events: Array = []
	if not is_bonus_event and _technique_round_state:
		if _technique_pre_evaluated:
			technique_atk = _pre_evaluated_technique_atk
			_technique_pre_evaluated = false
			_pre_evaluated_technique_atk = 0
		else:
			var eval_result: Dictionary = TechniqueEvaluator.evaluate(
				RunState.techniques, ctx, _technique_round_state)
			technique_atk = eval_result.get("attack_delta", 0)
			technique_events = eval_result.get("events", [])
			var coins_delta: int = eval_result.get("coins_delta", 0)
			Economy.add_coins(coins_delta)
			_round_technique_coins += coins_delta
			_handle_technique_flags(eval_result.get("flags", []))
			_update_round_state_after_eval(ctx, eval_result)

	var effective_enh_counts: Dictionary = _effective_enhancement_counts(_pending_enh_counts)
	var effective_enh_params: Dictionary = _effective_enhancement_params()

	var mastery_atk: int = 0
	if not is_bonus_event:
		mastery_atk = RunState.get_mastery_level(event_type)
	var honed_atk: int = 0
	if not is_bonus_event:
		honed_atk = PieceEnhancements.honed_bonus(effective_enh_counts, effective_enh_params["honed"])
	var modified: int = raw_attack + technique_atk + mastery_atk + honed_atk
	var keystone_flat_delta := 0
	var consumable_flat_delta := 0
	var log_surge_mult := 1.0
	var log_keystone_mult := 1.0
	var log_amplified_mult := 1.0
	if _is_attack_suppressed(event_type):
		modified = 0
	else:
		var pre_ks_flat := modified
		modified = _apply_keystone_flat_bonuses(modified, event_type)
		keystone_flat_delta = modified - pre_ks_flat

		var pre_con_flat := modified
		modified = _apply_consumable_flat_bonuses(modified, event_type)
		consumable_flat_delta = modified - pre_con_flat

		var pre_surge := modified
		modified = _apply_consumable_surge(modified, event_type)
		log_surge_mult = 2.0 if modified != pre_surge and pre_surge > 0 else 1.0

		var pre_ks_mult := modified
		modified = _apply_keystone_multipliers(modified, event_type)
		log_keystone_mult = float(modified) / float(pre_ks_mult) if pre_ks_mult > 0 else 1.0

		if not is_bonus_event:
			var amp := PieceEnhancements.amplified_multiplier(effective_enh_counts, effective_enh_params["amplified"])
			if amp > 1.0:
				modified = int(float(modified) * amp)
				log_amplified_mult = amp

	if not is_bonus_event and current_config.boss_modifier:
		if not current_config.boss_modifier.attack_counts_toward_quota(event_type):
			return

	if event_type != "b2b" and event_type != "combo":
		_last_attack_was_quad = (event_type == "quad")
	if event_type == "perfect_clear":
		_pc_count_this_round += 1

	if _run_stats and not is_bonus_event and event_type in CLEAR_TYPE_DISPLAY:
		_run_stats.clear_counts[event_type] = _run_stats.clear_counts.get(event_type, 0) + 1
		match event_type:
			"single": _run_stats.singles += 1
			"double": _run_stats.doubles += 1
			"triple": _run_stats.triples += 1
			"quad": _run_stats.quads += 1
			"tspin_single", "tspin_mini": _run_stats.tspin_singles += 1
			"tspin_double": _run_stats.tspin_doubles += 1
			"tspin_triple": _run_stats.tspin_triples += 1
			"perfect_clear": _run_stats.perfect_clears += 1

	if not is_bonus_event and event_type != "perfect_clear" and event_type in RunState.MASTERY_TRACKS:
		var new_level := RunState.grant_mastery_xp(event_type)
		if new_level > 0:
			_spawn_mastery_popup(event_type, new_level)
		if hud:
			hud._refresh_mastery_panel()

	var log_tag_bonus := 0

	if not is_bonus_event and ctx.lines_cleared > 0:
		for ks in RunState.keystones:
			if ks.attack_to_shield_pct > 0.0:
				var shield_gain := floori(modified * ks.attack_to_shield_pct)
				if shield_gain > 0:
					_garbage_shield += shield_gain
					if _shield_bar:
						_shield_bar.update_charges(_garbage_shield)

	if modified > 0:
		var tier := current_config.enemy.tier if current_config and current_config.enemy else ""
		DamageLog.log_attack(
			RunState.floor, tier, event_type,
			raw_attack, technique_atk, mastery_atk, honed_atk,
			keystone_flat_delta, consumable_flat_delta,
			log_surge_mult, log_keystone_mult, log_amplified_mult,
			log_tag_bonus, modified)

	var to_quota: int = _drain_attack(modified)
	quota_accumulated += to_quota
	surplus_attack = maxi(0, int(quota_accumulated) - current_config.quota)
	if _enemy_display:
		_enemy_display.update_hp(quota_accumulated)
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

	if not is_bonus_event and not _technique_pre_evaluated:
		var ks_events := _collect_keystone_events(modified, event_type)
		_fire_keystone_visuals(ks_events)
		var all_events := technique_events + ks_events
		if all_events.size() > 0:
			_schedule_popups(all_events, 0.0)

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
	ctx.cleared_enh_counts = _pending_enh_counts
	ctx.event_type = event_type
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
			"glass_cannon":
				pass
			"greedy_hands":
				_greedy_hands_active = true
			_:
				if flag.begins_with("post_quad_enhance:") or flag.begins_with("post_combo_enhance:"):
					var enh_type: String = flag.split(":")[1]
					if enh_type != "":
						_queue_enhancement_grant(enh_type, 1)
				elif flag.begins_with("shield_per_clear:"):
					var shield_amount := int(flag.split(":")[1])
					_garbage_shield += shield_amount
					if _shield_bar:
						_shield_bar.update_charges(_garbage_shield)

func _update_round_state_after_eval(ctx: AttackContext, _eval: Dictionary) -> void:
	if _technique_round_state == null:
		return
	var rs := _technique_round_state
	if ctx.lines_cleared > 0:
		rs.clears_this_round += 1
		rs.attack_events_this_round += 1
		rs.total_garbage_sent += ctx.garbage_sent

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

		rs.last_clear_type = ctx.event_type
		if rs.opening_blow_used == false:
			rs.opening_blow_used = true
		if rs.follow_up_pending:
			rs.follow_up_pending = false
		else:
			rs.follow_up_pending = true
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

		if not rs.combo_payout_used:
			for t in RunState.techniques:
				if t.effect_type == "economy" and t.params.get("trigger", "") == "combo_payout" \
						and ctx.combo >= t.params.get("combo_threshold", 4):
					rs.combo_payout_used = true
					break

		if _held_this_piece and rs.patience_cooldown_pieces == 0:
			rs.patience_pending = true

	_held_this_piece = false
	_used_soft_drop_this_piece = false
	_rotations_this_piece = 0

	if hud:
		hud.update_technique_states(_build_technique_states())

# ── Keystone attack modifiers ─────────────────────────────────────────────

func _is_attack_suppressed(event_type: String) -> bool:
	for ks in RunState.keystones:
		if ks.suppress_spins and event_type in ["tspin_mini", "tspin_single", "tspin_double", "tspin_triple", "tspin_any"]:
			return true
		if ks.suppress_tspin_single and event_type == "tspin_single":
			return true
		if ks.suppress_tspin_double and event_type == "tspin_double":
			return true
		if ks.suppress_tspin_triple and event_type == "tspin_triple":
			return true
		if ks.suppress_non_singles and event_type != "single":
			return true
	return false

static func compute_keystone_flat_bonus(ks: Keystone, event_type: String, techniques: Array, t_rotations: int) -> int:
	var b := 0
	match event_type:
		"single":
			b += ks.single_bonus
		"double":
			b += ks.double_bonus
		"triple":
			b += ks.triple_bonus
		"quad":
			b += ks.quad_bonus
		"tspin_mini", "tspin_single", "tspin_double", "tspin_triple":
			match event_type:
				"tspin_mini":   b += ks.tspin_mini_bonus
				"tspin_single": b += ks.tspin_single_bonus
				"tspin_double": b += ks.tspin_double_bonus
				"tspin_triple": b += ks.tspin_triple_bonus
			b += ks.tspin_any_bonus
		"b2b":
			b += ks.b2b_bonus
	if ks.dizzy and event_type.begins_with("tspin") and event_type != "tspin_mini" and t_rotations > 4:
		b += 8
	return b

func _apply_keystone_flat_bonuses(attack: int, event_type: String) -> int:
	var total_bonus := 0
	for ks in RunState.keystones:
		total_bonus += compute_keystone_flat_bonus(ks, event_type, RunState.techniques, _t_spin_rotations)
	return attack + total_bonus

func _apply_keystone_multipliers(attack: int, event_type: String) -> int:
	if attack == 0:
		return 0
	var mult := 1.0
	for ks in RunState.keystones:
		var ks_mult := 1.0
		match event_type:
			"single":
				if ks.single_multiplier > 0.0:
					ks_mult *= ks.single_multiplier
			"quad":
				if ks.quad_multiplier > 0.0:
					ks_mult *= ks.quad_multiplier
				if ks.consecutive_quad_multiplier > 0.0 and _last_attack_was_quad:
					ks_mult *= ks.consecutive_quad_multiplier
				if ks.daze_stun_seconds > 0.0:
					_enemy_timer = maxf(0.0, _enemy_timer - ks.daze_stun_seconds)
			"tspin_double":
				if ks.tspin_double_multiplier > 0.0:
					ks_mult *= ks.tspin_double_multiplier
			"tspin_triple":
				if ks.tspin_triple_multiplier > 0.0:
					ks_mult *= ks.tspin_triple_multiplier
			"combo":
				if ks.combo_multiplier > 0.0 and current_board and current_board.combo > ks.combo_multiplier_threshold:
					ks_mult *= ks.combo_multiplier
			"perfect_clear":
				if ks.pc_first_multiplier > 0.0 and _pc_count_this_round == 0:
					ks_mult *= ks.pc_first_multiplier
				elif ks.pc_after_first_multiplier > 0.0 and _pc_count_this_round > 0:
					ks_mult *= ks.pc_after_first_multiplier
		if ks.all_attack_multiplier > 0.0:
			ks_mult *= ks.all_attack_multiplier
		if ks.risky_business and event_type not in ["b2b", "combo"]:
			for row_idx in _last_cleared_rows:
				if row_idx >= TetrisBoard.HIDDEN_ROWS and row_idx < TetrisBoard.HIDDEN_ROWS + 5:
					ks_mult *= 2.0
					break
		mult *= ks_mult
	return int(float(attack) * mult)

func _collect_keystone_events(attack: int, event_type: String) -> Array:
	if _is_attack_suppressed(event_type):
		return []
	var events: Array = []
	for ks in RunState.keystones:
		var b := compute_keystone_flat_bonus(ks, event_type, RunState.techniques, _t_spin_rotations)
		if b > 0:
			events.append({"name": ks.display_name, "id": ks.id, "bonus": b})
	var mult := 1.0
	for ks in RunState.keystones:
		var km := 1.0
		match event_type:
			"single":       if ks.single_multiplier > 0.0: km *= ks.single_multiplier
			"quad":
				if ks.quad_multiplier > 0.0: km *= ks.quad_multiplier
				if ks.consecutive_quad_multiplier > 0.0 and _last_attack_was_quad: km *= ks.consecutive_quad_multiplier
			"tspin_double": if ks.tspin_double_multiplier > 0.0: km *= ks.tspin_double_multiplier
			"tspin_triple": if ks.tspin_triple_multiplier > 0.0: km *= ks.tspin_triple_multiplier
			"combo":
				if ks.combo_multiplier > 0.0 and current_board and current_board.combo > ks.combo_multiplier_threshold:
					km *= ks.combo_multiplier
			"perfect_clear":
				if ks.pc_first_multiplier > 0.0 and _pc_count_this_round == 0:
					km *= ks.pc_first_multiplier
				elif ks.pc_after_first_multiplier > 0.0 and _pc_count_this_round > 0:
					km *= ks.pc_after_first_multiplier
		mult *= km
	var mult_added := int(float(attack) * mult) - attack
	if mult_added > 0:
		for ks in RunState.keystones:
			var contributed := false
			match event_type:
				"single":       contributed = ks.single_multiplier > 0.0
				"quad":         contributed = ks.quad_multiplier > 0.0 or (ks.consecutive_quad_multiplier > 0.0 and _last_attack_was_quad)
				"tspin_double": contributed = ks.tspin_double_multiplier > 0.0
				"tspin_triple": contributed = ks.tspin_triple_multiplier > 0.0
				"combo":        contributed = ks.combo_multiplier > 0.0 and current_board and current_board.combo > ks.combo_multiplier_threshold
				"perfect_clear": contributed = ks.pc_first_multiplier > 0.0 or ks.pc_after_first_multiplier > 0.0
			if contributed:
				events.append({"name": ks.display_name, "id": ks.id, "bonus": mult_added})
				break
	return events

func _fire_keystone_visuals(events: Array) -> void:
	if hud == null:
		return
	for ev in events:
		hud.flash_keystone(ev.get("id", ""))

# ── Popup helpers ─────────────────────────────────────────────────────────

const CLEAR_POPUP_FADE_DURATION: float = 1.0

func _spawn_clear_type_popup(clear_type: String) -> void:
	var entry: Array = CLEAR_TYPE_DISPLAY.get(clear_type, ["", Color.WHITE])
	var label_text: String = entry[0]
	var label_color: Color = entry[1]
	if label_text.is_empty():
		return

	var lbl: Label
	if is_instance_valid(_active_clear_popup_label):
		if _active_clear_popup_tween:
			_active_clear_popup_tween.kill()
		lbl = _active_clear_popup_label
	else:
		if _hold_display == null:
			return
		lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(112, 0)
		lbl.pivot_offset = Vector2(56, 12)
		add_child(lbl)
		_active_clear_popup_label = lbl

	var hold_screen_pos: Vector2 = _hold_display.get_global_transform_with_canvas().origin
	var hold_slots: int = 1
	if current_board and current_board.config:
		hold_slots = current_board.config.hold_slots
	var panel_height: float = hold_slots * 96.0 + (hold_slots - 1) * 6.0 + 16.0

	lbl.text = label_text
	lbl.modulate = label_color
	lbl.scale = Vector2(1.0, 1.0)
	lbl.position = Vector2(hold_screen_pos.x, hold_screen_pos.y + panel_height + 8.0)

	var is_pop_tier: bool = label_color != Color.WHITE
	var tw := create_tween()
	_active_clear_popup_tween = tw
	if is_pop_tier:
		lbl.scale = Vector2(0.8, 0.8)
		tw.tween_property(lbl, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, CLEAR_POPUP_FADE_DURATION)
	else:
		tw.tween_property(lbl, "modulate:a", 0.0, CLEAR_POPUP_FADE_DURATION)
	tw.tween_callback(func() -> void:
		if _active_clear_popup_label == lbl:
			_active_clear_popup_label = null
			_active_clear_popup_tween = null
		lbl.queue_free())

func _spawn_event_popup(event: Dictionary, index: int, total: int) -> void:
	var lbl := Label.new()
	lbl.text = event.get("text", "")
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.modulate = event.get("color", Color.WHITE)

	var anchor_pos := Vector2(16, 360)
	if hud and hud._mastery_panel:
		anchor_pos = hud._mastery_panel.get_global_transform_with_canvas().origin

	var spread := (index - (total - 1) * 0.5) * 20.0
	lbl.position = Vector2(anchor_pos.x, anchor_pos.y - 20.0 + spread)
	add_child(lbl)

	var tw := create_tween()
	tw.tween_property(lbl, "position", lbl.position + Vector2(0, -40), 0.6)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.queue_free)

	if hud:
		hud.pop_icon(event.get("id", ""))

const _MASTERY_DISPLAY := {
	"single": "Singles", "double": "Doubles", "triple": "Triples", "quad": "Quads",
	"tspin_single": "T-Singles", "tspin_double": "T-Doubles", "tspin_triple": "T-Triples",
}

func _spawn_mastery_popup(track: String, level: int) -> void:
	var display_name: String = _MASTERY_DISPLAY.get(track, track)
	var lbl := Label.new()
	lbl.text = "%s Lv %d!" % [display_name, level]
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.modulate = Color(0.5, 1.0, 0.5)
	var anchor_pos := Vector2(16, 320)
	if hud and hud._mastery_panel:
		anchor_pos = hud._mastery_panel.get_global_transform_with_canvas().origin
	lbl.position = Vector2(anchor_pos.x, anchor_pos.y - 20.0)
	add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position", lbl.position + Vector2(0, -40), 0.8)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
	tw.tween_callback(lbl.queue_free)

func _schedule_popups(events: Array, delay: float, reset_elapsed: bool = true) -> void:
	if reset_elapsed:
		_popup_elapsed = 0.0
	var n := events.size()
	for i in range(n):
		var ev: Dictionary = events[i]
		var text: String
		var color: Color
		if ev.has("bonus"):
			text = "+%d %s" % [ev["bonus"], ev["name"]]
			color = ev.get("color", Color(0.5, 0.8, 1.0))
		elif ev.get("attack", 0) != 0:
			text = "+%d %s" % [ev["attack"], ev["name"]]
			color = Color.WHITE
		else:
			text = "+%d coin %s" % [ev.get("coins", 0), ev["name"]]
			color = Color(1.0, 0.85, 0.0)
		var entry := {
			"time": 0.0 if delay <= 0.0 else (float(i) / float(n)) * delay,
			"text": text,
			"color": color,
			"id": ev.get("id", ""),
			"index": i,
			"total": n,
		}
		_popup_schedule.append(entry)

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
				if _enemy_display:
					_enemy_display.update_hp(quota_accumulated)
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
	if _run_stats:
		_run_stats.run_time += round_timer
	_garbage_packets = []
	_popup_schedule.clear()
	_popup_elapsed = 0.0
	_technique_pre_evaluated = false
	_pre_evaluated_technique_atk = 0
	var _round_tier := current_config.enemy.tier if current_config and current_config.enemy else ""
	var _round_pieces := _technique_round_state.pieces_placed if _technique_round_state else 0
	DamageLog.log_round_end(RunState.floor, _round_tier,
		current_config.quota if current_config else 0, round_timer, _round_pieces)
	_notify_attack_bar()
	if current_board:
		current_board.is_active = false
	if not success:
		_flow.resolve_combat(false)
		return

	var surplus_income := _calculate_surplus_income()
	var keystone_income := _apply_keystone_economy()
	Economy.add_coins(surplus_income)
	Economy.pay_round(BASE_PAYOUT)

	_round_income_breakdown = {
		"base": BASE_PAYOUT,
		"techniques": _round_technique_coins + surplus_income + keystone_income,
		"enhancements": _round_enhancement_coins,
	}

	_flow.resolve_combat(true)

func _on_death_animation_finished() -> void:
	var fn := _pending_round_end
	_pending_round_end = Callable()
	fn.call()

func _on_boss_death_animation_finished() -> void:
	_show_round_success_then_boss_cleared()


func _apply_keystone_economy() -> int:
	var total := 0
	for ks in RunState.keystones:
		if ks.end_round_coins > 0:
			total += ks.end_round_coins
		if ks.time_coins:
			total += int(round_timer)
	Economy.coins += total
	return total

func _calculate_surplus_income() -> int:
	var income := 0
	for technique in RunState.techniques:
		if technique.effect_type == "economy" and technique.params.get("trigger", "") == "surplus":
			var divisor: int = technique.params.get("divisor", 2)
			income += surplus_attack / divisor
	if _greedy_hands_active:
		income += 15
	if _flow and RunState.is_boss_room(_flow.current_room) and RunState.has_technique("bounty_list"):
		income += 40
	return income

func _on_lock_processed() -> void:
	_t_spin_rotations = 0
	_rotations_this_piece = 0
	_clear_popup_shown_this_piece = false
	var _did_clear := not _last_cleared_rows.is_empty()
	_last_cleared_rows = []
	_piece_spawn_time = Time.get_ticks_msec() / 1000.0
	if _technique_round_state:
		_technique_round_state.switch_up_armed = _hard_drop_used_this_piece
	_hard_drop_used_this_piece = false
	if _flash_step_arr_active and current_board:
		current_board.arr_rate = 0.0 if _has_instant_arr() else Settings.load_arr()
		_flash_step_arr_active = false
	if _flash_step_arr_pending and current_board:
		current_board.arr_rate = 0.0
		_flash_step_arr_pending = false
		_flash_step_arr_active = true
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

func _show_round_success_then_map() -> void:
	var scene: PackedScene = load(SCENE_ROUND_SUCCESS)
	var screen = scene.instantiate()
	_active_overlay = screen
	add_child(screen)
	screen.connect("proceed", _on_round_success_proceed_to_map)
	screen.setup(_round_income_breakdown.base, _round_income_breakdown.techniques, _round_income_breakdown.enhancements)

func _on_round_success_proceed_to_map() -> void:
	_active_overlay = null
	RunSave.save()
	_show_dungeon_map()

func _show_round_success_then_boss_cleared() -> void:
	var scene: PackedScene = load(SCENE_ROUND_SUCCESS)
	var screen = scene.instantiate()
	_active_overlay = screen
	add_child(screen)
	screen.connect("proceed", _on_boss_cleared)
	screen.setup(_round_income_breakdown.base, _round_income_breakdown.techniques, _round_income_breakdown.enhancements)

func _on_boss_cleared() -> void:
	_active_overlay = null
	_flow.confirm_boss_cleared()

func _show_keystone_selection_then_map() -> void:
	var scene: PackedScene = load(SCENE_KEYSTONE_SELECTION)
	var screen = scene.instantiate()
	get_tree().root.add_child(screen)
	screen.setup(false)
	screen.connect("keystone_chosen", _on_floor_keystone_chosen)

func _on_floor_keystone_chosen(_keystone: Keystone) -> void:
	_show_dungeon_map()

func _compute_pbs(run_stats: RunStats) -> Dictionary:
	var pbs: Dictionary = {}
	if run_stats.total_damage > ProfileSave.best_single_run_damage:
		pbs["total_damage"] = true
	if run_stats.highest_combo_chain > ProfileSave.highest_combo_chain:
		pbs["highest_combo_chain"] = true
	if run_stats.highest_b2b > ProfileSave.highest_b2b:
		pbs["highest_b2b"] = true
	return pbs

func _show_failure() -> void:
	RunSave.delete()
	DamageLog.log_run_end("failure")
	if not is_inside_tree():
		return
	var pbs: Dictionary = _compute_pbs(_run_stats) if _run_stats else {}
	var scene: PackedScene = load(SCENE_RUN_FAILURE)
	var screen = scene.instantiate()
	add_child(screen)
	screen.setup(_run_stats, pbs, RunState.floor)

func _show_victory() -> void:
	RunSave.delete()
	DamageLog.log_run_end("victory")
	var beaten_level := AscensionManager.current_level
	var pbs: Dictionary = _compute_pbs(_run_stats) if _run_stats else {}
	var scene: PackedScene = load(SCENE_RUN_VICTORY)
	var screen = scene.instantiate()
	add_child(screen)
	screen.setup(_run_stats, pbs, Economy.coins, beaten_level)
	ProfileSave.record_victory(beaten_level)
	if _run_stats:
		for track in RunState.MASTERY_TRACKS:
			_run_stats.mastery_levels[track] = RunState.get_mastery_level(track)
		ProfileSave.accumulate_stats(_run_stats)
		UnlockChecker.check_all(_run_stats, ProfileSave)

# ── Consumable integration ────────────────────────────────────────────────

func apply_consumable(consumable: Consumable) -> void:
	if consumable.adds_time > 0.0:
		round_timer = minf(round_timer + consumable.adds_time, current_config.time_limit + consumable.adds_time)
	elif consumable.enhance_pieces > 0:
		var became_active: bool = _enhancement_grant.is_empty() \
			or _enhancement_grant.get("type", "") == consumable.enhance_type
		_queue_enhancement_grant(consumable.enhance_type, consumable.enhance_pieces)
		if became_active and current_board and current_board.current_enhancement == "":
			current_board.current_enhancement = PieceEnhancements.resolve_type(_enhancement_grant.get("type", ""))
			current_board.queue_redraw()
			_enhancement_grant["remaining"] -= 1
			if _enhancement_grant["remaining"] <= 0:
				_enhancement_grant.clear()
				if _enhancement_grant_queue.size() > 0:
					var next_grant: Dictionary = _enhancement_grant_queue.pop_front()
					_enhancement_grant["type"] = next_grant.get("type", "")
					_enhancement_grant["remaining"] = next_grant.get("remaining", 0)
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
	if attack == 0:
		return 0
	current_config.consumable_surge_clears_remaining -= 1
	return attack * 2
