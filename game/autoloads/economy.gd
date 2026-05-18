extends Node

var coins: int = 0

var interest_cap: int = 5
var speed_bonus_multiplier: float = 1.0

signal coins_changed(new_amount: int)

func reset() -> void:
	coins = 0
	interest_cap = 5
	speed_bonus_multiplier = 1.0
	emit_signal("coins_changed", coins)

func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed", coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	emit_signal("coins_changed", coins)
	return true

func can_afford(amount: int) -> bool:
	return coins >= amount

func apply_interest() -> int:
	var interest := mini(coins / 5, interest_cap)
	if interest > 0:
		add_coins(interest)
	return interest

func pay_round(base: int, speed_bonus: int, technique_income: int) -> void:
	var total := base + roundi(speed_bonus * speed_bonus_multiplier) + technique_income
	add_coins(total)

func calculate_speed_bonus(time_remaining: float, time_limit: float) -> int:
	if time_remaining <= 0.0:
		return 0
	return roundi((time_remaining / time_limit) * 3.0 * speed_bonus_multiplier)
