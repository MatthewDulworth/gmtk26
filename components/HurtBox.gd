extends Area2D
class_name HurtBox

@export var health: Health

var max_invuln_time: float
var invuln_time: float

signal hit(amount: float, source: Node)

func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount)
	hit.emit(amount, source)
	print(amount, source)
