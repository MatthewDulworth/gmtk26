extends Node2D
class_name Weapon

const WORLD_LAYER := 1 << 0 # world layer bitmask
const ENEMY_HURTBOX_LAYER := 1 << 4 # enemy_hurtbox layer bitmask
const HITSCAN_MASK := WORLD_LAYER | ENEMY_HURTBOX_LAYER

const TRACER_WIDTH := 4.0
const TRACER_COLOR := Color.RED
const TRACER_FADE_TIME := 0.05

var weapon_slot: WeaponSlot

var reload_timer: Timer
var reloading: bool
var tried_active_reload: bool

signal reloaded(active: bool)

func _ready() -> void:
	reload_timer = Timer.new()
	add_child(reload_timer)
	reload_timer.timeout.connect(_finish_reload)

func initialize(slot: WeaponSlot) -> void:
	weapon_slot = slot
	reloading = false
	tried_active_reload = false
	reload_timer.stop()

func reload() -> void:
	if weapon_slot.ammo.mags_left <= 0: return

	if not reloading: # begin reloading
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
		print("reloaded")
		reload_timer.stop()

func fire(dir: Vector2) -> void:
	if weapon_slot.ammo.bullets_left == 0:
		reload()
		return

	if (weapon_slot.weapon.hitscan):
		_fire_hitscan(dir)
	else:
		_fire_projectile(dir)

	weapon_slot.ammo.bullets_left -= 1
	print(weapon_slot.ammo.bullets_left)

func _fire_hitscan(dir: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	for i in weapon_slot.weapon.num_bullets:
		var spread := randf_range(-weapon_slot.weapon.bullet_spread, weapon_slot.weapon.bullet_spread)
		var shot_dir := dir.rotated(spread)
		var from := global_position
		var to := from + shot_dir * weapon_slot.weapon.hitscan_range
		var query := PhysicsRayQueryParameters2D.create(from, to)
		query.collision_mask = HITSCAN_MASK
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result := space_state.intersect_ray(query)
		if result:
			to = result.position
			if result.collider is HurtBox:
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
		projectile.activate(weapon_slot.weapon.damage, self, weapon_slot.weapon.bullet_radius, bullet_dir, weapon_slot.weapon.bullet_speed, global_position, weapon_slot.weapon.bullet_lifetime)
