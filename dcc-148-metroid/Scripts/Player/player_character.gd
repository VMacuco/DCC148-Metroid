class_name Player
extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var AIR_ACCELERATION = 1500.0 # Isso pra conseguir se mover no ar
@export var shoot_delay = 0.25
@export var death_screen_delay := 1.0
var shoot_timer := 0.0

var target: Vector2 #Serve para guardar a ultima posição que o player olhou
@export var energy: int #eventualmente a vida

@onready var sprite = $AnimatedSprite2D
@onready var BulletPool = $BulletPool


var armadillo_mode: bool #flag para verificar se está no modo normal ou bola
var is_taking_damage: bool
var spawn_locked: bool = false

@onready var player_collision = $PlayerCollision 
@onready var armadillo_collision = $ArmadilloColision
@onready var space_check = $SpaceCheck #Isso é um raycast para checar se o jogador sair do modo bola
@onready var hitbox_player = $Hitbox_player
@onready var hitbox_ball = $Hitbobx_ball


func _ready() -> void:
	target = Vector2.RIGHT
	sprite.play("idle")
	armadillo_mode = false 
	hitbox_player.disable_mode = false
	hitbox_ball.disable_mode = true
	is_taking_damage = false
	
	GameMannager.player_died.connect(_on_player_died)


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

func _process(delta: float) -> void:
	if shoot_timer > 0.0:
		shoot_timer -= delta
	
	if Input.is_action_pressed("shoot") and shoot_timer <= 0.0 and not armadillo_mode and not spawn_locked:
		shoot()
		shoot_timer = shoot_delay
		

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
	#Corta a velociade vertical do pulo se soltar o botão muito cedo
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5 
	
	
	#Se apertar seta pra baixo, vira bola
	if Input.is_action_just_pressed("ball") and GameMannager.armadillo_upgarade:
		#Animação, não funcional no momento, talvez nunca esteje funcional para fins de fidelidade
		if looking_right:
			sprite.play("armadillo_activation_right")
		else:
			sprite.play("armadillo_activation_left")
		player_collision.disabled = true #desabilita a colisão normal do jogador
		armadillo_collision.disabled = false #habilita a colisão de bola
		hitbox_player.disable_mode = true
		hitbox_ball.disable_mode = false
		armadillo_mode = true 
		
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if not is_taking_damage:
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
			hitbox_player.disable_mode = false
			hitbox_ball.disable_mode = true
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
	if spawn_locked:
		# Deixa a gravidade assentar o player no chão, mas ignora qualquer input
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		velocity.x = 0.0
		move_and_slide()
		return
	
	if not armadillo_mode:
		_player_process(delta)
	else:
		_armadillo_process(delta)
		

func take_damage(recivied_damage:int)->void:
	if recivied_damage <= 0 or spawn_locked:
		return
	is_taking_damage = true
		
	GameMannager.player_hp -= recivied_damage
		
	var tween =  create_tween()
	tween.tween_callback(func(): sprite.play("taking_damage_right"))
	tween.tween_interval(0.5)
	await tween.finished
	is_taking_damage = false

func heal (recevied_healling:int) ->void:
	if recevied_healling <= 0:
		return
	GameMannager.player_hp += recevied_healling

func play_intro_scene(duration: float = 2.0)->void:
	spawn_locked = true
	velocity = Vector2.ZERO
	sprite.play("idle")
	
	var blink_count = 5
	var step = duration / float(blink_count * 2)
	
	var tween = create_tween()
	for i in blink_count:
		tween.tween_property(sprite,"modulate:a", 0.0, step)
		tween.tween_property(sprite, "modulate:a", 1.0, step)
		
	await tween.finished
	sprite.modulate.a = 1.0
	spawn_locked = false
	
func _on_player_died()->void:
	spawn_locked = true
	is_taking_damage = false
	sprite.modulate.a = 1.0
	
	hitbox_player.disable_mode = true
	hitbox_ball.disable_mode = true
	
	
	var tween = create_tween()
	tween.tween_callback(func(): sprite.play("death"))
	await tween.finished
	await get_tree().create_timer(death_screen_delay).timeout
	get_tree().change_scene_to_file.call_deferred("res://Scenes/UI/game_over.tscn")
	
