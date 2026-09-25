extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
var target: Vector2
@export var energy: int

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	target = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var target_dir := Input.get_vector("move_left", "move_right", "look_up", "ball")
	
	if target_dir != Vector2.ZERO:
		target = target_dir
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if target.x < 0:
			sprite.play("jump_left")
		else:
			sprite.play("jump_right")
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED
		if target.x > 0 and target.y > 0:
			sprite.play("run_right_look_up")
		elif target.x < 0 and target.y > 0:
			sprite.play("run_left_look_up")
		elif target.x > 0 and not target.y > 0:
			sprite.play("run_right")
		elif target.x < 0 and not target.y > 0:
			sprite.play("run_left")
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if target.x > 0 and target.y > 0:
			sprite.play("idle_right_look_up")
		elif target.x < 0 and target.y > 0:
			sprite.play("idle_left_look_up")
		elif target.x > 0 and not target.y > 0:
			sprite.play("idle_right")
		elif target.x < 0 and not target.y > 0:
			sprite.play("idle_left")

	move_and_slide()
