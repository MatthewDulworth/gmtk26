extends CharacterBody2D
class_name EnemyController

@export var enemy_data: EnemyData
@export var players: Array[PlayerController]
@export var health: Health
@export var hurtbox: HurtBox
@export var state: EnemyState

var target: Vector2
var is_attack_on_cooldown: bool = false

const player_scan_time = 0.3 # Time in seconds until it scans for which player to chase
const feather_pickup_text = preload("res://components/FloatingText.tscn")

@onready var nav_agent_2d = $NavigationAgent2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $HitBox
@onready var hitbox_collision: CollisionShape2D = $HitBox/CollisionShape2D

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
	
	hitbox_collision.disabled = true
	
	# Signals
	health.died.connect(_dead_pending_collection)
	animation.animation_finished.connect(_on_animation_complete) 
	
	# make sure hurtbox is on layer 5 so hitscanning detects it
	_set_hurtbox_collision_layer(CollisionLayers.Layer.ENEMY_HURTBOX)


func _process(_delta: float) -> void:
	if _is_dead():
		return
	
	_set_target_player()
	_face_player()
		
	# State transitions
	if _should_begin_attack():
		_attack()
	
func _physics_process(_delta: float) ->  void:
	if state == EnemyState.ATTACK or state == EnemyState.DEAD_PENDING_COLLECTION:
		return
	
	if (position.distance_to(target)) > 5.0:
		_move_towards_target()
		
func _set_target_player():
	target = Vector2(_get_closest_player().position)
	nav_agent_2d.set_target_position(target)

func _get_closest_player():
	var closestPlayer
	var closestPlayerDistance = INF
	for player: PlayerController in players:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player < closestPlayerDistance:
			closestPlayerDistance = distance_to_player
			closestPlayer = player
	return closestPlayer

func _is_closest_player_to_right() -> bool:
	var player = _get_closest_player()
	return player.position.x > position.x

func _face_player():
	if _is_closest_player_to_right():
		animation.flip_h = 0
	else:
		animation.flip_h = -1

func _spawn() -> void:
	# Spawn in ready to chase
	_chase()
	
func _chase() -> void:
	state = EnemyState.CHASE
	animation.play(enemy_data.animation_name_move)
	
func _attack() -> void: 	
	state = EnemyState.ATTACK
	velocity = Vector2.ZERO 
	
	# Scale animation based on duration
	var sprite_frames = animation.sprite_frames
	var frame_count = sprite_frames.get_frame_count("attack")
	var base_fps = sprite_frames.get_animation_speed("attack")
	var native_duration = float(frame_count) / base_fps
	animation.speed_scale = native_duration / enemy_data.attack_duration
	animation.play("attack")
	
func _dead_pending_collection() -> void:	
	state = EnemyState.DEAD_PENDING_COLLECTION
	animation.speed_scale = 1.0
	animation.play(enemy_data.animation_name_die)
	velocity = Vector2.ZERO
	_set_hurtbox_collision_layer(CollisionLayers.Layer.ENEMY_BODY)
	collision_box.set_deferred("disabled", true)
	
	# Completely disable the weapon shape on death
	hitbox_collision.set_deferred("disabled", true)
	
	set_physics_process(false)
	set_process(false)
	
func _on_animation_complete() -> void:
	if animation.animation == enemy_data.animation_name_die:
		animation.stop()
		animation.play("down_feather") 
	if animation.animation == "attack":
		animation.stop()
		animation.speed_scale = 1.0 
		
		_deal_damage_on_final_frame()
		_cooldown_attack()
	
func collect() -> void:
	state = EnemyState.DEAD_COLLECTED
	
	var text_popup = feather_pickup_text.instantiate()
	text_popup.setup(enemy_data.count_down_value)
	text_popup.global_position = global_position
	get_tree().current_scene.add_child(text_popup)
	
	queue_free()
	
func _set_hurtbox_collision_layer(layer: CollisionLayers.Layer) -> void:
	# Reset any previous layers
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 0
	# Add to new layer
	hurtbox.set_collision_layer_value(layer, true) 
	
func _move_towards_target():
	var pos = global_transform.origin
	var new_pos = nav_agent_2d.get_next_path_position()
	var new_vel = (new_pos - pos).normalized() * enemy_data.move_speed;
	velocity = new_vel
	move_and_slide()
	
func _should_begin_attack() -> bool:
	return position.distance_to(target) < enemy_data.attack_range and state == EnemyState.CHASE and not is_attack_on_cooldown
	
func _is_dead() -> bool:
	return state == EnemyState.DEAD_PENDING_COLLECTION or state == EnemyState.DEAD_COLLECTED
			
func _deal_damage_on_final_frame() -> void:
	hitbox_collision.disabled = false
	
	# Wait two ticks
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# If player is overlapping, deal damage
	var hit_areas = hitbox.get_overlapping_areas()
	print(hit_areas)
	for area in hit_areas:
		var parent = area.get_parent()
		if parent is PlayerController:
			parent.take_damage(enemy_data.attack_damage)
			
	hitbox_collision.set_deferred("disabled", true)
		
func _cooldown_attack() -> void:
	is_attack_on_cooldown = true
	_chase() 
	await get_tree().create_timer(enemy_data.attack_cooldown).timeout
	is_attack_on_cooldown = false
