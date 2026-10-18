extends Area2D

@export var Healing: int = 15


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.heal(Healing)
		queue_free()
