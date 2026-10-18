extends CharacterBody2D

@export var SPEED: float = 30.0
@export var health: float = 15.0
@export var aderency: float = 30.0

@onready var ray_floor = $RayCast2D_floor
@onready var ray_wall = $RayCast2D_wall
@onready var sprite = $AnimatedSprite2D

signal died
var inicial_position: Vector2

enum State { PATROL, DEAD }
var geemer_state: State = State.PATROL

@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var radius: float = (collision_box.shape as CircleShape2D).radius
@onready var hitbox: hitbox_enemy = $hitbox_enemy
@onready var hurtbox: Hurtbox_enemy = $Hurtbox_enemy

const MIN_TURN_DISTANCE := 3.0
var lock_until_floor := false
var distance_since_turn := 999.0


func take_damage(recivied_damage: int)->void:
	if recivied_damage > 0:
		health -= recivied_damage
	if health <= 0:
		geemer_state = State.DEAD
		died.emit()
		killing_geemer()
		

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	geemer_state = State.PATROL
	health = 15.0
	inicial_position = global_position

	# Raycasts curtos, saindo do centro
	ray_floor.position = Vector2.ZERO
	ray_floor.target_position = Vector2(0, radius + 4)
	ray_wall.position = Vector2.ZERO
	ray_wall.target_position = Vector2(radius + 2, 0)
	
func _process(delta: float) -> void:
	if geemer_state == State.PATROL:
		sprite.play("move")

func killing_geemer()->void:
	sprite.stop()
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
	var tween = create_tween()
	var timer = 2.0
	var blink_number = 4
	var blink_time = (timer / blink_number) / 2.0
	
	tween.set_loops(4)
	
	tween.tween_property(sprite, "modulate:a", 0.0, 0.01)
	tween.tween_interval(blink_time - 0.01)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.01)
	tween.tween_interval(blink_time - 0.01)
	
	await tween.finished
	queue_free()
	

func _physics_process(delta: float) -> void:
	if geemer_state != State.PATROL:
		return

	ray_floor.force_raycast_update()
	ray_wall.force_raycast_update()

	# Depois de uma curva externa, só permite outra quando achar chão de novo
	if lock_until_floor and ray_floor.is_colliding():
		lock_until_floor = false

	if distance_since_turn >= MIN_TURN_DISTANCE:
		if ray_wall.is_colliding():
			_turn_inner()
		elif not lock_until_floor and not ray_floor.is_colliding():
			_turn_outer()

	velocity = transform.x * SPEED + transform.y * aderency
	var before := global_position
	move_and_slide()
	distance_since_turn += before.distance_to(global_position)
	
func _turn_inner() -> void:
	# Parede à frente vira o novo chão
	rotate(-PI / 2)
	_after_turn()

func _turn_outer() -> void:
	# Contorna a quina: leva o centro para o lado da nova superfície
	global_position += transform.x * radius + transform.y * radius
	rotate(PI / 2)
	_after_turn()
	lock_until_floor = true

func _after_turn() -> void:
	rotation = snappedf(rotation, PI / 2)
	distance_since_turn = 0.0
	_snap_to_surface()

func _snap_to_surface() -> void:
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + transform.y * (radius * 2.0),
		collision_mask,
		[get_rid()]
	)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit:
		global_position = hit.position - transform.y * (radius + 0.5)
