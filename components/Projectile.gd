extends Area2D
class_name Projectile

var damage: float
var source: Node
var velocity: Vector2

func _ready() -> void:
	monitoring = true
	area_entered.connect(_on_area_entered)

func initialize(_damage: float, _source: Node, radius: float, _velocity: Vector2) -> void:
	damage = _damage
	source = _source
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if not (area is HurtBox):
		return
	area.take_damage(damage, self)
	monitoring = false
	queue_free()
