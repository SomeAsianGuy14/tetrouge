class_name HUD
extends Control

@onready var quota_bar: ProgressBar = $TopBar/QuotaBar
@onready var quota_label: Label = $TopBar/QuotaLabel
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var round_label: Label = $TopBar/RoundLabel
@onready var modifier_label: Label = $TopBar/ModifierLabel
@onready var keystone_icons: HBoxContainer = $SidePanel/KeystoneIcons

func setup(config: RoundConfig) -> void:
	quota_bar.max_value = config.quota
	quota_bar.value = 0
	round_label.text = "Ante %d — %s" % [RunState.ante, RunState.get_round_name()]
	if config.boss_modifier:
		modifier_label.text = config.boss_modifier.display_name
		modifier_label.visible = true
	else:
		modifier_label.visible = false
	_refresh_keystone_icons()
	Economy.connect("coins_changed", _on_coins_changed)

func update_quota(accumulated: float, quota: int) -> void:
	quota_bar.value = minf(accumulated, quota)
	quota_label.text = "%d / %d" % [int(accumulated), quota]

func update_timer(time_remaining: float) -> void:
	var secs := maxf(0.0, time_remaining)
	timer_label.text = "%d:%02d" % [int(secs) / 60, int(secs) % 60]
	if secs <= 10.0:
		timer_label.modulate = Color.RED
	else:
		timer_label.modulate = Color.WHITE

func _on_coins_changed(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _refresh_keystone_icons() -> void:
	for child in keystone_icons.get_children():
		child.queue_free()
	for keystone in RunState.keystones:
		var lbl := Label.new()
		lbl.text = keystone.display_name[0]  # first letter as placeholder icon
		lbl.tooltip_text = keystone.display_name
		keystone_icons.add_child(lbl)
