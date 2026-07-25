extends Node2D
class_name PlayerHealthBar

@export var width: float = 40.0

@onready var fill: ColorRect = $Fill

var health: Health

func bind(_health: Health) -> void:
	health = _health
	health.health_changed.connect(_update)
	health.died.connect(_on_died)
	_update()

func _update(_current_health: float = 0.0) -> void:
	var pct = health.current_health / health.max_health
	fill.size.x = width * pct
	fill.color = Color.GREEN.lerp(Color.RED, 1.0 - pct)

func _on_died() -> void:
	visible = false
