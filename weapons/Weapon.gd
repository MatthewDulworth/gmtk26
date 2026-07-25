extends Node2D
class_name Weapon

const HITSCAN_MASK := 1 << 4 # enemy_hurtbox (see project.godot [layer_names])

const TRACER_WIDTH := 2.0
const TRACER_COLOR := Color.YELLOW
const TRACER_FADE_TIME := 0.05

var weapon_data: WeaponData
var mags: int
var bullets_in_mag: int

func initialize(data: WeaponData) -> void:
	weapon_data = data
	mags = weapon_data.num_mags
	bullets_in_mag = weapon_data.mag_size

func reload() -> void:
	pass

func fire(dir: Vector2) -> void:
	if (bullets_in_mag == 0):
		reload()
	
	if (weapon_data.hitscan):
		_fire_hitscan(dir)
	else:
		_fire_projectile(dir)

func _fire_hitscan(dir: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	for i in weapon_data.num_bullets:
		var spread := randf_range(-weapon_data.bullet_spread, weapon_data.bullet_spread)
		var shot_dir := dir.rotated(spread)
		var from := global_position
		var to := from + shot_dir * weapon_data.hitscan_range
		var query := PhysicsRayQueryParameters2D.create(from, to)
		query.collision_mask = HITSCAN_MASK
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result := space_state.intersect_ray(query)
		if result:
			to = result.position
			if result.collider is HurtBox:
				print("hit")
				result.collider.take_damage(weapon_data.damage, self)
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
	for i in weapon_data.num_bullets:
		var spread := randf_range(-weapon_data.bullet_spread, weapon_data.bullet_spread)
		var bullet_dir := dir.rotated(spread)
		var projectile := ProjectilePool.acquire()
		projectile.activate(weapon_data.damage, self, weapon_data.bullet_radius, bullet_dir, weapon_data.bullet_speed, global_position, weapon_data.bullet_lifetime)
