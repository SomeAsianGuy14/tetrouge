extends Node

var coins: int = 0

var interest_cap: int = 5

signal coins_changed(new_amount: int)

func reset() -> void:
	coins = 0
	interest_cap = 5
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

func pay_round(base: int) -> void:
	add_coins(base)
