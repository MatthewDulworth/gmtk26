extends Node2D
class_name HealthBar

@export var health: Health
@export var enemy: EnemyController

var is_bar_visible: bool = false

@onready var background_rect = $ColorRectBackground
@onready var health_rect = $ColorRectHealth

func _ready() -> void:
	_init();
	
	health.health_changed.connect(_on_health_change)
	
func _process(_delta: float) -> void:
	if enemy.state in [enemy.EnemyState.DEAD_PENDING_COLLECTION, enemy.EnemyState.DEAD_COLLECTED]:
		is_bar_visible = false
		
	_render()

func _init() -> void:
	is_bar_visible = false

func _render() -> void:
	var health_percent = health.current_health / health.max_health
	var health_width = health_percent * 20
	
	if is_bar_visible == false:
		background_rect.color = Color(background_rect.color.r, background_rect.color.g, background_rect.color.b, 0.0)
		health_rect.color = Color(health_rect.color.r, health_rect.color.g, health_rect.color.b, 0.0)
	else:
		background_rect.color = Color(background_rect.color.r, background_rect.color.g, background_rect.color.b, 1.0)
		health_rect.color = Color(health_rect.color.r, health_rect.color.g, health_rect.color.b, 1.0) 
		health_rect.size.x = health_width
	
func _on_health_change(_cur_health):
	is_bar_visible = true
	
