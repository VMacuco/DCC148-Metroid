class_name hitbox_enemy
extends Area2D

@export var contact_damage: int = 10


func _ready() -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 16:
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(contact_damage)
