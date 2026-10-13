class_name Hurtbox_enemy
extends Area2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not monitoring:
		return
	
	for area in  get_overlapping_areas():
			#print("HURTBOX VIU: ", area.name, " | layer=", area.collision_layer, " | pai=", get_parent().name)
			get_parent().take_damage(area.contact_damage)
