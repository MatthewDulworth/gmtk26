extends AnimatedSprite2D

@export var bob_amount := 6.0
@export var bob_duration := 0.8

var _start_position: Vector2

func _ready() -> void:
	
	await get_tree().create_timer(randf_range(0, 0.3)).timeout
	_start_position = position

	var tween := create_tween()
	tween.set_loops() # Infinite
	tween.tween_property(self, "position:y", _start_position.y - bob_amount, bob_duration)
	tween.tween_property(self, "position:y", _start_position.y, bob_duration)
