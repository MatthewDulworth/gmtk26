extends Area2D
class_name HurtBox

@onready var health: Health = $"../Health"
var max_invuln_time: float
var invuln_time: float

signal hit

func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount)
	hit.emit()
