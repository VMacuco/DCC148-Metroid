extends Control





func _on_retry_button_up() -> void:
	GameMannager.start_new_game()
	SceneManager.change_map("res://Scenes/maps/mp_01.tscn", "Spawn_form_start")




func _on_exit_button_up() -> void:
	get_tree().quit()
