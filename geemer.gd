extends CharacterBody2D

@export var SPEED: float = 100.0
@export var health: float = 15.0


enum State { PATROL, DEAD }
var geemer_state: State = State.PATROL


#@onready var raycast_ground: RayCast2D = $RayCast_Ground
#@onready var raycast_wall: RayCast2D = $RayCast_Wall
@onready var collision_box: CollisionShape2D = $CollisionShape2D
#var geemer_rect = collision_box.get_shape().get_rect()



func _ready() -> void:
	geemer_state = State.PATROL
	#raycast_ground.collision_mask = 0
	#raycast_wall.collision_mask = 0
	#raycast_ground.clear_exceptions()
	#raycast_wall.clear_exceptions()
	#_update_raycasts()
	up_direction = Vector2.UP

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT
	if geemer_state != State.PATROL:
		return
	
	
	velocity = transform.x * SPEED
	move_and_slide()
	
	
	if is_on_wall():
		print("está na parede")
		rotate(-PI/2)
		up_direction = get_wall_normal()
		if is_on_floor():
			print("Estou no chão")
	
	else:
		if not is_on_floor():
			print("encontrei uma beirada")
			rotate(PI/2)
			up_direction = up_direction.rotated(PI/2)
		
	
	##if is_on_floor():
		#print("estou no chão")
	#
	##if is_on_wall():
	##	rotate(PI/2)
		#up_direction = get_wall_normal()
		#print(up_direction)
		#print("estou tentando escalar", is_on_floor())
		##direction.rotated(PI/2)
	#
	#if not is_on_floor():
		#rotate(-PI/2)
		#up_direction.rotated(-PI/2)
		#direction.rotated(-PI/2)
		#print("vou virar")

	


#func _update_raycasts() -> void:
	#raycast_wall.force_raycast_update()
	#raycast_ground.force_raycast_update()
