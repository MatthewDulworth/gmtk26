extends Node
class_name Health

var max_health: float
var current_health: float
var regen_rate: float = 0.0

signal died
signal health_changed

func initialize(_max: float, _regen_rate: float = 0.0) -> void:
	max_health = _max
	current_health = _max
	regen_rate = _regen_rate

func _process(delta: float) -> void:
	if regen_rate > 0 and current_health > 0 and current_health < max_health:
		heal(regen_rate * delta)

func take_damage(damage: float) -> void:
	if (current_health <= 0): return # Cannot take damage if dead
	
	current_health = max (0, current_health - damage)
	if (current_health <= 0):
		died.emit()
	else:
		print("direct hit - ", current_health, "/", max_health)
		health_changed.emit(current_health)

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health)
