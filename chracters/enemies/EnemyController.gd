extends CharacterBody2D
class_name EnemyController

@export var enemy_data: EnemyData
@export var players: Array[PlayerController]
@export var health: Health
@export var hurtbox: HurtBox
@export var state: EnemyState

var target: Vector2

const player_scan_time = 0.3 # Time in seconds until it scans for which player to chase

@onready var nav_agent_2d = $NavigationAgent2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_box: CollisionShape2D = $CollisionShape2D


enum EnemyState {
	SPAWN,
	CHASE,
	ATTACK,
	DEAD_PENDING_COLLECTION,
	DEAD_COLLECTED
}

func _ready() -> void:
	_spawn()
	_set_target_player()
	scale = scale * enemy_data.size_scale;
	health.initialize(enemy_data.max_health)
	health.died.connect(_dead_pending_collection)
	animation.animation_finished.connect(_on_death_animation_complete)
	
	# make sure hurtbox is on layer 5 so hitscanning detects it
	_set_hurtbox_collision_layer(CollisionLayers.Layer.ENEMY_HURTBOX)


func _process(_delta: float) -> void:
	_set_target_player()
	_face_player()
	if (position.distance_to(target)) <= 1.0:
		velocity = Vector2(0, 0)
		position = target
	_animate()
	
func _physics_process(_delta: float) ->  void:
	if (position.distance_to(target)) > 0.5:
		var pos = global_transform.origin
		var new_pos = nav_agent_2d.get_next_path_position()
		var new_vel = (new_pos - pos).normalized() * enemy_data.move_speed; # speed
		velocity = new_vel
		move_and_slide()
		
func _set_target_player():
	target = Vector2(_get_closest_player().position)
	nav_agent_2d.set_target_position(target)
	
func _animate():
	if state == EnemyState.CHASE:
		animation.play(enemy_data.move_animation_name)

func _get_closest_player():
	var closestPlayer
	var closestPlayerDistance = INF
	for player: PlayerController in players:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player < closestPlayerDistance:
			closestPlayerDistance = distance_to_player
			closestPlayer = player
	return closestPlayer

func _get_is_closest_player_to_right() -> bool:
	var player = _get_closest_player()
	return player.position.x > position.x

func _face_player():
	if _get_is_closest_player_to_right():
		animation.flip_h = 0
	else:
		animation.flip_h = -1

func _spawn() -> void:
	# Spawn in ready to chase
	_chase()
	
func _chase() -> void:
	state = EnemyState.CHASE
	
func _attack() -> void: 
	state = EnemyState.ATTACK
	
func _dead_pending_collection() -> void:
	state = EnemyState.DEAD_PENDING_COLLECTION
	animation.play("death")
	velocity = Vector2.ZERO
	
	# Put in enemy_body layer
	_set_hurtbox_collision_layer(CollisionLayers.Layer.ENEMY_BODY)
	collision_box.set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)
	
func _on_death_animation_complete() -> void:
	if animation.animation == "death":
		animation.stop()
		animation.play("down_feather") 
	
func collect() -> void:
	state = EnemyState.DEAD_COLLECTED
	queue_free()
	
func _set_hurtbox_collision_layer(layer: CollisionLayers.Layer) -> void:
	# Reset any previous layers
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 0
	# Add to new layer
	hurtbox.set_collision_layer_value(layer, true) 
