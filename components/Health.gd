extends Node
class_name Health

var max_health: float
var current_health: float

signal died
signal health_changed

func initialize(_max: float) -> void:
	max_health = _max
	current_health = _max

func take_damage(damage: float) -> void:
	if (current_health <= 0): return # Cannot take damage if dead
	
	current_health = max (0, current_health - damage)
	if (current_health <= 0):
		died.emit()
	else:
		print("direct hit - ", current_health, "/", max_health)
		health_changed.emit()

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit()
