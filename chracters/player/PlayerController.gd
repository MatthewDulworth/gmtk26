extends CharacterBody2D
class_name PlayerController

@export var player_data: PlayerData
@export var health: Health
@export var hurtbox: HurtBox
@export var weapon: Weapon 

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_box: Area2D = $PickupBox


var player_id: InputManager.PlayerID = InputManager.PlayerID.PLAYER_1
var input: InputIntent

func _ready() -> void:
	health.initialize(player_data.max_health)
	input = InputManager.get_input_intent(player_id)
	health.died.connect(_on_death)
	_use_weapon(player_data.starting_weapon)
	animation.play("levitate")
	
	# Don't shoot ourself
	_set_hurtbox_collision_layer(CollisionLayers.Layer.PLAYER_HURTBOX)
	
	# Signals
	pickup_box.area_entered.connect(_on_collect_feather)

	

func _process(_delta: float) -> void:
	input = InputManager.get_input_intent(player_id)
	
	if (input.fire_just_pressed):
		weapon.fire(input.facing)
	
	if (input.reload):
		weapon.reload()
	
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
		animation.flip_h = -1
	elif velocity.x < 0: 
		animation.flip_h = 0
		
func _set_hurtbox_collision_layer(layer: CollisionLayers.Layer) -> void:
	# Reset any previous layers
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 0
	# Add to new layer
	hurtbox.set_collision_layer_value(layer, true) 
	
func _on_collect_feather(area: Area2D) -> void:
	print('area', area)
	# Check if the area belongs to an Enemy HurtBox
	if area is HurtBox:
		# Get the EnemyController parent owning this HurtBox
		var enemy = area.get_parent() as EnemyController
		
		if enemy and enemy.state == EnemyController.EnemyState.DEAD_PENDING_COLLECTION:
			enemy.collect()
