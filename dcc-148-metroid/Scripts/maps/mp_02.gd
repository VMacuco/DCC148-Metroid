extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SceneManager.target_spawn != "":
		var spawn_point = find_child(SceneManager.target_spawn, true, false)
		var player = find_child("Player_Character", true, false)
		if spawn_point and player:
			player.global_position = spawn_point.global_position
