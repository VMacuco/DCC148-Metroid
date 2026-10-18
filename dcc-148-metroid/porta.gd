extends Area2D
var door_Health: float
var is_oppened: bool
@onready var sprite = $AnimatedSprite2D
@export var linked_scene: String
@export var target_spawn: String

func _ready() -> void:
	door_Health = 15
	is_oppened = false
	sprite.play("Fechada")

func take_damage(damage: int)  -> void:
	if not is_oppened:
		door_Health -= damage
		var original_collor = sprite.modulate
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_interval(0.3)
		tween.tween_property(sprite, "modulate", original_collor, 0.1)
		
	
	if door_Health <= 0:
		var tween = create_tween()
		tween.tween_callback(func(): sprite.play("Abertura"))
		await tween.finished
		is_oppened = true
		sprite.play("Aberta")
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and is_oppened:
		if linked_scene != "":
			SceneManager.change_map(linked_scene, target_spawn)
