extends CanvasLayer
class_name ScreenFlash

const FADE_TIME := 0.15

@onready var rect: ColorRect = $ColorRect

var intensity: float = 0.5

func setup(_intensity: float) -> void:
	intensity = _intensity

func _ready() -> void:
	layer = 100
	rect.modulate.a = intensity
	var tween := create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(queue_free)
