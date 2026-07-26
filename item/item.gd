extends Area2D
class_name Item

@onready var box: ColorRect = $ColorRect

# Optional: Reuse your floating text popup for the box too!
const FLOATING_TEXT_SCENE = preload("res://components/FloatingText.tscn")

func collect() -> void:
	var text_popup = FLOATING_TEXT_SCENE.instantiate()
	text_popup.setup("new gun") 
	get_tree().current_scene.add_child(text_popup)
	text_popup.global_position = global_position
		
	# TODO: inventory
	queue_free()

func _ready() -> void:
	set_collision_layer_value(CollisionLayers.Layer.ENEMY_BODY, true)
	_bounce_animation(3)
		
func _bounce_animation(num_bounces: int) -> Tween:
	var tween = create_tween()
	var base_y = box.position.y 
	var vertical_change = 20
	var scale_change = 1.1
	var time = 0.4 # seconds

	for i in range(num_bounces):
		# Bounce Up + Grow slightly
		tween.tween_property(box, "position:y", base_y - vertical_change, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(box, "scale", Vector2.ONE * scale_change, time).set_trans(Tween.TRANS_SINE)

		# Fall Down + Shrink back
		tween.tween_property(box, "position:y", base_y, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(box, "scale", Vector2.ONE, time).set_trans(Tween.TRANS_SINE)
		
		# Decay the height on each bounce
		vertical_change *= 0.5 
		
	return tween	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
