extends CanvasLayer

@export var active_effect: int = -1:
	set(value):
		active_effect = value
		_apply()

var _effects: Array[ColorRect] = []

func _ready() -> void:
	for child in get_children():
		if child is ColorRect:
			_effects.append(child)
	_apply()

func _apply() -> void:
	for i in _effects.size():
		_effects[i].visible = i == active_effect
