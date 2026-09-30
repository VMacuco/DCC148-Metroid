extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var AIR_ACCELERATION = 1500.0 # Isso pra conseguir se mover no ar

var target: Vector2 #Serve para guardar a ultima posição que o player olhou
@export var energy: int #eventualmente a vida

@onready var sprite = $AnimatedSprite2D
@onready var BulletPool = $BulletPool

var armadillo_upgrade: bool #Variavel para guardar se pegou ou não o upgrade da bola, não sei se vamos usar
var armadillo_mode: bool #flag para verificar se está no modo normal ou bola
@onready var player_collision = $PlayerCollision 
@onready var armadillo_collision = $ArmadilloColision
@onready var space_check = $SpaceCheck #Isso é um raycast para checar se o jogador sair do modo bola

func _ready() -> void:
	target = Vector2.RIGHT
	sprite.play("idle")
	armadillo_upgrade = true
	armadillo_mode = false 
	

func shoot() -> void:
	var shoot_dir: Vector2
	var spawn_offset: Vector2
	var bullet_rotation: float
	
	#isso é invenção de moda, "get_rect()/2 + uns numeros"  funcionaria igual
	##Peguei quantos quadradinhos o player ocupa no grid da godot, 12 de altura e 8 de largura, crio um vetor com x,y inveridos
	var grid_cel = Vector2(12,8)
	
	if target.y < 0:
		shoot_dir = Vector2.UP
		bullet_rotation = -PI/2
		#Em cada direção, observo cada coordenada que o x deveria sair em quadradinhos e multiplico pelo vetor grid_cel, assim temos um spawn_offset que sai da ponta da arma
		if target.x > 0:
			spawn_offset = Vector2(0,-3) * grid_cel 
		else:
			spawn_offset = Vector2(0,-3) * grid_cel
	else:
		shoot_dir = Vector2.RIGHT if target.x > 0 else Vector2.LEFT
		bullet_rotation = 0.0 if target.x > 0 else PI
		
		if target.x > 0:
			spawn_offset = Vector2(1.5,-0.75) * grid_cel
		else:
			spawn_offset = Vector2(-1.5,-0.75) * grid_cel
	
	var bullet = BulletPool.get_from_pool()
	if bullet:
		bullet.global_position = global_position + spawn_offset
		bullet.rotation = bullet_rotation
		bullet.direction = shoot_dir
		bullet.traveled_distance = 0.0
		bullet.is_destroing = false
		#print("atirei")
		
		var return_bullet = func(): BulletPool.return_to_pool(bullet)
		if not bullet.hit_or_fade.is_connected(return_bullet):
			bullet.hit_or_fade.connect(return_bullet, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and not armadillo_mode:
		shoot()

#processos do jogador no modo normal
func _player_process(delta: float) -> void:
	var move_direction := Input.get_axis("move_left", "move_right") #guarda direção de movimento
	var target_direction := Input.get_vector("move_left", "move_right", "look_up", "ball") #aqui serve pra verificar a direção que olhou, deve ter um jeito melhor de fazer
	
	#Se você já olhou pra um algum canto, armazena se x é positivo ou negativo
	if target_direction.x != 0:
		target.x = sign(target_direction.x) 
	
	target.y = target_direction.y 
	
	var looking_up: bool = target.y < 0 #define se está olhando pra cima
	var looking_right: bool = target.x > 0 #define se olhando pra direita
	var is_moving: bool = move_direction != 0 #define se há movimento
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Se apertar seta pra baixo, vira bola
	if Input.is_action_just_pressed("ball") and armadillo_upgrade:
		#Animação, não funcional no momento, talvez nunca esteje funcional para fins de fidelidade
		if looking_right:
			sprite.play("armadillo_activation_right")
		else:
			sprite.play("armadillo_activation_left")
		player_collision.disabled = true #desabilita a colisão normal do jogador
		armadillo_collision.disabled = false #habilita a colisão de bola
		armadillo_mode = true 
		
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if is_on_floor():
		if is_moving:
			velocity.x = move_direction * SPEED
		else:
			velocity.x = 0 #se você para no chão, para na hora, sem inercia
	else:
		#no ar você tem inercia
		if is_moving:
			velocity.x = move_toward(velocity.x, move_direction * SPEED, AIR_ACCELERATION * delta)
	
	#Troca as animações das sprites
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

#processos do jogador no modo bola
func _armadillo_process(delta: float) ->void:
	var move_direction := Input.get_axis("move_left", "move_right")
	var is_moving: bool = move_direction != 0
	var direction = 0.0
	
	direction = move_direction if is_moving else direction
	
	#Aqui se pular ou olhar pra cima reverte
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("look_up"):
		if not space_check.is_colliding():
			#Aqui checamos se o Raycast colide com algo, se sim, o jogador não pode reverter ao modo normal
			if target.x > 0:
				sprite.play("armadillo_activation_right", 1,true)
			else:
				sprite.play("armadillo_activation_left", 1, true)
			armadillo_collision.disabled = true
			player_collision.disabled = false
			armadillo_mode = false
	
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
	
	if is_moving:
		sprite.play("armadillo_move_right" if direction > 0 else "armadillo_move_left")
	else:
		sprite.play("armadillo_idle_right" if direction > 0 else "armadillo_idle_left")
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	if not armadillo_mode:
		_player_process(delta)
	else:
		_armadillo_process(delta)
