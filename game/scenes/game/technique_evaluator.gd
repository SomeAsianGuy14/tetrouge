class_name TechniqueEvaluator

# Returns { "attack_delta": int, "coins_delta": int, "flags": Array, "events": Array }
# flags: string tokens RunManager handles as side-effects:
#   "flash_step_arr"    — set board ARR=0 for next piece
#   "burning_board"     — start/sustain periodic damage timer
#   "glass_cannon"      — apply +2 incoming garbage modifier
#   "greedy_hands"      — handled at round-end for +2 coins + enemy buff
# events: per-technique contributions — [{name, id, attack, coins}] for non-zero results
static func evaluate(techniques: Array, ctx: AttackContext, rs: TechniqueRoundState) -> Dictionary:
	var total_atk: int = 0
	var total_coins: int = 0
	var events: Array = []
	for t in techniques:
		var atk: int = _eval_attack(t, ctx, rs)
		var eco: int = _eval_economy(t, ctx, rs)
		total_atk += atk
		total_coins += eco
		if atk != 0 or eco != 0:
			events.append({"name": t.display_name, "id": t.id, "attack": atk, "coins": eco})
	var flags: Array = _collect_flags(techniques, ctx, rs)
	return {"attack_delta": total_atk, "coins_delta": total_coins, "flags": flags, "events": events}

static func compute_attack_bonus(techniques: Array, ctx: AttackContext, rs: TechniqueRoundState) -> int:
	var total: int = 0
	for t in techniques:
		var bonus: int = _eval_attack(t, ctx, rs)
		total += bonus
	return total

static func compute_economy_bonus(techniques: Array, ctx: AttackContext, rs: TechniqueRoundState) -> int:
	var total: int = 0
	for t in techniques:
		total += _eval_economy(t, ctx, rs)
	return total

# ── Per-technique attack evaluation ──────────────────────────────────────────

static func _eval_attack(t: Resource, ctx: AttackContext, rs: TechniqueRoundState) -> int:
	var et: String = t.effect_type
	var p: Dictionary = t.params
	var is_clear: bool = ctx.lines_cleared > 0
	var is_tspin: bool = ctx.tspin != ""
	var board_pct: float = ctx.board_height / 20.0

	match et:
		"flat":
			return _eval_flat(p, ctx, board_pct)

		"first_clear":
			if is_clear and not rs.opening_blow_used:
				return p.get("bonus", 3)
			return 0

		"follow_up":
			if is_clear and rs.follow_up_pending:
				return p.get("bonus", 1)
			return 0

		"tetris_echo":
			if is_clear and ctx.lines_cleared != 4 and rs.tetris_echo_pending:
				return p.get("bonus", 1)
			return 0

		"delayed_cannon":
			if ctx.lines_cleared != 4:
				return 0
			if rs.tetris_count % 2 == 1:
				return p.get("spike_bonus", 5)
			else:
				return p.get("base_bonus", 3)

		"four_disciplines":
			if ctx.lines_cleared == 4:
				return p.get("quad_bonus", 5)
			elif is_clear:
				return p.get("penalty", -1)
			return 0

		"every_nth_clear":
			if is_clear and (rs.clears_this_round + 1) % p.get("n", 4) == 0:
				return p.get("bonus", 3)
			return 0

		"every_nth_combo":
			if ctx.combo >= 0 and (ctx.combo + 1) % p.get("n", 4) == 0:
				return p.get("bonus", 3)
			return 0

		"combo_spike":
			if ctx.combo >= 0 and (ctx.combo + 1) % p.get("n", 5) == 0:
				return p.get("bonus", 5)
			return 0

		"chain_starter":
			if is_clear and rs.clears_this_round == 1:
				return p.get("bonus", 1)
			return 0

		"combo_spark":
			if ctx.combo >= 0:
				return p.get("bonus_per_step", 1)
			return 0

		"flurry":
			if is_clear and ctx.lines_cleared == 1 and ctx.combo >= 0:
				return p.get("bonus", 1)
			return 0

		"discipline_hold":
			if is_clear and not ctx.held_this_piece:
				return p.get("bonus", 2)
			return 0

		"patience":
			if is_clear and rs.patience_pending:
				return p.get("bonus", 1)
			return 0

		"after_receive":
			if is_clear and rs.after_receive_pending:
				var below_pct: float = p.get("board_below_pct", -1.0)
				if below_pct >= 0.0 and board_pct >= below_pct:
					return 0
				return p.get("bonus", 2)
			return 0

		"escalation":
			if is_clear and rs.escalation_pending:
				return p.get("bonus", 2)
			return 0

		"gambler_rng":
			if not is_clear:
				return 0
			var roll: float = randf()
			var win_chance: float = p.get("win_chance", 0.25)
			var loss_chance: float = p.get("loss_chance", 0.25)
			if roll < win_chance:
				return p.get("win_bonus", 4)
			elif roll < win_chance + loss_chance:
				return -p.get("loss_penalty", 2)
			return 0

		"glass_cannon":
			return p.get("attack_bonus", 4) if is_clear else 0

		"burning_board":
			return p.get("attack_bonus", 3) if is_clear else 0

		"flash_step":
			return 0  # movement effect only; handled via flags

		"greedy_hands":
			return 0  # economy/enemy effect only

		"adrenaline_rush":
			# Stack must reach into the top N rows (board_height is 0=empty..20=full)
			if is_clear and ctx.board_height > 20 - p.get("top_rows", 4):
				return p.get("bonus", 5)
			return 0

		"side_strike":
			if ctx.lines_cleared == 4 and (ctx.locked_col == 0 or ctx.locked_col >= 6):
				return p.get("bonus", 1)
			return 0

		"tspin_garbage":
			if is_tspin and ctx.garbage_sent > 0:
				return p.get("bonus", 3)
			return 0

		"enemy_hp_below":
			if is_clear and ctx.enemy_hp_pct < p.get("threshold", 0.25):
				return p.get("bonus", 1)
			return 0

		"controlled_drop":
			if is_clear and ctx.used_soft_drop:
				return p.get("bonus", 1)
			return 0

		"rotation_training":
			if is_clear and ctx.rotations_this_placement >= p.get("min_rotations", 2):
				return p.get("bonus", 1)
			return 0

		"constant_pressure":
			if is_clear and rs.constant_pressure_pending:
				return p.get("bonus", 1)
			return 0

		"flow_step":
			if is_clear and rs.flow_step_pending:
				return p.get("bonus", 2)
			return 0

		"switch_up":
			if is_clear and rs.switch_up_armed and ctx.used_soft_drop:
				return p.get("bonus", 1)
			return 0

		"good_planning":
			if is_clear and rs.good_planning_pending:
				return p.get("bonus", 2)
			return 0

		"golden_blade":
			if is_clear and ctx.cleared_enh_counts.get("gilded", 0) > 0:
				return p.get("bonus", 2)
			return 0

		"economy", "coupon", "specialist_discount", "smooth_haggling", "bounty_list", \
		"combo_payout", "green_thumb", "piece_enhancer", \
		"attack_to_shield", "height_shield", "post_quad_enhance", "post_combo_enhance":
			return 0  # shop/economy/shield/grant effects only — handled outside evaluator

		_:
			if et != "":
				push_warning("TechniqueEvaluator: unknown effect_type '%s' on technique '%s'" % [et, t.id])
			return 0

