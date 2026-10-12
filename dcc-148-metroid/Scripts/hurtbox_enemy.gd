class_name Hurtbox_enemy
extends Area2D

func _ready() -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 2:
		var recivied_damage = area.damage if area.get("damage") else 5
		
		if get_parent().has_method("take_damage"):
			get_parent().take_damage(recivied_damage)
			
		if area.has_method("destroy"):
			area.destroy()
	
