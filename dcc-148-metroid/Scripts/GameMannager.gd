extends Node

var player_hp: int
var inicial_hp: int = 35
var armadillo_upgarade: bool = false

func start_new_game() -> void:
	player_hp = inicial_hp
	armadillo_upgarade = false
