extends Node2D
class_name Weapon

const WORLD_LAYER := 1 << 0 # world layer bitmask
const PLAYER_HURTBOX_LAYER := 1 << 3 # player_hurtbox layer bitmask
const ENEMY_HURTBOX_LAYER := 1 << 4 # enemy_hurtbox layer bitmask
const OBSTACLE_LAYER := 1 << 7 # obstacle layer bitmask
const HITSCAN_MASK := WORLD_LAYER | ENEMY_HURTBOX_LAYER
const EXPLOSION_MASK := PLAYER_HURTBOX_LAYER | ENEMY_HURTBOX_LAYER

const TRACER_WIDTH := 4.0
const TRACER_COLOR := Color.RED
const TRACER_FADE_TIME := 0.05

const EXPLOSION_EFFECT_SCENE: PackedScene = preload("res://components/ExplosionEffect.tscn")
const SCREEN_FLASH_SCENE: PackedScene = preload("res://components/ScreenFlash.tscn")
const EXPLOSION_SHAKE_AMOUNT := 12.0
const EXPLOSION_SHAKE_DURATION := 0.3
const EXPLOSION_FLASH_INTENSITY := 0.5

var weapon_slot: WeaponSlot

var reload_timer: Timer
var reloading: bool
var tried_active_reload: bool
var fire_cooldown: float = 0.0

signal started_reload(weapon_data: WeaponData)
signal reloaded(active: bool)
signal fired(weapon_data: WeaponData)
signal ammo_changed

func _ready() -> void:
	reload_timer = Timer.new()
	add_child(reload_timer)
	reload_timer.timeout.connect(_finish_reload)

func initialize(slot: WeaponSlot) -> void:
	weapon_slot = slot
	reloading = false
	tried_active_reload = false
	fire_cooldown = 0.0
	reload_timer.stop()

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta

func reload() -> void:
	if weapon_slot.ammo.mags_left <= 0: return

	if not reloading: # begin reloading
		started_reload.emit(weapon_slot.weapon)
		reloading = true
		tried_active_reload = false
		reload_timer.start(weapon_slot.weapon.reload_time)
		print ("begin reload")


	elif not tried_active_reload: # Attempt active reload
		tried_active_reload = true
		var window_start = weapon_slot.weapon.active_reload_start
		var window_end = weapon_slot.weapon.active_reload_end
		var time = reload_timer.time_left

		if (time <= window_start and time >= window_end): # Active succeed?
			print ("active reload success")
			reload_timer.stop()
			_finish_reload(true)

func _finish_reload(active: bool = false):
	if (weapon_slot.ammo.mags_left > 0):
		reloading = false
		weapon_slot.ammo.bullets_left = weapon_slot.weapon.mag_size
		weapon_slot.ammo.mags_left -= 1
		reloaded.emit(active)
		ammo_changed.emit()
		print("reloaded")
		reload_timer.stop()

func fire(dir: Vector2) -> void:
	if reloading or weapon_slot.ammo.bullets_left == 0:
		reload()
		return

	if fire_cooldown > 0:
		return

	if (weapon_slot.weapon.hitscan):
		_fire_hitscan(dir)
	else:
		_fire_projectile(dir)


	fire_cooldown = 1.0 / max(weapon_slot.weapon.fire_rate, 0.01)
	weapon_slot.ammo.bullets_left -= 1
	fired.emit(weapon_slot.weapon)
	ammo_changed.emit()
	print(weapon_slot.ammo.bullets_left)

func _fire_hitscan(dir: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	for i in weapon_slot.weapon.num_bullets:
		var spread := randf_range(-weapon_slot.weapon.bullet_spread, weapon_slot.weapon.bullet_spread)
		var shot_dir := dir.rotated(spread)
		var from := global_position
		var to := from + shot_dir * weapon_slot.weapon.hitscan_range

		var hurtbox_query := PhysicsRayQueryParameters2D.create(from, to)
		hurtbox_query.collision_mask = HITSCAN_MASK
		hurtbox_query.collide_with_areas = true
		hurtbox_query.collide_with_bodies = false
		var result := space_state.intersect_ray(hurtbox_query)

		var obstacle_query := PhysicsRayQueryParameters2D.create(from, to)
		obstacle_query.collision_mask = OBSTACLE_LAYER
		obstacle_query.collide_with_areas = false
		obstacle_query.collide_with_bodies = true
		var obstacle_result := space_state.intersect_ray(obstacle_query)
		if obstacle_result and (not result or from.distance_squared_to(obstacle_result.position) < from.distance_squared_to(result.position)):
			result = obstacle_result

		if result:
			to = result.position
			if weapon_slot.weapon.hit_explosion:
				Weapon.explode(self, to, weapon_slot.weapon.hit_explosion_radius, weapon_slot.weapon.damage, self)
			elif result.collider is HurtBox:
				result.collider.take_damage(weapon_slot.weapon.damage, self)
		_draw_tracer(from, to)

func _draw_tracer(from: Vector2, to: Vector2) -> void:
	var line := Line2D.new()
	line.top_level = true
	line.width = TRACER_WIDTH
	line.default_color = TRACER_COLOR
	line.add_point(from)
	line.add_point(to)
	get_tree().current_scene.add_child(line)
	var tween := create_tween()
	tween.tween_property(line, "modulate:a", 0.0, TRACER_FADE_TIME)
	tween.tween_callback(line.queue_free)

func _fire_projectile(dir: Vector2) -> void:
	for i in weapon_slot.weapon.num_bullets:
		var spread := randf_range(-weapon_slot.weapon.bullet_spread, weapon_slot.weapon.bullet_spread)
		var bullet_dir := dir.rotated(spread)
		var projectile := ProjectilePool.acquire()
		projectile.activate(weapon_slot.weapon.damage, self, weapon_slot.weapon.bullet_radius, bullet_dir, weapon_slot.weapon.bullet_speed, global_position, weapon_slot.weapon.bullet_lifetime, weapon_slot.weapon.hit_explosion, weapon_slot.weapon.hit_explosion_radius)

# Damages every player or enemy HurtBox within `radius` of `position`.
static func explode(from_node: Node2D, position: Vector2, radius: float, damage: float, source: Node) -> void:
	var space_state := from_node.get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = EXPLOSION_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for result in space_state.intersect_shape(query):
		var collider = result.collider
		if collider is HurtBox:
			collider.take_damage(damage, source)

	_spawn_explosion_fx(from_node, position, radius)

static func _spawn_explosion_fx(from_node: Node2D, position: Vector2, radius: float) -> void:
	var current_scene := from_node.get_tree().current_scene

	AudioManager.play(AudioManager.SFX.EXPLOSION)

	var effect: ExplosionEffect = EXPLOSION_EFFECT_SCENE.instantiate()
	current_scene.add_child(effect)
	effect.global_position = position
	effect.setup(radius)

	var flash: ScreenFlash = SCREEN_FLASH_SCENE.instantiate()
	current_scene.add_child(flash)
	flash.setup(EXPLOSION_FLASH_INTENSITY)

	var camera := from_node.get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(EXPLOSION_SHAKE_AMOUNT, EXPLOSION_SHAKE_DURATION)
