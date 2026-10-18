extends Area2D

@export var speed: float = 150.0
@export var contact_damage: int = 5
@export var max_distance: float = 100.0 

var direction: Vector2 = Vector2.ZERO
var traveled_distance: float = 0.0

func _physics_process(delta: float) -> void:
	var step = speed * delta
	global_position += direction * step
	traveled_distance += step
	
	if traveled_distance >= max_distance:
		queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()
