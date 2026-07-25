class_name Obstacle extends Area2D

func _ready() -> void:
	body_entered.connect(_on_hitbox_enter)

func _on_hitbox_enter(body: Node):
	if body is Projectile:
		print("you hit a wall")

func _process(_delta: float) -> void:
		pass
