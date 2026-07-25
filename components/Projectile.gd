extends Area2D
class_name Projectile

var damage: float
var source: Node
var velocity: Vector2
var lifetime: float
var _time_alive: float
var is_explosive: bool
var explosion_radius: float

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func activate(_damage: float, _source: Node, radius: float, dir: Vector2, speed: float, spawn_position: Vector2, _lifetime: float, _is_explosive: bool = false, _explosion_radius: float = 0.0) -> void:
	damage = _damage
	source = _source
	velocity = dir * speed
	lifetime = _lifetime
	is_explosive = _is_explosive
	explosion_radius = _explosion_radius
	_time_alive = 0.0
	global_position = spawn_position
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	set_deferred("monitoring", true)
	visible = true
	set_physics_process(true)
	print("projectile exists")

func _physics_process(delta: float) -> void:
	position += velocity * delta
	_time_alive += delta
	if _time_alive >= lifetime:
		_deactivate()

func _on_area_entered(area: Area2D) -> void:
	print("entered", area)
	if not (area is HurtBox):
		return
	if is_explosive:
		Weapon.explode(self, global_position, explosion_radius, damage, source)
	else:
		area.take_damage(damage, self)
	_deactivate()

func _on_body_entered(_body: Node) -> void:
	if is_explosive:
		Weapon.explode(self, global_position, explosion_radius, damage, source)
	_deactivate()

func _deactivate() -> void:
	set_deferred("monitoring", false)
	visible = false
	set_physics_process(false)
	ProjectilePool.release(self)
