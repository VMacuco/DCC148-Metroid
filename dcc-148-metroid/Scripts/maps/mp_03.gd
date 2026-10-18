extends Node2D

@export var target_enemy : Node2D 

func _ready() -> void:
	if SceneManager.target_spawn != "":
		var spawn_point = find_child(SceneManager.target_spawn, true, false)
		var player = find_child("Player_Character", true, false)
		if spawn_point and player:
			player.global_position = spawn_point.global_position
	if target_enemy == null:
		print("esqueceu de linkar o inimigo que conclui o jogo cara")
		return
	target_enemy.tree_exiting.connect(_on_target_enemy_defeated)
	
func _on_target_enemy_defeated()->void:
	GameMannager.last_door = true
