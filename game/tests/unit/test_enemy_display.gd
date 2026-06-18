extends GutTest

# ── State ──────────────────────────────────────────────────────────────────
var _saved_floor: int
var _d: EnemyDisplay = null

func before_each() -> void:
	_saved_floor = RunState.floor
	RunState.floor = 1

func after_each() -> void:
	RunState.floor = _saved_floor
	if is_instance_valid(_d):
		_d.queue_free()
		_d = null

# ── Helpers ────────────────────────────────────────────────────────────────

func _make_boss_enemy(pname: String = "Boss") -> Enemy:
	var e := _make_enemy(pname)
	e.ability = BossModifier.new()
	return e

func _make_enemy(pname: String = "Test", flavor: String = "", sprite: Texture2D = null) -> Enemy:
	var e := Enemy.new()
	e.display_name = pname
	e.flavor_text = flavor
	e.color = Color.WHITE
	e.sprite = sprite
	e.tier = "Small"
	return e

func _make_display(enemy: Enemy = null, quota: int = 100) -> EnemyDisplay:
	if enemy == null:
		enemy = _make_enemy()
	_d = EnemyDisplay.new()
	add_child(_d)
	_d.setup(enemy, quota)
	return _d

# ── HP clamping ────────────────────────────────────────────────────────────

func test_update_hp_over_quota_clamps_display_to_zero() -> void:
	var d := _make_display(_make_enemy(), 100)
	d.update_hp(150.0)
	assert_eq(d._hp_bar.value, 0, "HP bar should not go below 0 when accumulated exceeds quota")

# ── ATK bar visibility ─────────────────────────────────────────────────────

func test_set_attack_bar_visible_false_hides_windup() -> void:
	var d := _make_display()
	d.set_attack_bar_visible(false)
	assert_false(d._windup_container.visible, "windup container should be hidden after set_attack_bar_visible(false)")

func test_set_attack_bar_visible_true_shows_windup() -> void:
	var d := _make_display()
	d.set_attack_bar_visible(false)
	d.set_attack_bar_visible(true)
	assert_true(d._windup_container.visible, "windup container should be visible after set_attack_bar_visible(true)")

# ── Flavor text visibility ─────────────────────────────────────────────────

func test_flavor_label_hidden_when_flavor_text_empty() -> void:
	var d := _make_display(_make_enemy("Test", ""))
	assert_false(d._flavor_label.visible, "flavor label should be hidden when flavor_text is empty")

func test_flavor_label_visible_when_flavor_text_non_empty() -> void:
	var d := _make_display(_make_enemy("Test", "An eerie presence lurks."))
	assert_true(d._flavor_label.visible, "flavor label should be visible when flavor_text is non-empty")

# ── Initial-letter placeholder ─────────────────────────────────────────────

func test_initial_label_shows_first_char_when_no_sprite() -> void:
	var d := _make_display(_make_enemy("Goblin", "", null))
	assert_true(d._initial_label.visible, "initial label should be visible when sprite is null")
	assert_eq(d._initial_label.text, "G", "initial label should show the first character of the display name")

# ── on_attack_fired null guard ────────────────────────────────────────────

func test_on_attack_fired_no_error_with_null_tween() -> void:
	var d := _make_display()
	# _lunge_tween starts null; the guard must not crash
	d.on_attack_fired()
	assert_true(true, "on_attack_fired completed without error when _lunge_tween was null")

# ── update_hp delta tracking ──────────────────────────────────────────────

func test_update_hp_increasing_value_gives_positive_delta() -> void:
	var d := _make_display(_make_enemy(), 100)
	d.update_hp(30.0)
	var prev := d._prev_accumulated
	d.update_hp(60.0)
	var delta := d._prev_accumulated - prev
	assert_gt(delta, 0.0, "delta should be positive when accumulated increases from 30 to 60")

func test_update_hp_same_value_twice_gives_zero_delta() -> void:
	var d := _make_display(_make_enemy(), 100)
	d.update_hp(50.0)
	var prev := d._prev_accumulated
	d.update_hp(50.0)
	var delta := d._prev_accumulated - prev
	assert_eq(delta, 0.0, "delta should be zero when accumulated value does not change")

# ── Death animation ────────────────────────────────────────────────────────

func test_play_death_animation_emits_signal_when_stop_animations_called() -> void:
	var d := _make_display(_make_enemy(), 100)
	watch_signals(d)
	d.play_death_animation()
	assert_true(d._death_pending_success, "death_pending_success should be true after play_death_animation")
	d.stop_animations()
	assert_signal_emitted(d, "death_animation_finished", "death_animation_finished should fire when stop_animations interrupts death tween")

func test_play_death_animation_regular_enemy_uses_regular_variant() -> void:
	var d := _make_display(_make_enemy(), 100)
	d.play_death_animation()
	assert_not_null(d._death_tween, "death tween should be created for regular enemy")
	assert_null(d._death_shake_tween, "shake tween should NOT be created for regular enemy")

func test_play_death_animation_boss_enemy_uses_boss_variant() -> void:
	var d := _make_display(_make_boss_enemy(), 100)
	d.play_death_animation()
	assert_not_null(d._death_tween, "death tween should be created for boss enemy")
	assert_not_null(d._death_shake_tween, "shake tween should be created for boss enemy")

func test_stop_animations_while_death_pending_does_not_leave_stuck() -> void:
	var d := _make_display(_make_enemy(), 100)
	watch_signals(d)
	d.play_death_animation()
	d.stop_animations()
	assert_false(d._death_pending_success, "death_pending_success should be cleared after stop_animations")
	assert_signal_emitted(d, "death_animation_finished", "signal should fire to unblock any waiting RunManager")

func test_play_death_animation_kills_active_pulse_tween() -> void:
	var d := _make_display(_make_enemy(), 100)
	d._pulse_active = true
	d._pulse_tween = d.create_tween().set_loops()
	d.play_death_animation()
	assert_false(d._pulse_active, "pulse should be stopped when death animation starts")
