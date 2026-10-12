extends CharacterBody2D

@export var SPEED: float = 30.0
@export var health: float = 15.0
@export var aderency: float = 30.0

@onready var raycast_tras = $RayCast2D_tras
@onready var raycast_frente = $RayCast2D_frente

@onready var sprite = $AnimatedSprite2D


enum State { PATROL, DEAD }
var geemer_state: State = State.PATROL

@onready var collision_box: CollisionShape2D = $CollisionShape2D




func _ready() -> void:
	geemer_state = State.PATROL
	up_direction = Vector2.UP
	
func _process(delta: float) -> void:
	if geemer_state == State.PATROL:
		sprite.play("move")
		

func _physics_process(delta: float) -> void:
	if geemer_state != State.PATROL:
		return
	
	var down_velocity = transform.y * aderency
	var right_velocity = transform.x * SPEED
	
	velocity = (right_velocity + down_velocity)
	#print("Velocidade padrão:", velocity)
	
	
	
	
	if is_on_wall():
		#print("estou na parede")
		rotate(-PI/2)
		up_direction = get_wall_normal()
		velocity = Vector2.ZERO
		
	
	elif (not raycast_tras.is_colliding()) and (not raycast_frente.is_colliding()):
		velocity = Vector2.ZERO
		#print("estou na beirada")
		rotate(PI/2)
		up_direction = up_direction.rotated(PI/2)
		global_position += (transform.x * 21) + (transform.y * 21)
		#print("up_direction: ", up_direction)
		#print("velocidade no momento que vira:", velocity)
	
	move_and_slide()
