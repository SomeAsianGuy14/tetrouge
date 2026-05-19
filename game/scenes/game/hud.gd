class_name HUD
extends Control

@onready var quota_bar: ProgressBar = $TopBar/QuotaBar
@onready var quota_label: Label = $TopBar/QuotaLabel
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var round_label: Label = $TopBar/RoundLabel
@onready var modifier_label: Label = $TopBar/ModifierLabel
@onready var keystone_icons: HBoxContainer = $SidePanel/KeystoneIcons

@onready var score_label: Label = $InfoPanel/ScoreLabel
@onready var timer_big_label: Label = $InfoPanel/TimerBigLabel
@onready var round_big_label: Label = $InfoPanel/RoundBigLabel
@onready var modifier_big_label: Label = $InfoPanel/ModifierBigLabel

func _ready() -> void:
	Economy.connect("coins_changed", _on_coins_changed)

func setup(config: RoundConfig) -> void:
	quota_bar.max_value = config.quota
	quota_bar.value = 0

	var round_text := "Stage %d — %s" % [RunState.stage, RunState.get_round_name()]
	round_label.text = round_text
	round_big_label.text = round_text

	score_label.text = "0 / %d" % config.quota

	var total_secs := int(config.time_limit)
	timer_big_label.text = "%d:%02d" % [total_secs / 60, total_secs % 60]
	timer_big_label.modulate = Color.WHITE
	timer_label.modulate = Color.WHITE

	if config.boss_modifier:
		modifier_label.text = config.boss_modifier.display_name
		modifier_label.visible = true
		modifier_big_label.text = config.boss_modifier.display_name
		modifier_big_label.visible = true
	else:
		modifier_label.visible = false
		modifier_big_label.visible = false

	coin_label.text = "Coins: %d" % Economy.coins
	_refresh_keystone_icons()

func update_quota(accumulated: float, quota: int) -> void:
	quota_bar.value = minf(accumulated, quota)
	quota_label.text = "%d / %d" % [int(accumulated), quota]
	score_label.text = "%d / %d" % [int(accumulated), quota]

func update_timer(time_remaining: float) -> void:
	var secs := maxf(0.0, time_remaining)
	var formatted := "%d:%02d" % [int(secs) / 60, int(secs) % 60]
	timer_label.text = formatted
	timer_big_label.text = formatted
	var color := Color.RED if secs <= 10.0 else Color.WHITE
	timer_label.modulate = color
	timer_big_label.modulate = color

func _on_coins_changed(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _refresh_keystone_icons() -> void:
	for child in keystone_icons.get_children():
		child.queue_free()
	for keystone in RunState.keystones:
		var lbl := Label.new()
		lbl.text = keystone.display_name[0]
		lbl.tooltip_text = keystone.display_name
		keystone_icons.add_child(lbl)
