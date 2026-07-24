extends Node

var input_intent := InputIntent.new(Vector2.ZERO, Vector2.DOWN, false, false)

func _process(_delta: float) -> void:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var facing: Vector2 = input_intent.move if (move == Vector2.ZERO) else move
	var fire_held := Input.is_action_pressed("shoot")
	var fire_just_pressed := Input.is_action_just_pressed("shoot")
	
	input_intent = InputIntent.new(move, facing, fire_held, fire_just_pressed)
