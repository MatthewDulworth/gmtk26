extends Node

enum PlayerID {
	PLAYER_1,
	PLAYER_2,
	PLAYER_3,
	PLAYER_4,
}

var intents: Array[InputIntent] = [
	InputIntent.new(Vector2.ZERO, Vector2.DOWN, false, false, false, false, false),
	InputIntent.new(Vector2.ZERO, Vector2.DOWN, false, false, false, false, false),
	InputIntent.new(Vector2.ZERO, Vector2.DOWN, false, false, false, false, false),
	InputIntent.new(Vector2.ZERO, Vector2.DOWN, false, false, false, false, false),
]

func _process(_delta: float) -> void:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var facing: Vector2 = intents[PlayerID.PLAYER_1].facing if (move == Vector2.ZERO) else move
	var fire_held := Input.is_action_pressed("shoot")
	var fire_just_pressed := Input.is_action_just_pressed("shoot")
	var reload := Input.is_action_just_pressed("reload")
	var next_weapon := Input.is_action_just_pressed("next_weapon")
	var prev_weapon := Input.is_action_just_pressed("previous_weapon")
	
	intents[PlayerID.PLAYER_1] = InputIntent.new(
		move, 
		facing, 
		fire_held, 
		fire_just_pressed, 
		reload, 
		next_weapon, 
		prev_weapon)

func get_input_intent(player_id: PlayerID) -> InputIntent:
	return intents[player_id]
