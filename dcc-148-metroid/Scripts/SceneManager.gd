extends Node

var target_spawn: String = ""

func change_map(target_scene_path: String, spawn_id: String) -> void:
	target_spawn = spawn_id
	get_tree().change_scene_to_file(target_scene_path)
