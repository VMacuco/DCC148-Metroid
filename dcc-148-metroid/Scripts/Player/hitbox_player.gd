extends Area2D

@export var invencibbility_time: float = 1.0
var invenssible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if invenssible or disable_mode:
		return
	for area in get_overlapping_areas():
		print("[Hurtbox] overlap: ", area.name,
		" | layer=", area.collision_layer,
		" | mask=", area.collision_mask,
		" | parent=", area.get_parent().name if area.get_parent() else "null")
		if area.collision_layer == 64:
			if get_parent().has_method("take_damage"):
				print("[Hurtbox] DANO de ", area.name)
				get_parent().take_damage(area.contact_damage)
				start_invencibility()
				break

func start_invencibility() -> void:
	invenssible = true
	await get_tree().create_timer(invencibbility_time).timeout
	invenssible = false
	
