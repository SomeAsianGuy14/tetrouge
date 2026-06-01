class_name UnlockChecker
extends RefCounted

# No unlock conditions are defined yet. Add UnlockCondition entries here as
# new content is created. check_all() evaluates each condition and records
# any newly met unlocks in ProfileSave.
const CONDITIONS: Array = []

static func check_all(_run_stats, profile_save: Node) -> void:
	var newly_unlocked := false
	for condition in CONDITIONS:
		if condition.target_id in profile_save.unlocked_ids:
			continue
		if _evaluate(condition, _run_stats, profile_save):
			profile_save.unlocked_ids.append(condition.target_id)
			newly_unlocked = true
	if newly_unlocked:
		profile_save.save_profile()

static func _evaluate(condition: UnlockCondition, run_stats, profile_save: Node) -> bool:
	match condition.condition_type:
		"cumulative_stat":
			var stat_name: String = condition.params.get("stat", "")
			var threshold: int = condition.params.get("threshold", 0)
			match stat_name:
				"runs_completed":     return profile_save.runs_completed >= threshold
				"total_damage":       return profile_save.total_damage >= threshold
				"total_quad_damage":  return profile_save.total_quad_damage >= threshold
				"total_tspin_damage": return profile_save.total_tspin_damage >= threshold
				"highest_combo_chain":return profile_save.highest_combo_chain >= threshold
				"highest_b2b":        return profile_save.highest_b2b >= threshold
		"run_condition":
			var cond: String = condition.params.get("cond", "")
			match cond:
				"beat_ascension":
					var level: int = condition.params.get("level", 0)
					return profile_save.highest_beaten >= level
	return false
