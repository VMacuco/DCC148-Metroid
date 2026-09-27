extends Area2D

signal hit_or_fade
var projectile_speed: float
var direction: Vector2 = Vector2.RIGHT
var max_projectile_distance: float
var traveled_distance: float
var is_destroing: bool



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	traveled_distance = 0
	projectile_speed = 300
	max_projectile_distance = 50
	is_destroing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_destroing:
		return
	
	var step = projectile_speed * delta
	global_position += direction * step
	traveled_distance += step
	
	#Se o tiro percorreu uma distancia definida, ele emite o sinal para sair de cena
	if traveled_distance >= max_projectile_distance:
		destroy()

func destroy() ->void:
	if is_destroing:
		return
	is_destroing = true
	#print("sumi")
	hit_or_fade.emit()
	

func _on_area_entered(area: Area2D) -> void:
	destroy()
	#print("bati")
