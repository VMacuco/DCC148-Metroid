extends Control

@onready var restart_button = $MarginContainer/VBoxContainer/Retry

func _ready() -> void:
	restart_button.grab_focus()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameMannager.game_restart()
	SceneManager.change_map("res://Scenes/maps/mp_01.tscn", "Spawn_from_start")
