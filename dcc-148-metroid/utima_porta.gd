extends Area2D

@onready var sprite = $AnimatedSprite2D
var ja_abriu: bool

func _ready() -> void:
	sprite.play("Fechada")
	ja_abriu = false

func _process(delta: float) -> void:
	if ja_abriu:
		return
	elif GameMannager.last_door:
		var tween = create_tween()
		tween.tween_callback(func(): sprite.play("Abrindo"))
		await tween.finished
		ja_abriu = true
		sprite.play("Aberta")
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and GameMannager.last_door:
		get_tree().change_scene_to_file.call_deferred("res://Scenes/UI/win_screen.tscn")
		
