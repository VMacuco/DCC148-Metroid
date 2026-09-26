extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var AIR_ACCELERATION = 1500.0 

var target: Vector2
@export var energy: int

@onready var sprite = $AnimatedSprite2D
@onready var BulletPool = $BulletPool

func _ready() -> void:
	target = Vector2.RIGHT
	sprite.play("idle")

func shoot() -> void:
	var shoot_dir: Vector2
	var spawn_offset: Vector2
	var bullet_rotation: float
	
	var grid_cel = Vector2(12,8)
	
	if target.y < 0:
		shoot_dir = Vector2.UP
		bullet_rotation = -PI/2
		
		if target.x > 0:
			spawn_offset = Vector2(0,-3) * grid_cel
		else:
			spawn_offset = Vector2(0,-3) * grid_cel
	else:
		shoot_dir = Vector2.RIGHT if target.x > 0 else Vector2.LEFT
		bullet_rotation = 0.0 if target.x > 0 else PI
		
		if target.x > 0:
			spawn_offset = Vector2(2,-1) * grid_cel
		else:
			spawn_offset = Vector2(-2,-1) * grid_cel
	
	var bullet = BulletPool.get_from_pool()
	if bullet:
		bullet.global_position = global_position + spawn_offset
		bullet.rotation = bullet_rotation
		bullet.direction = shoot_dir
		bullet.traveled_distance = 0.0
		
		var return_bullet = func(): BulletPool.return_to_pool(bullet)
		if not bullet.hit_or_fade.is_connected(return_bullet):
			bullet.hit_or_fade.connect(return_bullet, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta: float) -> void:
	var move_direction := Input.get_axis("move_left", "move_right")
	var target_direction := Input.get_vector("move_left", "move_right", "look_up", "ball")
	
	if target_direction.x != 0:
		target.x = sign(target_direction.x)
	
	target.y = target_direction.y
	
	var looking_up: bool = target.y < 0
	var looking_right: bool = target.x > 0
	var is_moving: bool = move_direction != 0
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if is_on_floor():
		if is_moving:
			velocity.x = move_direction * SPEED
		else:
			velocity.x = 0
	else:
		if is_moving:
			velocity.x = move_toward(velocity.x, move_direction * SPEED, AIR_ACCELERATION * delta)
	
	if not is_on_floor():
		if is_moving:
			sprite.play("jump_long_right" if looking_right else "jump_long_left")
		else:
			sprite.play("jump_right" if looking_right else "jump_left")
	else:
		if is_moving:
			if looking_up:
				sprite.play("run_right_look_up" if looking_right else "run_left_look_up")
			else:
				sprite.play("run_right" if looking_right else "run_left")
		else:
			if looking_up:
				sprite.play("idle_right_look_up" if looking_right else "idle_left_look_up")
			else:
				sprite.play("idle_right" if looking_right else "idle_left")
	
	move_and_slide()
