extends CharacterBody2D
class_name EnemyController

@export var enemy_data: EnemyData
@export var players: Array[PlayerController]
@export var health: Health
@export var hurtbox: HurtBox
@export var state: EnemyState:
	set(v):
		if v == EnemyState.CHASE and state !=  EnemyState.CHASE:
			SignalBus.enemy_started_walking.emit(self)
		elif v != EnemyState.CHASE:
			SignalBus.enemy_stopped_walking.emit(self)
		state = v

var knockback_velocity: Vector2 = Vector2.ZERO
var target: Vector2
var is_attack_on_cooldown: bool = false

const knockback_decay: float = 10.0 # Rate of knockback decay
const knockback_threshold = 10.0 # Only knockback applies when knock back velocity magnitude is more than this 
const player_scan_time = 0.3 # Time in seconds until it scans for which player to chase
const feather_pickup_text = preload("res://components/FloatingText.tscn")

@onready var nav_agent_2d = $NavigationAgent2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $HitBox
@onready var hitbox_collision: CollisionShape2D = $HitBox/CollisionShape2D

enum EnemyState {
	IDLE,
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
	health.health_changed.connect(func(current_health): SignalBus.enemy_damaged.emit(current_health))
	animation.animation_finished.connect(_on_animation_complete)
	hurtbox.hit.connect(_on_hurtbox_hit)

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

	elif _is_all_players_dead():
		animation.play("walk")

func _physics_process(delta: float) ->  void:
	if state == EnemyState.DEAD_PENDING_COLLECTION or state == EnemyState.DEAD_COLLECTED:
		return
		
	# Degrade knockback
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta * 100.0)
	
	# When in knockback, can't move (outside of knockback)
	if knockback_velocity.length() > knockback_threshold:
		velocity = knockback_velocity
		move_and_slide()
		return

	# Handle regular state logic when not experiencing knockback
	if state == EnemyState.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if (position.distance_to(target)) > 5.0:
		_move_towards_target()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func _set_target_player() -> void:
	# If all players are dead, go to the middle
	if _is_all_players_dead():
		target = Vector2(0, 0)
	else:
		target = _get_closest_player().position
	nav_agent_2d.set_target_position(target)

func _get_closest_player() -> PlayerController:
	var closestPlayer
	var closestPlayerDistance: float = INF
	for player: PlayerController in players:
		if player.state == PlayerController.PlayerState.DEAD:
			continue
		var distance_to_player = position.distance_squared_to(player.position)
		if distance_to_player < closestPlayerDistance:
			closestPlayerDistance = distance_to_player
			closestPlayer = player
	return closestPlayer

func _is_closest_player_to_right() -> bool:
	var player = _get_closest_player()
	if player == null:
		return position.x < 0
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
	var frame_count = sprite_frames.get_frame_count(enemy_data.animation_name_attack)
	var base_fps = sprite_frames.get_animation_speed(enemy_data.animation_name_attack)
	var native_duration = float(frame_count) / base_fps
	animation.speed_scale = native_duration / enemy_data.attack_duration
	animation.play(enemy_data.animation_name_attack)
	SignalBus.enemy_attacked.emit()

func _dead_pending_collection() -> void:
	SignalBus.enemy_died.emit(self)
	state = EnemyState.DEAD_PENDING_COLLECTION
	animation.speed_scale = 1.0
	animation.play(enemy_data.animation_name_die)
	velocity = Vector2.ZERO
	_set_hurtbox_collision_layer(CollisionLayers.Layer.ENEMY_BODY)
	collision_box.set_deferred("disabled", true)

	# Completely disable the weapon shape on death
	hitbox_collision.set_deferred("disabled", true)
	
	_drop_item_maybe()

	set_physics_process(false)
	set_process(false)

func _on_animation_complete() -> void:
	if animation.animation == enemy_data.animation_name_die:
		animation.stop()
		animation.play(enemy_data.animation_name_feather)
		var tween = _bounce_animation(10)
		tween.tween_callback(queue_free)
	elif animation.animation == enemy_data.animation_name_attack:
		animation.stop()
		animation.speed_scale = 1.0

		_deal_damage_on_final_frame()
		_cooldown_attack()

func collect() -> void:
	state = EnemyState.DEAD_COLLECTED
	_show_value_text_popup()
	queue_free()

func _show_value_text_popup() -> void:
	var text_popup = feather_pickup_text.instantiate()
	text_popup.setup("+" + str(enemy_data.count_down_value))
	text_popup.global_position = global_position
	get_tree().current_scene.add_child(text_popup)

func _set_hurtbox_collision_layer(layer: CollisionLayers.Layer) -> void:
	# Reset any previous layers
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 0
	# Add to new layer
	hurtbox.set_collision_layer_value(layer, true)

func _move_towards_target():
	if nav_agent_2d.is_navigation_finished():
		return
	var pos = global_transform.origin
	var new_pos = nav_agent_2d.get_next_path_position()
	var move_vel = (new_pos - pos).normalized() * enemy_data.move_speed
	velocity = move_vel
	move_and_slide()
	
func _should_begin_attack() -> bool:
	return position.distance_to(target) < enemy_data.attack_range \
		and state == EnemyState.CHASE \
		and not is_attack_on_cooldown \
		and not _is_all_players_dead() \
		and knockback_velocity.length() <= knockback_threshold

func _is_dead() -> bool:
	return state == EnemyState.DEAD_PENDING_COLLECTION or state == EnemyState.DEAD_COLLECTED

func _deal_damage_on_final_frame() -> void:
	hitbox_collision.disabled = false

	# Wait two ticks
	await get_tree().physics_frame
	await get_tree().physics_frame

	# If player is overlapping, deal damage
	var hit_areas = hitbox.get_overlapping_areas()
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

func _is_all_players_dead() -> bool:
	return players.all(func(p): return p.state == PlayerController.PlayerState.DEAD)

func _bounce_animation(num_bounces: int) -> Tween:
	var tween = create_tween()
	var base_y = position.y
	var vertical_change = 20
	var scale_change = 1.1
	var time = 0.4 # seconds

	for i in range(num_bounces):
		# Bounce + grow
		tween.tween_property(self, "position:y", base_y - vertical_change, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(self, "scale", scale * scale_change, time).set_trans(Tween.TRANS_SINE)

		# Fall + shrink
		tween.tween_property(self, "position:y", base_y, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(self, "scale", scale, time).set_trans(Tween.TRANS_SINE)
	return tween

func _on_hurtbox_hit(amount: float, source: Node) -> void:
	if _is_dead():
		return

	# Calculate knockback
	var knockback_force: float = source.weapon_slot.weapon.knockback
	var reduced_force = knockback_force / enemy_data.mass
	var knockback_direction = (global_position - source.global_position).normalized()
	knockback_velocity = knockback_direction * reduced_force * 100
	
func _drop_item_maybe():
	var random_roll = randf_range(0.0, 100.0)
	if random_roll <= enemy_data.drop_rate:
		var dropped_item = enemy_data.item_drop_scene.instantiate()
		get_tree().current_scene.add_child(dropped_item)
		var drop_offset = Vector2(30, 60) 
		dropped_item.global_position = global_position + drop_offset
