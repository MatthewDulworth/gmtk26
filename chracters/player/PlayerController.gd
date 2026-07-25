extends CharacterBody2D
class_name PlayerController

@export var player_data: PlayerData
@export var health: Health
@export var hurtbox: HurtBox
@export var weapon: Weapon

var player_id: InputManager.PlayerID = InputManager.PlayerID.PLAYER_1
var input: InputIntent

func _ready() -> void:
	health.initialize(player_data.max_health)
	input = InputManager.get_input_intent(player_id)
	health.died.connect(_on_death)
	_use_weapon(player_data.starting_weapon)
	$AnimatedSprite2D.play("levitate")

func _process(_delta: float) -> void:
	input = InputManager.get_input_intent(player_id)
	
	if (input.fire_just_pressed):
		print(input.facing)
		weapon.fire(input.facing)
		
	_about_face()

func _use_weapon(data: WeaponData) -> void:
	weapon.initialize(data)

func _physics_process(_delta: float) -> void:
	velocity = input.move * player_data.move_speed
	move_and_slide()

func _on_death() -> void:
	print(player_id, " died")

func _about_face() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = -1
	elif velocity.x < 0: 
		$AnimatedSprite2D.flip_h = 0
