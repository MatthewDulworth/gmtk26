extends CharacterBody2D
class_name PlayerController

@export var player_data: PlayerData
@export var health: Health
@export var hurtbox: HurtBox

var current_weapon: Weapon
var player_id: InputManager.PlayerID = InputManager.PlayerID.PLAYER_1
var input: InputIntent

func _ready() -> void:
	health.initialize(player_data.max_health)
	input = InputManager.get_input_intent(player_id)

func _process(_delta: float) -> void:
	input = InputManager.get_input_intent(player_id)

func _physics_process(_delta: float) -> void:
	velocity = input.move * player_data.move_speed
	move_and_slide()
