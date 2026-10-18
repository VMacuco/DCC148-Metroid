extends CharacterBody2D

@export var SPEED: float = 30.0
@export var health: float = 15.0
@export var aderency: float = 30.0

@onready var raycast_tras = $RayCast2D_tras
@onready var raycast_frente = $RayCast2D_frente

@onready var sprite = $AnimatedSprite2D

signal died

var inicial_position: Vector2


enum State { PATROL, DEAD }
var geemer_state: State = State.PATROL

@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var hitbox: hitbox_enemy = $hitbox_enemy
@onready var hurtbox: Hurtbox_enemy = $Hurtbox_enemy


func take_damage(recivied_damage: int)->void:
	if recivied_damage > 0:
		health -= recivied_damage
	if health <= 0:
		geemer_state = State.DEAD
		died.emit()
		killing_geemer()
		

func _ready() -> void:
	geemer_state = State.PATROL
	up_direction = Vector2.UP
	health = 15.0
	inicial_position = global_position
	
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
		global_position += (transform.x * 14) + (transform.y * 14)
		#print("up_direction: ", up_direction)
		#print("velocidade no momento que vira:", velocity)
	
	move_and_slide()
