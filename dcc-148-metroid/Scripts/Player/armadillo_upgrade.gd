extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameMannager.armadillo_upgarade = true
		
		var tween = body.create_tween()
		tween.tween_property(body.sprite, "modulate", Color.ORANGE, 0.1)
		tween.tween_interval(0.3)
		tween.tween_property(body.sprite, "modulate", Color.WHITE, 0.1)
		await tween.finished
		queue_free()
