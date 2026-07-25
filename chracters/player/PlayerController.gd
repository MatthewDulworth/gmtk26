extends CharacterBody2D
class_name PlayerController

@export var player_data: PlayerData
@export var health: Health
@export var hurtbox: HurtBox
@export var weapon: Weapon
@export var weapons_list: WeaponsList
@export var health_bar: PlayerHealthBar
@export var weapon_hud: WeaponHUD

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_box: Area2D = $PickupBox
@onready var collision_box: CollisionShape2D = $CollisionShape2D

@export var player_id: InputManager.PlayerID = InputManager.PlayerID.PLAYER_1
var input: InputIntent
var waiting_for_fire_release: bool = false
var state: PlayerState

enum PlayerState {
	ALIVE,
	DEAD
}

func pickup_weapon(data: WeaponData) -> void:
	weapons_list.add_weapon(data)
	
func take_damage(damage: float) -> void:
	health.take_damage(damage)

func _ready() -> void:
	health.initialize(player_data.max_health, player_data.health_regen_rate)
	health_bar.bind(health)
	input = InputManager.get_input_intent(player_id)
	health.died.connect(_on_death)
	weapons_list.initialize(player_data.starting_weapons)
	_use_weapon(weapons_list.get_current_weapon())
	state = PlayerState.ALIVE

	animation.play(player_data.animation_name_move)

	# Don't shoot ourself
	_set_hurtbox_collision_layer(CollisionLayers.Layer.PLAYER_HURTBOX)

	# Signals
	pickup_box.area_entered.connect(_on_collect_feather)
	weapon.reloaded.connect(_on_weapon_reloaded)
	animation.animation_finished.connect(_on_animation_complete)

func _process(_delta: float) -> void:
	input = InputManager.get_input_intent(player_id)

	if not input.fire_held:
		waiting_for_fire_release = false

	if input.fire_just_pressed or (input.fire_held and weapon.weapon_slot.weapon.full_auto and not weapon.reloading and not waiting_for_fire_release):
		weapon.fire(input.facing)

	if input.reload:
		weapon.reload()
		
	if input.next or input.prev:
		_cycle_weapon(input.next)
	
	_about_face()

func _on_weapon_reloaded(active: bool) -> void:
	if active and input.fire_held:
		waiting_for_fire_release = true

func _use_weapon(slot: WeaponSlot) -> void:
	print("using: ", slot.weapon.name, " n: ", slot.ammo.bullets_left, " m: ",  slot.ammo.mags_left)
	weapon.initialize(slot)
	weapon_hud.bind(slot)

func _cycle_weapon(forwards: bool) -> void:
	_use_weapon(weapons_list.switch_weapon(forwards))

func _physics_process(_delta: float) -> void:
	velocity = input.move * player_data.move_speed
	move_and_slide()

func _on_death() -> void:
	print("player ", player_id, " died.")
	state = PlayerState.DEAD
	set_process(false)
	set_physics_process(false)
	velocity = Vector2.ZERO
	animation.play(player_data.animation_name_die)
	
	# Disable collision
	collision_box.set_deferred("disabled", true)
	pickup_box.set_deferred("disabled", true)
	

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
	if area is HurtBox:
		var parent = area.get_parent()
		if parent is EnemyController:
			var enemy = area.get_parent() as EnemyController
			if enemy and enemy.state == EnemyController.EnemyState.DEAD_PENDING_COLLECTION:
				enemy.collect()
				
func _on_animation_complete() -> void:
	if animation.animation == player_data.animation_name_die:
		animation.stop()
		animation.frame = animation.sprite_frames.get_frame_count(player_data.animation_name_die) - 1
