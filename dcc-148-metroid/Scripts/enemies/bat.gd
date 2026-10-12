extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D

#velocidade do mergulho
const SPEED_DIVING = 400.0
# guarda o vetor que aponta o player
var dive_direction: Vector2 = Vector2.ZERO 
# guarda a posição do player
var target_position: Vector2 = Vector2.ZERO

# vida a ser talvez usada futuramente
var life: float = 20.0
var is_diving: bool = false 
var is_exploding: bool = false

func _physics_process(delta: float) -> void:

# ideia : se n ta mergulhando nem explodindo, anima idle
# se is_diving is true, ele a partir do target pega o angulo exato para
# atingir a ultima posicao do player com uma velocidade constante
#se tá no chao, marca q n ta mais mergulhando, zera a velocidade
# se no chão nao tá explodindo, bota pra explodir
	if not is_diving and not is_exploding:
		sprite.play("idle")
	if is_diving:
		sprite.play("dive")
		velocity = dive_direction*SPEED_DIVING
		move_and_slide()
	if is_on_floor():
		is_diving = false
		velocity = Vector2.ZERO
		
		# espera a animação de explosão
		if not is_exploding:
			is_exploding = true
			sprite.play("explode")
			await sprite.animation_finished
			# cria as 4 balas aqui?		
			# se autodestrói
			queue_free()

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target_position = body.global_position
		dive_direction = (target_position - global_position).normalized()
		# destaiva a area de gatilho para não disparar novamente
		$TriggerArea/CollisionShape2D.set_deferred("disabled", true)
		is_diving = true
