extends Node

const PROJECTILE_SCENE: PackedScene = preload("res://components/Projectile.tscn")

var _available: Array[Projectile] = []

func acquire() -> Projectile:
	if _available.is_empty():
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()
		get_tree().current_scene.add_child(projectile)
		return projectile
	return _available.pop_back()

func release(projectile: Projectile) -> void:
	_available.append(projectile)
