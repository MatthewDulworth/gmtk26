extends Node2D
class_name ExplosionEffect

const NATIVE_RADIUS := 256.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func setup(radius: float) -> void:
	var s = radius / NATIVE_RADIUS
	scale = Vector2(s, s)

func _ready() -> void:
	sprite.animation_finished.connect(queue_free)
	sprite.play("explode")
