extends CharacterBody2D

# apenas dois estados walk e colinding
# quando colide inverte a direcao

var speed: float = 50.0

var direction_x: int = 1

enum State {
	walk,
	colide
}

var ripper_state: State = State.walk

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	
	match ripper_state:
		State.walk:
			_walk_state()
		State.colide:
			_colide_state()
			
func go_to_colide_state()-> void:
	ripper_state = State.colide
	velocity = Vector2.ZERO
	sprite.play("colide")
	
	#timer para tocar o frame de colide
	await get_tree().create_timer(0.15).timeout
	
	#bate rebate
	direction_x = direction_x*-1
	if direction_x < 0:
		sprite.flip_h = true
	elif direction_x > 0:
		sprite.flip_h = false
	go_to_walk_state()
			
func go_to_walk_state()-> void:
	ripper_state= State.walk
	sprite.play("walk")
	
	
func _walk_state()-> void:
	velocity.x = direction_x * speed
	velocity.y = 0.0
	move_and_slide()
	
	if is_on_wall():
		go_to_colide_state()
	
func _colide_state()-> void:
	pass
	
# imortal
func take_damage(_amount: int) -> void:
	pass
