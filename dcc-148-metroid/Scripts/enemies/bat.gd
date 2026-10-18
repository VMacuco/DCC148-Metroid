extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var trigger_area_1 = $TriggerArea/CollisionShape2D
@onready var trigger_area_2 = $TriggerArea2/CollisionShape2D

@export var bat_projectile_scene: PackedScene = preload("res://Scenes/enemies/bullet.tscn")

signal died

enum State{
	idle,
	dive,
	explode,
	dead
}

#tempo entre um mergulho e outro (vai aumentando)
var dx : float = 0.3
#velocidade do mergulho, a definir
var speed_diving: float = 150.0
# guarda o vetor que aponta o player
var dive_direction: Vector2 = Vector2.ZERO
# guarda a posição do player
var target_position: Vector2 = Vector2.ZERO

var bat_state: State = State.idle

var life: float = 10.0	

func _ready() -> void:
	trigger_area_2.set_deferred("disabled", true)
	go_to_idle_state()
	
func _physics_process(_delta: float) -> void:

# IDEIA: as funções go_to são executadas uma vez, enquanto as
# funções dos próprios estados são executadas continuamente
# a forma de organizar o código foi influenciada pelos videos
# em https://www.youtube.com/@rafaelforbeck-game-dev

	match bat_state:
		State.idle:
			_idle_state()
		State.dive:
			_dive_state()
		State.explode:
			_explode_state()
		State.dead:
			_dead_state()
			
func go_to_idle_state() -> void:
	bat_state = State.idle
	sprite.play("idle")
	
func go_to_dive_state() -> void:
	bat_state = State.dive
	sprite.play("dive")
	_wait_for_redirect()
	
func go_to_explode_state() -> void:
	bat_state = State.explode
	velocity = Vector2.ZERO
	sprite.play("explode")
	trigger_area_1.set_deferred("disabled", true)
	trigger_area_2.set_deferred("disabled", true)
	
func go_to_dead_state() -> void:
	bat_state = State.dead
	#diferenciar morte matada ou morte morrida
	if life <= 0:
		died.emit()
	else:
		#diz que o loot já foi precessado
		#na verdade é só pra nao processar quando explode
		set_meta("loot_handled", true) 
		
	#resetar dx
	dx = 0.3
	queue_free()
	
func _idle_state() -> void:
	velocity = Vector2.ZERO
	
func _dive_state() -> void:
	velocity = dive_direction*speed_diving
	move_and_slide()
	if is_on_floor():
		go_to_explode_state()
		
func _explode_state() -> void:
	pass
	
func _dead_state() -> void:
	pass
	
func spawn_bullets() -> void:
	if not bat_projectile_scene:
		return

	var directions: Array[Vector2] = [
	 Vector2(-1, -1).normalized(),
	 Vector2(1, -1).normalized(),
	 Vector2(-1, 1).normalized(),
	 Vector2(1, 1).normalized() ]

	for dir in directions:
		var projectile = bat_projectile_scene.instantiate()
		projectile.direction = dir
		projectile.global_position = global_position
		projectile.rotation = dir.angle()
		
		get_tree().current_scene.add_child(projectile)
	
func take_damage(recivied_damage: int)->void:
	if recivied_damage > 0:
		life -= recivied_damage
	if life <= 0:
		go_to_dead_state()
	
func _wait_for_redirect() -> void:
	while bat_state == State.dive:
		await get_tree().create_timer(dx).timeout
		# para o loop se morrer durante a expera do timer
		if not is_inside_tree():
			return
		# só ativa se tiver no estado de dive (não em explode)
		if bat_state == State.dive:
			dx = 2*dx
			trigger_area_2.set_deferred("disabled", false)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if bat_state == State.explode:
		spawn_bullets()
		go_to_dead_state()

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body is Player and bat_state == State.idle:
		target_position = body.global_position
		dive_direction = (target_position - global_position).normalized()
		trigger_area_1.set_deferred("disabled", true)
		go_to_dive_state()
		

func _on_trigger_area_2_body_entered(body: Node2D) -> void:
	if body is Player and bat_state == State.dive:
		target_position = body.global_position
		dive_direction = (target_position - global_position).normalized()
		trigger_area_2.set_deferred("disabled", true)
