class_name DebugOverlay
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var lbl_round: Label = $Panel/VBox/LblRound
@onready var lbl_quota: Label = $Panel/VBox/LblQuota
@onready var lbl_timer: Label = $Panel/VBox/LblTimer
@onready var lbl_combo: Label = $Panel/VBox/LblCombo
@onready var lbl_piece: Label = $Panel/VBox/LblPiece
@onready var lbl_keystones: Label = $Panel/VBox/LblKeystones
@onready var lbl_techniques: Label = $Panel/VBox/LblTechniques
@onready var lbl_coins: Label = $Panel/VBox/LblCoins
@onready var refresh_timer: Timer = $RefreshTimer

var board: TetrisBoard = null
var run_manager = null  # set by RunManager after instantiation

func _ready() -> void:
	visible = false
	layer = 10
	refresh_timer.wait_time = 0.25
	refresh_timer.autostart = true
	refresh_timer.connect("timeout", _refresh_labels)
	refresh_timer.start()

func set_board(b: TetrisBoard) -> void:
	board = b

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F2:
			visible = not visible
			get_viewport().set_input_as_handled()

func _refresh_labels() -> void:
	if not visible:
		return
	lbl_round.text = "Ante %d — %s" % [RunState.ante, RunState.get_round_name()]
	lbl_coins.text = "Coins: %d" % Economy.coins

	if run_manager:
		lbl_quota.text = "Quota: %d / %d" % [int(run_manager.quota_accumulated), run_manager.current_config.quota if run_manager.current_config else 0]
		lbl_timer.text = "Timer: %.1fs" % run_manager.round_timer

	if board:
		lbl_combo.text = "Combo: %d | B2B: %s" % [board.combo, "YES" if board.is_b2b else "no"]
		lbl_piece.text = "Piece: %s rot %d" % [board.current_type, board.current_rotation]

	var ks_names := RunState.keystones.map(func(k): return k.display_name)
	lbl_keystones.text = "Keystones: " + (", ".join(ks_names) if ks_names else "—")

	var t_names := RunState.techniques.map(func(t): return t.display_name)
	lbl_techniques.text = "Techniques: " + (", ".join(t_names) if t_names else "—")
