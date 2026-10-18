extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var trigger_area = $TriggerArea/CollisionShape2D


enum State{
	idle,
	dive,
	walk,
	bounce,
	dead,
	imprisioned
}

signal died
#velocidade do mergulho e bounce
var speed: float = 120.0
#velocidade do walk
var walk_speed : float = 50.0
#aponta p/ player
var dive_direction: Vector2 = Vector2.ZERO
# posição do player
var target_position: Vector2 = Vector2.ZERO
var mosquito_state: State = State.idle
var life: float = 20.0
# referencia ao player para o walk state saber p/ onde andar
var player: Node2D = null
#timer para a duração do walk (varia em sorteio)
var walk_timer: float = 0.0
# normal para o bounce
var normal: Vector2 = Vector2.ZERO
var wall_normal: Vector2 = Vector2.ZERO
# guarda o vetor do bounce
var bounce: Vector2 = Vector2.ZERO
var wall_bounce: Vector2 = Vector2.ZERO
# altura maxima
var max_height: float = 0.0

func _ready() -> void:
	go_to_idle_state()
	max_height = global_position.y
	
func _physics_process(delta: float) -> void:

	match mosquito_state:
		State.idle:
			_idle_state()
		State.dive:
			_dive_state()
		State.walk:
			_walk_state(delta)
		State.bounce:
			_bounce_state()
		State.dead:
			_dead_state()
		State.imprisioned:
			_imprisoned_state()
			
func go_to_idle_state() -> void:
	mosquito_state = State.idle
	trigger_area.set_deferred("disabled", false)
	normal = Vector2.ZERO
	sprite.play("idle")
	
	
func go_to_dive_state() -> void:
	mosquito_state = State.dive
	sprite.play("dive")
	
	
func go_to_walk_state() -> void:
	#calcula o vetor espelhado a ser usado em bounce
	normal= get_floor_normal()
	
	# se falhar no calculo da normal
	if normal == Vector2.ZERO:
		normal = Vector2.UP
		
	bounce = dive_direction.bounce(normal)
	mosquito_state = State.walk
	sprite.play("walk")
	#simplificação: aqui o walk dura entre 0 e 1s (gerado aleatoriamente)
	walk_timer = randf_range(0.0, 1.0)
	

func go_to_bounce_state() -> void:
	mosquito_state = State.bounce
	

	
func go_to_dead_state() -> void:
	mosquito_state  = State.dead
	died.emit()
	queue_free()
	
func go_to_imprisoned_state() -> void:
	
	wall_normal = get_wall_normal()
	if wall_normal == Vector2.ZERO:
		wall_normal = Vector2.LEFT if dive_direction.x > 0 else Vector2.RIGHT
		
	match mosquito_state:
		State.dive:
			wall_bounce = dive_direction.bounce(wall_normal)
		State.bounce:
			wall_bounce = bounce.bounce(wall_normal)
			
	mosquito_state = State.imprisioned
	
	
func _idle_state() -> void:
	velocity = Vector2.ZERO
	
	
func _dive_state() -> void:
	velocity = dive_direction*speed
	move_and_slide()
	
	#simplificação : aqui o walk state é sempre no chão		
	if is_on_floor():
		go_to_walk_state()
		
	if is_on_wall():
		go_to_imprisoned_state()
		
		
func _walk_state(delta) -> void:
	var direction: int = 0
	if is_instance_valid(player):
		var distance_x = player.global_position.x - global_position.x
		if distance_x > 0:
			direction = 1
			sprite.flip_h = false
		elif distance_x < 0:
			direction = -1	
			sprite.flip_h = true 		
	
	# segue p/ a direita ou p/ a esquerda
	velocity.x = direction * walk_speed
	# caso haja irregularidades no chao, isso o mantem
	velocity.y = 50.0
	move_and_slide()
	
	walk_timer -= delta
	if walk_timer <= 0.0:
		go_to_bounce_state()
	
func _bounce_state() -> void:
	velocity = bounce.normalized()*speed
	move_and_slide()
	if is_on_ceiling() or global_position.y <= max_height:
		go_to_idle_state()
	if is_on_wall():
		go_to_imprisoned_state()

func _imprisoned_state() -> void:
	velocity = wall_bounce.normalized()*speed
	move_and_slide()
	
	if is_on_ceiling() or global_position.y <= max_height:
		go_to_idle_state()
	if is_on_floor():
		go_to_walk_state()
	if is_on_wall():
		go_to_imprisoned_state()
	
func _dead_state() -> void:
	pass
	
func take_damage(recivied_damage: int)->void:
	if recivied_damage > 0:
		life -= recivied_damage
	if life <= 0:
		go_to_dead_state()

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body is Player and mosquito_state == State.idle:
		
		var inaccuracy: float = 0
		player = body
		
		target_position = player.global_position
		var distance_x = player.global_position.x - global_position.x
		
		#ele faz um mergulho 'impreciso'
		if distance_x > 0:
			inaccuracy = 15
		elif distance_x < 0:
			inaccuracy = -15	
		elif distance_x == 0:
			inaccuracy = randf_range(-15,15)
			
		dive_direction = (target_position - global_position).normalized()
		# só pra garantir que o intervalo em randf fica certinho
		var low = min(0.0, inaccuracy)
		var high = max(0.0, inaccuracy)
		#calcula o desvio em até 15 graus (-15 graus)
		var deviation: float = deg_to_rad(randf_range(low,high))
		dive_direction = dive_direction.rotated(deviation)
		
		trigger_area.set_deferred("disabled", true)
		go_to_dive_state()
		
