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
	_update_intent(PlayerID.PLAYER_1, "move_left", "move_right", "move_up", "move_down", "shoot", "reload", "next_weapon", "previous_weapon")
	_update_intent(PlayerID.PLAYER_2, "move_left_p2", "move_right_p2", "move_up_p2", "move_down_p2", "shoot_p2", "reload_p2", "next_weapon_p2", "previous_weapon_p2")

func _update_intent(player_id: PlayerID, left: StringName, right: StringName, up: StringName, down: StringName, shoot: StringName, reload: StringName, next_weapon: StringName, prev_weapon: StringName) -> void:
	var move := Input.get_vector(left, right, up, down)
	var facing: Vector2 = intents[player_id].facing if (move == Vector2.ZERO) else move
	var fire_held := Input.is_action_pressed(shoot)
	var fire_just_pressed := Input.is_action_just_pressed(shoot)
	var reload_pressed := Input.is_action_just_pressed(reload)
	var next_pressed := Input.is_action_just_pressed(next_weapon)
	var prev_pressed := Input.is_action_just_pressed(prev_weapon)

	intents[player_id] = InputIntent.new(
		move,
		facing,
		fire_held,
		fire_just_pressed,
		reload_pressed,
		next_pressed,
		prev_pressed)

func get_input_intent(player_id: PlayerID) -> InputIntent:
	return intents[player_id]
