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
	_use_weapon(player_data.starting_weapon)
	animation.play("levitate")
	
	# Don't shoot ourself
	_set_hurtbox_collision_layer(CollisionLayers.Layer.PLAYER_HURTBOX)
	
	# Signals
	health.died.connect(_on_death)
	health.health_changed.connect(func(current_health): SignalBus.player_damaged.emit(current_health))
	pickup_box.area_entered.connect(_on_collect_feather)
	weapon.fired.connect(func(weapon_data): SignalBus.player_fired_weapon.emit(weapon_data))
	weapon.reloaded.connect(func(active): SignalBus.reloaded.emit(active))
	weapon.started_reload.connect(func(weapon_data): SignalBus.started_reload.emit(weapon_data))

	

func _process(_delta: float) -> void:
	input = InputManager.get_input_intent(player_id)
	
	if (input.fire_just_pressed):
		weapon.fire(input.facing)
	
	if (input.reload):
		weapon.reload()
	
	_about_face()

func _use_weapon(data: WeaponData) -> void:
	weapon.initialize(data)
	SignalBus.player_switched_weapon.emit()

var last_move = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	velocity = input.move * player_data.move_speed
	
	if velocity == Vector2.ZERO and last_move != Vector2.ZERO:
		SignalBus.player_stopped_walking.emit()
	elif (velocity.x != 0 or velocity.y != 0) and last_move == Vector2.ZERO:
		SignalBus.player_started_walking.emit()
	
	last_move = velocity
	move_and_slide()

func _on_death() -> void:
	print(player_id, " died")
	SignalBus.player_died.emit()

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
	SignalBus.player_picked_up_feather.emit()
	if area is HurtBox:
		var parent = area.get_parent()
		if parent is EnemyController:
			var enemy = area.get_parent() as EnemyController
			if enemy and enemy.state == EnemyController.EnemyState.DEAD_PENDING_COLLECTION:
				enemy.collect()
				

func take_damage(damage: float) -> void:
	health.take_damage(damage)
