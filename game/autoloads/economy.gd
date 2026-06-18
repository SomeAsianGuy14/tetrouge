extends Node

var coins: int = 0

signal coins_changed(new_amount: int)

func reset() -> void:
	coins = 0
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

func pay_round(base: int) -> void:
	add_coins(base)
