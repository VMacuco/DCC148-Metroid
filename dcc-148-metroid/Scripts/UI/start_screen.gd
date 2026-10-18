extends Control


func _on_start_button_down() -> void:
	GameMannager.start_new_game()
	SceneManager.change_map("res://Scenes/maps/mp_01.tscn","Spawn_from_start")
