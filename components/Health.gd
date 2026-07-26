extends Node
class_name Health

var max_health: float
var current_health: float
var regen_rate: float = 0.0
var regen_cooldown: float = 5.0
var _regen_cooldown_timer: float = 0.0

signal died
signal health_changed

func initialize(_max: float, _regen_rate: float = 0.0, _regen_cooldown: float = 5.0) -> void:
	max_health = _max
	current_health = _max
	regen_rate = _regen_rate
	regen_cooldown = _regen_cooldown

func _process(delta: float) -> void:
	if _regen_cooldown_timer > 0:
		_regen_cooldown_timer = max(0.0, _regen_cooldown_timer - delta)
		return

	if regen_rate > 0 and current_health > 0 and current_health < max_health:
		heal(regen_rate * delta)

func take_damage(damage: float) -> void:
	if (current_health <= 0): return # Cannot take damage if dead

	current_health = max (0, current_health - damage)
	_regen_cooldown_timer = regen_cooldown
	if (current_health <= 0):
		died.emit()
	else:
		print("direct hit - ", current_health, "/", max_health)
		health_changed.emit(current_health)

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health)