static func _eval_flat(p: Dictionary, ctx: AttackContext, board_pct: float) -> int:
	var is_clear: bool = ctx.lines_cleared > 0
	var is_tspin: bool = ctx.tspin != ""
	var on: String = p.get("on", "")
	var bonus: int = p.get("bonus", 0)

	var skip_mastery: bool = p.get("require_b2b", false) or on == "perfect_clear"
	if not skip_mastery:
		if on in RunState.MASTERY_TRACKS:
			bonus += RunState.get_mastery_level(on) / 2
		elif on in ["all_clear", "tspin", "multiline"]:
			bonus += RunState.get_highest_mastery_for(on) / 2

	if p.get("require_b2b", false) and not ctx.b2b:
		return 0
	var above_pct: float = p.get("board_above_pct", -1.0)
	if above_pct >= 0.0 and board_pct <= above_pct:
		return 0
	var below_pct: float = p.get("board_below_pct", -1.0)
	if below_pct >= 0.0 and board_pct >= below_pct:
		return 0

	match on:
		"all_clear":        return bonus if is_clear else 0
		"multiline":        return bonus if ctx.lines_cleared >= p.get("min_lines", 2) else 0
		"quad":             return bonus if ctx.lines_cleared == 4 else 0
		"tspin":            return bonus if is_tspin else 0
		"tspin_mini":       return bonus if ctx.tspin == "mini" else 0
		"tspin_double":     return bonus if ctx.tspin == "double" else 0
		"perfect_clear":    return bonus if ctx.perfect_clear else 0
	return 0

# ── Per-technique economy evaluation ─────────────────────────────────────────

static func _eval_economy(t: Resource, ctx: AttackContext, rs: TechniqueRoundState) -> int:
	if t.effect_type != "economy":
		return 0
	var p: Dictionary = t.params
	var trigger: String = p.get("trigger", "")
	var coins: int = p.get("coins", 1)
	var is_tspin: bool = ctx.tspin != ""

	match trigger:
		"tspin":
			return coins if is_tspin else 0
		"b2b":
			return coins if ctx.b2b else 0
		"perfect_clear":
			return coins if ctx.perfect_clear else 0
		"quad":
			return coins if ctx.lines_cleared == 4 else 0
		"all_clear":
			return coins if ctx.lines_cleared > 0 else 0
		"combo_payout":
			if ctx.combo >= p.get("combo_threshold", 4) and not rs.combo_payout_used:
				return p.get("coins", 5)
			return 0
	return 0

# ── Flag collection for RunManager side-effects ────────────────────────────

static func _collect_flags(techniques: Array, ctx: AttackContext, _rs: TechniqueRoundState) -> Array:
	var flags: Array = []
	for t in techniques:
		match t.effect_type:
			"flash_step":
				if ctx.lines_cleared >= t.params.get("min_lines", 2):
					flags.append("flash_step_arr")
			"burning_board":
				if ctx.lines_cleared > 0:
					flags.append("burning_board")
			"glass_cannon":
				if ctx.lines_cleared > 0:
					flags.append("glass_cannon")
			"greedy_hands":
				flags.append("greedy_hands")
			"post_quad_enhance":
				if ctx.lines_cleared == 4:
					flags.append("post_quad_enhance:" + str(t.params.get("enhancement", "")))
			"post_combo_enhance":
				var threshold: int = t.params.get("combo_threshold", 0)
				if ctx.combo > threshold:
					flags.append("post_combo_enhance:" + str(t.params.get("enhancement", "")))
	return flags
