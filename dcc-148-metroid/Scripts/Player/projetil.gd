extends Area2D

signal hit_or_fade
var projectile_speed: float
var direction: Vector2 = Vector2.RIGHT
var max_projectile_distance: float
var traveled_distance: float



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	traveled_distance = 0
	projectile_speed = 600
	max_projectile_distance = 50


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#usando global_position para ser mais facil de alterar a direção do tiro
	var step = projectile_speed * delta
	global_position += direction * step
	traveled_distance += step
	
	#Se o tiro percorreu uma distancia definida, ele emite o sinal para sair de cena
	if traveled_distance >= max_projectile_distance:
		hit_or_fade.emit()



func _on_area_entered(area: Area2D) -> void:
	hit_or_fade.emit()
