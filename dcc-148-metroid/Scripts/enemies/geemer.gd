extends CharacterBody2D

@export var SPEED: float = 100.0
@export var health: float = 15.0

enum State { PATROL, DEAD }
var greeb_state: State = State.PATROL

@onready var raycast_ground: RayCast2D = $RayCast_Ground
@onready var raycast_wall: RayCast2D = $RayCast_Wall

func _ready() -> void:
	greeb_state = State.PATROL

func _physics_process(delta: float) -> void:
	if greeb_state != State.PATROL:
		return

	
	if raycast_wall.is_colliding():
		rotation -= PI/2
		up_direction = raycast_wall.get_collision_normal()
		global_position += transform.x * 20.0
		_update_raycasts()


	elif not raycast_ground.is_colliding():
		rotation += PI/2
		global_position += transform.x * 10.0 + transform.y * 10.0
		_update_raycasts()

	velocity = transform.x * SPEED
	move_and_slide()


func _update_raycasts() -> void:
	raycast_wall.force_raycast_update()
	raycast_ground.force_raycast_update()
